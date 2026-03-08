import 'package:flutter/material.dart';
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
  final ClientService _service = ClientService();
  List<ClientModel> _clients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() => _isLoading = true);
    try {
      final clients = await _service.getClients();
      if (mounted) {
        setState(() {
          _clients = clients;
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
            title: const Text("Clients", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            backgroundColor: AppColors.background,
            scrolledUnderElevation: 0,
            floating: true,
            toolbarHeight: 72,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadClients,
              ),
              const SizedBox(width: 8),
            ],
          ),
          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_clients.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.handshake_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text("No clients found", style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
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
                    final client = _clients[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.1)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.business, color: AppColors.primary, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      client.name, 
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (client.isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    client.isActive ? "Active" : "Inactive",
                                    style: TextStyle(
                                      color: client.isActive ? AppColors.success : AppColors.error,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.tag_rounded, size: 14, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(client.code, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                const SizedBox(width: 16),
                                const Icon(Icons.phone_rounded, size: 14, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(client.phone.isNotEmpty ? client.phone : "N/A", style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              ],
                            ),
                            if (client.email.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.alternate_email_rounded, size: 14, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(client.email, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _clients.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ClientCreatePage()),
          );
          if (result == true) {
            _loadClients();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text("New Client", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
