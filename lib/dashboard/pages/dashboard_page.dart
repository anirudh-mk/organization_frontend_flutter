import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Construction Hub"),
        automaticallyImplyLeading: false, // Removes back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Project Progress",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textNavy),
            ),
            const SizedBox(height: 16),
            _buildProjectCard("City Plaza Foundation", 0.85),
            _buildProjectCard("Skyline Tower B", 0.42),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(String title, double progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.bgLight,
            color: AppColors.primaryBlue,
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}