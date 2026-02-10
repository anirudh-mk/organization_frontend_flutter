import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EquipmentListPage extends StatelessWidget {
  const EquipmentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventory")),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.9),
        itemCount: 6,
        itemBuilder: (context, index) => _buildEquipCard(index),
      ),
    );
  }

  Widget _buildEquipCard(int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.construction, color: AppColors.primaryBlue, size: 32),
          const Spacer(),
          const Text("Excavator", style: TextStyle(fontWeight: FontWeight.bold)),
          const Text("ID: #EQ-99", style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Text("Working", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}