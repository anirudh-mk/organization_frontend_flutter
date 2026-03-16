import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_models.dart';
import '../../shared/services/base_service.dart';

class VehicleService extends BaseService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1/vehicle/vehicles/';

  Future<List<VehicleModel>> getVehicles({String? organizationId}) async {
    try {
      String url = baseUrl;
      if (organizationId != null) {
        url += '?organization=$organizationId';
      }
      final response = await performRequest((headers) => http.get(Uri.parse(url), headers: headers));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => VehicleModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load vehicles: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching vehicles: $e");
    }
  }

  Future<VehicleModel> createVehicle(Map<String, dynamic> data) async {
    try {
      final response = await performRequest((headers) => http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(data),
      ));
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return VehicleModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to create vehicle: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error creating vehicle: $e");
    }
  }

  Future<void> updateVehicle(String id, Map<String, dynamic> data) async {
    try {
      final response = await performRequest((headers) => http.patch(
        Uri.parse('$baseUrl$id/'),
        headers: headers,
        body: jsonEncode(data),
      ));
      
      if (response.statusCode != 200) {
        throw Exception("Failed to update vehicle: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error updating vehicle: $e");
    }
  }

  Future<void> deleteVehicle(String id) async {
    try {
      final response = await performRequest((headers) => http.delete(
        Uri.parse('$baseUrl$id/'),
        headers: headers,
      ));
      
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception("Failed to delete vehicle: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error deleting vehicle: $e");
    }
  }

  Future<Map<String, dynamic>> getVehicleFormData({String? organizationId}) async {
    try {
      String url = '${baseUrl}form_data/';
      if (organizationId != null) {
        url += '?organization=$organizationId';
      }
      final response = await performRequest((headers) => http.get(Uri.parse(url), headers: headers));
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return {'contact_types': [], 'payment_types': []};
    } catch (e) {
      return {'contact_types': [], 'payment_types': []};
    }
  }
}
