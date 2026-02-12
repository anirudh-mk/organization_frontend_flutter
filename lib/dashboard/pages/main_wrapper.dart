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
              icon: Icon(Icons.apps_rounded),
              label: 'Quick Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_rounded),
              label: 'Staff',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.construction_rounded),
              label: 'Gear',
            ),
          ],
        ),
      ),
    );
  }
}
