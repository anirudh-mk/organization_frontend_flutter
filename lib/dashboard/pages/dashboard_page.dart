import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          /// ───────────── Sticky Header ─────────────
          SliverAppBar(
            pinned: true,
            elevation: 0,
            toolbarHeight: kToolbarHeight + 10,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            automaticallyImplyLeading: false,
            titleSpacing: 20,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                  child: const Text("A",
                      style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text("Welcome",
                        style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                    Text("Anirudh MK",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textNavy)),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(icon: const Icon(Icons.search, color: AppColors.textNavy), onPressed: () {}),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textNavy),
                      onPressed: () {},
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// ───────────── Dashboard Content ─────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                /// Quick Menu (Employees, Attendance, etc.)
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: const [
                    _QuickMenu(icon: Icons.people_outline, label: "Employees"),
                    _QuickMenu(icon: Icons.fact_check_outlined, label: "Attendance"),
                    _QuickMenu(icon: Icons.account_balance_wallet_outlined, label: "Payments"),
                    _QuickMenu(icon: Icons.analytics_outlined, label: "Reports"),
                  ],
                ),

                const SizedBox(height: 24),

                /// Horizontal Major Stats
                const _SectionTitle(title: "Overview"),
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      _StatCard(title: "Employees", value: "42", icon: Icons.people),
                      _StatCard(title: "Active Sites", value: "08", icon: Icons.business),
                      _StatCard(title: "Equipment", value: "15", icon: Icons.build_circle),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// Grid Stats
                const _SectionTitle(title: "Operational Status"),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: const [
                    _InfoTile(title: "Active Workers", value: "34"),
                    _InfoTile(title: "On Leave", value: "08"),
                    _InfoTile(title: "Attendance", value: "92%"),
                    _InfoTile(title: "Pending", value: "₹45K"),
                  ],
                ),

                const SizedBox(height: 24),

                /// Site Progress Section
                const _SectionTitle(title: "Site Progress"),
                const SizedBox(height: 12),
                const _ProgressTile(title: "City Plaza", subtitle: "Foundation Phase", progress: 0.75),
                const _ProgressTile(title: "Metro Station", subtitle: "Structural Work", progress: 0.45),

                const SizedBox(height: 24),

                /// Quick Actions Expansion
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text("Management Actions",
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textNavy)),
                    children: [
                      _actionItem(Icons.add_business_outlined, "Launch New Project"),
                      _actionItem(Icons.assignment_ind_outlined, "Assign Site Manager"),
                      _actionItem(Icons.person_add_alt_1_outlined, "Onboard Worker"),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// Recent Logs
                const _SectionTitle(title: "Recent Activity"),
                const SizedBox(height: 12),
                ListView.builder(
                  itemCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _RecentActivityItem(index: index);
                  },
                ),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

/// ───────────── Components ─────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textNavy));
  }
}

class _QuickMenu extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickMenu({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
          ),
          child: Icon(icon, color: AppColors.primaryBlue),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textNavy)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 24),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textNavy)),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textNavy)),
              Text("${(progress * 100).toInt()}%", style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          Text(subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.bgLight,
              color: AppColors.primaryBlue,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityItem extends StatelessWidget {
  final int index;
  const _RecentActivityItem({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.bgLight,
          child: const Icon(Icons.person_outline, color: AppColors.primaryBlue, size: 20),
        ),
        title: Text("Log entry #${1024 + index}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: const Text("Site A • Check-in recorded", style: TextStyle(fontSize: 12)),
        trailing: const Text("9:41 AM", style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
      ),
    );
  }
}