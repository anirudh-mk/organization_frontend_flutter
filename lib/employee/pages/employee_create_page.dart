import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/models/attachment_model.dart';
import '../../shared/models/location_models.dart';
import '../../organization/models/organization_model.dart' show UserOrganizationRoleModel;
import '../../organization/services/organization_service.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';
import '../../theme/app_theme.dart';

class EmployeeCreatePage extends StatefulWidget {
  final EmployeeModel? employee;

  const EmployeeCreatePage({super.key, this.employee});

  @override
  State<EmployeeCreatePage> createState() => _EmployeeCreatePageState();
}

class _EmployeeCreatePageState extends State<EmployeeCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final EmployeeService _service = EmployeeService();
  final OrganizationService _orgService = OrganizationService();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _codeController;
  late TextEditingController _salaryController;

  // Multiple contacts
  final List<TextEditingController> _mobileControllers = [];
  final List<TextEditingController> _emailControllers = [];

  // Address management
  final List<AddressModel> _tempAddresses = [];
  
  String? _selectedRoleId;
  bool _isActive = true;

  List<UserOrganizationRoleModel> _roles = [];
  List<CountryModel> _countries = [];
  List<AddressTypeModel> _addressTypes = [];
  
  List<XFile> _newPhotos = [];
  List<EmployeePhotoModel> _existingPhotos = [];
  List<PlatformFile> _newAttachments = [];
  List<AttachmentModel> _existingAttachments = [];

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.employee?.firstName);
    _lastNameController = TextEditingController(text: widget.employee?.lastName);
    _codeController = TextEditingController(text: widget.employee?.employeeCode);
    _salaryController = TextEditingController(text: widget.employee?.expectedSalary.toString());

    if (widget.employee != null) {
      for (var m in widget.employee!.mobiles) {
        _mobileControllers.add(TextEditingController(text: m.number));
      }
      for (var e in widget.employee!.emails) {
        _emailControllers.add(TextEditingController(text: e.email));
      }
      _tempAddresses.addAll(widget.employee!.addresses);
      _isActive = widget.employee!.isActive;
      _existingPhotos = widget.employee!.photos;
      _existingAttachments = widget.employee!.attachments;
    }

    if (_mobileControllers.isEmpty) _mobileControllers.add(TextEditingController());
    if (_emailControllers.isEmpty) _emailControllers.add(TextEditingController());

    _loadLookups();
  }

  Future<void> _loadLookups() async {
    try {
      final results = await Future.wait([
        _orgService.getRoles(),
        _orgService.getCountries(),
        _orgService.getAddressTypes(),
        widget.employee == null ? _service.getNextCode() : Future.value(''),
      ]);

      setState(() {
        _roles = results[0] as List<UserOrganizationRoleModel>;
        _countries = results[1] as List<CountryModel>;
        _addressTypes = results[2] as List<AddressTypeModel>;
        if (widget.employee == null) _codeController.text = results[3] as String;
        
        if (widget.employee != null && widget.employee?.jobRoleName != null) {
          try {
            _selectedRoleId = _roles.firstWhere((r) => r.name == widget.employee!.jobRoleName).id;
          } catch (_) {
            _selectedRoleId = null;
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => _isLoading = false);
    }
  }

  void _addMobileField() => setState(() => _mobileControllers.add(TextEditingController()));
  void _removeMobileField(int index) => setState(() => _mobileControllers.removeAt(index));

  void _addEmailField() => setState(() => _emailControllers.add(TextEditingController()));
  void _removeEmailField(int index) => setState(() => _emailControllers.removeAt(index));

  Future<void> _addAddress() async {
    final result = await showModalBottomSheet<AddressModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddressFormSheet(countries: _countries, addressTypes: _addressTypes),
    );
    if (result != null) {
      setState(() => _tempAddresses.add(result));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final mobiles = _mobileControllers.map((c) => {'number': c.text}).where((m) => m['number']!.isNotEmpty).toList();
      final emails = _emailControllers.map((c) => {'email': c.text}).where((e) => e['email']!.isNotEmpty).toList();
      final addresses = _tempAddresses.map((a) => {
        'line_1': a.line1,
        'line_2': a.line2,
        'city': a.city,
        'postal_code': a.postalCode,
        'district': a.districtId,
        'address_type': a.addressTypeId,
        'is_primary': a.isPrimary,
      }).toList();

      final data = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'employee_code': _codeController.text,
        'job_role': _selectedRoleId,
        'expected_salary': _salaryController.text.isEmpty ? null : _salaryController.text,
        'is_active': _isActive,
        'mobile_input': mobiles,
        'email_input': emails,
        'address_input': addresses,
      };

      if (widget.employee == null) {
        final newEmp = await _service.createEmployee(data);
        if (_newPhotos.isNotEmpty) await _service.uploadPhotos(newEmp.id, _newPhotos);
        if (_newAttachments.isNotEmpty) await _service.uploadAttachments(newEmp.id, _newAttachments);
      } else {
        await _service.updateEmployee(widget.employee!.id, data);
        if (_newPhotos.isNotEmpty) await _service.uploadPhotos(widget.employee!.id, _newPhotos);
        if (_newAttachments.isNotEmpty) await _service.uploadAttachments(widget.employee!.id, _newAttachments);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Staff details saved!")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        title: Text(widget.employee == null ? "Onboard Staff" : "Edit Profile", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: _isSaving ? const Center(child: CircularProgressIndicator()) : Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader("Profile Photos"),
              const SizedBox(height: 16),
              _buildPhotoPicker(),

              const SizedBox(height: 32),
              _sectionHeader("Identity & Role"),
              const SizedBox(height: 16),
              _buildIdentityFields(),
              
              const SizedBox(height: 32),
              _sectionHeader("Contact Information"),
              const SizedBox(height: 16),
              _buildContactSection("MOBILE NUMBERS", _mobileControllers, _addMobileField, _removeMobileField, TextInputType.phone),
              const SizedBox(height: 20),
              _buildContactSection("EMAIL ADDRESSES", _emailControllers, _addEmailField, _removeEmailField, TextInputType.emailAddress),

              const SizedBox(height: 32),
              _sectionHeader("Addresses"),
              const SizedBox(height: 16),
              _buildAddressSection(),

              const SizedBox(height: 32),
              _sectionHeader("Financials"),
              const SizedBox(height: 16),
              _label("EXPECTED SALARY (PER MONTH)"),
              _field(_salaryController, "0.00", keyboardType: TextInputType.number),

              const SizedBox(height: 32),
              _sectionHeader("KYC & Documents"),
              const SizedBox(height: 16),
              _buildAttachmentSection(),

              const SizedBox(height: 48),
              _buildSaveButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          InkWell(
            onTap: () async {
              final picker = ImagePicker();
              final selection = await picker.pickMultiImage();
              if (selection.isNotEmpty) setState(() => _newPhotos.addAll(selection));
            },
            child: Container(
              width: 120, height: 140, margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.12), width: 1.5)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_a_photo_outlined, color: AppColors.primary.withValues(alpha: 0.6), size: 32),
                const SizedBox(height: 8),
                const Text("Add Photo", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))
              ]),
            ),
          ),
          ..._existingPhotos.map((photo) => _mediaThumbnail(photo.imageUrl, () async {
            await _service.deletePhoto(photo.id);
            setState(() => _existingPhotos.remove(photo));
          })),
          ..._newPhotos.map((file) => _mediaThumbnail(file.path, () => setState(() => _newPhotos.remove(file)))),
        ],
      ),
    );
  }

  Widget _mediaThumbnail(String path, VoidCallback onDelete) {
    return Container(
      width: 120, margin: const EdgeInsets.only(right: 12),
      child: Stack(children: [
        ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(path, width: 120, height: 140, fit: BoxFit.cover)),
        Positioned(right: 8, top: 8, child: InkWell(onTap: onDelete, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)))),
      ]),
    );
  }

  Widget _buildIdentityFields() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("FIRST NAME *"), _field(_firstNameController, "e.g. Suresh", validator: (v) => v!.isEmpty ? "Req" : null)])),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("LAST NAME"), _field(_lastNameController, "e.g. Kumar")])),
      ]),
      const SizedBox(height: 16),
      _label("JOB ROLE *"),
      _dropdown<String>(value: _selectedRoleId, hint: "Select Designation", items: _roles.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(), onChanged: (v) => setState(() => _selectedRoleId = v)),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label("EMPLOYEE CODE *"), _field(_codeController, "EMP-000", validator: (v) => v!.isEmpty ? "Req" : null)])),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label("STATUS"),
          Container(height: 56, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(_isActive ? "Active" : "Inactive", style: TextStyle(color: _isActive ? AppColors.success : AppColors.error, fontWeight: FontWeight.bold)),
            Switch(value: _isActive, onChanged: (v) => setState(() => _isActive = v), activeColor: AppColors.success),
          ])),
        ])),
      ]),
    ]);
  }

  Widget _buildContactSection(String label, List<TextEditingController> controllers, VoidCallback onAdd, Function(int) onRemove, TextInputType type) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(label),
      ...controllers.asMap().entries.map((entry) {
        int idx = entry.key;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Expanded(child: _field(entry.value, "Enter details...", keyboardType: type)),
            if (controllers.length > 1) IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => onRemove(idx)),
          ]),
        );
      }),
      TextButton.icon(onPressed: onAdd, icon: const Icon(Icons.add_circle_outline, size: 20), label: const Text("Add Another")),
    ]);
  }

  Widget _buildAddressSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ..._tempAddresses.asMap().entries.map((entry) {
        final a = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1))),
          child: Row(children: [
            const Icon(Icons.location_on_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.line1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text("${a.city}, ${a.postalCode}", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ])),
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => setState(() => _tempAddresses.removeAt(entry.key))),
          ]),
        );
      }),
      OutlinedButton.icon(
        onPressed: _addAddress,
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        icon: const Icon(Icons.add_location_alt_outlined, size: 18),
        label: const Text("Add New Address"),
      ),
    ]);
  }

  Widget _buildAttachmentSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1))),
      child: Column(children: [
        ..._existingAttachments.map((att) => ListTile(
          onTap: () async => await launchUrl(Uri.parse(att.fileUrl)),
          leading: const Icon(Icons.description_outlined, color: AppColors.primary),
          title: Text(att.fileName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () async {
            await _service.deleteAttachment(att.id);
            setState(() => _existingAttachments.remove(att));
          }),
        )),
        ..._newAttachments.map((f) => ListTile(
          leading: const Icon(Icons.upload_file, color: Colors.blue),
          title: Text(f.name, style: const TextStyle(fontSize: 13)),
          trailing: IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => setState(() => _newAttachments.remove(f))),
        )),
        const Divider(height: 1),
        InkWell(
          onTap: () async {
            final res = await FilePicker.platform.pickFiles(allowMultiple: true);
            if (res != null) setState(() => _newAttachments.addAll(res.files));
          },
          child: const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20), SizedBox(width: 8), Text("Upload Documents", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))])),
        ),
      ]),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(width: double.infinity, height: 58, child: ElevatedButton(
      onPressed: _isSaving ? null : _save,
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      child: Text(widget.employee == null ? "Confirm Onboarding" : "Update Profile", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
    ));
  }

  Widget _sectionHeader(String title) {
    return Row(children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(width: 12), const Expanded(child: Divider())]);
  }
  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textSecondary, fontSize: 10, letterSpacing: 1.2)));
  Widget _field(TextEditingController ctrl, String hint, {TextInputType? keyboardType, String? Function(String?)? validator}) => TextFormField(controller: ctrl, keyboardType: keyboardType, validator: validator, decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.white, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.12))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary))));
  Widget _dropdown<T>({required T? value, required String hint, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) => Container(padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.12))), child: DropdownButtonHideUnderline(child: DropdownButton<T>(value: value, isExpanded: true, hint: Text(hint, style: const TextStyle(fontSize: 13)), items: items, onChanged: onChanged)));
}

