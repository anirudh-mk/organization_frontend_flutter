import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../shared/models/location_models.dart';
import '../../shared/services/location_service.dart';
import '../services/subcontractor_service.dart';
import '../models/subcontractor_model.dart';

class SubcontractorCreatePage extends StatefulWidget {
  final SubcontractorModel? subcontractor;
  const SubcontractorCreatePage({super.key, this.subcontractor});

  @override
  State<SubcontractorCreatePage> createState() => _SubcontractorCreatePageState();
}

class _SubcontractorCreatePageState extends State<SubcontractorCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final SubcontractorService _service = SubcontractorService();
  final LocationService _locationService = LocationService();

  bool _isSaving = false;
  bool _isLoadingLocations = true;

  // Basic fields
  final _nameController = TextEditingController();
  final _specializationController = TextEditingController();
  
  // Payment fields
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _accountHolderNameController = TextEditingController();

  bool _isActive = true;

  // Multiple Addresses
  final List<Map<String, dynamic>> _addressFields = [];
  List<CountryModel> _countries = [];
  List<AddressTypeModel> _addressTypes = [];

  // Multiple Contacts
  List<ContactTypeModel> _contactTypes = [];
  final List<Map<String, dynamic>> _emailFields = [];
  final List<Map<String, dynamic>> _mobileFields = [];

  bool get _isEditing => widget.subcontractor != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final s = widget.subcontractor!;
      _nameController.text = s.name;
      _specializationController.text = s.specialization;
      _bankNameController.text = s.bankName;
      _accountNumberController.text = s.accountNumber;
      _ifscCodeController.text = s.ifscCode;
      _accountHolderNameController.text = s.accountHolderName;
      _isActive = s.isActive;

      for (var addrObj in s.addresses) {
        final d = addrObj.addressDetails;
        if (d != null) {
          _addAddressField(
            initialLine1: d.line1,
            initialLine2: d.line2,
            initialCity: d.city,
            initialPostalCode: d.postalCode,
            initialTypeId: d.addressTypeId,
            initialCountryId: d.countryId,
            initialStateId: d.stateId,
            initialDistrictId: d.districtId,
          );
        }
      }

      for (var e in s.emails) {
        _addEmailField(initialValue: e.email, initialTypeId: e.contactTypeId);
      }
      for (var m in s.mobiles) {
        _addMobileField(initialValue: m.number, initialTypeId: m.contactTypeId);
      }
    }

    if (_addressFields.isEmpty) _addAddressField();
    if (_emailFields.isEmpty) _addEmailField();
    if (_mobileFields.isEmpty) _addMobileField();

    _initAppData();
  }

  void _addAddressField({
    String initialLine1 = '',
    String initialLine2 = '',
    String initialCity = '',
    String initialPostalCode = '',
    String? initialTypeId,
    String? initialCountryId,
    String? initialStateId,
    String? initialDistrictId,
  }) {
    setState(() {
      _addressFields.add({
        'line1': TextEditingController(text: initialLine1),
        'line2': TextEditingController(text: initialLine2),
        'city': TextEditingController(text: initialCity),
        'postalCode': TextEditingController(text: initialPostalCode),
        'typeId': initialTypeId,
        'countryId': initialCountryId,
        'stateId': initialStateId,
        'districtId': initialDistrictId,
        'selectedType': null,
        'selectedCountry': null,
        'selectedState': null,
        'selectedDistrict': null,
        'states': <StateModel>[],
        'districts': <DistrictModel>[],
      });
    });
  }

  void _addEmailField({String initialValue = '', String? initialTypeId}) {
    setState(() {
      _emailFields.add({
        'controller': TextEditingController(text: initialValue),
        'typeId': initialTypeId,
        'type': null,
      });
    });
  }

  void _addMobileField({String initialValue = '', String? initialTypeId}) {
    setState(() {
      _mobileFields.add({
        'controller': TextEditingController(text: initialValue),
        'typeId': initialTypeId,
        'type': null,
      });
    });
  }

  Future<void> _initAppData() async {
    try {
      final countries = await _locationService.getCountries();
      final contactTypes = await _locationService.getContactTypes();
      final addressTypes = await _locationService.getAddressTypes();

      if (!mounted) return;

      setState(() {
        _countries = countries;
        _contactTypes = contactTypes;
        _addressTypes = addressTypes;
      });

      for (var f in _emailFields) {
        f['type'] = _contactTypes.where((t) => t.id == f['typeId']).firstOrNull ?? (_contactTypes.isNotEmpty ? _contactTypes.first : null);
      }
      for (var f in _mobileFields) {
        f['type'] = _contactTypes.where((t) => t.id == f['typeId']).firstOrNull ?? (_contactTypes.isNotEmpty ? _contactTypes.first : null);
      }

      for (var i = 0; i < _addressFields.length; i++) {
        var f = _addressFields[i];
        f['selectedType'] = _addressTypes.where((t) => t.id == f['typeId']).firstOrNull;
        f['selectedCountry'] = _countries.where((c) => c.id == f['countryId']).firstOrNull;

        if (f['selectedCountry'] != null) {
          final states = await _locationService.getStates(f['selectedCountry'].id);
          f['states'] = states;
          f['selectedState'] = states.where((s) => s.id == f['stateId']).firstOrNull;

          if (f['selectedState'] != null) {
            final districts = await _locationService.getDistricts(f['selectedState'].id);
            f['districts'] = districts;
            f['selectedDistrict'] = districts.where((d) => d.id == f['districtId']).firstOrNull;
          }
        }
      }

      setState(() => _isLoadingLocations = false);
    } catch (e) {
      if (mounted) setState(() => _isLoadingLocations = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final addresses = _addressFields
          .where((f) => f['line1'].text.trim().isNotEmpty && f['selectedDistrict'] != null)
          .map((f) => {
                'line_1': f['line1'].text.trim(),
                'line_2': f['line2'].text.trim(),
                'city': f['city'].text.trim(),
                'postal_code': f['postalCode'].text.trim(),
                'district': (f['selectedDistrict'] as DistrictModel).id,
                'address_type': (f['selectedType'] as AddressTypeModel?)?.id,
                'is_primary': f['is_primary'] ?? false,
              })
          .toList();

      final emailsList = _emailFields
          .where((f) => f['controller'].text.trim().isNotEmpty)
          .map((f) => {
                'email': f['controller'].text.trim(),
                'contact_type': (f['type'] as ContactTypeModel?)?.id,
              })
          .toList();

      final mobilesList = _mobileFields
          .where((f) => f['controller'].text.trim().isNotEmpty)
          .map((f) => {
                'number': f['controller'].text.trim(),
                'contact_type': (f['type'] as ContactTypeModel?)?.id,
              })
          .toList();

      final data = {
        'name': _nameController.text.trim(),
        'specialization': _specializationController.text.trim(),
        'bank_name': _bankNameController.text.trim(),
        'account_number': _accountNumberController.text.trim(),
        'ifsc_code': _ifscCodeController.text.trim(),
        'account_holder_name': _accountHolderNameController.text.trim(),
        'is_active': _isActive,
        'address_input': addresses,
        'email_input': emailsList,
        'mobile_input': mobilesList,
      };

      if (_isEditing) {
        await _service.updateSubcontractor(widget.subcontractor!.id, data);
      } else {
        await _service.createSubcontractor(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? "Subcontractor updated!" : "Subcontractor created!"),
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
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _accountHolderNameController.dispose();
    for (var f in _addressFields) {
      f['line1']?.dispose();
      f['line2']?.dispose();
      f['city']?.dispose();
      f['postalCode']?.dispose();
    }
    for (var f in _emailFields) {
      f['controller']?.dispose();
    }
    for (var f in _mobileFields) {
      f['controller']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Subcontractor" : "New Subcontractor", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isSaving 
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _sectionHeader("Basic Info"),
                  const SizedBox(height: 16),
                  _label("COMPANY/INDIVIDUAL NAME *"),
                  _field(_nameController, "e.g. Acme Electrics", validator: (v) => v == null || v.isEmpty ? "Required" : null),
                  const SizedBox(height: 16),
                  _label("SPECIALIZATION"),
                  _field(_specializationController, "e.g. Electrical, HVAC"),
                  
                  const SizedBox(height: 32),
                  _sectionHeader("Contact Info"),
                  const SizedBox(height: 16),
                  _emailSection(),
                  const SizedBox(height: 16),
                  _mobileSection(),

                  const SizedBox(height: 32),
                  _sectionHeader("Addresses"),
                  const SizedBox(height: 16),
                  if (_isLoadingLocations)
                    const Center(child: CircularProgressIndicator())
                  else
                    _addressSection(),

                  const SizedBox(height: 32),
                  _sectionHeader("Payment Details"),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label("BANK NAME"),
                        _field(_bankNameController, "e.g. Chase"),
                      ])),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label("ACCOUNT NUMBER"),
                        _field(_accountNumberController, "123456789", keyboardType: TextInputType.number),
                      ])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label("ROUTING/IFSC CODE"),
                        _field(_ifscCodeController, "Routing code"),
                      ])),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _label("ACCOUNT HOLDER"),
                        _field(_accountHolderNameController, "Name on account"),
                      ])),
                    ],
                  ),

                  const SizedBox(height: 32),
                  _sectionHeader("Status"),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
                    ),
                    child: SwitchListTile(
                      title: const Text("Active Status", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      subtitle: const Text("Is this subcontractor actively working?", style: TextStyle(fontSize: 12)),
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
                      child: Text(_isEditing ? "Update Subcontractor" : "Save Subcontractor", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _field(TextEditingController controller, String hint, {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.12))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary)),
      ),
    );
  }

  Widget _dropdown<T>({required T? value, required String hint, required List<DropdownMenuItem<T>> items, required ValueChanged<T?>? onChanged, bool enabled = true}) {
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
        ),
      ),
    );
  }

  Widget _emailSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _label("EMAILS"),
        TextButton.icon(onPressed: _addEmailField, icon: const Icon(Icons.add, size: 16), label: const Text("Add Email", style: TextStyle(fontSize: 12))),
      ]),
      ..._emailFields.asMap().entries.map((entry) {
        int idx = entry.key;
        var field = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            Expanded(flex: 2, child: _dropdown<ContactTypeModel>(value: field['type'], hint: "Type", 
              items: _contactTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
              onChanged: (v) => setState(() => _emailFields[idx]['type'] = v))),
            const SizedBox(width: 8),
            Expanded(flex: 4, child: _field(field['controller'], "email@example.com", keyboardType: TextInputType.emailAddress)),
            if (_emailFields.length > 1) IconButton(icon: const Icon(Icons.remove_circle_outline, color: AppColors.error), onPressed: () => setState(() => _emailFields.removeAt(idx))),
          ]),
        );
      }),
    ]);
  }

  Widget _mobileSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _label("MOBILES"),
        TextButton.icon(onPressed: _addMobileField, icon: const Icon(Icons.add, size: 16), label: const Text("Add Mobile", style: TextStyle(fontSize: 12))),
      ]),
      ..._mobileFields.asMap().entries.map((entry) {
        int idx = entry.key;
        var field = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            Expanded(flex: 2, child: _dropdown<ContactTypeModel>(value: field['type'], hint: "Type", 
              items: _contactTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
              onChanged: (v) => setState(() => _mobileFields[idx]['type'] = v))),
            const SizedBox(width: 8),
            Expanded(flex: 4, child: _field(field['controller'], "+91 ...", keyboardType: TextInputType.phone)),
            if (_mobileFields.length > 1) IconButton(icon: const Icon(Icons.remove_circle_outline, color: AppColors.error), onPressed: () => setState(() => _mobileFields.removeAt(idx))),
          ]),
        );
      }),
    ]);
  }

  Widget _addressSection() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const SizedBox(),
        TextButton.icon(onPressed: _addAddressField, icon: const Icon(Icons.add_location_alt_rounded, size: 16), label: const Text("Add Address", style: TextStyle(fontSize: 12))),
      ]),
      ..._addressFields.asMap().entries.map((entry) {
        int idx = entry.key;
        var f = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _label("ADDRESS #${idx + 1}"),
              if (_addressFields.length > 1) IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20), onPressed: () => setState(() => _addressFields.removeAt(idx))),
            ]),
            const SizedBox(height: 8),
            _label("ADDRESS TYPE"),
            _dropdown<AddressTypeModel>(value: f['selectedType'], hint: "Select Type", 
              items: _addressTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
              onChanged: (v) => setState(() => f['selectedType'] = v)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label("COUNTRY"),
                _dropdown<CountryModel>(value: f['selectedCountry'], hint: "Country", items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                  onChanged: (v) async {
                    setState(() { f['selectedCountry'] = v; f['selectedState'] = null; f['selectedDistrict'] = null; f['states'] = []; f['districts'] = []; });
                    if (v != null) { final states = await _locationService.getStates(v.id); setState(() => f['states'] = states); }
                  }),
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label("STATE"),
                _dropdown<StateModel>(value: f['selectedState'], hint: "State", items: (f['states'] as List<StateModel>).map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                  onChanged: f['selectedCountry'] != null ? (v) async {
                    setState(() { f['selectedState'] = v; f['selectedDistrict'] = null; f['districts'] = []; });
                    if (v != null) { final districts = await _locationService.getDistricts(v.id); setState(() => f['districts'] = districts); }
                  } : null, enabled: f['selectedCountry'] != null),
              ])),
            ]),
            const SizedBox(height: 16),
            _label("DISTRICT"),
            _dropdown<DistrictModel>(value: f['selectedDistrict'], hint: "District", items: (f['districts'] as List<DistrictModel>).map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
              onChanged: f['selectedState'] != null ? (v) => setState(() => f['selectedDistrict'] = v) : null, enabled: f['selectedState'] != null),
            const SizedBox(height: 16),
            _label("STREET ADDRESS (LINE 1)"),
            _field(f['line1'], "Building No., Street Name"),
            const SizedBox(height: 16),
            _label("ADDRESS LINE 2"),
            _field(f['line2'], "Suite, Floor, Landmark"),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ _label("CITY"), _field(f['city'], "City") ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ _label("POSTAL CODE"), _field(f['postalCode'], "Zip") ])),
            ]),
          ]),
        );
      }),
    ]);
  }
}
