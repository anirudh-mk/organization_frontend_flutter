import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../models/equipment_model.dart';
import '../services/equipment_service.dart';
import '../../shared/models/attachment_model.dart';
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
  late TextEditingController _notesController;

  String? _selectedCategoryId;
  String? _selectedStatusId;
  String? _selectedOwnershipTypeId;
  String? _selectedVendorId;
  bool _isActive = true;

  List<EquipmentCategoryModel> _categories = [];
  List<EquipmentStatusModel> _statuses = [];
  List<EquipmentOwnershipTypeModel> _ownershipTypes = [];
  List<VendorModel> _vendors = [];
  List<XFile> _newPhotos = [];
  List<EquipmentPhotoModel> _existingPhotos = [];
  List<PlatformFile> _newAttachments = [];
  List<AttachmentModel> _existingAttachments = [];

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.equipment?.name);
    _codeController = TextEditingController(text: widget.equipment?.code);
    _purchaseDateController = TextEditingController(text: widget.equipment?.purchaseDate);
    _purchaseCostController = TextEditingController(text: widget.equipment?.purchaseCost);
    _notesController = TextEditingController(text: widget.equipment?.notes);
    
    _rentalStartDateController = TextEditingController(text: widget.equipment?.rentalDetails?.rentalStartDate);
    _rentalEndDateController = TextEditingController(text: widget.equipment?.rentalDetails?.rentalEndDate);
    _rentalRateController = TextEditingController(text: widget.equipment?.rentalDetails?.rentalRatePerDay);
    _securityDepositController = TextEditingController(text: widget.equipment?.rentalDetails?.securityDeposit);

    _selectedCategoryId = widget.equipment?.categoryId;
    _selectedStatusId = widget.equipment?.statusId;
    _selectedOwnershipTypeId = widget.equipment?.ownershipTypeId;
    _selectedVendorId = widget.equipment?.rentalDetails?.vendorId;
    _existingPhotos = widget.equipment?.photos ?? [];
    _existingAttachments = widget.equipment?.attachments ?? [];
    _isActive = widget.equipment?.isActive ?? true;

    _loadLookups();
  }

  Future<void> _loadLookups() async {
    try {
      final results = await Future.wait<dynamic>([
        _service.getCategories(),
        _service.getStatuses(),
        _service.getOwnershipTypes(),
        _vendorService.getVendors(),
        widget.equipment == null ? _service.getNextCode() : Future.value(''),
      ]);

      setState(() {
        _categories = List<EquipmentCategoryModel>.from(results[0]);
        _statuses = List<EquipmentStatusModel>.from(results[1]);
        _ownershipTypes = List<EquipmentOwnershipTypeModel>.from(results[2]);
        _vendors = List<VendorModel>.from(results[3]);
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

  bool get _isOwned => _ownershipTypes.any((t) => t.id == _selectedOwnershipTypeId && t.code.toLowerCase() == 'owned');
  bool get _isRentalOrLeased => _ownershipTypes.any((t) => t.id == _selectedOwnershipTypeId && t.code.toLowerCase() != 'owned');

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
        'name': _nameController.text,
        'code': _codeController.text,
        'category': _selectedCategoryId,
        'status': _selectedStatusId,
        'ownership_type': _selectedOwnershipTypeId,
        'notes': _notesController.text,
        'purchase_date': _purchaseDateController.text.isEmpty ? null : _purchaseDateController.text,
        'is_active': _isActive,
      };

      if (_isOwned) {
        data['purchase_cost'] = _purchaseCostController.text.isEmpty ? null : _purchaseCostController.text;
      } else if (_isRentalOrLeased) {
        data['rental_details'] = {
          'vendor': _selectedVendorId,
          'rental_start_date': _rentalStartDateController.text,
          'rental_end_date': _rentalEndDateController.text.isEmpty ? null : _rentalEndDateController.text,
          'rental_rate_per_day': _rentalRateController.text,
          'security_deposit': _securityDepositController.text.isEmpty ? null : _securityDepositController.text,
        };
      }

      if (widget.equipment == null) {
        final newEquipment = await _service.createEquipment(data);
        if (_newPhotos.isNotEmpty) {
          await _service.uploadPhotos(newEquipment.id, _newPhotos);
        }
        if (_newAttachments.isNotEmpty) {
          await _service.uploadAttachments(newEquipment.id, _newAttachments);
        }
      } else {
        await _service.updateEquipment(widget.equipment!.id, data);
        if (_newPhotos.isNotEmpty) {
          await _service.uploadPhotos(widget.equipment!.id, _newPhotos);
        }
        if (_newAttachments.isNotEmpty) {
          await _service.uploadAttachments(widget.equipment!.id, _newAttachments);
        }
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

  Future<void> _openAttachment(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open attachment")));
      }
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
        title: Text(widget.equipment == null ? "Register Gear" : "Edit Equipment", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
              const SizedBox(height: 8),
              _sectionHeader("Photos & Media"),
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
                          border: Border.all(color: AppColors.textMuted.withOpacity(0.12), width: 1.5, style: BorderStyle.solid)
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.add_a_photo_outlined, color: AppColors.primary.withOpacity(0.6), size: 32), 
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
              _sectionHeader("Basic Information"),
              const SizedBox(height: 16),
              _label("EQUIPMENT NAME *"),
              _field(_nameController, "e.g., Concrete Mixer", validator: (v) => v == null || v.isEmpty ? "Required" : null),
              const SizedBox(height: 16),
              
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label("ASSET CODE *"),
                  _field(_codeController, "e.g., EQ-001", validator: (v) => v == null || v.isEmpty ? "Required" : null),
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
                      border: Border.all(color: AppColors.textMuted.withOpacity(0.12)),
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

              _label("CATEGORY *"),
              _dropdown<String>(
                value: _selectedCategoryId,
                hint: "Select Category",
                items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
              ),
              const SizedBox(height: 16),

              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label("EQUIPMENT STATUS *"),
                  _dropdown<String>(
                    value: _selectedStatusId,
                    hint: "Select Status",
                    items: _statuses.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (val) => setState(() => _selectedStatusId = val),
                  ),
                ])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _label("OWNERSHIP *"),
                  _dropdown<String>(
                    value: _selectedOwnershipTypeId,
                    hint: "Ownership",
                    items: _ownershipTypes.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                    onChanged: (val) => setState(() => _selectedOwnershipTypeId = val),
                  ),
                ])),
              ]),
              const SizedBox(height: 16),
              _label("GENERAL NOTES"),
              _field(_notesController, "Describe this equipment...", maxLines: 3),

              if (_selectedOwnershipTypeId != null) ...[
                if (_isOwned) ...[
                  const SizedBox(height: 32),
                  _sectionHeader("Purchase Details"),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _label("PURCHASE DATE"),
                      _field(_purchaseDateController, "YYYY-MM-DD"),
                    ])),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _label("PURCHASE COST"),
                      _field(_purchaseCostController, "0.00", keyboardType: TextInputType.number),
                    ])),
                  ]),
                ] else if (_isRentalOrLeased) ...[
                  const SizedBox(height: 32),
                  _sectionHeader("Rental Information"),
                  const SizedBox(height: 16),
                  _label("VENDOR *"),
                  _dropdown<String>(
                    value: _selectedVendorId,
                    hint: "Select Vendor",
                    items: _vendors.map((v) => DropdownMenuItem(value: v.id, child: Text(v.name))).toList(),
                    onChanged: (val) => setState(() => _selectedVendorId = val),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _label("RENTAL START *"),
                      _field(_rentalStartDateController, "YYYY-MM-DD", validator: (v) => v == null || v.isEmpty ? "Required" : null),
                    ])),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _label("DAILY RATE *"),
                      _field(_rentalRateController, "0.00", keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? "Required" : null),
                    ])),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _label("SECURITY DEPOSIT"),
                      _field(_securityDepositController, "0.00", keyboardType: TextInputType.number),
                    ])),
                    const SizedBox(width: 12),
                    Expanded(child: Container()), 
                  ]),
                ],
              ],

              const SizedBox(height: 32),
              _sectionHeader("Documents & Attachments"),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.textMuted.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    ..._existingAttachments.map((att) => ListTile(
                      onTap: () => _openAttachment(att.fileUrl),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
                      ),
                      title: Text(att.fileName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: Text(att.fileSize != null ? "${(att.fileSize! / 1024).toStringAsFixed(1)} KB" : "Document", style: const TextStyle(fontSize: 12)),
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
                        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.upload_file_outlined, color: Colors.grey, size: 20),
                      ),
                      title: Text(file.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text("${(file.size / 1024).toStringAsFixed(1)} KB", style: const TextStyle(fontSize: 12)),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red, size: 20),
                        onPressed: () => setState(() => _newAttachments.remove(file)),
                      ),
                    )),
                    if (_existingAttachments.isEmpty && _newAttachments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text("No documents attached", style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      ),
                    const Divider(height: 1),
                    InkWell(
                      onTap: _pickFiles,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, color: AppColors.primary.withOpacity(0.6), size: 20),
                            const SizedBox(width: 8),
                            const Text("Attach Bills or Manuals", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
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
                      : Text(widget.equipment == null ? "Register Gear" : "Update Equipment",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
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
      {TextInputType? keyboardType, String? Function(String?)? validator, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.textMuted.withOpacity(0.12))),
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
        border: Border.all(color: AppColors.textMuted.withOpacity(0.12)),
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