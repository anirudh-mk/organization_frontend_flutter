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
  late Future<List<SiteModel>> _sitesFuture;
  List<SiteModel> _allSites = [];
  List<SiteModel> _displaySites = [];

  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'All'; // All, Planning, Active, On Hold, Completed

  @override
  void initState() {
    super.initState();
    _loadSites();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSites() {
    setState(() {
      _sitesFuture = _fetchSites();
    });
  }

  Future<List<SiteModel>> _fetchSites() async {
    final sites = await _service.getSites();
    setState(() {
      _allSites = sites;
      _applyFilters();
    });
    return sites;
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _displaySites = _allSites.where((s) {
        final matchesSearch = s.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            s.code.toLowerCase().contains(_searchController.text.toLowerCase());

        bool matchesStatus = true;
        if (_filterStatus != 'All') {
          matchesStatus = s.status.toLowerCase() == _filterStatus.toLowerCase().replaceAll(' ', '_');
        }

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Future<void> _deleteSite(SiteModel site) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Site"),
        content: Text("Are you sure you want to delete ${site.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _service.deleteSite(site.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Site deleted successfully")));
          _loadSites();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
        }
      }
    }
  }

  void _showSiteDetails(SiteModel site) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.architecture_rounded, color: AppColors.primary, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(site.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("Code: ${site.code}", style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                _statusDot(site.status),
              ],
            ),
            const SizedBox(height: 32),
            _detailItem(Icons.info_outline, "Status", site.status.toUpperCase()),
            if (site.estimatedBudget != null) _detailItem(Icons.payments_outlined, "Budget", "₹${site.estimatedBudget}"),
            if (site.expectedStartDate != null) _detailItem(Icons.calendar_today_outlined, "Start Date", "${site.expectedStartDate!.day}/${site.expectedStartDate!.month}/${site.expectedStartDate!.year}"),
            if (site.expectedEndDate != null) _detailItem(Icons.event_outlined, "End Date", "${site.expectedEndDate!.day}/${site.expectedEndDate!.month}/${site.expectedEndDate!.year}"),

            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SiteCreatePage(site: site))
                      );
                      if (result == true) _loadSites();
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text("Edit"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteSite(site);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text("Delete"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
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
            title: Text("Project Sites", style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20)),
            actions: [
              IconButton(
                icon: Icon(isGridView ? Icons.format_list_bulleted_rounded : Icons.grid_view_rounded),
                onPressed: () => setState(() => isGridView = !isGridView),
                style: IconButton.styleFrom(backgroundColor: colorScheme.surface),
              ),
              const SizedBox(width: 16),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search by name or code...",
                      prefixIcon: const Icon(Icons.search_rounded, size: 22),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.1))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.1))),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Planning', 'Active', 'On Hold', 'Completed'].map((status) {
                        final isSelected = _filterStatus == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ChoiceChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _filterStatus = status;
                                  _applyFilters();
                                });
                              }
                            },
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                            selectedColor: AppColors.accent,
                            backgroundColor: Colors.white,
                            checkmarkColor: Colors.white,
                            side: BorderSide(color: isSelected ? AppColors.accent : AppColors.textMuted.withValues(alpha: 0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: isSelected ? 2 : 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          FutureBuilder<List<SiteModel>>(
            future: _sitesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && _allSites.isEmpty) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError && _allSites.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                        const SizedBox(height: 16),
                        Text("Error loading data", style: theme.textTheme.titleMedium),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadSites, child: const Text("Retry"))
                      ],
                    ),
                  ),
                );
              }

              if (_displaySites.isEmpty) {
                return const SliverFillRemaining(child: Center(child: Text("No sites found matching filters.")));
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: isGridView
                    ? _buildGrid(_displaySites)
                    : _buildList(_displaySites),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: FloatingActionButton.extended(
          heroTag: 'site_list_fab',
          onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const SiteCreatePage()));
            if (result == true) _loadSites();
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

  Widget _buildGrid(List<SiteModel> sites) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final site = sites[index];
          return GestureDetector(
            onTap: () => _showSiteDetails(site),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.04), blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.architecture_rounded, color: AppColors.textSecondary, size: 20),
                        ),
                        _statusDot(site.status),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(site.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text("Code: ${site.code}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: sites.length,
      ),
    );
  }

  Widget _buildList(List<SiteModel> sites) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final site = sites[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: Key(site.id),
              direction: DismissDirection.horizontal,
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  await _deleteSite(site);
                  return false;
                } else if (direction == DismissDirection.startToEnd) {
                  final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SiteCreatePage(site: site))
                  );
                  if (result == true) _loadSites();
                  return false;
                }
                return false;
              },
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.edit, color: Colors.white),
              ),
              secondaryBackground: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: GestureDetector(
                onTap: () => _showSiteDetails(site),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.03), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.architecture_rounded, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(site.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), overflow: TextOverflow.ellipsis),
                            Text("Code: ${site.code}", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      _statusDot(site.status),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        childCount: sites.length,
      ),
    );
  }

  Widget _statusDot(String status) {
    status = status.toLowerCase();
    Color color = AppColors.textSecondary;
    String label = status.toUpperCase();

    if (status == 'active') {
      color = AppColors.success;
    } else if (status == 'planning') {
      color = Colors.blue;
    } else if (status == 'on_hold') {
      color = AppColors.warning;
    } else if (status == 'completed') {
      color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
