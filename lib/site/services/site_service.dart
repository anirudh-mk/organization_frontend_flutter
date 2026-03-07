import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/site_model.dart';
import '../../shared/services/base_service.dart';

class SiteService extends BaseService {
  static const String baseUrl = 'https://abdominal-danyelle-unindicative.ngrok-free.dev/api/v1/site/sites';

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

  Future<SiteModel> createSite(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201) {
        return SiteModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to create site: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error creating site: $e");
    }
  }
}
