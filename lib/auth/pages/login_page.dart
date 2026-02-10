import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../auth_routes.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              const Text("Welcome Back!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textNavy)),
              const Text("Sign in to manage your construction sites", style: TextStyle(fontSize: 16, color: AppColors.textGrey)),
              const SizedBox(height: 48),
              _buildInputLabel("Email Address"),
              _buildTextField(hint: "hello@example.com", icon: Icons.email_outlined),
              const SizedBox(height: 24),
              _buildInputLabel("Password"),
              _buildTextField(hint: "••••••••", icon: Icons.lock_outline_rounded, isPassword: true),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, AuthRoutes.forgotPassword),
                  child: const Text("Forgot Password?", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textNavy)),
  );

  Widget _buildTextField({required String hint, required IconData icon, bool isPassword = false}) => TextField(
    obscureText: isPassword,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primaryBlue.withValues(alpha: 0.6)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    ),
  );
}