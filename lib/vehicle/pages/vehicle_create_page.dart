import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/vehicle_models.dart';
import '../services/vehicle_service.dart';
import '../../auth/services/token_manager.dart';

class VehicleCreatePage extends StatefulWidget {
  final VehicleModel? vehicle;
  const VehicleCreatePage({super.key, this.vehicle});

  @override
  State<VehicleCreatePage> createState() => _VehicleCreatePageState();
}

class _VehicleCreatePageState extends State<VehicleCreatePage> {
  final _formKey = GlobalKey<FormState>();
  
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _vinController = TextEditingController();
  final _yearController = TextEditingController();
  final _vehicleTypeController = TextEditingController();

  // Contact info controllers
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactAddressController = TextEditingController();
  String? _selectedContactType;

  // Payment option controllers
  final _paymentRateController = TextEditingController();
  final _currencyController = TextEditingController(text: 'INR');
  final _paymentTermsController = TextEditingController();
  String? _selectedPaymentType;

  bool _isActive = true;
  bool _isLoading = false;
  List<Map<String, dynamic>> _contactTypes = [];
  List<Map<String, dynamic>> _paymentTypes = [];

  final VehicleService _service = VehicleService();

  @override
  void initState() {
    super.initState();
    _fetchTypes();
    if (widget.vehicle != null) {
      _makeController.text = widget.vehicle!.make;
      _modelController.text = widget.vehicle!.model;
      _licensePlateController.text = widget.vehicle!.licensePlate;
      _vinController.text = widget.vehicle!.vin ?? '';
      _yearController.text = widget.vehicle!.year?.toString() ?? '';
      _vehicleTypeController.text = widget.vehicle!.vehicleType;
      _isActive = widget.vehicle!.isActive;

      if (widget.vehicle!.contactInfo != null) {
        _contactNameController.text = widget.vehicle!.contactInfo!.name;
        _contactPhoneController.text = widget.vehicle!.contactInfo!.phoneNumber;
        _contactEmailController.text = widget.vehicle!.contactInfo!.email ?? '';
        _contactAddressController.text = widget.vehicle!.contactInfo!.address;
        _selectedContactType = widget.vehicle!.contactInfo!.contactType;
      }

      if (widget.vehicle!.paymentOption != null) {
        _paymentRateController.text = widget.vehicle!.paymentOption!.rate.toString();
        _currencyController.text = widget.vehicle!.paymentOption!.currency;
        _paymentTermsController.text = widget.vehicle!.paymentOption!.terms;
        _selectedPaymentType = widget.vehicle!.paymentOption!.paymentType;
      }
    }
  }

  Future<void> _fetchTypes() async {
    final orgId = await TokenManager.getOrganizationId();
    final formData = await _service.getVehicleFormData(organizationId: orgId);
    if (mounted) {
      setState(() {
        _contactTypes = List<Map<String, dynamic>>.from(formData['contact_types'] ?? []);
        _paymentTypes = List<Map<String, dynamic>>.from(formData['payment_types'] ?? []);
        
        if (_selectedContactType == null && _contactTypes.isNotEmpty) {
          _selectedContactType = _contactTypes.first['id']?.toString();
        }
        if (_selectedPaymentType == null && _paymentTypes.isNotEmpty) {
          _selectedPaymentType = _paymentTypes.first['id']?.toString();
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final orgIdRef = await TokenManager.getOrganizationId();
      final data = {
        "organization": widget.vehicle?.organization ?? orgIdRef,
        "make": _makeController.text.trim(),
        "model": _modelController.text.trim(),
        "license_plate": _licensePlateController.text.trim().toUpperCase(),
        "vin": _vinController.text.isEmpty ? null : _vinController.text.trim().toUpperCase(),
        "year": int.tryParse(_yearController.text),
        "vehicle_type": _vehicleTypeController.text.trim(),
        "is_active": _isActive,
        "contact_info": {
          "name": _contactNameController.text.trim(),
          "phone_number": _contactPhoneController.text.trim(),
          "email": _contactEmailController.text.isEmpty ? null : _contactEmailController.text.trim(),
          "address": _contactAddressController.text.trim(),
          "contact_type": _selectedContactType,
        },
        "payment_option": {
          "rate": _paymentRateController.text.trim(),
          "currency": _currencyController.text.trim(),
          "terms": _paymentTermsController.text.trim(),
          "payment_type": _selectedPaymentType,
        }
      };

      if (widget.vehicle != null) {
        await _service.updateVehicle(widget.vehicle!.id, data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vehicle updated successfully!")));
          Navigator.pop(context, true);
        }
      } else {
        await _service.createVehicle(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vehicle registered successfully!")));
          Navigator.pop(context, true); 
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _licensePlateController.dispose();
    _vinController.dispose();
    _yearController.dispose();
    _vehicleTypeController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _contactAddressController.dispose();
    _paymentRateController.dispose();
    _currencyController.dispose();
    _paymentTermsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.vehicle != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? "Edit Vehicle" : "Register Vehicle", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Core Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _makeController,
                        decoration: _buildInputDecoration("Make", "e.g. Ford"),
                        validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _modelController,
                        decoration: _buildInputDecoration("Model", "e.g. F-150"),
                        validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration("Year", "e.g. 2024"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _vehicleTypeController,
                        decoration: _buildInputDecoration("Type", "e.g. Truck"),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                const Text("Identification", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _licensePlateController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: _buildInputDecoration("License Plate", "123-ABC"),
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vinController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: _buildInputDecoration("VIN (Optional)", "17-character ID"),
                ),

                const SizedBox(height: 32),
                const Text("Contact Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactNameController,
                  decoration: _buildInputDecoration("Contact Name", "e.g. Primary Owner"),
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _contactPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _buildInputDecoration("Phone", "e.g. +91..."),
                        validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedContactType,
                        decoration: _buildInputDecoration("Type", ""),
                        items: _contactTypes.map((t) => DropdownMenuItem<String>(
                          value: t['id']?.toString(),
                          child: Text(t['name']),
                        )).toList(),
                        onChanged: (val) => setState(() => _selectedContactType = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration("Email (Optional)", "e.g. owner@example.com"),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactAddressController,
                  maxLines: 2,
                  decoration: _buildInputDecoration("Address", "Full address"),
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 32),
                const Text("Payment & Rates", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _paymentRateController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration("Rate", "e.g. 1500"),
                        validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPaymentType,
                        decoration: _buildInputDecoration("Frequency", ""),
                        items: _paymentTypes.map((t) => DropdownMenuItem<String>(
                          value: t['id']?.toString(),
                          child: Text(t['name']),
                        )).toList(),
                        onChanged: (val) => setState(() => _selectedPaymentType = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _paymentTermsController,
                  maxLines: 2,
                  decoration: _buildInputDecoration("Terms", "e.g. Daily rental, Net 30"),
                ),

                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
                  ),
                  child: SwitchListTile(
                    title: const Text("Active Status", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    subtitle: const Text("Is this vehicle currently in service?", style: TextStyle(fontSize: 12)),
                    value: _isActive,
                    onChanged: (val) => setState(() => _isActive = val),
                    activeColor: AppColors.success,
                  ),
                ),
                
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: Text(isEditing ? "Update Vehicle" : "Register Vehicle", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  InputDecoration _buildInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label, 
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
    );
  }
}
