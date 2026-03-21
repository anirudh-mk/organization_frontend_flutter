import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';
import 'employee_create_page.dart';
import 'employee_details_page.dart';

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
            emp.emails.any((e) => e.email.toLowerCase().contains(query)) ||
            emp.mobiles.any((m) => m.number.contains(query));

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true, toolbarHeight: 72, backgroundColor: Colors.white,
            title: Text("Workforce", style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(icon: Icon(isGridView ? Icons.format_list_bulleted_rounded : Icons.grid_view_rounded, color: AppColors.textPrimary), onPressed: () => setState(() => isGridView = !isGridView)),
              IconButton(icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary), onPressed: _loadEmployees),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 8), child: Column(children: [
            Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))]), child: TextField(controller: _searchController, decoration: const InputDecoration(hintText: "Search by name or code...", prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 18)))),
            const SizedBox(height: 16),
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ['All', 'Active', 'Inactive'].map((status) {
              final isSelected = _filterStatus == status;
              return Padding(padding: const EdgeInsets.only(right: 12), child: FilterChip(label: Text(status), selected: isSelected, onSelected: (v) { setState(() { _filterStatus = status; _applyFilters(); }); }, backgroundColor: Colors.white, selectedColor: AppColors.primary, labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.2))), showCheckmark: false));
            }).toList())),
          ]))),
          if (_isLoading) const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_filteredEmployees.isEmpty) SliverFillRemaining(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.people_alt_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.3)), const SizedBox(height: 16), Text("No workforce staff found", style: TextStyle(color: AppColors.textMuted, fontSize: 16))])))
          else SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 24), sliver: isGridView ? _buildEmployeeGrid() : _buildEmployeeList()),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: Padding(padding: const EdgeInsets.only(bottom: 20), child: FloatingActionButton.extended(heroTag: 'employee_list_fab', onPressed: () async { final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => const EmployeeCreatePage())); if (res == true) _loadEmployees(); }, backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), icon: const Icon(Icons.add_rounded), label: const Text("Onboard Staff", style: TextStyle(fontWeight: FontWeight.w800)))),
    );
  }

  Widget _buildEmployeeGrid() => SliverGrid(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.75), delegate: SliverChildBuilderDelegate((ctx, idx) => _buildEmployeeCard(_filteredEmployees[idx]), childCount: _filteredEmployees.length));
  Widget _buildEmployeeList() => SliverList(delegate: SliverChildBuilderDelegate((ctx, idx) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildEmployeeListTile(_filteredEmployees[idx])), childCount: _filteredEmployees.length));

  Widget _buildEmployeeCard(EmployeeModel emp) => GestureDetector(onTap: () => _showEmployeeDetails(emp), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), child: emp.photos.isNotEmpty ? Image.network(emp.photos.first.imageUrl, height: 130, width: double.infinity, fit: BoxFit.cover) : Container(height: 130, width: double.infinity, color: AppColors.background, child: Icon(Icons.person_rounded, color: AppColors.textMuted.withValues(alpha: 0.4), size: 48))),
    Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(emp.displayName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)), _statusDot(emp.isActive)]),
      Text(emp.jobRoleName ?? 'General Staff', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1),
      const SizedBox(height: 8),
      Text(emp.mobiles.isNotEmpty ? emp.mobiles.first.number : 'No contact', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
    ])),
  ])));

  Widget _buildEmployeeListTile(EmployeeModel emp) => GestureDetector(onTap: () => _showEmployeeDetails(emp), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]), child: Row(children: [
    ClipRRect(borderRadius: BorderRadius.circular(12), child: emp.photos.isNotEmpty ? Image.network(emp.photos.first.imageUrl, width: 50, height: 50, fit: BoxFit.cover) : Container(width: 50, height: 50, color: AppColors.background, child: const Icon(Icons.person_rounded, color: AppColors.textMuted))),
    const SizedBox(width: 16),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(emp.displayName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)), Text(emp.jobRoleName ?? 'Staff', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600))])),
    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [_statusDot(emp.isActive), const SizedBox(height: 4), Text(emp.employeeCode ?? '', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold))]),
  ])));

  Widget _statusDot(bool active) => Container(width: 8, height: 8, decoration: BoxDecoration(color: active ? AppColors.success : AppColors.error, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)));

  void _showEmployeeDetails(EmployeeModel emp) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailPage(employee: emp),
      ),
    ).then((_) => _loadEmployees());
  }

  Widget _detailSection(String title, List<Widget> children) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.2)),
    const SizedBox(height: 12),
    ...children,
  ]);

  Widget _detailRow(IconData icon, String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
    Icon(icon, size: 18, color: AppColors.textSecondary),
    const SizedBox(width: 12),
    Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
    const Spacer(),
    Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
  ]));
}