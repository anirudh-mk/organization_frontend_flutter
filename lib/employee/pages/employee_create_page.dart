import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';
import '../../shared/models/attachment_model.dart';
import '../../organization/models/organization_model.dart';
import '../../organization/services/organization_service.dart';

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
  late TextEditingController _mobileController;
  late TextEditingController _emailController;
  late TextEditingController _salaryController;

  String? _selectedRoleId;
  bool _isActive = true;

  List<UserOrganizationRoleModel> _roles = [];
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
    _mobileController = TextEditingController(
      text: widget.employee?.mobiles.isNotEmpty == true ? widget.employee?.mobiles.first.number : '',
    );
    _emailController = TextEditingController(
      text: widget.employee?.emails.isNotEmpty == true ? widget.employee?.emails.first.email : '',
    );
    _salaryController = TextEditingController(text: widget.employee?.expectedSalary.toString());

    // We don't have the jobRoleId in the model yet, we only have jobRoleName.
    // However, for the lookup, we'll need to find it or let the user re-select.
    _existingPhotos = widget.employee?.photos ?? [];
    _existingAttachments = widget.employee?.attachments ?? [];
    _isActive = widget.employee?.isActive ?? true;

    _loadLookups();
  }

  Future<void> _loadLookups() async {
    try {
      final results = await Future.wait([
        _orgService.getRoles(),
        widget.employee == null ? _service.getNextCode() : Future.value(''),
      ]);

      setState(() {
        _roles = results[0] as List<UserOrganizationRoleModel>;
        if (widget.employee == null) _codeController.text = results[1] as String;
        
        // Match jobRoleName to _selectedRoleId if editing
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading data: $e")));
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _newPhotos.addAll(images));
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() => _newAttachments.addAll(result.files));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final data = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'employee_code': _codeController.text,
        'job_role': _selectedRoleId,
        'expected_salary': _salaryController.text.isEmpty ? null : _salaryController.text,
        'is_active': _isActive,
      };

      if (_mobileController.text.isNotEmpty) {
        data['mobile_input'] = [{'number': _mobileController.text}];
      }
      if (_emailController.text.isNotEmpty) {
        data['email_input'] = [{'email': _emailController.text}];
      }

      if (widget.employee == null) {
        final newEmp = await _service.createEmployee(data);
        if (_newPhotos.isNotEmpty) {
          await _service.uploadPhotos(newEmp.id, _newPhotos);
        }
        if (_newAttachments.isNotEmpty) {
          await _service.uploadAttachments(newEmp.id, _newAttachments);
        }
      } else {
        await _service.updateEmployee(widget.employee!.id, data);
        if (_newPhotos.isNotEmpty) {
          await _service.uploadPhotos(widget.employee!.id, _newPhotos);
        }
        if (_newAttachments.isNotEmpty) {
          await _service.uploadAttachments(widget.employee!.id, _newAttachments);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Staff details saved!")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving: $e"), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _openAttachment(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.employee == null ? "Onboard Staff" : "Edit Profile", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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
              _sectionHeader("Profile Photos"),
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    InkWell(
                      onTap: _pickImages,
                      child: Container(
                        width: 120, height: 140,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(20), 
                          border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.12), width: 1.5)
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.add_a_photo_outlined, color: AppColors.primary.withValues(alpha: 0.6), size: 32), 
                          const SizedBox(height: 8), 
                          const Text("Add Photo", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary))
                        ]),
                      ),
                    ),
                    ..._existingPhotos.map((photo) => Container(
                      width: 120, margin: const EdgeInsets.only(right: 12),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(photo.imageUrl, width: 120, height: 140, fit: BoxFit.cover),
                          ),
                          Positioned(right: 8, top: 8, child: InkWell(
                            onTap: () async {
                              await _service.deletePhoto(photo.id);
                              setState(() => _existingPhotos.removeWhere((p) => p.id == photo.id));
                            },
                            child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)),
                          )),
                        ],
                      ),
                    )),
                    ..._newPhotos.map((file) => Container(
                      width: 120, margin: const EdgeInsets.only(right: 12),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(file.path, width: 120, height: 140, fit: BoxFit.cover),
                          ),
                          Positioned(right: 8, top: 8, child: InkWell(
                            onTap: () => setState(() => _newPhotos.remove(file)),
                            child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)),
                          )),
                        ],
                      ),
                    )),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              _sectionHeader("Identity & Role"),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label("FIRST NAME *"),
                  _field(_firstNameController, "e.g. Suresh", validator: (v) => v == null || v.isEmpty ? "Required" : null),
                ])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label("LAST NAME"),
                  _field(_lastNameController, "e.g. Kumar"),
                ])),
              ]),
              const SizedBox(height: 16),
              
              _label("JOB ROLE *"),
              _dropdown<String>(
                value: _selectedRoleId,
                hint: "Select Designation",
                items: _roles.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(),
                onChanged: (val) => setState(() => _selectedRoleId = val),
              ),
              const SizedBox(height: 16),

              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label("EMPLOYEE CODE *"),
                  _field(_codeController, "EMP-000", validator: (v) => v == null || v.isEmpty ? "Required" : null),
                ])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label("STATUS"),
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.12)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(_isActive ? "Active" : "Inactive",
                          style: TextStyle(color: _isActive ? AppColors.success : AppColors.error, fontWeight: FontWeight.w600)),
                      Switch(value: _isActive, onChanged: (v) => setState(() => _isActive = v), activeColor: AppColors.success),
                    ]),
                  ),
                ])),
              ]),

              const SizedBox(height: 32),
              _sectionHeader("Contact Info"),
              const SizedBox(height: 16),
              _label("MOBILE NUMBER"),
              _field(_mobileController, "+91 00000 00000", keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _label("EMAIL ADDRESS"),
              _field(_emailController, "suresh.k@gmail.com", keyboardType: TextInputType.emailAddress),

              const SizedBox(height: 32),
              _sectionHeader("Financials"),
              const SizedBox(height: 16),
              _label("EXPECTED SALARY (PER MONTH)"),
              _field(_salaryController, "0.00", keyboardType: TextInputType.number),

              const SizedBox(height: 32),
              _sectionHeader("KYC & Documents"),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    ..._existingAttachments.map((att) => ListTile(
                      onTap: () => _openAttachment(att.fileUrl),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
                      ),
                      title: Text(att.fileName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () async {
                          await _service.deleteAttachment(att.id);
                          setState(() => _existingAttachments.removeWhere((a) => a.id == att.id));
                        },
                      ),
                    )),
                    ..._newAttachments.map((file) => ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.upload_file_outlined, color: Colors.blue, size: 20),
                      ),
                      title: Text(file.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red, size: 20),
                        onPressed: () => setState(() => _newAttachments.remove(file)),
                      ),
                    )),
                    if (_existingAttachments.isEmpty && _newAttachments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text("No documents (ID, KYC, Contracts)", style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      ),
                    const Divider(height: 1),
                    InkWell(
                      onTap: _pickFiles,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, color: AppColors.primary.withValues(alpha: 0.6), size: 20),
                            const SizedBox(width: 8),
                            const Text("Upload Documents", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity, height: 58,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.employee == null ? "Confirm Onboarding" : "Update Profile",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
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
      {TextInputType? keyboardType, String? Function(String?)? validator, int maxLines = 1, bool readOnly = false, VoidCallback? onTap}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          items: items,
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}