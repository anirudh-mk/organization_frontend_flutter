import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SiteCreatePage extends StatelessWidget {
  const SiteCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Launch New Site"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(title: "Identity", subtitle: "Basic site and branding details"),
            const SizedBox(height: 20),
            _buildField("Project Name", "e.g. Skyline Tower A", Icons.business_rounded),
            const SizedBox(height: 20),
            _buildField("Site Location", "e.g. Whitefield, Bengaluru", Icons.location_on_rounded),

            const SizedBox(height: 40),
            const _SectionHeader(title: "Project Scope", subtitle: "Financial and timeline parameters"),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildField("Budget (₹ Cr)", "0.00", Icons.payments_rounded)),
                const SizedBox(width: 16),
                Expanded(child: _buildField("Duration (Days)", "365", Icons.event_available_rounded)),
              ],
            ),

            const SizedBox(height: 20),
            _buildField("Project Manager", "Select manager", Icons.person_pin_circle_rounded, isDropdown: true),

            const SizedBox(height: 60),

            // Create Button
            Container(
              width: double.infinity,
              height: 60,
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
                onPressed: () {
                  // TODO: Implement Creation Logic
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text("Initialise Site Hub",
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textNavy)),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textNavy)),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
      ],
    );
  }
}