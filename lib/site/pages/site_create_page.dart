import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../auth/services/token_manager.dart';
import '../models/site_model.dart';
import '../services/site_service.dart';

class SiteCreatePage extends StatefulWidget {
  final SiteModel? site;
  const SiteCreatePage({super.key, this.site});

  @override
  State<SiteCreatePage> createState() => _SiteCreatePageState();
}

class _SiteCreatePageState extends State<SiteCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _quotationDetailsController = TextEditingController();
  DateTime? _expectedStartDate;
  DateTime? _expectedEndDate;
  String _selectedStatus = 'planning';

  final SiteService _service = SiteService();
  bool _isLoading = false;

  final List<String> _statusOptions = [
    'planning',
    'active',
    'on_hold',
    'completed'
  ];

  bool get _isEditing => widget.site != null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final orgId = await TokenManager.getOrganizationId();
      
      if (_isEditing) {
        // Edit Mode
        await _service.updateSite(widget.site!.id, {
          "name": _nameController.text.trim(),
          "status": _selectedStatus,
          "estimated_budget": _budgetController.text.isNotEmpty ? double.tryParse(_budgetController.text) : null,
          "expected_start_date": _expectedStartDate?.toIso8601String().split('T')[0],
          "expected_end_date": _expectedEndDate?.toIso8601String().split('T')[0],
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Site updated successfully!"), backgroundColor: AppColors.success));
          Navigator.pop(context, true);
        }
      } else {
        // Create Mode
        await _service.onboardSite({
          "name": _nameController.text.trim(),
          "status": _selectedStatus,
          "estimated_budget": _budgetController.text.isNotEmpty ? double.tryParse(_budgetController.text) : null,
          "expected_start_date": _expectedStartDate?.toIso8601String().split('T')[0],
          "expected_end_date": _expectedEndDate?.toIso8601String().split('T')[0],
          "organizations": orgId != null ? [orgId] : [],
          "project_data": {
            "name": _nameController.text.trim(),
            "description": _descriptionController.text.trim(),
            "quotation_details": _quotationDetailsController.text.trim(),
          },
          "addresses": [
            {
              "address_line_1": _locationController.text.trim(),
              "is_primary": true
            }
          ],
        });
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
  void initState() {
    super.initState();
    if (widget.site != null) {
      _nameController.text = widget.site!.name;
      _budgetController.text = widget.site!.estimatedBudget?.toString() ?? '';
      _selectedStatus = widget.site!.status;
      _expectedStartDate = widget.site!.expectedStartDate;
      _expectedEndDate = widget.site!.expectedEndDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    _quotationDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(_isEditing ? "Edit Site" : "New Site", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                _sectionHeader("Identity"),
                const SizedBox(height: 16),
                _label("PROJECT NAME *"),
                _field(_nameController, "e.g. Skyline Tower A", validator: (v) => v == null || v.isEmpty ? "Required" : null),
                const SizedBox(height: 16),
                _label("DESCRIPTION"),
                _field(_descriptionController, "Brief project overview...", maxLines: 3),
                const SizedBox(height: 16),
                _label("SITE LOCATION"),
                _field(_locationController, "e.g. 123 Construction St, Downtown"),
                
                const SizedBox(height: 32),
                _sectionHeader("Project Scope"),
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
                            items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStatus = val);
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
                          _field(_budgetController, "e.g. 500000", keyboardType: TextInputType.number),
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
                            onSelect: (date) => setState(() => _expectedStartDate = date),
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
                            onSelect: (date) => setState(() => _expectedEndDate = date),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _label("QUOTATION DETAILS"),
                _field(_quotationDetailsController, "e.g. Total amount, terms...", maxLines: 3),

                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isEditing ? "Update Site Details" : "Initialise Site Hub",
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
            Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Text(
              selectedDate == null ? "Select Date" : "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
              style: TextStyle(fontSize: 14, color: selectedDate == null ? AppColors.textMuted : AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
