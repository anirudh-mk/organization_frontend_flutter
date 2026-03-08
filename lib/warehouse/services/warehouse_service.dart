import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/warehouse_model.dart';
import '../../shared/services/base_service.dart';
import '../../auth/services/token_manager.dart';

class WarehouseService extends BaseService {
  // Host loopback address for Android emulator to hit the backend
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1/warehouse/warehouses/';

  Future<List<WarehouseModel>> getWarehouses({String? organizationId}) async {
    try {
      Uri url = Uri.parse(baseUrl);
      if (organizationId != null) {
        url = url.replace(queryParameters: {'organization': organizationId});
      }

      final response = await http.get(
        url,
        headers: await getHeaders(),
      );
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        
        List<dynamic> results;
        // DRF may return paginated responses
        if (body is Map && body.containsKey('results')) {
          results = body['results'];
        } else if (body is List) {
          results = body;
        } else {
          results = [];
        }
        
        return results.map((dynamic item) => WarehouseModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load warehouses");
      }
    } catch (e) {
      throw Exception("Error fetching warehouses: $e");
    }
  }

  Future<WarehouseModel> createWarehouse(Map<String, dynamic> data) async {
    try {
      final headers = await getHeaders();
      headers['Content-Type'] = 'application/json';

      // Organization is required by the DRF API
      if (!data.containsKey('organization')) {
        final orgId = await TokenManager.getOrganizationId();
        if (orgId != null) {
          data['organization'] = orgId;
        }
      }
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return WarehouseModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to create warehouse: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error creating warehouse: $e");
    }
  }

  Future<WarehouseModel> updateWarehouse(String id, Map<String, dynamic> data) async {
    try {
      final headers = await getHeaders();
      headers['Content-Type'] = 'application/json';

      final response = await http.put(
        Uri.parse('$baseUrl$id/'),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return WarehouseModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to update warehouse: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error updating warehouse: $e");
    }
  }

  Future<void> deleteWarehouse(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$id/'),
        headers: await getHeaders(),
      );
      if (response.statusCode != 204) {
        throw Exception("Failed to delete warehouse: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error deleting warehouse: $e");
    }
  }
}
