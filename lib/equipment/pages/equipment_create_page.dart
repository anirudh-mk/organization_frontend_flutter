import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EquipmentCreatePage extends StatelessWidget {
  const EquipmentCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Gear")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildField("Equipment Name", Icons.settings),
            const SizedBox(height: 20),
            _buildField("Asset Serial ID", Icons.tag),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Add to Fleet"),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}