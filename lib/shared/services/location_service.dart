import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_models.dart';

class LocationService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1/shared/';

  List<dynamic> _extractResults(dynamic body) {
    if (body is Map && body.containsKey('results')) {
      return body['results'];
    } else if (body is List) {
      return body;
    }
    return [];
  }

  Future<List<CountryModel>> getCountries() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}countries/'));
      if (response.statusCode == 200) {
        final List<dynamic> results = _extractResults(jsonDecode(response.body));
        return results.map((item) => CountryModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load countries");
      }
    } catch (e) {
      throw Exception("Error fetching countries: $e");
    }
  }

  Future<List<StateModel>> getStates(int countryId) async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}states/?country=$countryId'));
      if (response.statusCode == 200) {
        final List<dynamic> results = _extractResults(jsonDecode(response.body));
        return results.map((item) => StateModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load states");
      }
    } catch (e) {
      throw Exception("Error fetching states: $e");
    }
  }

  Future<List<DistrictModel>> getDistricts(int stateId) async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}districts/?state=$stateId'));
      if (response.statusCode == 200) {
        final List<dynamic> results = _extractResults(jsonDecode(response.body));
        return results.map((item) => DistrictModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load districts");
      }
    } catch (e) {
      throw Exception("Error fetching districts: $e");
    }
  }
}
