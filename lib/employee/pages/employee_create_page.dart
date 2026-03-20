import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../services/employee_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/employee_model.dart';

class EmployeeCreatePage extends StatefulWidget {
  const EmployeeCreatePage({super.key});

  @override
  State<EmployeeCreatePage> createState() => _EmployeeCreatePageState();
}

class _EmployeeCreatePageState extends State<EmployeeCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _salaryController = TextEditingController();

  final EmployeeService _service = EmployeeService();
  bool _isLoading = false;

  List<XFile> _newPhotos = [];
  List<PlatformFile> _newAttachments = [];

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final employee = await _service.createEmployee({
        "first_name": _firstNameController.text.trim(),
        "last_name": _lastNameController.text.trim(),
        "mobile_input": _mobileController.text.trim().isEmpty ? [] : [{"number": _mobileController.text.trim()}],
        "email_input": _emailController.text.trim().isEmpty ? [] : [{"email": _emailController.text.trim()}],
        "expected_salary": _salaryController.text.isEmpty ? null : double.tryParse(_salaryController.text),
      });

      if (_newPhotos.isNotEmpty) {
        await _service.uploadPhotos(employee.id, _newPhotos);
      }
      if (_newAttachments.isNotEmpty) {
        await _service.uploadAttachments(employee.id, _newAttachments);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Staff onboarding complete!")));
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _lastNameController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Onboard Staff"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FormSectionHeader(title: "Media", subtitle: "Profile photos and documentation"),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      InkWell(
                        onTap: _pickImages,
                        child: Container(
                          width: 100, height: 120,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white, 
                            borderRadius: BorderRadius.circular(20), 
                            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1), width: 1.5)
                          ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.add_a_photo_outlined, color: AppColors.primaryBlue.withValues(alpha: 0.6), size: 28), 
                            const SizedBox(height: 8), 
                            const Text("Add Photo", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textGrey))
                          ]),
                        ),
                      ),
                      ..._newPhotos.map((file) => Container(
                        width: 100, margin: const EdgeInsets.only(right: 12),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(file.path, width: 100, height: 120, fit: BoxFit.cover),
                            ),
                            Positioned(right: 6, top: 6, child: InkWell(
                              onTap: () => setState(() => _newPhotos.remove(file)),
                              child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 12, color: Colors.white)),
                            )),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),


                const SizedBox(height: 40),

                const _FormSectionHeader(title: "Identity", subtitle: "Full name and professional role"),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _firstNameController,
                  decoration: _buildInputDecoration("First Name", "e.g. Anirudh", Icons.person_outline_rounded),
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: _buildInputDecoration("Last Name", "e.g. MK", Icons.person_outline_rounded),
                ),

                const SizedBox(height: 32),

                const _FormSectionHeader(title: "Contact", subtitle: "How to reach this staff member"),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mobileController,
                  decoration: _buildInputDecoration("Mobile Number", "00000 00000", Icons.phone_android_rounded),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: _buildInputDecoration("Email Address", "email@example.com", Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                ),


                const SizedBox(height: 32),
                const _FormSectionHeader(title: "Financials", subtitle: "Payment logic"),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _salaryController,
                  decoration: _buildInputDecoration("Expected Salary", "0.00", Icons.payments_rounded),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),

                const SizedBox(height: 32),
                const _FormSectionHeader(title: "Attachments", subtitle: "National IDs, KYC or Contracts"),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    children: [
                      ..._newAttachments.map((file) => ListTile(
                        leading: const Icon(Icons.description_outlined, color: AppColors.primaryBlue, size: 20),
                        title: Text(file.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red, size: 16),
                          onPressed: () => setState(() => _newAttachments.remove(file)),
                        ),
                      )),
                      if (_newAttachments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text("No documents attached", style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
                        ),
                      const Divider(height: 1),
                      InkWell(
                        onTap: _pickFiles,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryBlue, size: 18),
                              SizedBox(width: 8),
                              Text("Attach Files", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


                const SizedBox(height: 48),

                Container(
                  width: double.infinity,
                  height: 58,
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
                    child: const Text("Confirm Onboarding",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

class _FormSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _FormSectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textNavy)),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
      ],
    );
  }
}