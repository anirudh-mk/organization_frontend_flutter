import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee_model.dart';
import '../../shared/services/base_service.dart';

class EmployeeService extends BaseService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1/employee';

  Future<List<EmployeeModel>> getEmployees() async {
    try {
      final response = await performRequest((headers) => http.get(
        Uri.parse('$baseUrl/'),
        headers: headers,
      ));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => EmployeeModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load employees: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching employees: $e");
    }
  }

  Future<EmployeeModel> createEmployee(Map<String, dynamic> data) async {
    try {
      final response = await performRequest((headers) => http.post(
        Uri.parse('$baseUrl/'),
        headers: headers,
        body: jsonEncode(data),
      ));
      
      if (response.statusCode == 201) {
        return EmployeeModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to create employee: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error creating employee: $e");
    }
  }
}
