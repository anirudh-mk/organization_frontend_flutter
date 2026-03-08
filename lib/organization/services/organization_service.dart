import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/organization_model.dart';
import '../../shared/services/base_service.dart';

class OrganizationService extends BaseService {
  // Using same base host as auth for now
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1/organization';

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

  Future<OrganizationModel> createOrganization(String name, String typeId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/organizations/'),
        headers: await getHeaders(),
        body: jsonEncode({
          'name': name,
          'type': typeId,
        }),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return OrganizationModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to create organization: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error creating organization: $e");
    }
  }
}
