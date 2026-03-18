import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/equipment_model.dart';
import '../services/equipment_service.dart';
import '../../vendor/models/vendor_model.dart';
import '../../vendor/services/vendor_service.dart';

class EquipmentCreatePage extends StatefulWidget {
  final EquipmentModel? equipment;

  const EquipmentCreatePage({super.key, this.equipment});

  @override
  State<EquipmentCreatePage> createState() => _EquipmentCreatePageState();
}

class _EquipmentCreatePageState extends State<EquipmentCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final EquipmentService _service = EquipmentService();
  final VendorService _vendorService = VendorService();

  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _purchaseDateController;
  late TextEditingController _purchaseCostController;
  
  // Rental controllers
  late TextEditingController _rentalStartDateController;
  late TextEditingController _rentalEndDateController;
  late TextEditingController _rentalRateController;
  late TextEditingController _securityDepositController;

  String? _selectedCategoryId;
  String? _selectedStatusId;
  String? _selectedOwnershipTypeId;
  String? _selectedVendorId;
  bool _isActive = true;

  List<EquipmentCategoryModel> _categories = [];
  List<EquipmentStatusModel> _statuses = [];
  List<EquipmentOwnershipTypeModel> _ownershipTypes = [];
  List<VendorModel> _vendors = [];

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.equipment?.name);
    _codeController = TextEditingController(text: widget.equipment?.code);
    _purchaseDateController = TextEditingController(text: widget.equipment?.purchaseDate);
    _purchaseCostController = TextEditingController(text: widget.equipment?.purchaseCost);
    
    _rentalStartDateController = TextEditingController(text: widget.equipment?.rentalDetails?.rentalStartDate);
    _rentalEndDateController = TextEditingController(text: widget.equipment?.rentalDetails?.rentalEndDate);
    _rentalRateController = TextEditingController(text: widget.equipment?.rentalDetails?.rentalRatePerDay);
    _securityDepositController = TextEditingController(text: widget.equipment?.rentalDetails?.securityDeposit);

    _selectedCategoryId = widget.equipment?.categoryId;
    _selectedStatusId = widget.equipment?.statusId;
    _selectedOwnershipTypeId = widget.equipment?.ownershipTypeId;
    _selectedVendorId = widget.equipment?.rentalDetails?.vendorId;
    _isActive = widget.equipment?.isActive ?? true;

    _loadLookups();
  }

  Future<void> _loadLookups() async {
    try {
      final results = await Future.wait([
        _service.getCategories(),
        _service.getStatuses(),
        _service.getOwnershipTypes(),
        _vendorService.getVendors(),
        if (widget.equipment == null) _service.getNextCode() else Future.value(''),
      ]);

      setState(() {
        _categories = results[0] as List<EquipmentCategoryModel>;
        _statuses = results[1] as List<EquipmentStatusModel>;
        _ownershipTypes = results[2] as List<EquipmentOwnershipTypeModel>;
        _vendors = results[3] as List<VendorModel>;
        if (widget.equipment == null) _codeController.text = results[4] as String;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading data: $e")));
      }
      setState(() => _isLoading = false);
    }
  }

  bool get _isRental => _ownershipTypes.any((t) => t.id == _selectedOwnershipTypeId && t.code.toLowerCase() == 'rental');

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final data = {
        'name': _nameController.text,
        'code': _codeController.text,
        'category': _selectedCategoryId,
        'status': _selectedStatusId,
        'ownership_type': _selectedOwnershipTypeId,
        'purchase_date': _purchaseDateController.text.isEmpty ? null : _purchaseDateController.text,
        'purchase_cost': _purchaseCostController.text.isEmpty ? null : _purchaseCostController.text,
        'is_active': _isActive,
      };

      if (_isRental) {
        data['rental_details'] = {
          'vendor': _selectedVendorId,
          'rental_start_date': _rentalStartDateController.text,
          'rental_end_date': _rentalEndDateController.text.isEmpty ? null : _rentalEndDateController.text,
          'rental_rate_per_day': _rentalRateController.text,
          'security_deposit': _securityDepositController.text.isEmpty ? null : _securityDepositController.text,
        };
      }

      if (widget.equipment == null) {
        await _service.createEquipment(data);
      } else {
        await _service.updateEquipment(widget.equipment!.id, data);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.equipment == null ? "Register Gear" : "Edit Equipment"),
        actions: [
          if (_isSaving)
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
          else
            TextButton(onPressed: _save, child: const Text("SAVE", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Basic Information"),
              _buildTextField(_nameController, "Equipment Name", Icons.settings, true),
              const SizedBox(height: 16),
              _buildTextField(_codeController, "Asset Code", Icons.tag, true),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                label: "Category",
                value: _selectedCategoryId,
                items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
                icon: Icons.category_rounded,
              ),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                label: "Status",
                value: _selectedStatusId,
                items: _statuses.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (val) => setState(() => _selectedStatusId = val),
                icon: Icons.info_outline_rounded,
              ),
              const SizedBox(height: 16),
              _buildDropdown<String>(
                label: "Ownership",
                value: _selectedOwnershipTypeId,
                items: _ownershipTypes.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                onChanged: (val) => setState(() => _selectedOwnershipTypeId = val),
                icon: Icons.vpn_key_rounded,
              ),

              const SizedBox(height: 32),
              _buildSectionTitle("Purchase Details"),
              _buildTextField(_purchaseDateController, "Purchase Date (YYYY-MM-DD)", Icons.calendar_today, false),
              const SizedBox(height: 16),
              _buildTextField(_purchaseCostController, "Purchase Cost", Icons.currency_rupee, false, keyboardType: TextInputType.number),

              if (_isRental) ...[
                const SizedBox(height: 32),
                _buildSectionTitle("Rental Information"),
                _buildDropdown<String>(
                  label: "Vendor",
                  value: _selectedVendorId,
                  items: _vendors.map((v) => DropdownMenuItem(value: v.id, child: Text(v.name))).toList(),
                  onChanged: (val) => setState(() => _selectedVendorId = val),
                  icon: Icons.business_rounded,
                ),
                const SizedBox(height: 16),
                _buildTextField(_rentalStartDateController, "Rental Start (YYYY-MM-DD)", Icons.calendar_today, true),
                const SizedBox(height: 16),
                _buildTextField(_rentalRateController, "Daily Rental Rate", Icons.payments_rounded, true, keyboardType: TextInputType.number),
              ],
              
              const SizedBox(height: 32),
              SwitchListTile(
                title: const Text("Active In Fleet", style: TextStyle(fontWeight: FontWeight.w600)),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
                activeColor: AppColors.primary,
              ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool required, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      validator: (val) => required && (val == null || val.isEmpty) ? "Field required" : null,
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
      validator: (val) => val == null ? "Field required" : null,
    );
  }
}