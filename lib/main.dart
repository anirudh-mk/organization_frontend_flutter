import 'package:flutter/material.dart';
import 'package:organization_frontend_app/dashboard/pages/main_wrapper.dart';
import 'auth/auth_routes.dart';
import 'theme/app_theme.dart';
import 'organization/pages/organization_create_page.dart';

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
        '/organization_create': (_) => const OrganizationCreatePage(),
        '/dashboard': (_) => const MainWrapper(),
        // Change this        '/settings': (_) => const SettingsPage(),
      },
    );
  }
}
