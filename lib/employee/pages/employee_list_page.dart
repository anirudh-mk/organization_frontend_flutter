import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';
import 'employee_create_page.dart';

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({super.key});

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  bool isGridView = true; 
  final EmployeeService _service = EmployeeService();
  List<EmployeeModel> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      final employees = await _service.getEmployees();
      if (mounted) {
        setState(() {
          _employees = employees;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            toolbarHeight: 72,
            backgroundColor: AppColors.background,
            surfaceTintColor: AppColors.background,
            title: Text(
              "Workforce",
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isGridView ? Icons.format_list_bulleted_rounded : Icons.grid_view_rounded,
                ),
                onPressed: () => setState(() => isGridView = !isGridView),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadEmployees,
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_employees.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_alt_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text("No workforce staff found", style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: isGridView ? _buildEmployeeGrid() : _buildEmployeeList(),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90), 
        child: FloatingActionButton.extended(
          heroTag: 'employee_list_fab',
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EmployeeCreatePage()),
            );
            if (result == true) {
              _loadEmployees();
            }
          },
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.add_rounded),
          label: const Text("Onboard Staff", style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _buildEmployeeGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildEmployeeCard(index, _employees[index]),
        childCount: _employees.length,
      ),
    );
  }

  Widget _buildEmployeeList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildEmployeeListTile(index, _employees[index]),
        ),
        childCount: _employees.length,
      ),
    );
  }

  Widget _buildEmployeeCard(int index, EmployeeModel employee) {
    final bool isOnDuty = true; // Hardcoded until user wants attendance logic
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.background,
                  child: const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.textSecondary),
                ),
                _statusDot(isOnDuty),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  employee.phoneNumber.isNotEmpty ? employee.phoneNumber : "No Phone Data",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeListTile(int index, EmployeeModel employee) {
    final bool isOnDuty = true; 
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.background,
            child: const Icon(Icons.person_rounded, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee.displayName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(employee.phoneNumber.isNotEmpty ? employee.phoneNumber : "No Phone Data", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          _statusDot(isOnDuty),
        ],
      ),
    );
  }

  Widget _statusDot(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (active ? AppColors.success : AppColors.warning).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: active ? AppColors.success : AppColors.warning, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            active ? "On Duty" : "Off",
            style: TextStyle(
              color: active ? AppColors.success : AppColors.warning,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}