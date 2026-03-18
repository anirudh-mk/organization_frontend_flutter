import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/equipment_model.dart';
import '../services/equipment_service.dart';
import 'equipment_details_page.dart';
import 'equipment_create_page.dart';

class EquipmentListPage extends StatefulWidget {
  const EquipmentListPage({super.key});

  @override
  State<EquipmentListPage> createState() => _EquipmentListPageState();
}

class _EquipmentListPageState extends State<EquipmentListPage> {
  bool isGridView = true;
  final EquipmentService _service = EquipmentService();
  late Future<List<EquipmentModel>> _equipmentsFuture;
  List<EquipmentModel> _allEquipments = [];
  List<EquipmentModel> _displayEquipments = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _equipmentsFuture = _fetchEquipments();
    });
  }

  Future<List<EquipmentModel>> _fetchEquipments() async {
    final list = await _service.getEquipments();
    setState(() {
      _allEquipments = list;
      _applyFilters();
    });
    return list;
  }

  void _applyFilters() {
    setState(() {
      _displayEquipments = _allEquipments.where((e) {
        return e.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
               e.code.toLowerCase().contains(_searchController.text.toLowerCase());
      }).toList();
    });
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
              "Fleet Inventory",
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20),
            ),
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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Search equipment...",
                        prefixIcon: Icon(Icons.search_rounded, size: 20),
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                   _miniStat("Total Fleet", _allEquipments.length.toString()),
                  const SizedBox(width: 12),
                  _miniStat("Active", _allEquipments.where((e) => e.isActive).length.toString(), isHighlight: true),
                  const SizedBox(width: 12),
                  _miniStat("Inactive", _allEquipments.where((e) => !e.isActive).length.toString()),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          FutureBuilder<List<EquipmentModel>>(
            future: _equipmentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && _allEquipments.isEmpty) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError && _allEquipments.isEmpty) {
                return SliverFillRemaining(child: Center(child: Text("Error loading inventory: ${snapshot.error}")));
              }
              if (_displayEquipments.isEmpty) {
                return const SliverFillRemaining(child: Center(child: Text("No equipment found.")));
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: isGridView 
                  ? _buildEquipmentGrid(_displayEquipments) 
                  : _buildEquipmentList(_displayEquipments),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton.extended(
          heroTag: 'equipment_list_fab',
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EquipmentCreatePage()),
            );
            if (result == true) _loadData();
          },
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.add_box_rounded),
          label: const Text("Register Gear", style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, {bool isHighlight = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isHighlight ? AppColors.accent.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlight ? AppColors.accent.withValues(alpha: 0.1) : AppColors.textMuted.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: isHighlight ? AppColors.accent : AppColors.textPrimary)),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentGrid(List<EquipmentModel> list) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildEquipmentCard(context, list[index]),
        childCount: list.length,
      ),
    );
  }

  Widget _buildEquipmentList(List<EquipmentModel> list) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildEquipmentListTile(context, list[index]),
        ),
        childCount: list.length,
      ),
    );
  }

  Widget _buildEquipmentCard(BuildContext context, EquipmentModel equipment) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EquipmentDetailPage(equipment: equipment))),
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
                    child: const Icon(Icons.construction_rounded, color: AppColors.textSecondary, size: 20),
                  ),
                  _statusDot(equipment.isActive),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(equipment.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text("ID: ${equipment.code}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentListTile(BuildContext context, EquipmentModel equipment) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EquipmentDetailPage(equipment: equipment))),
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
              child: const Icon(Icons.construction_rounded, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(equipment.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text("ID: ${equipment.code} • ${equipment.categoryDetail?.name ?? ''}", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            _statusDot(equipment.isActive),
          ],
        ),
      ),
    );
  }

  Widget _statusDot(bool working) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (working ? AppColors.success : AppColors.error).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: working ? AppColors.success : AppColors.error, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(working ? "Active" : "Inactive", style: TextStyle(color: working ? AppColors.success : AppColors.error, fontSize: 10, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
