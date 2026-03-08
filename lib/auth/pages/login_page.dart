import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../../organization/services/organization_service.dart';

enum LoginMethod { password, otp }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  final _authService = AuthService();
  
  LoginMethod _loginMethod = LoginMethod.password;
  bool _isOtpSent = false;
  bool _isLoading = false;

  Future<void> _handlePasswordLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and Password are required"), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await _authService.loginWithPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (success) {
        final orgService = OrganizationService();
        try {
          final org = await orgService.getCurrentOrganization();
          if (mounted) {
            if (org == null) {
              Navigator.pushReplacementNamed(context, '/organization_create');
            } else {
              Navigator.pushReplacementNamed(context, '/dashboard');
            }
          }
        } catch (_) {
          if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRequestOtp() async {
    if (_emailController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final success = await _authService.requestOtp(_emailController.text.trim());
      if (success) {
        setState(() => _isOtpSent = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OTP sent to your email")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final success = await _authService.verifyOtp(
        _emailController.text.trim(),
        _otpController.text.trim(),
      );
      if (success) {
        final orgService = OrganizationService();
        try {
          final org = await orgService.getCurrentOrganization();
          if (mounted) {
            if (org == null) {
              Navigator.pushReplacementNamed(context, '/organization_create');
            } else {
              Navigator.pushReplacementNamed(context, '/dashboard');
            }
          }
        } catch (_) {
          if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid or expired OTP"), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleLoginMethod() {
    setState(() {
      if (_loginMethod == LoginMethod.password) {
        _loginMethod = LoginMethod.otp;
      } else {
        _loginMethod = LoginMethod.password;
        _isOtpSent = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.architecture_rounded, size: 48, color: AppColors.accent),
                ),
                const SizedBox(height: 32),
                Text(
                  "Build Tomorrow",
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _loginMethod == LoginMethod.otp && _isOtpSent 
                      ? "Check your email for OTP" 
                      : "Sign in to access your dashboard",
                  style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 48),

                if (_loginMethod == LoginMethod.password) ...[
                  _buildInputLabel("Email Address"),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "name@company.com",
                      prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInputLabel("Password"),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "Enter your password",
                      prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
                    ),
                  ),
                ] else if (_loginMethod == LoginMethod.otp && !_isOtpSent) ...[
                  _buildInputLabel("Email Address"),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "name@company.com",
                      prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                    ),
                  ),
                ] else if (_loginMethod == LoginMethod.otp && _isOtpSent) ...[
                  _buildInputLabel("One-Time Password"),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Enter 6-digit OTP",
                      prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading 
                      ? null 
                      : (_loginMethod == LoginMethod.password ? _handlePasswordLogin : (_isOtpSent ? _handleVerifyOtp : _handleRequestOtp)),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_loginMethod == LoginMethod.password ? "Login" : (_isOtpSent ? "Verify OTP" : "Send OTP")),
                  ),
                ),

                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _toggleLoginMethod,
                    child: Text(
                      _loginMethod == LoginMethod.password 
                        ? "Login with OTP Instead" 
                        : "Login with Password Instead", 
                      style: const TextStyle(color: AppColors.accent)
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("New here?", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      TextButton(
                        onPressed: () {
                           Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text(
                          "Create Enterprise Account",
                          style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) => Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      );
}