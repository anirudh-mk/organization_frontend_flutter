import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/subcontractor_model.dart';
import '../services/subcontractor_service.dart';
import 'subcontractor_create_page.dart';

class SubcontractorListPage extends StatefulWidget {
  const SubcontractorListPage({super.key});

  @override
  State<SubcontractorListPage> createState() => _SubcontractorListPageState();
}

class _SubcontractorListPageState extends State<SubcontractorListPage> {
  final SubcontractorService _service = SubcontractorService();
  List<SubcontractorModel> _subcontractors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubcontractors();
  }

  Future<void> _loadSubcontractors() async {
    setState(() => _isLoading = true);
    try {
      final subcontractors = await _service.getSubcontractors();
      if (mounted) {
        setState(() {
          _subcontractors = subcontractors;
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text("Subcontractors", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            backgroundColor: AppColors.background,
            scrolledUnderElevation: 0,
            floating: true,
            toolbarHeight: 72,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadSubcontractors,
              ),
              const SizedBox(width: 8),
            ],
          ),
          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_subcontractors.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.engineering_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text("No subcontractors found", style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final sub = _subcontractors[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.1)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.handshake_outlined, color: AppColors.accent),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          sub.name, 
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: sub.isActive ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          sub.isActive ? "Active" : "Inactive",
                                          style: TextStyle(
                                            color: sub.isActive ? AppColors.success : AppColors.error,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  if (sub.specialization.isNotEmpty) ...[
                                    Text(
                                      sub.specialization,
                                      style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  if (sub.contactPerson.isNotEmpty || sub.phone.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            "${sub.contactPerson} ${sub.phone.isNotEmpty ? '• ${sub.phone}' : ''}",
                                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                            maxLines: 1,
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
                  },
                  childCount: _subcontractors.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubcontractorCreatePage()),
          );
          if (result == true) {
            _loadSubcontractors();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Subcontractor", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