class _AddressFormSheet extends StatefulWidget {
  final List<CountryModel> countries;
  final List<AddressTypeModel> addressTypes;
  const _AddressFormSheet({required this.countries, required this.addressTypes});

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _line1 = TextEditingController();
  final _line2 = TextEditingController();
  final _city = TextEditingController();
  final _zip = TextEditingController();

  CountryModel? _country;
  StateModel? _state;
  DistrictModel? _district;
  AddressTypeModel? _type;
  
  List<StateModel> _states = [];
  List<DistrictModel> _districts = [];
  bool _isLoading = false;

  final _service = OrganizationService();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Add Address", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _dropdown<CountryModel>("Country", widget.countries.map((c) => DropdownMenuItem<CountryModel>(value: c, child: Text(c.name))).toList(), _country, (v) async {
          setState(() { _country = v; _state = null; _district = null; _states = []; _isLoading = true; });
          final res = await _service.getStates(v!.id);
          setState(() { _states = res; _isLoading = false; });
        }),
        const SizedBox(height: 12),
        _dropdown<StateModel>("State", _states.map((s) => DropdownMenuItem<StateModel>(value: s, child: Text(s.name))).toList(), _state, (v) async {
          setState(() { _state = v; _district = null; _districts = []; _isLoading = true; });
          final res = await _service.getDistricts(v!.id);
          setState(() { _districts = res; _isLoading = false; });
        }, enabled: _country != null),
        const SizedBox(height: 12),
        _dropdown<DistrictModel>("District", _districts.map((d) => DropdownMenuItem<DistrictModel>(value: d, child: Text(d.name))).toList(), _district, (v) => setState(() => _district = v), enabled: _state != null),
        const SizedBox(height: 12),
        _field(_line1, "Address Line 1"),
        const SizedBox(height: 12),
        _field(_city, "City"),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _field(_zip, "Pin Code")),
          const SizedBox(width: 12),
          Expanded(child: _dropdown<AddressTypeModel>("Type", widget.addressTypes.map((t) => DropdownMenuItem<AddressTypeModel>(value: t, child: Text(t.name))).toList(), _type, (v) => setState(() => _type = v))),
        ]),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: () {
          if (!_formKey.currentState!.validate() || _district == null) return;
          Navigator.pop(context, AddressModel(id: '', line1: _line1.text, line2: _line2.text, districtId: _district!.id, city: _city.text, postalCode: _zip.text, addressTypeId: _type?.id));
        }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text("Save Address", style: TextStyle(color: Colors.white)))),
      ])),
    );
  }

  Widget _field(TextEditingController c, String h) => TextFormField(controller: c, decoration: InputDecoration(hintText: h, filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)), validator: (v) => v!.isEmpty ? "Req" : null);
  Widget _dropdown<T>(String h, List<DropdownMenuItem<T>> items, T? val, ValueChanged<T?>? onC, {bool enabled = true}) => Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: enabled ? AppColors.background : Colors.grey[200], borderRadius: BorderRadius.circular(12)), child: DropdownButtonHideUnderline(child: DropdownButton<T>(value: val, isExpanded: true, hint: Text(h, style: const TextStyle(fontSize: 13)), items: enabled ? items : null, onChanged: onC)));
}