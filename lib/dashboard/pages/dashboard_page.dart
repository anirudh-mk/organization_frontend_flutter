import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Dashboard", style: TextStyle(color: AppColors.textNavy, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textNavy),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome back, Ani!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Statistics Row
            Row(
              children: [
                _buildStatCard("Active Projects", "12", Icons.architecture, Colors.orange),
                const SizedBox(width: 15),
                _buildStatCard("Total Staff", "48", Icons.people, Colors.blue),
              ],
            ),

            const SizedBox(height: 30),
            const Text("Recent Projects", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            _buildProjectCard("City Center Plaza", "85%", 0.85),
            _buildProjectCard("Skyline Apartments", "40%", 0.40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(String title, String percent, double progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(percent, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.bgLight,
            valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}