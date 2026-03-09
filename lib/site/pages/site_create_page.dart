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

  // Project & Quotation
  String? _selectedProjectId;

  final List<String> _statusOptions = [
    'planning',
    'active',
    'on_hold',
    'completed'
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final orgId = await TokenManager.getOrganizationId();
      
      if (widget.site != null) {
        // Edit Mode
        await _service.updateSite(widget.site!.id, {
          "name": _nameController.text.trim(),
          "status": _selectedStatus,
          "estimated_budget": _budgetController.text.isNotEmpty ? double.tryParse(_budgetController.text) : null,
          "expected_start_date": _expectedStartDate?.toIso8601String().split('T')[0],
          "expected_end_date": _expectedEndDate?.toIso8601String().split('T')[0],
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Site updated successfully!")));
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Site initialized successfully!")));
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
      // Note: project details are harder to pre-fill without a separate project fetch,
      // but we can at least handle the site fields for now.
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
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(widget.site != null ? "Edit Site" : "Launch New Site"),
        actions: widget.site == null ? null : [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete Site"),
                  content: const Text("Are you sure you want to delete this site permanently?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true), 
                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                setState(() => _isLoading = true);
                try {
                  await _service.deleteSite(widget.site!.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Site deleted.")));
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
            },
          ),
          const SizedBox(width: 8),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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
                const _SectionHeader(title: "Identity", subtitle: "Basic site and branding details"),
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration("Project Name", "e.g. Skyline Tower A", Icons.business_rounded),
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: _buildInputDecoration("Description", "Brief project overview...", Icons.notes_rounded),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _locationController,
                  decoration: _buildInputDecoration("Site Location", "e.g. 123 Construction St, Downtown", Icons.location_on_rounded),
                ),
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration("Estimated Budget", "e.g. 500000", Icons.payments_rounded),
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: _DateSelector(
                        label: "Start Date",
                        selectedDate: _expectedStartDate,
                        onSelect: (date) => setState(() => _expectedStartDate = date),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _DateSelector(
                        label: "End Date",
                        selectedDate: _expectedEndDate,
                        onSelect: (date) => setState(() => _expectedEndDate = date),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                const _SectionHeader(title: "Project Scope", subtitle: "Core status parameters"),
                const SizedBox(height: 20),
                
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: _buildInputDecoration("Status", "Select Status", Icons.info_outline_rounded),
                  items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStatus = val);
                  },
                ),
                
                const SizedBox(height: 20),
                TextFormField(
                  controller: _quotationDetailsController,
                  maxLines: 3,
                  decoration: _buildInputDecoration("Quotation Details", "e.g. Total amount, terms...", Icons.description_rounded),
                ),

                const SizedBox(height: 60),

                // Create Button
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Text(widget.site != null ? "Update Site Details" : "Initialise Site Hub",
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

  InputDecoration _buildInputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
      hintStyle: TextStyle(color: AppColors.textGrey.withValues(alpha: 0.5), fontSize: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textNavy)),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textGrey)),
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime) onSelect;

  const _DateSelector({
    required this.label,
    required this.selectedDate,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
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
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primaryBlue),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.05)),
          ),
        ),
        child: Text(
          selectedDate == null ? "Select" : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}