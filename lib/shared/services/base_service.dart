import '../../../auth/services/token_manager.dart';

abstract class BaseService {
  Future<Map<String, String>> getHeaders() async {
    final token = await TokenManager.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
