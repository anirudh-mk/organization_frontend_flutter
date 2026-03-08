import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SiteDetailPage extends StatelessWidget {
  const SiteDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// ───────────── Modern Elegant Header ─────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: colorScheme.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(backgroundColor: Colors.black26),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              titlePadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              centerTitle: false,
              title: Text("Green Valley Phase 1",
                  style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1541888946425-d81bb19480c5?auto=format&fit=crop&w=800&q=80',
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
                onPressed: () {},
                style: IconButton.styleFrom(backgroundColor: Colors.black26),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () {},
                style: IconButton.styleFrom(backgroundColor: Colors.black26),
              ),
              const SizedBox(width: 16),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ───────────── Operational Metrics ─────────────
                  Row(
                    children: [
                      _buildMiniStat(Icons.calendar_today_rounded, "Est. Completion", "Oct 2026"),
                      const SizedBox(width: 16),
                      _buildMiniStat(Icons.location_on_rounded, "Location", "Sector 4, BLR"),
                    ],
                  ),
                  const SizedBox(height: 40),

                  /// ───────────── Resource Management Grid ─────────────
                  _SectionHeader(title: "Project Resources"),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      _buildResourceCard("Manage Staff", "48 Workers", Icons.groups_rounded, AppColors.primary, () {}),
                      _buildResourceCard("Fleet / Units", "12 Units", Icons.construction_rounded, Colors.orange, () {}),
                      _buildResourceCard("Budget Logs", "₹4.5 Cr / 8 Cr", Icons.account_balance_wallet_rounded, Colors.teal, () {}),
                      _buildResourceCard("Site Reports", "14 Updates", Icons.description_rounded, AppColors.primary, () {}),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// ───────────── Premium Progress Tracker ─────────────
                  _SectionHeader(title: "Construction Health", trailing: "Timeline"),
                  const SizedBox(height: 16),
                  _buildDetailedProgressCard(theme),

                  const SizedBox(height: 40),

                  /// ───────────── Critical Tasks ─────────────
                  _SectionHeader(title: "Critical Tasks", trailing: "View All"),
                  const SizedBox(height: 16),
                  _buildTaskTile("Foundation Reinforcement", "In Progress", 0.85, AppColors.primary),
                  _buildTaskTile("Electrical Conduit Laying", "Pending", 0.0, AppColors.textMuted),
                  _buildTaskTile("Level 4 Slab Pouring", "Scheduled", 0.1, Colors.orange),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton.extended(
          heroTag: 'site_details_fab',
          onPressed: () {},
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.add_a_photo_rounded),
          label: const Text("Post Update", style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  /// ───────────── UI Components ─────────────

  Widget _buildMiniStat(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
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
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedProgressCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Project Health", style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                child: const Text("ON TRACK", style: TextStyle(color: Colors.tealAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              )
            ],
          ),
          const SizedBox(height: 12),
          const Text("75.4%", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(value: 0.75, color: Colors.tealAccent, backgroundColor: Colors.white12, minHeight: 12),
          ),
          const SizedBox(height: 20),
          const Text("Milestone: Interior Walling & Level 5 Slab", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTaskTile(String task, String status, double progress, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 42,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                Text(status, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress == 0 ? 0.05 : progress,
                  strokeWidth: 4,
                  backgroundColor: AppColors.background,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Center(child: Text("${(progress * 100).toInt()}%", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900))),
              ],
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
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        if (trailing != null)
          TextButton(
            onPressed: () {},
            child: Text(trailing!, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w800, fontSize: 13)),
          ),
      ],
    );
  }
}
