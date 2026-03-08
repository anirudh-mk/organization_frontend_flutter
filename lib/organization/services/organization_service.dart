import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../auth/services/token_manager.dart';
import '../models/organization_model.dart';
import '../../shared/services/base_service.dart';

class OrganizationService extends BaseService {
  // Using same base host as auth for now
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1/organization';

  Future<OrganizationModel?> getCurrentOrganization() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/organizations/current/'),
        headers: await getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final org = OrganizationModel.fromJson(data);
        await TokenManager.saveOrganizationId(org.id);
        return org;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception("Failed to load current organization (${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Error fetching current organization: $e");
    }
  }

  Future<List<OrganizationModel>> getOrganizations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/organizations/'),
        headers: await getHeaders(),
      );
      
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        List<dynamic> results;
        if (body is Map && body.containsKey('results')) {
          results = body['results'];
        } else if (body is List) {
          results = body;
        } else {
          results = [];
        }
        return results.map((item) => OrganizationModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load organizations (${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Error fetching organizations: $e");
    }
  }

  Future<List<OrganizationTypeModel>> getOrganizationTypes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/types/'),
        headers: await getHeaders(),
      );
      
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        List<dynamic> results;
        if (body is Map && body.containsKey('results')) {
          results = body['results'];
        } else if (body is List) {
          results = body;
        } else {
          results = [];
        }
        return results.map((item) => OrganizationTypeModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load organization types");
      }
    } catch (e) {
      throw Exception("Error fetching organization types: $e");
    }
  }

  Future<OrganizationModel> createOrganization(
    String name,
    String typeId, {
    List<Map<String, dynamic>>? addresses,
    File? logo,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/organizations/');
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      final headers = await getHeaders();
      request.headers.addAll(headers);

      // Add fields
      request.fields['name'] = name;
      request.fields['type'] = typeId;

      // Add nested data as JSON strings if they existed as fields in backend
      // actually DRF usually expects JSON for nested, but if we are doing Multipart,
      // it gets tricky. Let's see how our backend handles it.
      if (addresses != null && addresses.isNotEmpty) {
        request.fields['addresses_json'] = jsonEncode(addresses);
      }

      // Add logo
      if (logo != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'logo',
          logo.path,
          contentType: MediaType('image', 'jpeg'), // Adjust based on file type if needed
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (streamedResponse.statusCode == 201 || streamedResponse.statusCode == 200) {
        final org = OrganizationModel.fromJson(jsonDecode(response.body));
        await TokenManager.saveOrganizationId(org.id);
        return org;
      } else {
        throw Exception("Failed to create organization: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error creating organization: $e");
    }
  }
}
