import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EquipmentDetailPage extends StatelessWidget {
  const EquipmentDetailPage({super.key});

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
                      "JCB Backhoe #402",
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Whitefield Site Assignment",
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
                   Text("Operational Health", style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStat("Fuel Level", "72%", Icons.gas_meter_rounded, Colors.blue),
                      const SizedBox(width: 16),
                      _buildStat("Machine Health", "94%", Icons.handyman_rounded, Colors.teal),
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
                        _buildInfoTile(theme, "Manufacturer Model", "CAT 2024-X"),
                        Divider(height: 1, color: AppColors.textMuted.withValues(alpha: 0.05), indent: 20, endIndent: 20),
                        _buildInfoTile(theme, "Serial Number", "SN-99281-B"),
                        Divider(height: 1, color: AppColors.textMuted.withValues(alpha: 0.05), indent: 20, endIndent: 20),
                        _buildInfoTile(theme, "Last Service Date", "12 Jan 2026"),
                      ],
                    ),
                  ),

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
            Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
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