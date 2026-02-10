import 'package:flutter/material.dart';

class AppColors {
  static const primaryBlue = Color(0xFF0066FF);
  static const bgLight = Color(0xFFF5F9FF);
  static const textNavy = Color(0xFF1A202C);
  static const textGrey = Color(0xFF718096);
  static const surfaceWhite = Colors.white;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.textNavy,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 58),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
      ),
    );
  }
}