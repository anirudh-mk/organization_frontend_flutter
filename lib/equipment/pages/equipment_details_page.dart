import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/equipment_model.dart';

class EquipmentDetailPage extends StatelessWidget {
  final EquipmentModel equipment;

  const EquipmentDetailPage({super.key, required this.equipment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(backgroundColor: colorScheme.surface),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: colorScheme.surface,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(Icons.construction_rounded, size: 48, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      equipment.name,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ID: ${equipment.code}",
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text("Operational Info", style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStat("Category", equipment.categoryDetail?.name ?? 'N/A', Icons.category_rounded, AppColors.primary),
                      const SizedBox(width: 16),
                      _buildStat("Status", equipment.statusDetail?.name ?? 'N/A', Icons.info_outline_rounded, equipment.isActive ? AppColors.success : AppColors.error),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  Text("Asset Details", style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      children: [
                        _buildInfoTile(theme, "Ownership Type", equipment.ownershipTypeDetail?.name ?? 'N/A'),
                        Divider(height: 1, color: AppColors.textMuted.withValues(alpha: 0.05), indent: 20, endIndent: 20),
                        _buildInfoTile(theme, "Purchase Date", equipment.purchaseDate ?? 'N/A'),
                        Divider(height: 1, color: AppColors.textMuted.withValues(alpha: 0.05), indent: 20, endIndent: 20),
                        _buildInfoTile(theme, "Purchase Cost", equipment.purchaseCost != null ? "₹${equipment.purchaseCost}" : 'N/A'),
                      ],
                    ),
                  ),

                  if (equipment.rentalDetails != null) ...[
                    const SizedBox(height: 24),
                    Text("Rental Information", style: theme.textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        children: [
                          _buildInfoTile(theme, "Vendor", equipment.rentalDetails!.vendorName ?? 'N/A'),
                          Divider(height: 1, color: AppColors.textMuted.withValues(alpha: 0.05), indent: 20, endIndent: 20),
                          _buildInfoTile(theme, "Rental Start", equipment.rentalDetails!.rentalStartDate),
                          Divider(height: 1, color: AppColors.textMuted.withValues(alpha: 0.05), indent: 20, endIndent: 20),
                          _buildInfoTile(theme, "Daily Rate", "₹${equipment.rentalDetails!.rentalRatePerDay}"),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 120),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStat(String label, String val, IconData icon, Color col) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: col.withValues(alpha: 0.05), shape: BoxShape.circle),
              child: Icon(icon, color: col, size: 20),
            ),
            const SizedBox(height: 12),
            Text(val, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(ThemeData theme, String label, String val) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
      subtitle: Text(val, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 15)),
    );
  }
}
