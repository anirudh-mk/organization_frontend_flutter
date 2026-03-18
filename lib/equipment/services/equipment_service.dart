import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/equipment_model.dart';
import '../../shared/services/base_service.dart';
import '../../auth/services/token_manager.dart';

class EquipmentService extends BaseService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1/equipments/';

  Future<List<EquipmentModel>> getEquipments({Map<String, String>? filters}) async {
    try {
      Uri url = Uri.parse('${baseUrl}equipments/');
      if (filters != null) {
        url = url.replace(queryParameters: filters);
      } else {
        final orgId = await TokenManager.getOrganizationId();
        if (orgId != null) {
          url = url.replace(queryParameters: {'organization': orgId});
        }
      }

      final response = await performRequest((headers) => http.get(url, headers: headers));

      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        List<dynamic> results = body is Map ? body['results'] : body;
        return results.map((item) => EquipmentModel.fromJson(item)).toList();
      }
      throw Exception("Failed to load equipments");
    } catch (e) {
      throw Exception("Error fetching equipments: $e");
    }
  }

  Future<List<EquipmentCategoryModel>> getCategories() async {
    try {
      final orgId = await TokenManager.getOrganizationId();
      final url = Uri.parse('${baseUrl}categories/').replace(queryParameters: orgId != null ? {'organization': orgId} : {});
      final response = await performRequest((headers) => http.get(url, headers: headers));
      if (response.statusCode == 200) {
        List<dynamic> results = jsonDecode(response.body);
        return results.map((item) => EquipmentCategoryModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) { return []; }
  }

  Future<List<EquipmentStatusModel>> getStatuses() async {
    try {
      final orgId = await TokenManager.getOrganizationId();
      final url = Uri.parse('${baseUrl}statuses/').replace(queryParameters: orgId != null ? {'organization': orgId} : {});
      final response = await performRequest((headers) => http.get(url, headers: headers));
      if (response.statusCode == 200) {
        List<dynamic> results = jsonDecode(response.body);
        return results.map((item) => EquipmentStatusModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) { return []; }
  }

  Future<List<EquipmentOwnershipTypeModel>> getOwnershipTypes() async {
    try {
      final orgId = await TokenManager.getOrganizationId();
      final url = Uri.parse('${baseUrl}ownership-types/').replace(queryParameters: orgId != null ? {'organization': orgId} : {});
      final response = await performRequest((headers) => http.get(url, headers: headers));
      if (response.statusCode == 200) {
        List<dynamic> results = jsonDecode(response.body);
        return results.map((item) => EquipmentOwnershipTypeModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) { return []; }
  }

  Future<EquipmentModel> createEquipment(Map<String, dynamic> data) async {
    try {
      if (!data.containsKey('organization')) {
        final orgId = await TokenManager.getOrganizationId();
        if (orgId != null) data['organization'] = orgId;
      }
      final response = await performRequest((headers) => http.post(
        Uri.parse('${baseUrl}equipments/'),
        headers: headers,
        body: jsonEncode(data),
      ));
      if (response.statusCode == 201 || response.statusCode == 200) {
        return EquipmentModel.fromJson(jsonDecode(response.body));
      }
      throw Exception("Failed to create equipment: ${response.body}");
    } catch (e) {
      throw Exception("Error creating equipment: $e");
    }
  }

  Future<EquipmentModel> updateEquipment(String id, Map<String, dynamic> data) async {
    try {
      final response = await performRequest((headers) => http.patch(
        Uri.parse('${baseUrl}equipments/$id/'),
        headers: headers,
        body: jsonEncode(data),
      ));
      if (response.statusCode == 200) {
        return EquipmentModel.fromJson(jsonDecode(response.body));
      }
      throw Exception("Failed to update equipment: ${response.body}");
    } catch (e) {
      throw Exception("Error updating equipment: $e");
    }
  }

  Future<void> deleteEquipment(String id) async {
    try {
      final response = await performRequest((headers) => http.delete(
        Uri.parse('${baseUrl}equipments/$id/'),
        headers: headers,
      ));
      if (response.statusCode != 204) {
        throw Exception("Failed to delete equipment");
      }
    } catch (e) {
      throw Exception("Error deleting equipment: $e");
    }
  }

  Future<String> getNextCode() async {
    try {
      final response = await performRequest((headers) => http.get(
        Uri.parse('${baseUrl}equipments/get-next-code/'),
        headers: headers,
      ));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['code'];
      }
      return '';
    } catch (e) { return ''; }
  }
}
