import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/warehouse_model.dart';
import '../../shared/services/base_service.dart';

class WarehouseService extends BaseService {
  // Host loopback address for Android emulator to hit the backend
  static const String baseUrl = 'https://abdominal-danyelle-unindicative.ngrok-free.dev/api/v1/warehouse/warehouses/';

  Future<List<WarehouseModel>> getWarehouses() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
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
      // Organization is required by the DRF API, defaulting to 1 for this implementation
      if (!data.containsKey('organization')) {
        data['organization'] = 1; 
      }
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
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
}
