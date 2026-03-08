import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/site_model.dart';
import '../../shared/services/base_service.dart';

class SiteService extends BaseService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1/site/sites';

  Future<List<SiteModel>> getSites() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
        headers: await getHeaders(),
      );
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => SiteModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load sites");
      }
    } catch (e) {
      throw Exception("Error fetching sites: $e");
    }
  }

  Future<SiteModel> onboardSite(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/v1/site/onboard/'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201) {
        return SiteModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to onboard site: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error onboarding site: $e");
    }
  }

  Future<SiteModel> updateSite(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$id/'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        return SiteModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to update site: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error updating site: $e");
    }
  }

  Future<void> deleteSite(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id/'),
        headers: await getHeaders(),
      );
      
      if (response.statusCode != 204) {
        throw Exception("Failed to delete site: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error deleting site: $e");
    }
  }
}
