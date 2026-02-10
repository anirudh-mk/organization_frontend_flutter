import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EquipmentDetailPage extends StatelessWidget {
  const EquipmentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          // 1. Equipment Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.textNavy, AppColors.primaryBlue],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.construction_rounded, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Caterpillar Excavator 320",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                      ),
                      child: const Text(
                        "IN USE",
                        style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Primary Metrics
                  Row(
                    children: [
                      _buildMetricCard("Fuel Level", "78%", Icons.local_gas_station_rounded, Colors.blue),
                      const SizedBox(width: 12),
                      _buildMetricCard("Health", "Good", Icons.settings_suggest_rounded, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Equipment Specs Card
                  _buildSectionTitle("Identification & Specs"),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        _buildSpecRow("Asset ID", "#EQ-CAT-320-04"),
                        const Divider(height: 24),
                        _buildSpecRow("Model Year", "2023"),
                        const Divider(height: 24),
                        _buildSpecRow("Current Site", "Green Valley Phase 1"),
                        const Divider(height: 24),
                        _buildSpecRow("Operator", "Ramesh Singh"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Maintenance Timeline
                  _buildSectionTitle("Maintenance Schedule"),
                  const SizedBox(height: 12),
                  _buildMaintenanceCard(),

                  const SizedBox(height: 32),

                  // Recent Activity Logs
                  _buildSectionTitle("Usage Logs"),
                  const SizedBox(height: 12),
                  _buildLogItem("Started Engine", "Site A • 08:30 AM"),
                  _buildLogItem("Idling detected (>15m)", "Site A • 11:15 AM"),
                  _buildLogItem("Fuel Refill (40L)", "Site A • 02:45 PM"),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: _buildActionFooter(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textNavy));
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textNavy)),
      ],
    );
  }

  Widget _buildMaintenanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_note_rounded, color: AppColors.primaryBlue),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Next Service Due", style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
              Text("March 15, 2026", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textNavy)),
            ],
          ),
          const Spacer(),
          TextButton(onPressed: () {}, child: const Text("Book Now")),
        ],
      ),
    );
  }

  Widget _buildLogItem(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.history_toggle_off_rounded, size: 20, color: AppColors.textGrey),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildActionFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text("Report Issue", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.bgLight, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.map_rounded, color: AppColors.primaryBlue),
          )
        ],
      ),
    );
  }
}