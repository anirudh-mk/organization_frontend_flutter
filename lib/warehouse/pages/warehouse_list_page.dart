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

  @override
  void initState() {
    super.initState();
    _loadWarehouses();
  }

  void _loadWarehouses() {
    setState(() {
      _warehousesFuture = _fetchWarehouses();
    });
  }

  Future<List<WarehouseModel>> _fetchWarehouses() async {
    final orgId = await TokenManager.getOrganizationId();
    return _service.getWarehouses(organizationId: orgId);
  }

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
              "Warehouses",
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
              const SizedBox(width: 16),
            ],
          ),

          /// ───────────── Search & Filter ─────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search warehouse...",
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),

          /// ───────────── List/Grid Content via HTTP ─────────────
          FutureBuilder<List<WarehouseModel>>(
            future: _warehousesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                        const SizedBox(height: 16),
                        Text("Error loading data", style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            snapshot.error.toString(), 
                            style: const TextStyle(color: AppColors.textSecondary), 
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadWarehouses,
                          child: const Text("Retry"),
                        )
                      ],
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      "No warehouses found.\\nTap below to create one!",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final List<WarehouseModel> warehouses = snapshot.data!;

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: isGridView 
                  ? _buildGrid(warehouses)
                  : _buildList(warehouses),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24), // Above standard padding
        child: FloatingActionButton.extended(
          heroTag: 'warehouse_list_fab',
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WarehouseCreatePage()),
            );
            if (result == true) {
              _loadWarehouses();
            }
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                      Text(
                        warehouse.name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Code: ${warehouse.code}",
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                      if (warehouse.isPrimary)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text("PRIMARY", style: TextStyle(fontSize: 8, color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ],
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
            child: Container(
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.warehouse_rounded, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                warehouse.name, 
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (warehouse.isPrimary)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text("PRIMARY", style: TextStyle(fontSize: 8, color: AppColors.primary, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        Text("Code: ${warehouse.code}", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  _statusDot(warehouse.isActive),
                ],
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
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: isActive ? AppColors.success : AppColors.error, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? "Active" : "Inactive",
            style: TextStyle(
              color: isActive ? AppColors.success : AppColors.error,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
