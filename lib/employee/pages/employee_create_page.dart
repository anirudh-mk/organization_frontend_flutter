import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EmployeeCreatePage extends StatelessWidget {
  const EmployeeCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Onboard Staff"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Photo Picker Placeholder
            Center(
              child: Column(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                        )
                      ],
                    ),
                    child: const Icon(Icons.add_a_photo_rounded, color: AppColors.primaryBlue, size: 30),
                  ),
                  const SizedBox(height: 12),
                  const Text("Upload Profile Photo",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 2. Identity Section
            const _FormSectionHeader(title: "Identity", subtitle: "Full name and professional role"),
            const SizedBox(height: 16),
            _buildField("Full Name", "e.g. Anirudh MK", Icons.person_outline_rounded),
            const SizedBox(height: 16),
            _buildField("Designation", "e.g. Site Supervisor", Icons.work_outline_rounded, isDropdown: true),

            const SizedBox(height: 32),

            // 3. Contact Section
            const _FormSectionHeader(title: "Contact", subtitle: "How to reach this staff member"),
            const SizedBox(height: 16),
            _buildField("Phone Number", "+91 00000 00000", Icons.phone_android_rounded),
            const SizedBox(height: 16),
            _buildField("Email Address (Optional)", "hello@company.com", Icons.alternate_email_rounded),

            const SizedBox(height: 48),

            // 4. Submit Button
            Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text("Confirm Onboarding",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, IconData icon, {bool isDropdown = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textNavy)),
        const SizedBox(height: 8),
        TextField(
          readOnly: isDropdown,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textGrey.withValues(alpha: 0.5), fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
            suffixIcon: isDropdown ? const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textGrey) : null,
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
        ),
      ],
    );
  }
}

class _FormSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _FormSectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textNavy)),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
      ],
    );
  }
}