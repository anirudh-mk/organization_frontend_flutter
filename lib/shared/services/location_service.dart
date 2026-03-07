import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_models.dart';
import '../../shared/services/base_service.dart';

class LocationService extends BaseService {
  static const String baseUrl = 'https://abdominal-danyelle-unindicative.ngrok-free.dev/api/v1/shared/';

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
      final response = await http.get(
        Uri.parse('${baseUrl}countries/'),
        headers: await getHeaders(),
      );
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
      final response = await http.get(
        Uri.parse('${baseUrl}states/?country=$countryId'),
        headers: await getHeaders(),
      );
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

  Future<List<AddressTypeModel>> getAddressTypes() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}address-type/'));
      if (response.statusCode == 200) {
        final List<dynamic> results = _extractResults(jsonDecode(response.body));
        return results.map((item) => AddressTypeModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load address types");
      }
    } catch (e) {
      throw Exception("Error fetching address types: $e");
    }
  }
}
