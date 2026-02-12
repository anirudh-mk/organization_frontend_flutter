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
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          /// ───────────── Sticky Header ─────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppColors.surfaceWhite,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: const Text(
                "Fleet Inventory",
                style: TextStyle(
                  color: AppColors.textNavy,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isGridView ? Icons.format_list_bulleted_rounded : Icons.grid_view_rounded,
                  color: AppColors.textNavy,
                ),
                onPressed: () => setState(() => isGridView = !isGridView),
              ),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.textNavy),
                onPressed: () {},
              ),
            ],
          ),

          /// ───────────── Summary Stats Card ─────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryStat("Total Fleet", "42"),
                    _buildDivider(),
                    _buildSummaryStat("In Use", "34"),
                    _buildDivider(),
                    _buildSummaryStat("Maintenance", "08"),
                  ],
                ),
              ),
            ),
          ),

          /// ───────────── Search & Filter ─────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Search equipment ID...",
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: AppColors.primaryBlue, size: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildIconButton(Icons.tune_rounded),
                ],
              ),
            ),
          ),

          /// ───────────── Content (Grid or List) ─────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: isGridView ? _buildEquipmentGrid() : _buildEquipmentList(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EquipmentCreatePage()),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add_box_rounded, color: Colors.white),
        label: const Text("Register Gear", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  /// ───────────── Shared Components ─────────────

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: Colors.white.withValues(alpha: 0.15));
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  /// ───────────── View Builders ─────────────

  Widget _buildEquipmentGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) => _buildModernEquipCard(context, index),
        childCount: 6,
      ),
    );
  }

  Widget _buildEquipmentList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildEquipListTile(context, index),
        ),
        childCount: 6,
      ),
    );
  }

  /// ───────────── Modern Cards ─────────────

  Widget _buildModernEquipCard(BuildContext context, int index) {
    final List<String> types = ["Excavator", "Crane", "Mixer", "Truck"];
    final String type = types[index % 4];
    final bool isWorking = index % 3 != 0;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EquipmentDetailPage())),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      index % 2 == 0 ? Icons.construction_rounded : Icons.local_shipping_rounded,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                  _buildStatusDot(isWorking),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textNavy)),
                  const SizedBox(height: 4),
                  Text("ID: #EQ-00${index + 1}", style: const TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 12, color: AppColors.primaryBlue),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text("Site Alpha-01", style: TextStyle(fontSize: 10, color: AppColors.textNavy.withValues(alpha: 0.7), fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
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

  Widget _buildEquipListTile(BuildContext context, int index) {
    final List<String> types = ["Excavator", "Crane", "Mixer", "Truck"];
    final bool isWorking = index % 3 != 0;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EquipmentDetailPage())),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(index % 2 == 0 ? Icons.construction_rounded : Icons.local_shipping_rounded, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(types[index % 4], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textNavy)),
                  Text("ID: #EQ-00${index + 1} • Site Alpha", style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                ],
              ),
            ),
            _buildStatusDot(isWorking),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDot(bool working) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (working ? Colors.green : Colors.orange).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: working ? Colors.green : Colors.orange, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(working ? "Active" : "Idle", style: TextStyle(color: working ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}