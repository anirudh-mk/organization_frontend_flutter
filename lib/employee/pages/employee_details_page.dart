import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EmployeeDetailPage extends StatelessWidget {
  const EmployeeDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. Profile Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(backgroundColor: colorScheme.surface),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: colorScheme.surface,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1), width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.background,
                        child: Icon(Icons.person_rounded, size: 50, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Suresh Kumar",
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Lead Structural Engineer",
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status & Action Row
                  _buildActionRow(colorScheme),
                  const SizedBox(height: 40),

                  // Info Cards
                  _buildSectionTitle(theme, "Employment Vitals"),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoCard(theme, "Employee ID", "EMP-2024-08", Icons.badge_outlined),
                      const SizedBox(width: 16),
                      _buildInfoCard(theme, "Joined Date", "12 Jan 2024", Icons.calendar_today_outlined),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLargeInfoCard(theme, "Assigned Site", "Green Valley Phase 1", Icons.location_on_outlined),

                  const SizedBox(height: 40),

                  // Attendance Summary
                  _buildSectionTitle(theme, "Performance"),
                  const SizedBox(height: 16),
                  _buildAttendanceStats(theme),

                  const SizedBox(height: 40),

                  // Contact Details
                  _buildSectionTitle(theme, "Contact Information"),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      children: [
                        _buildContactTile(theme, "Email", "suresh.k@construction.com", Icons.email_outlined),
                        Divider(height: 1, color: AppColors.textMuted.withValues(alpha: 0.05), indent: 56),
                        _buildContactTile(theme, "Phone", "+91 98765 43210", Icons.phone_android_outlined),
                      ],
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(title, style: theme.textTheme.titleLarge);
  }

  Widget _buildActionRow(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCircleAction(Icons.call_rounded, "Call", Colors.teal),
        _buildCircleAction(Icons.chat_bubble_rounded, "Chat", AppColors.primary),
        _buildCircleAction(Icons.history_rounded, "Logs", Colors.orange),
      ],
    );
  }

  Widget _buildCircleAction(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildInfoCard(ThemeData theme, String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(height: 16),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeInfoCard(ThemeData theme, String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStats(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("22", "Present", Colors.teal),
          _statItem("02", "Absent", AppColors.error),
          _statItem("92%", "Rate", AppColors.accent),
        ],
      ),
    );
  }

  Widget _statItem(String val, String label, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildContactTile(ThemeData theme, String label, String value, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 14)),
      trailing: const Icon(Icons.copy_rounded, size: 16, color: AppColors.textMuted),
    );
  }
}