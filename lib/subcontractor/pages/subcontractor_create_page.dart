import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../services/subcontractor_service.dart';

class SubcontractorCreatePage extends StatefulWidget {
  const SubcontractorCreatePage({super.key});

  @override
  State<SubcontractorCreatePage> createState() => _SubcontractorCreatePageState();
}

class _SubcontractorCreatePageState extends State<SubcontractorCreatePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Basic
  final _nameController = TextEditingController();
  final _specializationController = TextEditingController();
  
  // Contact
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  // Payment
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _accountHolderNameController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;

  final SubcontractorService _service = SubcontractorService();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      await _service.createSubcontractor({
        "name": _nameController.text.trim(),
        "specialization": _specializationController.text.trim(),
        "contact_person": _contactPersonController.text.trim(),
        "phone": _phoneController.text.trim(),
        "email": _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        "address": _addressController.text.trim(),
        "bank_name": _bankNameController.text.trim(),
        "account_number": _accountNumberController.text.trim(),
        "ifsc_code": _ifscCodeController.text.trim(),
        "account_holder_name": _accountHolderNameController.text.trim(),
        "is_active": _isActive,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Subcontractor added successfully!")));
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
    _specializationController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _accountHolderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("New Subcontractor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.background,
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
                _buildSectionTitle("Basic Info"),
                _buildTextField(_nameController, "Company/Individual Name", "e.g. Acme Electrics", true),
                const SizedBox(height: 16),
                _buildTextField(_specializationController, "Specialization", "e.g. Electrical, HVAC", false),
                
                const SizedBox(height: 32),
                _buildSectionTitle("Contact Details"),
                _buildTextField(_contactPersonController, "Contact Person Name", "Primary point of contact", false),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_phoneController, "Phone", "Phone number", false, keyboardType: TextInputType.phone)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_emailController, "Email", "Email address", false, keyboardType: TextInputType.emailAddress)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(_addressController, "Full Address", "Business address", false, keyboardType: TextInputType.multiline, maxLines: 2),

                const SizedBox(height: 32),
                _buildSectionTitle("Payment Details"),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_bankNameController, "Bank Name", "e.g. Chase", false)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_accountNumberController, "Account Number", "123456789", false, keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_ifscCodeController, "Routing/IFSC Code", "Routing code", false)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_accountHolderNameController, "Account Holder", "Name on account", false)),
                  ],
                ),

                const SizedBox(height: 32),
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
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: const Text("Save Subcontractor", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    String hint, 
    bool required, 
    {TextInputType keyboardType = TextInputType.text, int maxLines = 1}
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? "$label *" : label, 
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
      ),
      validator: required ? (v) => v == null || v.isEmpty ? "Required" : null : null,
    );
  }
}
