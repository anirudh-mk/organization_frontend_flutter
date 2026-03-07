import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/material_models.dart';

class MaterialService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1/material';

  Future<List<MaterialCategoryModel>> getMaterialCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories/'));
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
        
        return results.map((dynamic item) => MaterialCategoryModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load material categories: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching material categories: $e");
    }
  }

  Future<List<MaterialModel>> getMaterials() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/materials/'));
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
        
        return results.map((dynamic item) => MaterialModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load materials: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching materials: $e");
    }
  }

  Future<MaterialModel> createMaterial(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/materials/'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return MaterialModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to create material: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error creating material: $e");
    }
  }
}
