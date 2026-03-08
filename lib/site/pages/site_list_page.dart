import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/site_model.dart';
import '../services/site_service.dart';
import 'site_create_page.dart';

class SiteListPage extends StatefulWidget {
  const SiteListPage({super.key});

  @override
  State<SiteListPage> createState() => _SiteListPageState();
}

class _SiteListPageState extends State<SiteListPage> {
  bool isGridView = false;
  final SiteService _service = SiteService();
  List<SiteModel> _sites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  Future<void> _loadSites() async {
    setState(() => _isLoading = true);
    try {
      final sites = await _service.getSites();
      if (mounted) {
        setState(() {
          _sites = sites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            toolbarHeight: 72,
            backgroundColor: AppColors.background,
            surfaceTintColor: AppColors.background,
            title: Text(
              "Project Sites",
              style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isGridView ? Icons.format_list_bulleted_rounded : Icons.grid_view_rounded,
                ),
                onPressed: () => setState(() => isGridView = !isGridView),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadSites,
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_sites.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.architecture_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text("No project sites found", style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: isGridView ? _buildSiteGrid() : _buildSiteList(),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton.extended(
          heroTag: 'site_list_fab',
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SiteCreatePage()),
            );
            if (result == true) {
              _loadSites();
            }
          },
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.add_location_alt_rounded),
          label: const Text("New Site", style: TextStyle(fontWeight: FontWeight.w700)),
        ),
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
        (context, index) => _buildSiteGridCard(context, index, _sites[index]),
        childCount: _sites.length,
      ),
    );
  }

  Widget _buildSiteList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildSiteListCard(context, index, _sites[index]),
        ),
        childCount: _sites.length,
      ),
    );
  }

  Widget _buildSiteGridCard(BuildContext context, int index, SiteModel site) {
    bool active = site.status != 'COMPLETED' && site.status != 'ON_HOLD';
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SiteCreatePage(site: site)),
        );
        if (result == true) {
          _loadSites();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.business_rounded, color: AppColors.textSecondary, size: 20),
                  _statusDot(active, site.status),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(site.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(site.code, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildProgressFooter(0.0, "₹0.00"), // Stubbed fields since not in basic API response
          ],
        ),
      ),
    );
  }

  Widget _buildSiteListCard(BuildContext context, int index, SiteModel site) {
    bool active = site.status != 'COMPLETED' && site.status != 'ON_HOLD';
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SiteCreatePage(site: site)),
        );
        if (result == true) {
          _loadSites();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.architecture_rounded, color: AppColors.textSecondary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(site.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        Text(site.code, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  _statusDot(active, site.status),
                ],
              ),
            ),
            _buildProgressFooter(0.0, "₹0.00"), // Stubbed fields
          ],
        ),
      ),
    );
  }

  Widget _buildProgressFooter(double progress, String budget) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text("Budget: $budget", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const Spacer(),
              Text("${(progress * 100).toInt()}%", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white,
              color: AppColors.accent,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusDot(bool active, String statusName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (active ? AppColors.success : AppColors.warning).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusName,
        style: TextStyle(
          color: active ? AppColors.success : AppColors.warning,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}