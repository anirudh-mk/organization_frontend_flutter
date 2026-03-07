import 'package:flutter/material.dart';
import 'package:organization_frontend_app/settings/pages/settings_page.dart';
import 'package:organization_frontend_app/warehouse/pages/warehouse_list_page.dart';
import 'package:organization_frontend_app/site/pages/site_create_page.dart';
import 'package:organization_frontend_app/employee/pages/employee_create_page.dart';
import 'package:organization_frontend_app/client/pages/client_list_page.dart';
import '../../vehicle/pages/vehicle_list_page.dart';
import '../../subcontractor/pages/subcontractor_list_page.dart';
import '../../material/pages/material_list_page.dart';
import '../../theme/app_theme.dart';

class QuickMenuPage extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const QuickMenuPage({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// ───────────── Modern Header ─────────────
          SliverAppBar(
            pinned: true,
            toolbarHeight: 72,
            backgroundColor: AppColors.background,
            surfaceTintColor: AppColors.background,
            title: Text(
              "Quick Access",
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                },
                icon: const Icon(Icons.settings_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),

          /// ───────────── Content ─────────────
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                /// Navigation Grid
                const _SectionHeader(title: "Main Navigation"),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _QuickMenuIcon(
                          icon: Icons.grid_view_rounded,
                          label: "Home",
                          onTap: () => onNavigateToTab(0),
                        ),
                        _QuickMenuIcon(
                          icon: Icons.architecture_rounded,
                          label: "Sites",
                          onTap: () => onNavigateToTab(1),
                        ),
                        _QuickMenuIcon(
                          icon: Icons.groups_rounded,
                          label: "Staff",
                          onTap: () => onNavigateToTab(3),
                        ),
                        _QuickMenuIcon(
                          icon: Icons.construction_rounded,
                          label: "Gear",
                          onTap: () => onNavigateToTab(4),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                /// Management Bento
                const _SectionHeader(title: "Management"),
                const SizedBox(height: 16),
                _BentoShortcut(
                  icon: Icons.add_business_rounded,
                  title: "New Project",
                  subtitle: "Register a construction site",
                  color: AppColors.primary.withValues(alpha: 0.05),
                  iconColor: AppColors.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SiteCreatePage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _BentoShortcut(
                  icon: Icons.person_add_alt_1_rounded,
                  title: "Onboard Staff",
                  subtitle: "Add new employees",
                  color: Colors.teal.withValues(alpha: 0.05),
                  iconColor: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EmployeeCreatePage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _BentoShortcut(
                  icon: Icons.assignment_rounded,
                  title: "Equipment Audit",
                  subtitle: "Check machinery status",
                  color: Colors.amber.withValues(alpha: 0.05),
                  iconColor: Colors.amber,
                  onTap: () => onNavigateToTab(4),
                ),
                const SizedBox(height: 12),
                _BentoShortcut(
                  icon: Icons.people_alt_rounded,
                  title: "Manage Clients",
                  subtitle: "View and add clients",
                  color: Colors.brown.withValues(alpha: 0.05),
                  iconColor: Colors.brown,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ClientListPage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _BentoShortcut(
                  icon: Icons.warehouse_rounded,
                  title: "Warehouse Logistics",
                  subtitle: "Manage inventory hubs",
                  color: Colors.indigo.withValues(alpha: 0.05),
                  iconColor: Colors.indigo,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const WarehouseListPage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _BentoShortcut(
                  icon: Icons.local_shipping_rounded,
                  title: "Vehicle Fleet",
                  subtitle: "Manage company vehicles",
                  color: AppColors.primary.withValues(alpha: 0.05),
                  iconColor: AppColors.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VehicleListPage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _BentoShortcut(
                  icon: Icons.handshake_rounded,
                  title: "Subcontractors",
                  subtitle: "Manage external contacts",
                  color: AppColors.accent.withValues(alpha: 0.05),
                  iconColor: AppColors.accent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SubcontractorListPage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _BentoShortcut(
                  icon: Icons.inventory_2_rounded,
                  title: "Materials",
                  subtitle: "Manage inventory items",
                  color: AppColors.warning.withValues(alpha: 0.05),
                  iconColor: AppColors.warning,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MaterialListPage()),
                    );
                  },
                ),

                const SizedBox(height: 32),

                /// Other Utilities
                const _SectionHeader(title: "Utilities"),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    children: [
                      _UtilityTile(
                        icon: Icons.account_balance_wallet_rounded,
                        title: "Payroll & Payments",
                        onTap: () {},
                      ),
                      Divider(height: 1, color: AppColors.textMuted.withValues(alpha: 0.05), indent: 56),
                      _UtilityTile(
                        icon: Icons.analytics_rounded,
                        title: "Advanced Reports",
                        onTap: () {},
                      ),
                      Divider(height: 1, color: AppColors.textMuted.withValues(alpha: 0.05), indent: 56),
                      _UtilityTile(
                        icon: Icons.help_outline_rounded,
                        title: "Support Center",
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

class _QuickMenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickMenuIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.08)),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoShortcut extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _BentoShortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
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
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}

class _UtilityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _UtilityTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
      ),
      trailing: Icon(Icons.north_east_rounded, size: 14, color: AppColors.textMuted.withValues(alpha: 0.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
