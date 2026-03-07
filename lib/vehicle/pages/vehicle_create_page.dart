import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../services/vehicle_service.dart';

class VehicleCreatePage extends StatefulWidget {
  const VehicleCreatePage({super.key});

  @override
  State<VehicleCreatePage> createState() => _VehicleCreatePageState();
}

class _VehicleCreatePageState extends State<VehicleCreatePage> {
  final _formKey = GlobalKey<FormState>();
  
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _vinController = TextEditingController();
  final _yearController = TextEditingController();
  final _vehicleTypeController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;

  final VehicleService _service = VehicleService();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      await _service.createVehicle({
        "make": _makeController.text.trim(),
        "model": _modelController.text.trim(),
        "license_plate": _licensePlateController.text.trim().toUpperCase(),
        "vin": _vinController.text.isEmpty ? null : _vinController.text.trim().toUpperCase(),
        "year": int.tryParse(_yearController.text),
        "vehicle_type": _vehicleTypeController.text.trim(),
        "is_active": _isActive,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vehicle registered successfully!")));
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
    _makeController.dispose();
    _modelController.dispose();
    _licensePlateController.dispose();
    _vinController.dispose();
    _yearController.dispose();
    _vehicleTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Register Vehicle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                const Text("Core Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _makeController,
                        decoration: _buildInputDecoration("Make", "e.g. Ford"),
                        validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _modelController,
                        decoration: _buildInputDecoration("Model", "e.g. F-150"),
                        validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration("Year", "e.g. 2024"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _vehicleTypeController,
                        decoration: _buildInputDecoration("Type", "e.g. Truck"),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                const Text("Identification", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _licensePlateController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: _buildInputDecoration("License Plate", "123-ABC"),
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vinController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: _buildInputDecoration("VIN (Optional)", "17-character ID"),
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
                    subtitle: const Text("Is this vehicle currently in service?", style: TextStyle(fontSize: 12)),
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
                    child: const Text("Register Vehicle", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
