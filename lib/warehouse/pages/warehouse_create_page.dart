import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../shared/models/location_models.dart';
import '../../shared/services/location_service.dart';
import '../services/warehouse_service.dart';

import '../models/warehouse_model.dart';

class WarehouseCreatePage extends StatefulWidget {
  final WarehouseModel? warehouse;
  const WarehouseCreatePage({super.key, this.warehouse});

  @override
  State<WarehouseCreatePage> createState() => _WarehouseCreatePageState();
}

class _WarehouseCreatePageState extends State<WarehouseCreatePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _postalCodeController;

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
    _isPrimary = widget.warehouse?.isPrimary ?? false;
    _isActive = widget.warehouse?.isActive ?? true;

    var addr = widget.warehouse?.addressList.firstOrNull?.addressDetails;
    _nameController = TextEditingController(text: widget.warehouse?.name);
    _codeController = TextEditingController(text: widget.warehouse?.code);
    _addressLine1Controller = TextEditingController(text: addr?.line1);
    _addressLine2Controller = TextEditingController(text: addr?.line2);
    _cityController = TextEditingController(text: addr?.city);
    _postalCodeController = TextEditingController(text: addr?.postalCode);

    _initLocations(addr);
  }

  Future<void> _initLocations(AddressModel? addr) async {
    try {
      final countries = await _locationService.getCountries();
      if (!mounted) return;
      
      CountryModel? matchedCountry;
      if (addr?.countryId != null) {
        matchedCountry = countries.where((c) => c.id == addr!.countryId).firstOrNull;
      }

      setState(() {
        _countries = countries;
        _selectedCountry = matchedCountry;
        _isLoadingLocations = matchedCountry != null; // Keep loading if we need to fetch states
      });

      if (matchedCountry != null && addr?.stateId != null) {
        final states = await _locationService.getStates(matchedCountry.id);
        if (!mounted) return;
        
        StateModel? matchedState = states.where((s) => s.id == addr!.stateId).firstOrNull;
        
        setState(() {
          _states = states;
          _selectedState = matchedState;
        });

        if (matchedState != null && addr?.districtId != null) {
          final districts = await _locationService.getDistricts(matchedState.id);
          if (!mounted) return;
          
          DistrictModel? matchedDistrict = districts.where((d) => d.id == addr!.districtId).firstOrNull;
          
          setState(() {
            _districts = districts;
            _selectedDistrict = matchedDistrict;
            _isLoadingLocations = false;
          });
        } else {
          setState(() => _isLoadingLocations = false);
        }
      } else {
        setState(() => _isLoadingLocations = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocations = false);
      }
    }
  }

  Future<void> _loadCountries() async {
    // Already doing in initState/_initLocations
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
      } catch (e) {}
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
      } catch (e) {}
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDistrict == null && widget.warehouse == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a District.")));
       return;
    }
    
    setState(() => _isLoading = true);
    try {
      final data = {
        "name": _nameController.text,
        "code": _codeController.text,
        "is_primary": _isPrimary,
        "is_active": _isActive,
        "address": {
          "address_line_1": _addressLine1Controller.text,
          "address_line_2": _addressLine2Controller.text,
          "city": _cityController.text,
          "postal_code": _postalCodeController.text,
        }
      };

      if (_selectedDistrict != null) {
        (data["address"] as Map)["district"] = _selectedDistrict!.id;
      }

      if (widget.warehouse != null) {
        await _service.updateWarehouse(widget.warehouse!.id, data);
      } else {
        await _service.createWarehouse(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.warehouse != null ? "Warehouse updated successfully!" : "Warehouse created successfully!")));
        Navigator.pop(context, true);
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
        title: Text(widget.warehouse != null ? "Edit Warehouse" : "New Warehouse", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                    child: Text(widget.warehouse != null ? "Update Warehouse" : "Create Warehouse & Address", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
