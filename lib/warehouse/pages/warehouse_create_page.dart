import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../shared/models/location_models.dart';
import '../../shared/services/location_service.dart';
import '../services/warehouse_service.dart';

class WarehouseCreatePage extends StatefulWidget {
  const WarehouseCreatePage({super.key});

  @override
  State<WarehouseCreatePage> createState() => _WarehouseCreatePageState();
}

class _WarehouseCreatePageState extends State<WarehouseCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  
  // Address controllers
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  bool _isPrimary = false;
  bool _isActive = true;
  bool _isLoading = false;

  final WarehouseService _service = WarehouseService();
  final LocationService _locationService = LocationService();

  List<CountryModel> _countries = [];
  List<StateModel> _states = [];
  List<DistrictModel> _districts = [];

  CountryModel? _selectedCountry;
  StateModel? _selectedState;
  DistrictModel? _selectedDistrict;

  bool _isLoadingLocations = true;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await _locationService.getCountries();
      if (mounted) {
        setState(() {
          _countries = countries;
          _isLoadingLocations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocations = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load countries: $e')));
      }
    }
  }

  Future<void> _onCountryChanged(CountryModel? country) async {
    setState(() {
      _selectedCountry = country;
      _selectedState = null;
      _selectedDistrict = null;
      _states = [];
      _districts = [];
    });
    
    if (country != null) {
      try {
        final states = await _locationService.getStates(country.id);
        if (mounted) {
          setState(() => _states = states);
        }
      } catch (e) {
        // Handle error implicitly
      }
    }
  }

  Future<void> _onStateChanged(StateModel? state) async {
    setState(() {
      _selectedState = state;
      _selectedDistrict = null;
      _districts = [];
    });
    
    if (state != null) {
      try {
        final districts = await _locationService.getDistricts(state.id);
        if (mounted) {
          setState(() => _districts = districts);
        }
      } catch (e) {
        // Handle error implicitly
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a District.")));
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      await _service.createWarehouse({
        "name": _nameController.text,
        "code": _codeController.text,
        "is_primary": _isPrimary,
        "is_active": _isActive,
        "address": {
          "address_line_1": _addressLine1Controller.text,
          "address_line_2": _addressLine2Controller.text,
          "city": _cityController.text,
          "postal_code": _postalCodeController.text,
          "district": _selectedDistrict!.id,
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Warehouse & Address created successfully!")));
        Navigator.pop(context, true); // Return true to indicate the list should refresh
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
    _nameController.dispose();
    _codeController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Warehouse", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
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
                const Text("Warehouse Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Warehouse Name", 
                    hintText: "e.g. Main Central Hub",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Name is required" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: "Warehouse Code", 
                    hintText: "e.g. WH-001",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Code is required" : null,
                ),
                
                const SizedBox(height: 32),
                const Text("Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressLine1Controller,
                  decoration: InputDecoration(
                    labelText: "Address Line 1", 
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Address is required" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressLine2Controller,
                  decoration: InputDecoration(
                    labelText: "Address Line 2 (Optional)", 
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          labelText: "City", 
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                        ),
                        validator: (value) => value == null || value.isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _postalCodeController,
                        decoration: InputDecoration(
                          labelText: "Postal Code", 
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                        ),
                        validator: (value) => value == null || value.isEmpty ? "Required" : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                _isLoadingLocations 
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<CountryModel>(
                            decoration: InputDecoration(
                              labelText: "Country", 
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                            ),
                            value: _selectedCountry,
                            items: _countries.map((country) => DropdownMenuItem(value: country, child: Text(country.name))).toList(),
                            onChanged: _onCountryChanged,
                            validator: (v) => v == null ? "Required" : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<StateModel>(
                            decoration: InputDecoration(
                              labelText: "State/Province", 
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                            ),
                            value: _selectedState,
                            items: _states.map((state) => DropdownMenuItem(value: state, child: Text(state.name))).toList(),
                            onChanged: _states.isNotEmpty ? _onStateChanged : null,
                            validator: (v) => v == null ? "Required" : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<DistrictModel>(
                            decoration: InputDecoration(
                              labelText: "District", 
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                            ),
                            value: _selectedDistrict,
                            items: _districts.map((district) => DropdownMenuItem(value: district, child: Text(district.name))).toList(),
                            onChanged: _districts.isNotEmpty ? (val) => setState(() => _selectedDistrict = val) : null,
                            validator: (v) => v == null ? "Required" : null,
                          ),
                        ],
                      ),

                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text("Primary Warehouse", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        subtitle: const Text("Set as main organizational hub", style: TextStyle(fontSize: 12)),
                        value: _isPrimary,
                        onChanged: (val) => setState(() => _isPrimary = val),
                        activeColor: AppColors.primary,
                      ),
                      Divider(height: 1, color: AppColors.textMuted.withValues(alpha: 0.1)),
                      SwitchListTile(
                        title: const Text("Active Status", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        subtitle: const Text("Is this warehouse operational?", style: TextStyle(fontSize: 12)),
                        value: _isActive,
                        onChanged: (val) => setState(() => _isActive = val),
                        activeColor: AppColors.success,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: const Text("Create Warehouse & Address", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
