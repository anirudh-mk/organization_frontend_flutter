import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../services/client_service.dart';
import '../../shared/models/location_models.dart';
import '../../shared/services/location_service.dart';

class ClientCreatePage extends StatefulWidget {
  const ClientCreatePage({super.key});

  @override
  State<ClientCreatePage> createState() => _ClientCreatePageState();
}

class _ClientCreatePageState extends State<ClientCreatePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Identity
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isActive = true;

  // Address
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  // Primary Contact
  final _contactNameController = TextEditingController();
  final _contactDesignationController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();

  final ClientService _clientService = ClientService();
  final LocationService _locationService = LocationService();
  
  bool _isLoading = false;

  // Location Data
  List<CountryModel> _countries = [];
  List<StateModel> _states = [];
  List<DistrictModel> _districts = [];
  List<AddressTypeModel> _addressTypes = [];

  CountryModel? _selectedCountry;
  StateModel? _selectedState;
  DistrictModel? _selectedDistrict;
  AddressTypeModel? _selectedAddressType;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        _locationService.getCountries(),
        _locationService.getAddressTypes(),
      ]);
      setState(() {
        _countries = futures[0] as List<CountryModel>;
        _addressTypes = futures[1] as List<AddressTypeModel>;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading location data: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        final st = await _locationService.getStates(country.id);
        setState(() => _states = st);
      } catch (e) {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching states: $e")));
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
        final dist = await _locationService.getDistricts(state.id);
        setState(() => _districts = dist);
      } catch (e) {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching districts: $e")));
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDistrict == null || _selectedAddressType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select Address Type and District.")));
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> data = {
        "name": _nameController.text.trim(),
        "code": _codeController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "is_active": _isActive,
        "addresses": [
          {
            "address_type": _selectedAddressType!.id,
            "address_line_1": _addressLine1Controller.text.trim(),
            "address_line_2": _addressLine2Controller.text.trim(),
            "district": _selectedDistrict!.id,
            "city": _cityController.text.trim(),
            "postal_code": _postalCodeController.text.trim(),
            "is_primary": true
          }
        ],
        "contacts": []
      };

      if (_contactNameController.text.trim().isNotEmpty) {
        data["contacts"].add({
          "name": _contactNameController.text.trim(),
          "designation": _contactDesignationController.text.trim(),
          "phone": _contactPhoneController.text.trim(),
          "email": _contactEmailController.text.trim(),
          "is_primary": true
        });
      }

      await _clientService.createClient(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Client created successfully!")));
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
    _emailController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _contactNameController.dispose();
    _contactDesignationController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Client"),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SectionTitle(title: "Client Identity"),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration("Client Name", Icons.business_rounded),
                  validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codeController,
                  decoration: _buildInputDecoration("Client Code (Unique)", Icons.tag_rounded),
                  validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: _buildInputDecoration("HQ Email", Icons.alternate_email_rounded),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: _buildInputDecoration("HQ Phone", Icons.phone_android_rounded),
                  keyboardType: TextInputType.phone,
                ),
                SwitchListTile(
                  title: const Text("Is Active Client?", style: TextStyle(fontWeight: FontWeight.w600)),
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 32),
                const _SectionTitle(title: "Primary HQ Address"),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<AddressTypeModel>(
                  value: _selectedAddressType,
                  decoration: _buildInputDecoration("Address Type", Icons.local_offer_rounded),
                  items: _addressTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                  onChanged: (val) => setState(() => _selectedAddressType = val),
                  validator: (v) => v == null ? "Required" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressLine1Controller,
                  decoration: _buildInputDecoration("Address Line 1", Icons.signpost_rounded),
                  validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressLine2Controller,
                  decoration: _buildInputDecoration("Address Line 2 (Optional)", Icons.signpost_rounded),
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<CountryModel>(
                  value: _selectedCountry,
                  decoration: _buildInputDecoration("Country", Icons.public_rounded),
                  items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                  onChanged: _onCountryChanged,
                  validator: (v) => v == null ? "Required" : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<StateModel>(
                  value: _selectedState,
                  decoration: _buildInputDecoration("State", Icons.map_rounded),
                  items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                  onChanged: _states.isEmpty ? null : _onStateChanged,
                  validator: (v) => v == null ? "Required" : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DistrictModel>(
                  value: _selectedDistrict,
                  decoration: _buildInputDecoration("District", Icons.location_city_rounded),
                  items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
                  onChanged: _districts.isEmpty ? null : (val) => setState(() => _selectedDistrict = val),
                  validator: (v) => v == null ? "Required" : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: _buildInputDecoration("City", Icons.location_on_rounded),
                        validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _postalCodeController,
                        decoration: _buildInputDecoration("Postal Code", Icons.markunread_mailbox_rounded),
                        validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                
                const _SectionTitle(title: "Primary Contact Person (Optional)"),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactNameController,
                  decoration: _buildInputDecoration("Full Name", Icons.person_rounded),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactDesignationController,
                  decoration: _buildInputDecoration("Designation", Icons.work_rounded),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _contactEmailController,
                        decoration: _buildInputDecoration("Email", Icons.email_rounded),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _contactPhoneController,
                        decoration: _buildInputDecoration("Phone", Icons.phone_rounded),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    child: const Text("Save Client", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
     return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }
}
