import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../auth/auth_routes.dart';
import '../../auth/services/auth_service.dart';
import 'profile_settings_page.dart';
import 'notifications_page.dart';
import 'security_page.dart';
import 'appearance_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSettingsTile(context, Icons.person_outline_rounded, "Profile Settings", "Edit your professional information", const ProfileSettingsPage()),
          _buildSettingsTile(context, Icons.notifications_none_rounded, "Notifications", "Alerts and communication preferences", const NotificationsPage()),
          _buildSettingsTile(context, Icons.lock_outline_rounded, "Security", "Privacy and password management", const SecurityPage()),
          _buildSettingsTile(context, Icons.palette_outlined, "Appearance", "App theme and visual settings", const AppearancePage()),
          const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: const Text("Logout", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onTap: () async {
                  try {
                    await AuthService().logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, AuthRoutes.login, (route) => false);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error logging out: $e")),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      );
    }

  Widget _buildSettingsTile(BuildContext context, IconData icon, String title, String sub, Widget page) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}