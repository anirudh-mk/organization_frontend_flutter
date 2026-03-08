import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/material_models.dart';
import '../../shared/services/base_service.dart';

class MaterialService extends BaseService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1/material';

  Future<List<MaterialCategoryModel>> getMaterialCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories/'),
        headers: await getHeaders(),
      );
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => MaterialCategoryModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load categories");
      }
    } catch (e) {
      throw Exception("Error fetching categories: $e");
    }
  }

  Future<List<MaterialModel>> getMaterials() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/materials/'),
        headers: await getHeaders(),
      );
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => MaterialModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load materials");
      }
    } catch (e) {
      throw Exception("Error fetching materials: $e");
    }
  }

  Future<MaterialModel> createMaterial(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/materials/'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) {
        return MaterialModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to create material: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error creating material: $e");
    }
  }
}
