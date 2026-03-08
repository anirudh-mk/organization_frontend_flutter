import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../shared/models/location_models.dart';
import '../../shared/services/location_service.dart';
import '../models/client_model.dart';
import '../services/client_service.dart';

class ClientCreatePage extends StatefulWidget {
  final ClientModel? client; // null = create, non-null = edit

  const ClientCreatePage({super.key, this.client});

  @override
  State<ClientCreatePage> createState() => _ClientCreatePageState();
}

class _ClientCreatePageState extends State<ClientCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final ClientService _service = ClientService();
  final LocationService _locationService = LocationService();

  bool _isSaving = false;
  bool _isLoadingLocations = true;

  // ── Client fields ──
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isActive = true;

  // ── Address fields ──
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  List<CountryModel> _countries = [];
  List<StateModel> _states = [];
  List<DistrictModel> _districts = [];
  CountryModel? _selectedCountry;
  StateModel? _selectedState;
  DistrictModel? _selectedDistrict;

  // ── Contact fields ──
  final _contactNameController = TextEditingController();
  final _contactDesignationController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();

  bool get _isEditing => widget.client != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final c = widget.client!;
      _nameController.text = c.name;
      _codeController.text = c.code;
      _emailController.text = c.email;
      _phoneController.text = c.phone;
      _isActive = c.isActive;
      final primary = c.primaryContact;
      if (primary != null) {
        _contactNameController.text = primary.name;
        _contactDesignationController.text = primary.designation;
        _contactPhoneController.text = primary.phone;
        _contactEmailController.text = primary.email;
      }
      
      final addr = c.addresses.firstOrNull?.addressDetails;
      if (addr != null) {
        _line1Controller.text = addr.line1;
        _line2Controller.text = addr.line2;
        _cityController.text = addr.city;
        _postalCodeController.text = addr.postalCode;
      }
    }
    _initLocations();
  }

  Future<void> _initLocations() async {
    try {
      final countries = await _locationService.getCountries();
      if (!mounted) return;
      
      CountryModel? matchedCountry;
      StateModel? matchedState;
      DistrictModel? matchedDistrict;
      List<StateModel> states = [];
      List<DistrictModel> districts = [];

      final addr = widget.client?.addresses.firstOrNull?.addressDetails;
      
      if (addr != null && addr.countryId != null) {
        matchedCountry = countries.where((c) => c.id == addr.countryId).firstOrNull;
        if (matchedCountry != null && addr.stateId != null) {
          states = await _locationService.getStates(matchedCountry.id);
          matchedState = states.where((s) => s.id == addr.stateId).firstOrNull;
          if (matchedState != null && addr.districtId != null) {
            districts = await _locationService.getDistricts(matchedState.id);
            matchedDistrict = districts.where((d) => d.id == addr.districtId).firstOrNull;
          }
        }
      }

      setState(() {
        _countries = countries;
        _selectedCountry = matchedCountry;
        _states = states;
        _selectedState = matchedState;
        _districts = districts;
        _selectedDistrict = matchedDistrict;
        _isLoadingLocations = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingLocations = false);
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
        if (mounted) setState(() => _states = states);
      } catch (_) {}
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
        if (mounted) setState(() => _districts = districts);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _contactNameController.dispose();
    _contactDesignationController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      // Build addresses list
      final addresses = <Map<String, dynamic>>[];
      if (_line1Controller.text.trim().isNotEmpty && _selectedDistrict != null) {
        addresses.add({
          'line_1': _line1Controller.text.trim(),
          'line_2': _line2Controller.text.trim(),
          'city': _cityController.text.trim(),
          'postal_code': _postalCodeController.text.trim(),
          'district': _selectedDistrict!.id,
        });
      }

      // Build contacts list
      final contacts = <Map<String, dynamic>>[];
      if (_contactNameController.text.trim().isNotEmpty) {
        contacts.add({
          'name': _contactNameController.text.trim(),
          'designation': _contactDesignationController.text.trim(),
          'phone': _contactPhoneController.text.trim(),
          'email': _contactEmailController.text.trim(),
          'is_primary': true,
        });
      }

      final data = {
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'is_active': _isActive,
        'address_input': addresses,
        'contact_input': contacts,
      };

      if (_isEditing) {
        await _service.updateClient(widget.client!.id, data);
      } else {
        await _service.createClient(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? "Client updated!" : "Client created!"),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(_isEditing ? "Edit Client" : "New Client"),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(_isEditing ? "Update" : "Save", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Client Details ──
              _sectionHeader("Client Details"),
              const SizedBox(height: 16),
              _label("CLIENT NAME *"),
              _field(_nameController, "e.g., Acme Corp",
                  validator: (v) => v == null || v.isEmpty ? "Required" : null),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label("CLIENT CODE *"),
                  _field(_codeController, "e.g., CLT-001",
                      validator: (v) => v == null || v.isEmpty ? "Required" : null),
                ])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label("STATUS"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.15)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(_isActive ? "Active" : "Inactive",
                          style: TextStyle(color: _isActive ? AppColors.success : AppColors.textMuted, fontWeight: FontWeight.w600)),
                      Switch(value: _isActive, onChanged: (v) => setState(() => _isActive = v), activeColor: AppColors.success),
                    ]),
                  ),
                ])),
              ]),
              const SizedBox(height: 16),
              _label("EMAIL"),
              _field(_emailController, "client@company.com", keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _label("PHONE"),
              _field(_phoneController, "+91 9876543210", keyboardType: TextInputType.phone),

              const SizedBox(height: 32),

              // ── Address ──
              _sectionHeader("Address"),
              const SizedBox(height: 4),
              const Text("Street address for this client's office or site.",
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 16),
              if (_isLoadingLocations)
                const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
              else ...[
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label("COUNTRY"),
                    _dropdown<CountryModel>(
                      value: _selectedCountry,
                      hint: "Select Country",
                      items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                      onChanged: _onCountryChanged,
                    ),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label("STATE"),
                    _dropdown<StateModel>(
                      value: _selectedState,
                      hint: "Select State",
                      items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                      onChanged: _states.isNotEmpty ? _onStateChanged : null,
                      enabled: _selectedCountry != null,
                    ),
                  ])),
                ]),
                const SizedBox(height: 16),
                _label("DISTRICT"),
                _dropdown<DistrictModel>(
                  value: _selectedDistrict,
                  hint: "Select District",
                  items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
                  onChanged: _districts.isNotEmpty ? (v) => setState(() => _selectedDistrict = v) : null,
                  enabled: _selectedState != null,
                ),
                const SizedBox(height: 16),
                _label("STREET ADDRESS (LINE 1)"),
                _field(_line1Controller, "Building No., Street Name"),
                const SizedBox(height: 16),
                _label("ADDRESS LINE 2 (OPTIONAL)"),
                _field(_line2Controller, "Suite, Floor, Landmark"),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label("CITY"),
                    _field(_cityController, "City"),
                  ])),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label("POSTAL CODE"),
                    _field(_postalCodeController, "Zip"),
                  ])),
                ]),
              ],

              const SizedBox(height: 32),

              // ── Primary Contact ──
              _sectionHeader("Primary Contact"),
              const SizedBox(height: 4),
              const Text("Optional. Add the main point of contact for this client.",
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label("CONTACT NAME"),
                  _field(_contactNameController, "John Doe"),
                ])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label("DESIGNATION"),
                  _field(_contactDesignationController, "Site Engineer"),
                ])),
              ]),
              const SizedBox(height: 16),
              _label("CONTACT PHONE"),
              _field(_contactPhoneController, "+91 9876543210", keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _label("CONTACT EMAIL"),
              _field(_contactEmailController, "john@company.com", keyboardType: TextInputType.emailAddress),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isEditing ? "Update Client" : "Create Client",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(children: [
      Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      const SizedBox(width: 12),
      const Expanded(child: Divider()),
    ]);
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              fontSize: 11,
              letterSpacing: 1.2)),
    );
  }

  Widget _field(TextEditingController controller, String hint,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.12))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.error)),
      ),
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          items: enabled ? items : null,
          onChanged: enabled ? onChanged : null,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
