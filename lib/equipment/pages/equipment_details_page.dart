import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EquipmentDetailPage extends StatelessWidget {
  const EquipmentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.textNavy, AppColors.primaryBlue],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Icon(Icons.construction_rounded, size: 50, color: Colors.white),
                    const SizedBox(height: 12),
                    const Text("JCB Backhoe #402", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text("Whitefield Site Assignment", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildStat("Fuel", "72%", Icons.gas_meter, Colors.blue),
                      const SizedBox(width: 12),
                      _buildStat("Health", "94%", Icons.handyman, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoTile("Model", "CAT 2024-X"),
                  _buildInfoTile("Serial Number", "SN-99281-B"),
                  _buildInfoTile("Last Service", "12 Jan 2026"),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStat(String label, String val, IconData icon, Color col) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Icon(icon, color: col),
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String val) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
      subtitle: Text(val, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textNavy)),
    );
  }
}