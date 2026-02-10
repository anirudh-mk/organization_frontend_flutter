import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EmployeeDetailPage extends StatelessWidget {
  const EmployeeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          // 1. Profile Header
          SliverAppBar(
            expandedHeight: 240,
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
                    const CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 50, color: AppColors.primaryBlue),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Suresh Kumar",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Lead Structural Engineer",
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status & Action Row
                  _buildActionRow(),
                  const SizedBox(height: 32),

                  // Info Cards
                  _buildSectionTitle("Employment Vitals"),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoCard("Employee ID", "EMP-2024-08", Icons.badge_outlined),
                      const SizedBox(width: 12),
                      _buildInfoCard("Joined Date", "12 Jan 2024", Icons.calendar_today_outlined),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildLargeInfoCard("Assigned Site", "Green Valley Phase 1", Icons.location_on_outlined),

                  const SizedBox(height: 32),

                  // Attendance Summary
                  _buildSectionTitle("Monthly Performance"),
                  const SizedBox(height: 16),
                  _buildAttendanceStats(),

                  const SizedBox(height: 32),

                  // Contact Details
                  _buildSectionTitle("Contact Information"),
                  const SizedBox(height: 16),
                  _buildContactTile("Email", "suresh.k@construction.com", Icons.email_outlined),
                  _buildContactTile("Phone", "+91 98765 43210", Icons.phone_android_outlined),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textNavy));
  }

  Widget _buildActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCircleAction(Icons.call, "Call", Colors.green),
        _buildCircleAction(Icons.message, "Text", Colors.blue),
        _buildCircleAction(Icons.history, "History", Colors.orange),
      ],
    );
  }

  Widget _buildCircleAction(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 20),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeInfoCard(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("22", "Present", Colors.green),
          _statItem("02", "Absent", Colors.red),
          _statItem("92%", "Rate", AppColors.primaryBlue),
        ],
      ),
    );
  }

  Widget _statItem(String val, String label, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
      ],
    );
  }

  Widget _buildContactTile(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textNavy)),
      ),
    );
  }
}