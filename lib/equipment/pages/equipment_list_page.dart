import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'equipment_details_page.dart';
import 'equipment_create_page.dart';

class EquipmentListPage extends StatefulWidget {
  const EquipmentListPage({super.key});

  @override
  State<EquipmentListPage> createState() => _EquipmentListPageState();
}

class _EquipmentListPageState extends State<EquipmentListPage> {
  bool isGridView = true; // State for switching between Grid and List

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
            expandedHeight: 120,
            collapsedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: colorScheme.surface),
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              centerTitle: false,
              title: Text(
                "Fleet Inventory",
                style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20),
              ),
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
                icon: const Icon(Icons.qr_code_scanner_rounded),
                onPressed: () {},
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
                        hintText: "Search equipment ID...",
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

          /// ───────────── Stats Summary ─────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _miniStat("Total Fleet", "42"),
                  const SizedBox(width: 12),
                  _miniStat("In Use", "34", isHighlight: true),
                  const SizedBox(width: 12),
                  _miniStat("Service", "08"),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          /// ───────────── List/Grid Content ─────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: isGridView ? _buildEquipmentGrid() : _buildEquipmentList(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90), // Floating above navbar
        child: FloatingActionButton.extended(
          heroTag: 'equipment_list_fab',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EquipmentCreatePage()),
            );
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

  Widget _buildEquipmentGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildEquipmentCard(context, index),
        childCount: 6,
      ),
    );
  }

  Widget _buildEquipmentList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildEquipmentListTile(context, index),
        ),
        childCount: 6,
      ),
    );
  }

  Widget _buildEquipmentCard(BuildContext context, int index) {
    final List<String> types = ["Excavator", "Crane", "Mixer", "Truck"];
    final String type = types[index % 4];
    final bool isWorking = index % 3 != 0;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EquipmentDetailPage())),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.08)),
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
                    child: Icon(
                      index % 2 == 0 ? Icons.construction_rounded : Icons.local_shipping_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  _statusDot(isWorking),
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
                    type,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "ID: #EQ-00${index + 1}",
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentListTile(BuildContext context, int index) {
    final List<String> types = ["Excavator", "Crane", "Mixer", "Truck"];
    final bool isWorking = index % 3 != 0;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EquipmentDetailPage())),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(index % 2 == 0 ? Icons.construction_rounded : Icons.local_shipping_rounded, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(types[index % 4], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text("ID: #EQ-00${index + 1} • Site Alpha", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            _statusDot(isWorking),
          ],
        ),
      ),
    );
  }

  Widget _statusDot(bool working) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (working ? AppColors.success : AppColors.warning).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: working ? AppColors.success : AppColors.warning, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            working ? "Active" : "Idle",
            style: TextStyle(
              color: working ? AppColors.success : AppColors.warning,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}