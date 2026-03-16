import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../models/client_model.dart';
import '../services/client_service.dart';
import 'client_create_page.dart';

class ClientListPage extends StatefulWidget {
  const ClientListPage({super.key});

  @override
  State<ClientListPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {
  bool _isGridView = false;
  final ClientService _service = ClientService();
  late Future<List<ClientModel>> _clientsFuture;
  List<ClientModel> _allClients = [];
  List<ClientModel> _displayClients = [];
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadClients();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadClients() {
    setState(() {
      _clientsFuture = _fetchClients();
    });
  }

  Future<List<ClientModel>> _fetchClients() async {
    final clients = await _service.getClients();
    if (mounted) {
      setState(() {
        _allClients = clients;
        _applyFilters();
      });
    }
    return clients;
  }

  void _applyFilters() {
    setState(() {
      _displayClients = _allClients.where((c) {
        final q = _searchController.text.toLowerCase();
        final matchesSearch = c.name.toLowerCase().contains(q) ||
            c.code.toLowerCase().contains(q) ||
            c.primaryEmail.toLowerCase().contains(q);
        final matchesStatus = _filterStatus == 'All' ||
            (_filterStatus == 'Active' && c.isActive) ||
            (_filterStatus == 'Inactive' && !c.isActive);
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Future<void> _deleteClient(ClientModel client) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Client"),
        content: Text("Are you sure you want to delete ${client.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (result == true) {
      try {
        await _service.deleteClient(client.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Client deleted"), backgroundColor: AppColors.success),
          );
          _loadClients();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not launch $url"), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _callClient(String phone) => _launchUrl("tel:$phone");
  void _smsClient(String phone) => _launchUrl("sms:$phone");
  void _whatsappClient(String phone) {
    // Basic number cleaning (remove non-digits except +)
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    _launchUrl("https://wa.me/$cleanPhone");
  }

  void _editClient(ClientModel client) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ClientCreatePage(client: client)),
    );
    if (result == true) _loadClients();
  }

  void _showClientDetails(ClientModel client) {
    final addr = client.addresses.firstOrNull?.addressDetails;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.9,
        minChildSize: 0.35,
        builder: (ctx, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(24),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.textMuted.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.handshake_rounded, color: AppColors.primary, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(client.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("Code: ${client.code}", style: const TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  _statusBadge(client.isActive),
                ],
              ),
              const SizedBox(height: 24),
              _detailRow(Icons.info_outline, "Status", client.isActive ? "Active" : "Inactive"),
              
              for (var m in client.mobiles)
                _detailRow(Icons.phone_rounded, m.contactTypeName ?? "Mobile", m.number),
                
              for (var e in client.emails)
                _detailRow(Icons.alternate_email_rounded, e.contactTypeName ?? "Email", e.email),
              
              if (addr != null) ...[
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                const Text("Location Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                _detailRow(Icons.location_on_outlined, "Address", "${addr.line1}${addr.line2.isNotEmpty ? ', ' + addr.line2 : ''}"),
                _detailRow(Icons.location_city_outlined, "City", addr.city),
                _detailRow(Icons.pin_outlined, "Postal Code", addr.postalCode),
              ],

              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ClientCreatePage(client: client)),
                        );
                        if (result == true) _loadClients();
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
                      onPressed: () { Navigator.pop(ctx); _deleteClient(client); },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text("Delete"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error, foregroundColor: Colors.white,
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
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _statusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isActive ? "Active" : "Inactive",
        style: TextStyle(color: isActive ? AppColors.success : AppColors.error, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _statusDot(bool isActive) {
    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(
        color: isActive ? AppColors.success : AppColors.textMuted,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            toolbarHeight: 72,
            backgroundColor: AppColors.background,
            surfaceTintColor: AppColors.background,
            title: Text("Clients", style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20)),
            actions: [
              IconButton(
                icon: Icon(_isGridView ? Icons.format_list_bulleted_rounded : Icons.grid_view_rounded),
                onPressed: () => setState(() => _isGridView = !_isGridView),
                style: IconButton.styleFrom(backgroundColor: colorScheme.surface),
              ),
              const SizedBox(width: 16),
            ],
          ),

          // Search + filter chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search by name, code or email...",
                      prefixIcon: const Icon(Icons.search_rounded, size: 22),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.1))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.1))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Active', 'Inactive'].map((s) {
                        final sel = _filterStatus == s;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(s),
                            selected: sel,
                            onSelected: (v) { if (v) setState(() { _filterStatus = s; _applyFilters(); }); },
                            labelStyle: TextStyle(color: sel ? Colors.white : AppColors.textSecondary, fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 13),
                            selectedColor: AppColors.accent,
                            backgroundColor: Colors.white,
                            checkmarkColor: Colors.white,
                            side: BorderSide(color: sel ? AppColors.accent : AppColors.textMuted.withValues(alpha: 0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: sel ? 2 : 0,
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

          FutureBuilder<List<ClientModel>>(
            future: _clientsFuture,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && _allClients.isEmpty) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError && _allClients.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                      const SizedBox(height: 16),
                      Text("Error loading clients", style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadClients, child: const Text("Retry")),
                    ]),
                  ),
                );
              }
              if (_displayClients.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.handshake_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      const Text("No clients found", style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                    ]),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: _isGridView ? _buildGrid() : _buildList(),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: FloatingActionButton.extended(
          heroTag: 'client_list_fab',
          onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientCreatePage()));
            if (result == true) _loadClients();
          },
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text("New Client", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) {
          final c = _displayClients[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Slidable(
              key: ValueKey(c.id),
              startActionPane: ActionPane(
                motion: const BehindMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => _editClient(c),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                  if (c.primaryPhone.isNotEmpty) ...[
                    SlidableAction(
                      onPressed: (_) => _callClient(c.primaryPhone),
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      icon: Icons.phone,
                      label: 'Call',
                    ),
                    SlidableAction(
                      onPressed: (_) => _smsClient(c.primaryPhone),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      icon: Icons.message,
                      label: 'SMS',
                    ),
                    SlidableAction(
                      onPressed: (_) => _whatsappClient(c.primaryPhone),
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      icon: FontAwesomeIcons.whatsapp,
                      label: 'WhatsApp',
                    ),
                  ],
                ],
              ),
              endActionPane: ActionPane(
                motion: const BehindMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => _deleteClient(c),
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () => _showClientDetails(c),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.03), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.handshake_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(c.code, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            if (c.primaryPhone.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(children: [
                                  const Icon(Icons.phone_rounded, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Text(c.primaryPhone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ]),
                              ),
                            if (c.primaryEmail.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(children: [
                                  const Icon(Icons.alternate_email_rounded, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Text(c.primaryEmail, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ]),
                              ),
                          ],
                        ),
                      ),
                      _statusDot(c.isActive),
                      if (c.primaryPhone.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _actionButton(Icons.phone_rounded, Colors.indigo, () => _callClient(c.primaryPhone)),
                        const SizedBox(width: 6),
                        _actionButton(Icons.message_rounded, Colors.orange, () => _smsClient(c.primaryPhone)),
                        const SizedBox(width: 6),
                        _actionButton(FontAwesomeIcons.whatsapp, const Color(0xFF25D366), () => _whatsappClient(c.primaryPhone)),
                      ],
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        childCount: _displayClients.length,
      ),
    );
  }

  Widget _buildGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (ctx, i) {
          final c = _displayClients[i];
          return GestureDetector(
            onTap: () => _showClientDetails(c),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.handshake_rounded, color: AppColors.primary, size: 22),
                      ),
                      _statusDot(c.isActive),
                    ],
                  ),
                  const Spacer(),
                  Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(c.code, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  const SizedBox(height: 8),
                  if (c.primaryPhone.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _actionButton(Icons.phone_rounded, Colors.indigo, () => _callClient(c.primaryPhone)),
                          const SizedBox(width: 8),
                          _actionButton(Icons.message_rounded, Colors.orange, () => _smsClient(c.primaryPhone)),
                          const SizedBox(width: 8),
                          _actionButton(FontAwesomeIcons.whatsapp, const Color(0xFF25D366), () => _whatsappClient(c.primaryPhone)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        childCount: _displayClients.length,
      ),
    );
  }
}
