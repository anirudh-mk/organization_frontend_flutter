import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_manager.dart';

class AuthService {
  static const String authBaseUrl = 'https://abdominal-danyelle-unindicative.ngrok-free.dev/api/v1/user';
  // Use http://10.0.2.2:8000/api/v1/accounts/user for local Android Emulator testing if needed

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

  Future<bool> registerWithPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String mobile,
    required String dob,
  }) async {
    try {
      // For local testing on android emulator, user may need to change authBaseUrl. Left as ngrok per user setup.
      final response = await http.post(
        Uri.parse('$authBaseUrl/password-signup/'), // Based on django urls ending with user/password-signup/
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': mobile,
          // 'dob' might need specific date formatting (YYYY-MM-DD), assume frontend sends it correctly or backend parses DD/MM/YYYY. The serializer expects a date format.
          // In signup_page.dart it sets it to "${picked.day}/${picked.month}/${picked.year}". Let's reformat it to standard YYYY-MM-DD for Django if needed below, or just pass it directly.
          'dob': _formatDateForDjango(dob),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['access'];
        if (token != null) {
          await TokenManager.saveAccessToken(token);
          return true;
        }
      } else {
        throw Exception(response.body); // Let UI handle detailed error
      }
      return false;
    } catch (e) {
      throw Exception("Error registering: $e");
    }
  }

  Future<bool> loginWithPassword(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$authBaseUrl/password-login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access'];
        if (token != null) {
          await TokenManager.saveAccessToken(token);
          return true;
        }
      } else {
        throw Exception(response.body); // Let UI handle detailed error
      }
      return false;
    } catch (e) {
      throw Exception("Error logging in: $e");
    }
  }

  // Helper to convert DD/MM/YYYY to YYYY-MM-DD for Django
  String _formatDateForDjango(String originalDate) {
    try {
      final parts = originalDate.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day';
      }
    } catch (_) {}
    return originalDate; // fallback if already correct or empty
  }
}
