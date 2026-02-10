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
              const SizedBox(height: 60),

              // Header
              const Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textNavy,
                    letterSpacing: -0.5,
                  )
              ),
              const Text(
                  "Sign in to manage your construction sites",
                  style: TextStyle(fontSize: 16, color: AppColors.textGrey)
              ),
              const SizedBox(height: 40),

              // Email Field
              _buildInputLabel("Email Address"),
              _buildTextField(hint: "hello@example.com", icon: Icons.email_outlined),
              const SizedBox(height: 20),

              // Password Field
              _buildInputLabel("Password"),
              _buildTextField(hint: "••••••••", icon: Icons.lock_outline_rounded, isPassword: true),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, AuthRoutes.forgotPassword),
                  child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Primary Sign In Button
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text(
                      "Sign In",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // OR Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.2))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                        "OR",
                        style: TextStyle(
                            color: AppColors.textGrey.withValues(alpha: 0.6),
                            fontWeight: FontWeight.bold
                        )
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.2))),
                ],
              ),

              const SizedBox(height: 30),

              // Google Sign In Button (Using Icon instead of Network Image)
              SizedBox(
                width: double.infinity,
                height: 58,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement Google Sign In
                  },
                  icon: const Icon(
                    Icons.g_mobiledata_rounded, // Native Flutter Icon
                    size: 32,
                    color: AppColors.primaryBlue,
                  ),
                  label: const Text(
                    "Continue with Google",
                    style: TextStyle(
                        color: AppColors.textNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Footer: Create Account
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?", style: TextStyle(color: AppColors.textGrey)),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, AuthRoutes.signup),
                      child: const Text(
                          "Sign Up",
                          style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable label widget
  Widget _buildInputLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textNavy, fontSize: 14)
    ),
  );

  // Reusable text field widget
  Widget _buildTextField({required String hint, required IconData icon, bool isPassword = false}) => TextField(
    obscureText: isPassword,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textGrey.withValues(alpha: 0.5)),
      prefixIcon: Icon(icon, color: AppColors.primaryBlue.withValues(alpha: 0.6)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
    ),
  );
}