import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../auth/services/token_manager.dart';
import '../models/organization_model.dart';
import '../../shared/services/base_service.dart';

class OrganizationService extends BaseService {
  // Using same base host as auth for now
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  Future<OrganizationModel?> getCurrentOrganization() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/organization/organizations/current/'),
        headers: await getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final org = OrganizationModel.fromJson(data);
        await TokenManager.saveOrganizationDetails(
          id: org.id,
          name: org.name,
          logo: org.logo,
        );
        return org;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception("Failed to load current organization (${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Error fetching current organization: $e");
    }
  }

  Future<List<OrganizationModel>> getOrganizations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/organization/organizations/'),
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
        Uri.parse('$baseUrl/organization/types/'),
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

  Future<List<CountryModel>> getCountries() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shared/countries/'),
        headers: await getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CountryModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<StateModel>> getStates(String countryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shared/states/?country=$countryId'),
        headers: await getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => StateModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<DistrictModel>> getDistricts(String stateId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shared/districts/?state=$stateId'),
        headers: await getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DistrictModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<AddressTypeModel>> getAddressTypes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shared/address-type/'),
        headers: await getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => AddressTypeModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<OrganizationModel> createOrganization(
    String name,
    String typeId, {
    List<Map<String, dynamic>>? addresses,
    File? logo,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/organization/organizations/');
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      final headers = await getHeaders();
      request.headers.addAll(headers);

      // Add fields
      request.fields['name'] = name;
      request.fields['type'] = typeId;

      if (addresses != null && addresses.isNotEmpty) {
        request.fields['addresses_json'] = jsonEncode(addresses);
      }

      // Add logo
      if (logo != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'logo',
          logo.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (streamedResponse.statusCode == 201 || streamedResponse.statusCode == 200) {
        final org = OrganizationModel.fromJson(jsonDecode(response.body));
        await TokenManager.saveOrganizationDetails(
          id: org.id,
          name: org.name,
          logo: org.logo,
        );
        return org;
      } else {
        throw Exception("Failed to create organization: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error creating organization: $e");
    }
  }
}
