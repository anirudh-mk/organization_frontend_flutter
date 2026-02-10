import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'equipment_details_page.dart';
import 'equipment_create_page.dart';

class EquipmentListPage extends StatelessWidget {
  const EquipmentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
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
                icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.textNavy),
                onPressed: () {},
              ),
            ],
          ),
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
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
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
            ),
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

  Widget _buildModernEquipCard(BuildContext context, int index) {
    final List<String> types = ["Excavator", "Crane", "Mixer", "Truck"];
    final String type = types[index % 4];
    final bool isWorking = index % 3 != 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EquipmentDetailPage()),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
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
                      index % 2 == 0
                          ? Icons.construction_rounded
                          : Icons.local_shipping_rounded, // FIXED ERROR HERE
                      color: AppColors.primaryBlue,
                      size: 22,
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
                        child: Text(
                          "Site Alpha-01",
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