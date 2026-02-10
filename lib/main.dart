import 'package:flutter/material.dart';
import 'auth/auth_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: AuthRoutes.login,
      routes: AuthRoutes.routes,
    );
  }
}
