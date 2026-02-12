import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SiteDetailPage extends StatelessWidget {
  const SiteDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          /// ───────────── Modern Image Header ─────────────
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primaryBlue,
            leading: const BackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              title: const Text("Green Valley Phase 1",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Site Image Placeholder
                  Image.network(
                    'https://images.unsplash.com/photo-1541888946425-d81bb19480c5?auto=format&fit=crop&w=800&q=80',
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.edit_note_rounded, color: Colors.white), onPressed: () {}),
              IconButton(icon: const Icon(Icons.share_rounded, color: Colors.white), onPressed: () {}),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ───────────── Operational Metrics ─────────────
                  Row(
                    children: [
                      _buildMiniStat(Icons.calendar_today_rounded, "Est. Completion", "Oct 2026"),
                      const SizedBox(width: 12),
                      _buildMiniStat(Icons.location_on_rounded, "Location", "Sector 4, BLR"),
                    ],
                  ),
                  const SizedBox(height: 24),

                  /// ───────────── Resource Management Grid ─────────────
                  const _SectionHeader(title: "Resource Management"),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _buildResourceCard("Manage Staff", "48 Workers", Icons.groups_rounded, Colors.purple, () {}),
                      _buildResourceCard("Equipment", "12 Units", Icons.construction_rounded, Colors.orange, () {}),
                      _buildResourceCard("Budget Logs", "₹4.5 Cr / 8 Cr", Icons.account_balance_wallet_rounded, Colors.green, () {}),
                      _buildResourceCard("Site Notes", "14 Updates", Icons.description_rounded, Colors.blue, () {}),
                    ],
                  ),

                  const SizedBox(height: 32),

                  /// ───────────── Live Progress Tracker ─────────────
                  const _SectionHeader(title: "Structural Progress", trailing: "View Details"),
                  const SizedBox(height: 16),
                  _buildDetailedProgressCard(),

                  const SizedBox(height: 32),

                  /// ───────────── Active Works / Tasks ─────────────
                  const _SectionHeader(title: "Critical Tasks", trailing: "Add Task"),
                  const SizedBox(height: 12),
                  _buildTaskTile("Foundation Reinforcement", "In Progress", 0.85, Colors.blue),
                  _buildTaskTile("Electrical Conduit Laying", "Pending", 0.0, Colors.grey),
                  _buildTaskTile("Level 4 Slab Pouring", "Scheduled", 0.1, Colors.orange),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
        label: const Text("Post Update", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  /// ───────────── UI Components ─────────────

  Widget _buildMiniStat(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
                  Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textNavy)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textNavy)),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.textNavy,
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: const NetworkImage('https://www.transparenttextures.com/patterns/carbon-fibre.png'),
          opacity: 0.05,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Project Health", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: const Text("ON TRACK", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 8),
          const Text("75.4%", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(value: 0.75, color: Colors.green, backgroundColor: Colors.white12, minHeight: 8),
          ),
          const SizedBox(height: 16),
          const Text("Current Milestone: Interior Walling & Level 5 Slab", style: TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTaskTile(String task, String status, double progress, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textNavy)),
                Text(status, style: TextStyle(fontSize: 12, color: color)),
              ],
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: AppColors.bgLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          )
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textNavy)),
        if (trailing != null)
          Text(trailing!, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}