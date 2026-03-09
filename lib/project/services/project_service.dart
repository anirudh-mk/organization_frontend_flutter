import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_model.dart';
import '../../shared/services/base_service.dart';

class ProjectService extends BaseService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1/project/';

  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: await getHeaders(),
      );
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => ProjectModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load projects");
      }
    } catch (e) {
      throw Exception("Error fetching projects: $e");
    }
  }

  Future<ProjectModel> createProject(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await getHeaders(),
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201) {
        return ProjectModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to create project: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error creating project: $e");
    }
  }
}
