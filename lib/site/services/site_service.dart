import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import '../models/site_model.dart';
import '../../shared/services/base_service.dart';

class SiteService extends BaseService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1/site/sites';

  Future<List<SiteModel>> getSites() async {
    try {
      final response = await performRequest((headers) => http.get(
        Uri.parse('$baseUrl/'),
        headers: headers,
      ));
      if (response.statusCode == 200) {
        dynamic decoded = jsonDecode(response.body);
        List<dynamic> body;
        if (decoded is Map && decoded.containsKey('results')) {
          body = decoded['results'];
        } else if (decoded is List) {
          body = decoded;
        } else {
          body = [];
        }
        return body.map((dynamic item) => SiteModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load sites: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching sites: $e");
    }
  }

  Future<SiteModel> onboardSite({
    required String name,
    required String organizationId,
    String? status,
    double? budget,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, dynamic>? clientData,
    List<Map<String, dynamic>>? addresses,
    List<File>? images,
    List<PlatformFile>? attachments,
    String? notes,
  }) async {
    try {
      final response = await performMultipartRequest((headers) async {
        final uri = Uri.parse('$baseUrl/');
        final request = http.MultipartRequest('POST', uri);
        request.headers.addAll(headers);
        request.fields['name'] = name;
        request.fields['organization'] = organizationId;
        if (notes != null) request.fields['notes'] = notes;
        if (status != null) request.fields['status'] = status;
        if (budget != null) request.fields['estimated_budget'] = budget.toString();
        if (startDate != null) {
          request.fields['expected_start_date'] = startDate.toIso8601String().split('T')[0];
        }
        if (endDate != null) {
          request.fields['expected_end_date'] = endDate.toIso8601String().split('T')[0];
        }
        if (clientData != null) request.fields['client_data'] = jsonEncode(clientData);
        if (addresses != null) request.fields['addresses'] = jsonEncode(addresses);
        
        if (images != null) {
          for (var i = 0; i < images.length; i++) {
            request.files.add(await http.MultipartFile.fromPath(
              'images',
              images[i].path,
              contentType: MediaType('image', 'jpeg'),
            ));
          }
        }

        if (attachments != null) {
          for (var file in attachments) {
            if (file.path != null) {
              request.files.add(await http.MultipartFile.fromPath(
                'attachments',
                file.path!,
              ));
            }
          }
        }
        
        return request;
      });

      if (response.statusCode == 201) {
        return SiteModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to onboard site: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error onboarding site: $e');
    }
  }

  Future<SiteModel> updateSite(String id, Map<String, dynamic> data, {List<File>? images}) async {
    try {
      final response = await performMultipartRequest((headers) async {
        final uri = Uri.parse('$baseUrl/$id/');
        final request = http.MultipartRequest('PATCH', uri);
        request.headers.addAll(headers);
        data.forEach((key, value) {
          if (value != null) {
            if (value is Map || value is List) {
              request.fields[key] = jsonEncode(value);
            } else {
              request.fields[key] = value.toString();
            }
          }
        });
        if (images != null) {
          for (var image in images) {
            request.files.add(await http.MultipartFile.fromPath(
              'images',
              image.path,
              contentType: MediaType('image', 'jpeg'),
            ));
          }
        }
        return request;
      });
      
      if (response.statusCode == 200) {
        return SiteModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to update site: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error updating site: $e");
    }
  }

  Future<void> assignResource({
    required String siteId,
    required String type, // 'employee' or 'equipment'
    required String id,
    String? phaseId,
  }) async {
    try {
      final response = await performRequest((headers) => http.post(
        Uri.parse('$baseUrl/$siteId/assign-resource/'),
        headers: headers,
        body: jsonEncode({
          'type': type,
          'id': id,
          'phase_id': phaseId,
        }),
      ));

      if (response.statusCode != 200) {
        throw Exception('Failed to assign resource: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error assigning resource: $e');
    }
  }

  Future<Map<String, dynamic>> createQuotation({
    required String siteId,
    required double amount,
    Map<String, dynamic>? details,
  }) async {
    try {
      final response = await performRequest((headers) => http.post(
        Uri.parse('$baseUrl/$siteId/create-quotation/'),
        headers: headers,
        body: jsonEncode({
          'amount': amount,
          'details': details,
        }),
      ));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create quotation: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating quotation: $e');
    }
  }

  Future<void> deleteSite(String id) async {
    try {
      final response = await performRequest((headers) => http.delete(
        Uri.parse('$baseUrl/$id/'),
        headers: headers,
      ));
      
      if (response.statusCode != 204) {
        throw Exception("Failed to delete site: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error deleting site: $e");
    }
  }

  Future<String> getNextCode() async {
    try {
      final response = await performRequest((headers) => http.get(
        Uri.parse('$baseUrl/get-next-code/'),
        headers: headers,
      ));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['code'];
      }
      return '';
    } catch (e) {
      return '';
    }
  }
}
