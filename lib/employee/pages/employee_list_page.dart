import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({super.key});

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  bool isGridView = true; // Default to Grid to match your Equipment layout

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          /// ───────────── Sliver App Bar ─────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppColors.surfaceWhite,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: const Text(
                "Workforce",
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
            ],
          ),

          /// ───────────── Top Stats Card ─────────────
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
                    _buildSummaryStat("Total Staff", "124"),
                    _buildDivider(),
                    _buildSummaryStat("On Duty", "86"),
                    _buildDivider(),
                    _buildSummaryStat("Leaves", "08"),
                  ],
                ),
              ),
            ),
          ),

          /// ───────────── Search & Filter Row ─────────────
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
                          hintText: "Search employee name or ID...",
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

          /// ───────────── Dynamic Content (Grid or List) ─────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: isGridView ? _buildEmployeeGrid() : _buildEmployeeList(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text("Onboard Staff", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  /// ───────────── UI Helper Methods ─────────────

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

  /// ───────────── Grid View Builder ─────────────
  Widget _buildEmployeeGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) => _buildEmployeeCard(index),
        childCount: 8,
      ),
    );
  }

  /// ───────────── List View Builder ─────────────
  Widget _buildEmployeeList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildEmployeeListTile(index),
        ),
        childCount: 8,
      ),
    );
  }

  /// ───────────── Modern Employee Card (Grid) ─────────────
  Widget _buildEmployeeCard(int index) {
    final bool isOnDuty = index % 3 != 0;
    return Container(
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
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.08),
                  child: const Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue, size: 20),
                ),
                _buildStatusBadge(isOnDuty),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Staff Member #$index", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textNavy)),
                const SizedBox(height: 4),
                Text("ID: EMP-102$index", style: const TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.work_outline_rounded, size: 12, color: AppColors.primaryBlue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Site Supervisor",
                        style: TextStyle(fontSize: 10, color: AppColors.textNavy.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ───────────── Modern List Tile (List) ─────────────
  Widget _buildEmployeeListTile(int index) {
    final bool isOnDuty = index % 3 != 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.bgLight,
            child: const Icon(Icons.person, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Staff Member #$index", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textNavy)),
                Text("Site Supervisor • Site Alpha", style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
          _buildStatusBadge(isOnDuty),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (active ? Colors.green : Colors.orange).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: active ? Colors.green : Colors.orange, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            active ? "On Duty" : "Off Duty",
            style: TextStyle(color: active ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}