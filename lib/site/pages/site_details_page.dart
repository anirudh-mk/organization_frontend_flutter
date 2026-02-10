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
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("Site Alpha-01", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.textNavy, AppColors.primaryBlue], begin: Alignment.topRight, end: Alignment.bottomLeft),
                ),
                child: Opacity(opacity: 0.1, child: Icon(Icons.architecture_rounded, size: 200, color: Colors.white)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildMetricCard("Budget", "₹8.4 Cr", Icons.payments_rounded, Colors.green),
                      _buildMetricCard("Labor", "124 Active", Icons.groups_rounded, Colors.orange),
                      _buildMetricCard("Days", "142 Left", Icons.timer_rounded, AppColors.primaryBlue),
                      _buildMetricCard("Safety", "98% Score", Icons.verified_user_rounded, Colors.teal),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const _ActionHeader(title: "Structural Progress"),
                  const SizedBox(height: 12),
                  _buildProgressCard(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textNavy)),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Current: Level 4 Floor"), Text("75%")]),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: 0.75, color: AppColors.primaryBlue, backgroundColor: AppColors.bgLight, minHeight: 8, borderRadius: BorderRadius.circular(10)),
        ],
      ),
    );
  }
}

class _ActionHeader extends StatelessWidget {
  final String title;
  const _ActionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textNavy)),
      const Text("View Timeline", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14)),
    ]);
  }
}