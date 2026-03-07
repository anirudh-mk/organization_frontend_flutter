import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../services/warehouse_service.dart';

class WarehouseCreatePage extends StatefulWidget {
  const WarehouseCreatePage({super.key});

  @override
  State<WarehouseCreatePage> createState() => _WarehouseCreatePageState();
}

class _WarehouseCreatePageState extends State<WarehouseCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isPrimary = false;
  bool _isActive = true;
  bool _isLoading = false;

  final WarehouseService _service = WarehouseService();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      await _service.createWarehouse({
        "name": _nameController.text,
        "code": _codeController.text,
        "is_primary": _isPrimary,
        "is_active": _isActive,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Warehouse created successfully!")));
        Navigator.pop(context, true); // Return true to indicate the list should refresh
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
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Warehouse", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
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
                const Text("Warehouse Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Warehouse Name", 
                    hintText: "e.g. Main Central Hub",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Name is required" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: "Warehouse Code", 
                    hintText: "e.g. WH-001",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.2))),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Code is required" : null,
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text("Primary Warehouse", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        subtitle: const Text("Set as main organizational hub", style: TextStyle(fontSize: 12)),
                        value: _isPrimary,
                        onChanged: (val) => setState(() => _isPrimary = val),
                        activeColor: AppColors.primary,
                      ),
                      Divider(height: 1, color: AppColors.textMuted.withValues(alpha: 0.1)),
                      SwitchListTile(
                        title: const Text("Active Status", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        subtitle: const Text("Is this warehouse operational?", style: TextStyle(fontSize: 12)),
                        value: _isActive,
                        onChanged: (val) => setState(() => _isActive = val),
                        activeColor: AppColors.success,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: const Text("Create Warehouse", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
