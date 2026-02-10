import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'dashboard_page.dart';
import '../../site/pages/site_list_page.dart';
import '../../employee/pages/employee_list_page.dart'; // Import Employee
import '../../equipment/pages/equipment_list_page.dart'; // Import Equipment
import '../../settings/pages/settings_page.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  // 1. Expanded list of pages
  final List<Widget> _pages = [
    const DashboardPage(),
    const SiteListPage(),
    const EmployeeListPage(), // Added
    const EquipmentListPage(), // Added
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack preserves the scroll state of each page
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppColors.surfaceWhite,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.textGrey.withValues(alpha: 0.5),
          showSelectedLabels: true,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed, // Essential for more than 3 items
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.architecture_rounded),
              label: 'Sites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_rounded),
              label: 'Staff',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.construction_rounded),
              label: 'Gear',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'Menu',
            ),
          ],
        ),
      ),
    );
  }
}