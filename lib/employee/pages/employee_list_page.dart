import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EmployeeListPage extends StatelessWidget {
  const EmployeeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Workforce")),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 8,
        itemBuilder: (context, index) => _buildEmployeeCard(context, index),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeeCreatePage())),
        backgroundColor: AppColors.primaryBlue,
        label: const Text("Add Staff", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: AppColors.bgLight, child: Icon(Icons.person, color: AppColors.primaryBlue)),
        title: Text("Worker #$index", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Structural Engineer • Site A"),
        trailing: const Icon(Icons.call, color: Colors.green, size: 20),
      ),
    );
  }
}

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
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Save Details")),
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