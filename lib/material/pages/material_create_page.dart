import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/material_models.dart';
import '../services/material_service.dart';

class MaterialCreatePage extends StatefulWidget {
  const MaterialCreatePage({super.key});

  @override
  State<MaterialCreatePage> createState() => _MaterialCreatePageState();
}

class _MaterialCreatePageState extends State<MaterialCreatePage> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _unitController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _basePriceController = TextEditingController();

  MaterialCategoryModel? _selectedCategory;
  List<MaterialCategoryModel> _categories = [];

  bool _isActive = true;
  bool _isLoading = false;
  bool _isLoadingCategories = true;

  final MaterialService _service = MaterialService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _service.getMaterialCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
        // Soft fail if categories fail to load
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      await _service.createMaterial({
        "name": _nameController.text.trim(),
        "code": _codeController.text.trim().toUpperCase(),
        "category": _selectedCategory?.id,
        "unit": _unitController.text.trim(),
        "description": _descriptionController.text.trim(),
        "base_price": _basePriceController.text.isEmpty ? null : double.tryParse(_basePriceController.text),
        "is_active": _isActive,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Material created successfully!")));
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
    _unitController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("New Material", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                const Text("Material Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration("Material Name *", "e.g. Cement 50kg bag"),
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: _buildInputDecoration("Code (Optional)", "e.g. CEM-50"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _unitController,
                        decoration: _buildInputDecoration("Unit *", "e.g. kg, lit, bag"),
                        validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _isLoadingCategories 
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<MaterialCategoryModel>(
                      value: _selectedCategory,
                      decoration: _buildInputDecoration("Category", "Select a category"),
                      items: _categories.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c.name));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                    ),
                
                const SizedBox(height: 16),
                TextFormField(
                  controller: _basePriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _buildInputDecoration("Base Price", "0.00"),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: _buildInputDecoration("Description", "Additional details..."),
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
                    subtitle: const Text("Is this material available for use?", style: TextStyle(fontSize: 12)),
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
                    child: const Text("Create Material", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  InputDecoration _buildInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label, 
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
    );
  }
}
