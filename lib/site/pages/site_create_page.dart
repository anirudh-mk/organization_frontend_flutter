import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../services/site_service.dart';

class SiteCreatePage extends StatefulWidget {
  const SiteCreatePage({super.key});

  @override
  State<SiteCreatePage> createState() => _SiteCreatePageState();
}

class _SiteCreatePageState extends State<SiteCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  String _selectedStatus = 'PLANNING';

  final SiteService _service = SiteService();
  bool _isLoading = false;

  final List<String> _statusOptions = [
    'PLANNING',
    'ACTIVE',
    'ON_HOLD',
    'COMPLETED'
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      await _service.createSite({
        "name": _nameController.text.trim(),
        "code": _codeController.text.trim(),
        "status": _selectedStatus,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Site initialized successfully!")));
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
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Launch New Site"),
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
                  controller: _codeController,
                  decoration: _buildInputDecoration("Site Code", "e.g. SKY-A", Icons.tag_rounded),
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 40),
                const _SectionHeader(title: "Project Scope", subtitle: "Core status parameters"),
                const SizedBox(height: 20),
                
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: _buildInputDecoration("Status", "Select Status", Icons.info_outline_rounded),
                  items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStatus = val);
                  },
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
                    child: const Text("Initialise Site Hub",
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