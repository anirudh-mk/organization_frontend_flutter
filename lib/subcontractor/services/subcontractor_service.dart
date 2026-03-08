import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/subcontractor_model.dart';
import '../../shared/services/base_service.dart';

class SubcontractorService extends BaseService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1/subcontractor/subcontractors/';

  Future<List<SubcontractorModel>> getSubcontractors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
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
        
        return results.map((dynamic item) => SubcontractorModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load subcontractors: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching subcontractors: $e");
    }
  }

  Future<SubcontractorModel> createSubcontractor(Map<String, dynamic> data) async {
    try {
      if (!data.containsKey('organization')) {
        data['organization'] = 1; 
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201) {
        return SubcontractorModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to create subcontractor: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error creating subcontractor: $e");
    }
  }
}
