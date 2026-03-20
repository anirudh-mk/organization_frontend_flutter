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
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'All';
  List<EmployeeModel> _employees = [];
  List<EmployeeModel> _filteredEmployees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      final employees = await _service.getEmployees();
      if (mounted) {
        setState(() {
          _employees = employees;
          _isLoading = false;
          _applyFilters();
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

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEmployees = _employees.where((emp) {
        final matchesQuery = emp.displayName.toLowerCase().contains(query) ||
            (emp.employeeCode?.toLowerCase().contains(query) ?? false) ||
            (emp.mobiles.isNotEmpty && emp.mobiles.first.number.contains(query));

        final matchesStatus = _filterStatus == 'All' ||
            (_filterStatus == 'Active' && emp.isActive) ||
            (_filterStatus == 'Inactive' && !emp.isActive);

        return matchesQuery && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            toolbarHeight: 72,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: Text(
              "Workforce",
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isGridView ? Icons.format_list_bulleted_rounded : Icons.grid_view_rounded,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => setState(() => isGridView = !isGridView),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.background,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
                onPressed: _loadEmployees,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.background,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),

          // Search and Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search by name or code...",
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Active', 'Inactive'].map((status) {
                        final isSelected = _filterStatus == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: FilterChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (val) {
                              setState(() {
                                _filterStatus = status;
                                _applyFilters();
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.2),
                              ),
                            ),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_filteredEmployees.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_alt_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.3)),
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
        padding: const EdgeInsets.only(bottom: 20),
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
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          icon: const Icon(Icons.add_rounded),
          label: const Text("Onboard Staff", style: TextStyle(fontWeight: FontWeight.w800)),
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
        childAspectRatio: 0.75,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildEmployeeCard(_filteredEmployees[index]),
        childCount: _filteredEmployees.length,
      ),
    );
  }

  Widget _buildEmployeeList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildEmployeeListTile(_filteredEmployees[index]),
        ),
        childCount: _filteredEmployees.length,
      ),
    );
  }

  Widget _buildEmployeeCard(EmployeeModel employee) {
    return GestureDetector(
      onTap: () => _showEmployeeDetails(employee),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: employee.photos.isNotEmpty
                  ? Image.network(
                      employee.photos.first.imageUrl,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 130,
                      width: double.infinity,
                      color: AppColors.background,
                      child: Icon(Icons.person_rounded, color: AppColors.textMuted.withValues(alpha: 0.4), size: 48),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          employee.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _statusDot(employee.isActive),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employee.jobRoleName ?? 'General Staff',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone_android_rounded, size: 10, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        employee.mobiles.isNotEmpty ? employee.mobiles.first.number : 'No contact',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeListTile(EmployeeModel employee) {
    return GestureDetector(
      onTap: () => _showEmployeeDetails(employee),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: employee.photos.isNotEmpty
                  ? Image.network(employee.photos.first.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                  : Container(
                      width: 50,
                      height: 50,
                      color: AppColors.background,
                      child: const Icon(Icons.person_rounded, color: AppColors.textMuted),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                  ),
                  Text(
                    employee.jobRoleName ?? 'Staff',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _statusDot(employee.isActive),
                const SizedBox(height: 4),
                Text(
                  employee.employeeCode ?? '',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusDot(bool active) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.success : AppColors.error,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: (active ? AppColors.success : AppColors.error).withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  void _showEmployeeDetails(EmployeeModel employee) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.background,
                  backgroundImage: employee.photos.isNotEmpty ? NetworkImage(employee.photos.first.imageUrl) : null,
                  child: employee.photos.isEmpty ? const Icon(Icons.person_rounded, size: 40, color: AppColors.textMuted) : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.displayName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        employee.jobRoleName ?? 'General Staff',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (employee.isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          employee.isActive ? "ACTIVE" : "INACTIVE",
                          style: TextStyle(
                            color: employee.isActive ? AppColors.success : AppColors.error,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _detailRow(Icons.badge_outlined, "Employee Code", employee.employeeCode ?? 'Not Assigned'),
            _detailRow(Icons.phone_android_rounded, "Contact", employee.mobiles.isNotEmpty ? employee.mobiles.first.number : 'N/A'),
            _detailRow(Icons.email_outlined, "Email", employee.emails.isNotEmpty ? employee.emails.first.email : 'N/A'),
            _detailRow(Icons.payments_outlined, "Expected Salary", "₹ ${employee.expectedSalary}"),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EmployeeCreatePage(employee: employee)),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Edit Profile"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Close", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}