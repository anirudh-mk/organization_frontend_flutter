import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/site_model.dart';
import '../../theme/app_theme.dart';
import '../../employee/models/employee_model.dart';
import '../../equipment/models/equipment_model.dart';
import '../services/site_service.dart';
import '../../shared/models/location_models.dart';
import 'site_create_page.dart';

class SiteDetailsPage extends StatefulWidget {
  final SiteModel site;

  const SiteDetailsPage({super.key, required this.site});

  @override
  State<SiteDetailsPage> createState() => _SiteDetailsPageState();
}

class _SiteDetailsPageState extends State<SiteDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SiteModel _site;
  final SiteService _siteService = SiteService();
  bool _isLoading = false;

  int _currentPhotoIndex = 0;
  final ImagePicker _picker = ImagePicker();

  // Theme constants
  late Color _bgColor;
  late Color _surfaceColor;
  late Color _cardColor;
  late Color _accentColor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _site = widget.site;
    _refreshSite();
    
    // Original app theme colors
    _bgColor = AppColors.background;
    _surfaceColor = Colors.white;
    _cardColor = Colors.white;
    _accentColor = AppColors.accent;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isLoading = true);
    try {
      await _siteService.updateSite(_site.id, {}, newImages: [image]);
      await _refreshSite();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo uploaded successfully.', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.accent));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload photo: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshSite() async {
    setState(() => _isLoading = true);
    try {
      final updatedSite = await _siteService.getSite(_site.id);
      setState(() {
        _site = updatedSite;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error refreshing site: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _site.photos.isNotEmpty 
        ? (_site.photos.first.image.startsWith('http') ? _site.photos.first.image : "http://127.0.0.1:8000${_site.photos.first.image}")
        : null;

    return Scaffold(
      backgroundColor: _bgColor,
      body: CustomScrollView(
        slivers: [
          // Immersive Header with Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.background,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: IconButton(
                    icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: _site.photos.length + 1,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPhotoIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      if (index == _site.photos.length) {
                        return GestureDetector(
                          onTap: _pickAndUploadPhoto,
                          child: Container(
                            color: AppColors.background,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_rounded, size: 48, color: AppColors.accent),
                                SizedBox(height: 16),
                                Text("Add Photo", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      final photo = _site.photos[index];
                      final url = photo.image.startsWith('http') ? photo.image : "http://127.0.0.1:8000${photo.image}";
                      return Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => _buildPlaceholder(),
                      );
                    },
                  ),
                  // Gradient removed by user request
                  if (_site.photos.isNotEmpty)
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_site.photos.length + 1, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: _currentPhotoIndex == index ? 20 : 6,
                            decoration: BoxDecoration(
                              color: _currentPhotoIndex == index ? AppColors.accent : AppColors.textSecondary.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Site Info Section
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.background,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _site.name, 
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 4),
                        Text("Code: ${_site.code}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text((_site.statusDetails?.name ?? _site.status).toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quick Action Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  _buildQuickAction(Icons.directions_rounded, "Directions"),
                  const SizedBox(width: 12),
                  _buildQuickAction(Icons.phone_rounded, "Call client"),
                  const SizedBox(width: 12),
                  _buildQuickAction(Icons.edit_rounded, "Edit Site", isPrimary: true),
                ],
              ),
            ),
          ),

          // Content Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.accent,
                indicatorWeight: 3,
                tabAlignment: TabAlignment.start,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: AppColors.background,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: const [
                  Tab(text: "Overview"),
                  Tab(text: "Client"),
                  Tab(text: "Team"),
                  Tab(text: "Equipment"),
                  Tab(text: "Documents"),
                  Tab(text: "Timeline"),
                ],
              ),
              AppColors.background,
            ),
          ),

          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildClientTab(),
                _buildTeamTab(),
                _buildEquipmentTab(),
                _buildDocumentsTab(),
                _buildTimelineTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showActionMenu,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: _bgColor,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _showAddProgressDialog,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Record Progress", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SiteCreatePage(site: _site))).then((_) => _refreshSite());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text("Edit Site", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard("Site Details", [
            _buildInfoRow(Icons.calendar_today_rounded, "Start Date", _site.expectedStartDate != null ? DateFormat('MMM dd, yyyy').format(_site.expectedStartDate!) : 'N/A'),
            _buildInfoRow(Icons.event_rounded, "End Date", _site.expectedEndDate != null ? DateFormat('MMM dd, yyyy').format(_site.expectedEndDate!) : 'N/A'),
            _buildInfoRow(Icons.payments_rounded, "Budget", _site.estimatedBudget != null ? "\$${_site.estimatedBudget!.toStringAsFixed(2)}" : 'N/A'),
          ]),
          const SizedBox(height: 24),
          _buildInfoCard("Notes", [
            Text(_site.notes ?? "No notes available for this site.", style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
          ]),
          const SizedBox(height: 24),
          if (_site.addresses.isNotEmpty) ...[
            _buildInfoCard("Location", [
              ..._site.addresses.map((addr) => _buildAddressItem(addr)),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildClientTab() {
    if (_site.clientLink == null || _site.clientLink!.client == null) {
      return _buildEmptyState(Icons.business_rounded, "No client details available.");
    }

    final client = _site.clientLink!.client!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard("Client Information", [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text("Code: ${client.code}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (client.isActive ? AppColors.success : AppColors.error).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    client.isActive ? "Active" : "Inactive",
                    style: TextStyle(color: client.isActive ? AppColors.success : AppColors.error, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 24),
          _buildInfoCard("Contact Details", [
            if (client.mobiles.isEmpty && client.emails.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("No phone numbers or emails linked to this client.", style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
              ),
            for (var m in client.mobiles) _buildInfoRow(Icons.phone_rounded, m.contactTypeName ?? "Mobile", m.number),
            for (var e in client.emails) _buildInfoRow(Icons.alternate_email_rounded, e.contactTypeName ?? "Email", e.email),
          ]),

          const SizedBox(height: 24),
          _buildInfoCard("Addresses", [
            if (client.addresses.isEmpty || client.addresses.where((ca) => ca.addressDetails != null).isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("No addresses on file for this client.", style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
              ),
            ...client.addresses.where((ca) => ca.addressDetails != null).map((ca) => _buildAddressItem(ca.addressDetails!)),
          ]),
        ],
      ),
    );
  }

  Widget _buildTeamTab() {
    if (_site.employees.isEmpty) {
      return _buildEmptyState(Icons.people_outline_rounded, "No team members assigned yet.");
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _site.employees.length,
      itemBuilder: (context, index) {
        final link = _site.employees[index];
        final emp = link.employee;
        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.background)),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: AppColors.background,
              child: Text(emp?.firstName.substring(0, 1).toUpperCase() ?? "?", style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
            ),
            title: Text(emp?.displayName ?? "Unknown Employee", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(emp?.jobRoleName ?? "No Role"),
            trailing: link.phaseId != null ? Chip(label: Text("Phase ${link.phaseId}"), backgroundColor: AppColors.background) : null,
          ),
        );
      },
    );
  }

  Widget _buildEquipmentTab() {
    if (_site.equipments.isEmpty) {
      return _buildEmptyState(Icons.construction_rounded, "No equipment assigned yet.");
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _site.equipments.length,
      itemBuilder: (context, index) {
        final link = _site.equipments[index];
        final eq = link.equipment;
        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.background)),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.construction_rounded, color: AppColors.accent),
            ),
            title: Text(eq?.name ?? "Unknown Equipment", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Code: ${eq?.code}"),
            trailing: link.phaseId != null ? Chip(label: Text("Phase ${link.phaseId}"), backgroundColor: AppColors.background) : null,
          ),
        );
      },
    );
  }

  Widget _buildTimelineTab() {
    if (_site.progressEntries.isEmpty) {
      return _buildEmptyState(Icons.timeline_rounded, "No progress entries recorded.");
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _site.progressEntries.length,
      itemBuilder: (context, index) {
        final entry = _site.progressEntries[index];
        return IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  ),
                  if (index != _site.progressEntries.length - 1)
                    Expanded(child: Container(width: 2, color: Colors.white12)),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${entry.percentage.toInt()}% Complete", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(DateFormat('MMM dd').format(entry.date), style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(entry.description ?? "Regular progress update", style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAction(IconData icon, String label, {bool isPrimary = false}) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (label == "Edit Site") {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SiteCreatePage(site: _site))).then((_) => _refreshSite());
          } else if (label == "Call client") {
            // Call logic
          } else if (label == "Directions") {
            // Maps logic
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isPrimary ? null : Border.all(color: AppColors.background),
            boxShadow: [
              if (!isPrimary) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: isPrimary ? Colors.white : AppColors.primary, size: 22),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: isPrimary ? Colors.white : AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.background),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const Spacer(),
          Text(value, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildAddressItem(AddressModel address) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.background),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(address.addressTypeName ?? "Site Address", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accent)),
                const SizedBox(height: 6),
                Text(address.line1, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                if (address.line2.isNotEmpty) Text(address.line2, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                Text("${address.city}${address.districtName != null ? ', ${address.districtName}' : ''}", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                if (address.postalCode.isNotEmpty) Text("Postal Code: ${address.postalCode}", style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Photos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          if (_site.photos.isEmpty)
            _buildEmptySection(Icons.photo_library_outlined, "No photos uploaded")
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: _site.photos.length,
              itemBuilder: (context, index) {
                final photo = _site.photos[index];
                final url = photo.image.startsWith('http') ? photo.image : "http://127.0.0.1:8000${photo.image}";
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(url, fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildPlaceholder()),
                );
              },
            ),
          const SizedBox(height: 32),
          Text("Attachments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          if (_site.attachments.isEmpty)
            _buildEmptySection(Icons.file_present_outlined, "No attachments found")
          else
            ..._site.attachments.map((att) => Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.background)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.insert_drive_file_rounded, color: AppColors.accent),
                ),
                title: Text(att.caption.isNotEmpty ? att.caption : "Attachment", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.download_rounded, color: AppColors.textMuted),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildEmptySection(IconData icon, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.background),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.textMuted.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textMuted.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  void _showActionMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Quick Actions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildActionItem(Icons.person_add_rounded, "Assign Employee", () {
              Navigator.pop(context);
              _showAssignDialog('employee');
            }),
            _buildActionItem(Icons.add_business_rounded, "Assign Equipment", () {
              Navigator.pop(context);
              _showAssignDialog('equipment');
            }),
            _buildActionItem(Icons.trending_up_rounded, "Add Progress", () {
              Navigator.pop(context);
              _showAddProgressDialog();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text(label),
      onTap: onTap,
    );
  }

  void _showAddProgressDialog() {
    final percentageController = TextEditingController(text: _site.progressEntries.isNotEmpty ? _site.progressEntries.first.percentage.toString() : "0");
    final descriptionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Record Progress"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: percentageController,
              decoration: const InputDecoration(labelText: "Percentage (%)", hintText: "0-100"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description", hintText: "Work done..."),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final percentage = double.tryParse(percentageController.text);
              if (percentage == null) return;
              Navigator.pop(context);
              try {
                await _siteService.recordProgress(
                  siteId: _site.id,
                  percentage: percentage,
                  description: descriptionController.text,
                );
                _refreshSite();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Progress recorded!"), backgroundColor: AppColors.success));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
              }
            },
            child: const Text("Record"),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(String type) async {
    final idController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Assign ${type.toUpperCase()}"),
        content: TextField(controller: idController, decoration: const InputDecoration(hintText: "Enter ID")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, idController.text), child: const Text("Assign")),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await _siteService.assignResource(siteId: _site.id, type: type, id: result);
        _refreshSite();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$type assigned!"), backgroundColor: AppColors.success));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
      }
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
      ),
      child: Center(child: Icon(Icons.architecture_rounded, size: 80, color: Colors.white.withOpacity(0.2))),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this._bgColor);

  final TabBar _tabBar;
  final Color _bgColor;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _bgColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
