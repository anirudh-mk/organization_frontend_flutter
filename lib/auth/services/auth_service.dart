import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_manager.dart';

class AuthService {
  static const String authBaseUrl = 'https://abdominal-danyelle-unindicative.ngrok-free.dev/api/v1/user';

  Future<bool> requestOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$authBaseUrl/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Error requesting OTP: $e");
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$authBaseUrl/verify-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access'];
        if (token != null) {
          await TokenManager.saveAccessToken(token);
          return true;
        }
      }
      return false;
    } catch (e) {
      throw Exception("Error verifying OTP: $e");
    }
  }
}
