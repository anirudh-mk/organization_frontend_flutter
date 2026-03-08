import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/vehicle_models.dart';
import '../services/vehicle_service.dart';
import 'vehicle_create_page.dart';

class VehicleListPage extends StatefulWidget {
  const VehicleListPage({super.key});

  @override
  State<VehicleListPage> createState() => _VehicleListPageState();
}

class _VehicleListPageState extends State<VehicleListPage> {
  bool isGridView = false;
  final VehicleService _service = VehicleService();
  List<VehicleModel> _allVehicles = [];
  List<VehicleModel> _displayVehicles = [];
  bool _isLoading = true;
  
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'All'; // All, Active, Inactive

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    try {
      final vehicles = await _service.getVehicles();
      if (mounted) {
        setState(() {
          _allVehicles = vehicles;
          _applyFilters();
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

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _displayVehicles = _allVehicles.where((v) {
        final matchesSearch = v.make.toLowerCase().contains(_searchController.text.toLowerCase()) || 
                             v.model.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                             v.licensePlate.toLowerCase().contains(_searchController.text.toLowerCase());
        
        bool matchesStatus = true;
        if (_filterStatus == 'Active') {
          matchesStatus = v.isActive;
        } else if (_filterStatus == 'Inactive') {
          matchesStatus = !v.isActive;
        }
        
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Future<void> _deleteVehicle(VehicleModel vehicle) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Vehicle"),
        content: Text("Are you sure you want to delete ${vehicle.make} ${vehicle.model} (${vehicle.licensePlate})?"),
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
        await _service.deleteVehicle(vehicle.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vehicle deleted successfully")));
          _loadVehicles();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
        }
      }
    }
  }

  void _showVehicleDetails(VehicleModel vehicle) {
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
                  child: const Icon(Icons.local_shipping_rounded, color: AppColors.primary, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${vehicle.make} ${vehicle.model}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("Plate: ${vehicle.licensePlate}", style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                _statusDot(vehicle.isActive),
              ],
            ),
            const SizedBox(height: 32),
            _detailItem(Icons.info_outline, "Type", vehicle.vehicleType),
            if (vehicle.year != null) _detailItem(Icons.calendar_today_outlined, "Year", vehicle.year.toString()),
            if (vehicle.vin != null && vehicle.vin!.isNotEmpty) _detailItem(Icons.fingerprint_outlined, "VIN", vehicle.vin!),
            
            if (vehicle.contactInfo != null) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),
              const Text("Contact Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              _detailItem(Icons.person_outline, "Name", vehicle.contactInfo!.name),
              _detailItem(Icons.phone_outlined, "Phone", vehicle.contactInfo!.phoneNumber),
              if (vehicle.contactInfo!.email != null) _detailItem(Icons.email_outlined, "Email", vehicle.contactInfo!.email!),
              _detailItem(Icons.location_on_outlined, "Address", vehicle.contactInfo!.address),
            ],

            if (vehicle.paymentOption != null) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),
              const Text("Payment Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              _detailItem(Icons.payments_outlined, "Rate", "${vehicle.paymentOption!.rate} ${vehicle.paymentOption!.currency}"),
              _detailItem(Icons.description_outlined, "Terms", vehicle.paymentOption!.terms),
            ],
            
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => VehicleCreatePage(vehicle: vehicle))
                      );
                      if (result == true) _loadVehicles();
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
                      _deleteVehicle(vehicle);
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.end),
        ],
      ),
    );
  }

  Widget _statusDot(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? AppColors.success : AppColors.error).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: isActive ? AppColors.success : AppColors.error, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(isActive ? "Active" : "Inactive", style: TextStyle(color: isActive ? AppColors.success : AppColors.error, fontSize: 10, fontWeight: FontWeight.w800)),
        ],
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
            title: Text("Vehicle Fleet", style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: Icon(isGridView ? Icons.format_list_bulleted_rounded : Icons.grid_view_rounded),
                onPressed: () => setState(() => isGridView = !isGridView),
                style: IconButton.styleFrom(backgroundColor: Colors.white),
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
                      hintText: "Search make, model, or plate...",
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
                      children: ['All', 'Active', 'Inactive'].map((status) {
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
                            selectedColor: AppColors.primary,
                            backgroundColor: Colors.white,
                            checkmarkColor: Colors.white,
                            side: BorderSide(color: isSelected ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.2)),
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

          if (_isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (_displayVehicles.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_car_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text("No vehicles found", style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: isGridView 
                ? _buildGrid(_displayVehicles)
                : _buildList(_displayVehicles),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VehicleCreatePage()),
            );
            if (result == true) {
              _loadVehicles();
            }
          },
          icon: const Icon(Icons.add),
          label: const Text("Add Vehicle", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildGrid(List<VehicleModel> vehicles) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final vehicle = vehicles[index];
          return GestureDetector(
            onTap: () => _showVehicleDetails(vehicle),
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
                          child: const Icon(Icons.local_shipping_rounded, color: AppColors.textSecondary, size: 20),
                        ),
                        _statusDot(vehicle.isActive),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${vehicle.make} ${vehicle.model}", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(vehicle.licensePlate, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: vehicles.length,
      ),
    );
  }

  Widget _buildList(List<VehicleModel> vehicles) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final vehicle = vehicles[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: Key(vehicle.id.toString()),
              direction: DismissDirection.horizontal,
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  await _deleteVehicle(vehicle);
                  return false;
                } else if (direction == DismissDirection.startToEnd) {
                  final result = await Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => VehicleCreatePage(vehicle: vehicle))
                  );
                  if (result == true) _loadVehicles();
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
                onTap: () => _showVehicleDetails(vehicle),
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
                        child: const Icon(Icons.local_shipping_rounded, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${vehicle.make} ${vehicle.model}", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), overflow: TextOverflow.ellipsis),
                            Text(vehicle.licensePlate, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      _statusDot(vehicle.isActive),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        childCount: vehicles.length,
      ),
    );
  }
}
