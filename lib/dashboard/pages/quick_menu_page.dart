import 'package:flutter/material.dart';
import 'package:organization_frontend_app/settings/pages/settings_page.dart';
import '../../theme/app_theme.dart';

class QuickMenuPage extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const QuickMenuPage({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          /// ───────────── Sticky Header ─────────────
          SliverAppBar(
            pinned: true,
            elevation: 0,
            toolbarHeight: kToolbarHeight + 10,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            titleSpacing: 20,
            title: const Text(
              "Quick Access",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textNavy,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppColors.textNavy),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          /// ───────────── Content ─────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                /// Top Grid - Core Navigation
                const _SectionTitle(title: "Main Navigation"),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  children: [
                    _QuickMenuIcon(
                      icon: Icons.grid_view_rounded,
                      label: "Home",
                      color: Colors.blue,
                      onTap: () => onNavigateToTab(0),
                    ),
                    _QuickMenuIcon(
                      icon: Icons.architecture_rounded,
                      label: "Sites",
                      color: Colors.orange,
                      onTap: () => onNavigateToTab(1),
                    ),
                    _QuickMenuIcon(
                      icon: Icons.groups_rounded,
                      label: "Staff",
                      color: Colors.purple,
                      onTap: () => onNavigateToTab(3),
                    ),
                    _QuickMenuIcon(
                      icon: Icons.construction_rounded,
                      label: "Tools",
                      color: Colors.amber,
                      onTap: () => onNavigateToTab(4),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                /// Secondary Actions - Detailed Cards
                const _SectionTitle(title: "Management Shortcuts"),
                const SizedBox(height: 16),
                _ShortcutCard(
                  icon: Icons.add_business_rounded,
                  title: "Create New Site",
                  subtitle: "Register a new project location",
                  color: Colors.orange,
                  onTap: () => onNavigateToTab(1),
                ),
                _ShortcutCard(
                  icon: Icons.person_add_alt_1_rounded,
                  title: "Onboard Staff",
                  subtitle: "Add new employees to the system",
                  color: Colors.purple,
                  onTap: () => onNavigateToTab(3),
                ),
                _ShortcutCard(
                  icon: Icons.assignment_rounded,
                  title: "Equipment Audit",
                  subtitle: "Check current machinery status",
                  color: Colors.amber,
                  onTap: () => onNavigateToTab(4),
                ),
                _ShortcutCard(
                  icon: Icons.assignment_ind_rounded,
                  title: "Assign Site Manager",
                  subtitle: "Allocate supervision to projects",
                  color: Colors.teal,
                  onTap: () => onNavigateToTab(1), // Navigates to Sites tab
                ),

                const SizedBox(height: 32),

                /// Finance & HR Section
                const _SectionTitle(title: "Finance & HR"),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  children: [
                    _QuickMenuIcon(
                      icon: Icons.fact_check_rounded,
                      label: "Attendance",
                      color: Colors.green,
                      onTap: () => onNavigateToTab(3), // Navigates to Staff tab
                    ),
                    _QuickMenuIcon(
                      icon: Icons.account_balance_wallet_rounded,
                      label: "Payments",
                      color: Colors.indigo,
                      onTap: () {
                         // Placeholder for Payments
                         debugPrint("Navigate to Payments");
                      },
                    ),
                    _QuickMenuIcon(
                      icon: Icons.analytics_rounded,
                      label: "Reports",
                      color: Colors.redAccent,
                      onTap: () {
                         // Placeholder for Reports
                         debugPrint("Navigate to Reports");
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                /// Settings Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.withValues(alpha: 0.1),
                      child: const Icon(Icons.settings, color: Colors.grey),
                    ),
                    title: const Text("System Settings",
                        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textNavy)),
                    subtitle: const Text("App preferences and configurations"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      );
                    },
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// ───────────── Components ─────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textNavy,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _QuickMenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickMenuIcon({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textNavy,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textNavy,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textGrey),
      ),
    );
  }
}