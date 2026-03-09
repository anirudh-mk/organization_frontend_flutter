import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../auth/services/token_manager.dart';
import '../models/site_model.dart';
import '../services/site_service.dart';
import '../../client/services/client_service.dart';
import '../../client/models/client_model.dart';
import 'dart:convert';

class SiteCreatePage extends StatefulWidget {
  final SiteModel? site;
  const SiteCreatePage({super.key, this.site});

  @override
  State<SiteCreatePage> createState() => _SiteCreatePageState();
}

class _SiteCreatePageState extends State<SiteCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _contractValueController = TextEditingController();
  final _contractRemarksController = TextEditingController();
  final _newClientNameController = TextEditingController();
  
  DateTime? _expectedStartDate;
  DateTime? _expectedEndDate;
  String _selectedStatus = 'planning';
  
  // Client selection
  final ClientService _clientService = ClientService();
  List<ClientModel> _clients = [];
  String? _selectedClientId;
  bool _isNewClient = false;

  final SiteService _service = SiteService();
  bool _isLoading = false;
  final List<File> _images = [];
  final _picker = ImagePicker();

  final List<String> _statusOptions = [
    'planning',
    'active',
    'on_hold',
    'completed'
  ];

  bool get _isEditing => widget.site != null;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    if (widget.site != null) {
      _nameController.text = widget.site!.name;
      _codeController.text = widget.site!.code ?? '';
      _budgetController.text = widget.site!.estimatedBudget?.toString() ?? '';
      _selectedStatus = widget.site!.status.isNotEmpty ? widget.site!.status : 'planning';
      // _selectedStatus = widget.site!.statusDetails?.name ?? 'planning'; // Adjust if status model is used
      _expectedStartDate = widget.site!.expectedStartDate;
      _expectedEndDate = widget.site!.expectedEndDate;
      _selectedClientId = widget.site!.clientLink?.clientId;
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final clients = await _clientService.getClients();
      setState(() {
        _clients = clients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _images.add(File(image.path)));
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final orgId = await TokenManager.getOrganizationId();
      
      Map<String, dynamic>? clientData;
      if (_isNewClient) {
        clientData = {
          "name": _newClientNameController.text.trim(),
          "contract_value": double.tryParse(_contractValueController.text) ?? 0,
          "contract_remarks": _contractRemarksController.text.trim(),
        };
      } else if (_selectedClientId != null) {
        clientData = {
          "client_id": _selectedClientId,
          "contract_value": double.tryParse(_contractValueController.text) ?? 0,
          "contract_remarks": _contractRemarksController.text.trim(),
        };
      }

      if (_isEditing) {
        // Handle update
        // (Simplified for now as user requested onboarding focus)
        final Map<String, dynamic> payload = {
          "name": _nameController.text.trim(),
          "code": _codeController.text.trim(),
          "status": _selectedStatus,
          "estimated_budget": _budgetController.text.isNotEmpty ? double.tryParse(_budgetController.text) : null,
          "expected_start_date": _expectedStartDate?.toIso8601String().split('T')[0],
          "expected_end_date": _expectedEndDate?.toIso8601String().split('T')[0],
        };
        await _service.updateSite(widget.site!.id, payload, images: _images);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Site updated successfully!"), backgroundColor: AppColors.success));
          Navigator.pop(context, true);
        }
      } else {
        await _service.onboardSite(
          name: _nameController.text.trim(),
          organizationId: orgId ?? "",
          status: _selectedStatus,
          budget: double.tryParse(_budgetController.text),
          startDate: _expectedStartDate,
          endDate: _expectedEndDate,
          clientData: clientData,
          addresses: [
            {"line_1": _locationController.text.trim(), "is_primary": true}
          ],
          images: _images,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Site initialized successfully!"), backgroundColor: AppColors.success));
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
    _nameController.dispose();
    _codeController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(_isEditing ? "Edit Site" : "New Site",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader("Site Information"),
                    const SizedBox(height: 16),
                    _label("SITE NAME *"),
                    _field(_nameController, "e.g. Skyline Tower A",
                        validator: (v) =>
                            v == null || v.isEmpty ? "Required" : null),
                    const SizedBox(height: 16),
                    _label("SITE CODE"),
                    _field(_codeController, "e.g. ST-001 (Optional)"),
                    const SizedBox(height: 16),
                    _label("SITE LOCATION"),
                    _field(_locationController,
                        "e.g. 123 Construction St, Downtown"),
                    const SizedBox(height: 32),
                    _sectionHeader("Project Details"),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label("STATUS"),
                              _dropdown<String>(
                                value: _selectedStatus,
                                hint: "Select Status",
                                items: _statusOptions
                                    .map((s) => DropdownMenuItem(
                                        value: s, child: Text(s.toUpperCase())))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedStatus = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label("ESTIMATED BUDGET"),
                              _field(_budgetController, "e.g. 500000",
                                  keyboardType: TextInputType.number),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label("START DATE"),
                              _datePicker(
                                selectedDate: _expectedStartDate,
                                onSelect: (date) =>
                                    setState(() => _expectedStartDate = date),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label("END DATE"),
                              _datePicker(
                                selectedDate: _expectedEndDate,
                                onSelect: (date) =>
                                    setState(() => _expectedEndDate = date),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _sectionHeader("Client & Contract"),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text("EXISTING CLIENT"),
                            selected: !_isNewClient,
                            onSelected: (val) =>
                                setState(() => _isNewClient = !val),
                            selectedColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            labelStyle: TextStyle(
                                color: !_isNewClient
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text("NEW CLIENT"),
                            selected: _isNewClient,
                            onSelected: (val) =>
                                setState(() => _isNewClient = val),
                            selectedColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            labelStyle: TextStyle(
                                color: _isNewClient
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!_isNewClient) ...[
                      _label("SELECT CLIENT"),
                      _dropdown<String>(
                        value: _selectedClientId,
                        hint: "Choose an existing client",
                        items: _clients
                            .map((c) => DropdownMenuItem(
                                value: c.id, child: Text(c.name)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedClientId = val),
                      ),
                    ] else ...[
                      _label("CLIENT NAME"),
                      _field(_newClientNameController, "e.g. Acme Corp",
                          validator: (v) => _isNewClient && (v == null || v.isEmpty)
                              ? "Required for new client"
                              : null),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label("CONTRACT VALUE"),
                              _field(_contractValueController, "e.g. 100000",
                                  keyboardType: TextInputType.number),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _label("CONTRACT REMARKS"),
                    _field(_contractRemarksController,
                        "Any specific terms or notes",
                        maxLines: 2),
                    const SizedBox(height: 32),
                    _sectionHeader("Site Images"),
                    const SizedBox(height: 16),
                    _imagePickerSection(),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _isEditing
                                    ? "Update Site Details"
                                    : "Create Site & Project",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _imagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ..._images.asMap().entries.map((entry) {
              int idx = entry.key;
              File file = entry.value;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(file, width: 90, height: 90, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(idx),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 14, color: AppColors.error),
                      ),
                    ),
                  ),
                ],
              );
            }),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.15), style: BorderStyle.solid),
                ),
                child: const Icon(Icons.add_a_photo_outlined, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ],
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

  Widget _field(TextEditingController controller, String hint, {TextInputType? keyboardType, String? Function(String?)? validator, int maxLines = 1}) {
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
    // Ensure the value exists in items to avoid assertion error
    final bool valueExists = value != null && items.any((item) => item.value == value);
    final T? selectedValue = valueExists ? value : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.12)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: selectedValue,
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          items: enabled ? items : null,
          onChanged: enabled ? onChanged : null,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _datePicker({required DateTime? selectedDate, required Function(DateTime) onSelect}) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) onSelect(date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                selectedDate == null ? "Select Date" : "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                style: TextStyle(fontSize: 14, color: selectedDate == null ? AppColors.textMuted : AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
