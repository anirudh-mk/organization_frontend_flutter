import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../auth/auth_routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingsTile(Icons.person_outline, "Profile Settings", "Edit your information"),
          _buildSettingsTile(Icons.notifications_none, "Notifications", "Alerts and updates"),
          _buildSettingsTile(Icons.lock_outline, "Security", "Change password"),
          const Divider(height: 40),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () => Navigator.pushNamedAndRemoveUntil(context, AuthRoutes.login, (route) => false),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String sub) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}