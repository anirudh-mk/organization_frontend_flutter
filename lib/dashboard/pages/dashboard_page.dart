import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// ───────────── Modern Header ─────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            collapsedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: colorScheme.surface),
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              centerTitle: false,
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Overview",
                    style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surface,
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
            ],
          ),

          /// ───────────── Dashboard Content ─────────────
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                /// Bento Grid Row 1: Major Stats
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _BentoCard(
                        title: "Active Staff",
                        value: "124",
                        subtitle: "+12 since Monday",
                        color: colorScheme.primary,
                        textColor: Colors.white,
                        icon: Icons.people_alt_rounded,
                        height: 200,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _BentoCard(
                            title: "Sites",
                            value: "08",
                            icon: Icons.business_center_rounded,
                            height: 92,
                            mini: true,
                          ),
                          const SizedBox(height: 16),
                          _BentoCard(
                            title: "Alerts",
                            value: "03",
                            icon: Icons.warning_amber_rounded,
                            height: 92,
                            mini: true,
                            color: AppColors.warning.withValues(alpha: 0.1),
                            iconColor: AppColors.warning,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// Bento Grid Row 2: Secondary Stats
                Row(
                  children: [
                    Expanded(
                      child: _BentoCard(
                        title: "Equipment",
                        value: "42",
                        subtitle: "3 in maintenance",
                        icon: Icons.build_rounded,
                        height: 150,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _BentoCard(
                        title: "Attendance",
                        value: "94%",
                        subtitle: "High efficiency",
                        icon: Icons.check_circle_outline_rounded,
                        height: 120,
                        color: AppColors.success.withValues(alpha: 0.1),
                        iconColor: AppColors.success,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                /// Quick Navigation Section
                const _SectionHeader(title: "Management"),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _QuickAction(icon: Icons.person_add_rounded, label: "Add Staff"),
                      _QuickAction(icon: Icons.assignment_rounded, label: "Work Logs"),
                      _QuickAction(icon: Icons.account_balance_rounded, label: "Payments"),
                      _QuickAction(icon: Icons.analytics_rounded, label: "Reports"),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                /// Site Progress Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _SectionHeader(title: "Site Progress"),
                    TextButton(
                      onPressed: () {},
                      child: const Text("View All"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const _ProgressTile(
                  title: "City Plaza Redesign",
                  subtitle: "Structural Phase • 24 Workers",
                  progress: 0.72,
                ),
                const _ProgressTile(
                  title: "Metro Extension",
                  subtitle: "Foundation Phase • 18 Workers",
                  progress: 0.45,
                ),

                const SizedBox(height: 32),

                /// Activity Feed
                const _SectionHeader(title: "Recent Activity"),
                const SizedBox(height: 16),
                ...List.generate(3, (index) => _ActivityItem(index: index)),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

class _BentoCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final double height;
  final Color? color;
  final Color? textColor;
  final Color? iconColor;
  final bool mini;

  const _BentoCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.height,
    this.color,
    this.textColor,
    this.iconColor,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      padding: EdgeInsets.all(mini ? 12 : 20),
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: color == null ? Border.all(color: AppColors.textMuted.withValues(alpha: 0.15)) : null,
        boxShadow: color == null ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: mini ? 18 : 22, // Slightly smaller icons
                color: iconColor ?? (textColor?.withValues(alpha: 0.8) ?? AppColors.textSecondary),
              ),
              if (!mini && subtitle != null)
                Icon(Icons.north_east_rounded, size: 14, color: textColor?.withValues(alpha: 0.5) ?? AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: mini ? 20 : 32,
                        fontWeight: FontWeight.w800,
                        color: textColor ?? AppColors.textPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: mini ? 10 : 12,
                      fontWeight: FontWeight.w600,
                      color: textColor?.withValues(alpha: 0.7) ?? AppColors.textSecondary,
                    ),
                  ),
                ),
                if (!mini && subtitle != null) ...[
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: textColor?.withValues(alpha: 0.5) ?? AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.08)),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;

  const _ProgressTile({required this.title, required this.subtitle, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${(progress * 100).toInt()}%",
                  style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.background,
              color: AppColors.accent,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final int index;
  const _ActivityItem({required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history_edu_rounded, size: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  index == 0 ? "Shift started at Site Alpha" : "Material delivery received",
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  "2 hours ago • By Site Manager",
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
