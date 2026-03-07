import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/client_model.dart';
import '../../shared/services/base_service.dart';

class ClientService extends BaseService {
  static const String baseUrl = 'https://abdominal-danyelle-unindicative.ngrok-free.dev/api/v1/client/clients';

  Future<List<ClientModel>> getClients() async {
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
        
        return results.map((dynamic item) => ClientModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load clients: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching clients: $e");
    }
  }

  Future<ClientModel> createClient(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return ClientModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to create client: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error creating client: $e");
    }
  }
}
