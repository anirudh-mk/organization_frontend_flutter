import 'package:flutter/material.dart';
import 'auth/auth_routes.dart';
import 'theme/app_theme.dart';
import 'dashboard/pages/dashboard_page.dart';
import 'settings/pages/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Construction Management',
      theme: AppTheme.lightTheme,
      initialRoute: AuthRoutes.login,
      routes: {
        ...AuthRoutes.routes,
        '/dashboard': (_) => const DashboardPage(),
        '/settings': (_) => const SettingsPage(),
      },
    );
  }
}