import 'package:flutter/material.dart';
import 'package:organization_frontend_app/theme/app_theme.dart';

class EmployeeCreatePage extends StatelessWidget {
  const EmployeeCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Onboard Staff")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildField("Full Name", Icons.person_outline),
            const SizedBox(height: 16),
            _buildField("Designation", Icons.work_outline),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Save Details"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
