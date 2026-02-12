import 'package:flutter/material.dart';
import 'package:organization_frontend_app/site/pages/site_create_page.dart';
import '../../theme/app_theme.dart';
import 'site_details_page.dart';

class SiteListPage extends StatefulWidget {
  const SiteListPage({super.key});

  @override
  State<SiteListPage> createState() => _SiteListPageState();
}

class _SiteListPageState extends State<SiteListPage> {
  bool isGridView = false; // Sites often look better in List view, but toggle is here for consistency

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
                "Project Sites",
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
                    _buildSummaryStat("Active Sites", "12"),
                    _buildDivider(),
                    _buildSummaryStat("Completed", "05"),
                    _buildDivider(),
                    _buildSummaryStat("On Hold", "02"),
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
                          hintText: "Search site location or name...",
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

          /// ───────────── Sites Content ─────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: isGridView ? _buildSiteGrid() : _buildSiteList(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SiteCreatePage()),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text("New Site", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  /// ───────────── View Builders ─────────────

  Widget _buildSiteList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) => _buildModernSiteCard(context, index),
        childCount: 5,
      ),
    );
  }

  Widget _buildSiteGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) => _buildSiteGridCard(context, index),
        childCount: 6,
      ),
    );
  }

  /// ───────────── UI Components ─────────────

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

  Widget _buildModernSiteCard(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SiteDetailPage())),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.architecture_rounded, color: AppColors.primaryBlue, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Green Valley Phase $index", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textNavy)),                        Text("Bengaluru, India", style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                      ],
                    ),
                  ),
                  _buildStatusDot(index % 3 != 0),
                ],
              ),
            ),
            _buildProgressFooter(0.75, "₹4.5 Cr"),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteGridCard(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SiteDetailPage())),
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
                  const Icon(Icons.business_rounded, color: AppColors.primaryBlue, size: 20),
                  _buildStatusDot(index % 2 == 0),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Phase $index", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textNavy)),
                  const Text("Bengaluru", style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildProgressFooter(0.60, "₹2.1 Cr", isSmall: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressFooter(double progress, String budget, {bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: isSmall ? 10 : 15),
      decoration: BoxDecoration(
        color: AppColors.bgLight.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text("Budget: $budget", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textNavy)),
              const Spacer(),
              Text("${(progress * 100).toInt()}%", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white,
              color: AppColors.primaryBlue,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (active ? Colors.green : Colors.orange).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        active ? "On Track" : "Delayed",
        style: TextStyle(color: active ? Colors.green : Colors.orange, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}