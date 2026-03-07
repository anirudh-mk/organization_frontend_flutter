import 'package:flutter/material.dart';
import 'package:organization_frontend_app/dashboard/pages/quick_menu_page.dart';
import 'package:organization_frontend_app/employee/pages/employee_list_page.dart';
import 'package:organization_frontend_app/equipment/pages/equipment_list_page.dart';
import '../../theme/app_theme.dart';
import 'dashboard_page.dart';
import '../../site/pages/site_list_page.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const DashboardPage(),
      const SiteListPage(),
      QuickMenuPage(onNavigateToTab: (index) {
        setState(() => _currentIndex = index);
      }),
      const EmployeeListPage(),
      const EquipmentListPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBody: true, // Seamless background for floating navbar
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        height: 100, // Extra height for padding
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.grid_view_rounded, 'Home', 0),
              _buildNavItem(Icons.architecture_rounded, 'Sites', 1),
              _buildNavItem(Icons.apps_rounded, 'Menu', 2),
              _buildNavItem(Icons.groups_rounded, 'Staff', 3),
              _buildNavItem(Icons.construction_rounded, 'Gear', 4),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          size: 24,
          color: isSelected ? Theme.of(context).colorScheme.secondary : AppColors.textMuted,
        ),
      ),
    );
  }
}
