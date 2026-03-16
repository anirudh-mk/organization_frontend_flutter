import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/warehouse_model.dart';
import '../services/warehouse_service.dart';
import 'warehouse_create_page.dart';

import '../../auth/services/token_manager.dart';

class WarehouseListPage extends StatefulWidget {
  const WarehouseListPage({super.key});

  @override
  State<WarehouseListPage> createState() => _WarehouseListPageState();
}

class _WarehouseListPageState extends State<WarehouseListPage> {
  bool isGridView = false;
  final WarehouseService _service = WarehouseService();
  late Future<List<WarehouseModel>> _warehousesFuture;
  List<WarehouseModel> _allWarehouses = [];
  List<WarehouseModel> _displayWarehouses = [];
  
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'All'; // All, Active, Primary

  @override
  void initState() {
    super.initState();
    _loadWarehouses();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadWarehouses() {
    setState(() {
      _warehousesFuture = _fetchWarehouses();
    });
  }

  Future<List<WarehouseModel>> _fetchWarehouses() async {
    final orgId = await TokenManager.getOrganizationId();
    final warehouses = await _service.getWarehouses(organizationId: orgId);
    setState(() {
      _allWarehouses = warehouses;
      _applyFilters();
    });
    return warehouses;
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _displayWarehouses = _allWarehouses.where((w) {
        final matchesSearch = w.name.toLowerCase().contains(_searchController.text.toLowerCase()) || 
                             w.code.toLowerCase().contains(_searchController.text.toLowerCase());
        
        bool matchesStatus = true;
        if (_filterStatus == 'Active') {
          matchesStatus = w.isActive;
        } else if (_filterStatus == 'Primary') {
          matchesStatus = w.isPrimary;
        }
        
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Future<void> _deleteWarehouse(WarehouseModel warehouse) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Warehouse"),
        content: Text("Are you sure you want to delete ${warehouse.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Delete", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _service.deleteWarehouse(warehouse.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Warehouse deleted successfully")));
          _loadWarehouses();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
        }
      }
    }
  }

  void _showWarehouseDetails(WarehouseModel warehouse) {
    var addr = warehouse.addressList.firstOrNull?.addressDetails;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.warehouse_rounded, color: AppColors.primary, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(warehouse.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("Code: ${warehouse.code}", style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                _statusDot(warehouse.isActive),
              ],
            ),
            const SizedBox(height: 32),
            _detailItem(Icons.info_outline, "Status", warehouse.isActive ? "Active" : "Inactive"),
            _detailItem(Icons.star_outline, "Role", warehouse.isPrimary ? "Primary Warehouse" : "Standard Warehouse"),
            
            if (warehouse.addressList.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),
              const Text("Location Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ...warehouse.addressList.map((wa) {
                final d = wa.addressDetails;
                if (d == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailItem(Icons.location_on_outlined, "Address", "${d.line1}${d.line2.isNotEmpty ? ', ' + d.line2 : ''}"),
                      _detailItem(Icons.location_city_outlined, "City", d.city),
                      _detailItem(Icons.pin_outlined, "Postal Code", d.postalCode),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              }),
            ],

            if (warehouse.emails.isNotEmpty) ...[
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
              const Text("Email Addresses", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ...warehouse.emails.map((e) => _detailItem(Icons.email_outlined, e.contactTypeName ?? "Email", e.email)),
            ],

            if (warehouse.mobiles.isNotEmpty) ...[
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
              const Text("Mobile Numbers", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ...warehouse.mobiles.map((m) => _detailItem(Icons.phone_outlined, m.contactTypeName ?? "Mobile", m.number)),
            ],
            
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => WarehouseCreatePage(warehouse: warehouse))
                      );
                      if (result == true) _loadWarehouses();
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text("Edit"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteWarehouse(warehouse);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text("Delete"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
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
            title: Text("Warehouses", style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20)),
            actions: [
              IconButton(
                icon: Icon(isGridView ? Icons.format_list_bulleted_rounded : Icons.grid_view_rounded),
                onPressed: () => setState(() => isGridView = !isGridView),
                style: IconButton.styleFrom(backgroundColor: colorScheme.surface),
              ),
              const SizedBox(width: 16),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search by name or code...",
                      prefixIcon: const Icon(Icons.search_rounded, size: 22),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.1))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.1))),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Active', 'Inactive', 'Primary'].map((status) {
                        final isSelected = _filterStatus == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ChoiceChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _filterStatus = status;
                                  _applyFilters();
                                });
                              }
                            },
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                            selectedColor: AppColors.primary,
                            backgroundColor: Colors.white,
                            checkmarkColor: Colors.white,
                            side: BorderSide(color: isSelected ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: isSelected ? 2 : 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          FutureBuilder<List<WarehouseModel>>(
            future: _warehousesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && _allWarehouses.isEmpty) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError && _allWarehouses.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                        const SizedBox(height: 16),
                        Text("Error loading data", style: theme.textTheme.titleMedium),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadWarehouses, child: const Text("Retry"))
                      ],
                    ),
                  ),
                );
              }

              if (_displayWarehouses.isEmpty) {
                return const SliverFillRemaining(child: Center(child: Text("No warehouses found matching filters.")));
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: isGridView 
                  ? _buildGrid(_displayWarehouses)
                  : _buildList(_displayWarehouses),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: FloatingActionButton.extended(
          heroTag: 'warehouse_list_fab',
          onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const WarehouseCreatePage()));
            if (result == true) _loadWarehouses();
          },
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.add_business_rounded),
          label: const Text("New Warehouse", style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _buildGrid(List<WarehouseModel> warehouses) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final warehouse = warehouses[index];
          return GestureDetector(
            onTap: () => _showWarehouseDetails(warehouse),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.04), blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.warehouse_rounded, color: AppColors.textSecondary, size: 20),
                        ),
                        _statusDot(warehouse.isActive),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(warehouse.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text("Code: ${warehouse.code}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: warehouses.length,
      ),
    );
  }

  Widget _buildList(List<WarehouseModel> warehouses) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final warehouse = warehouses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: Key(warehouse.id),
              direction: DismissDirection.horizontal,
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  await _deleteWarehouse(warehouse);
                  return false;
                } else if (direction == DismissDirection.startToEnd) {
                  final result = await Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => WarehouseCreatePage(warehouse: warehouse))
                  );
                  if (result == true) _loadWarehouses();
                  return false;
                }
                return false;
              },
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.edit, color: Colors.white),
              ),
              secondaryBackground: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: GestureDetector(
                onTap: () => _showWarehouseDetails(warehouse),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.03), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.warehouse_rounded, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(warehouse.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), overflow: TextOverflow.ellipsis),
                            Text("Code: ${warehouse.code}", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      _statusDot(warehouse.isActive),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        childCount: warehouses.length,
      ),
    );
  }

  Widget _statusDot(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: isActive ? AppColors.success : AppColors.error, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(isActive ? "Active" : "Inactive", style: TextStyle(color: isActive ? AppColors.success : AppColors.error, fontSize: 10, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
