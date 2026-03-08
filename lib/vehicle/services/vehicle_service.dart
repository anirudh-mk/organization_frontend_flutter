import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_models.dart';
import '../../shared/services/base_service.dart';

class VehicleService extends BaseService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1/vehicle/vehicles/';

  Future<List<VehicleModel>> getVehicles() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: await getHeaders(),
      );
      if (response.statusCode == 200) {
        dynamic body = jsonDecode(response.body);
        
        List<dynamic> results = body is Map ? body['results'] : body;
        
        return results.map((dynamic item) => VehicleModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load vehicles");
      }
    } catch (e) {
      throw Exception("Error fetching vehicles: $e");
    }
  }

  Future<VehicleModel> createVehicle(Map<String, dynamic> data) async {
    try {
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
        return VehicleModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to create vehicle: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error creating vehicle: $e");
    }
  }
}
