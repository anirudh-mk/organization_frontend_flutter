import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../services/organization_service.dart';
import '../models/organization_model.dart';

class OrganizationCreatePage extends StatefulWidget {
  const OrganizationCreatePage({super.key});

  @override
  State<OrganizationCreatePage> createState() => _OrganizationCreatePageState();
}

class _OrganizationCreatePageState extends State<OrganizationCreatePage> {
  final _formKeyDetails = GlobalKey<FormState>();
  final _formKeyAddress = GlobalKey<FormState>();
  
  // Step 1: Details
  final _nameController = TextEditingController();
  
  // Step 2: Address
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  
  int _currentStep = 0;
  File? _logo;
  final _picker = ImagePicker();
  
  final OrganizationService _organizationService = OrganizationService();
  
  bool _isLoading = false;
  List<OrganizationTypeModel> _types = [];
  OrganizationTypeModel? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    setState(() => _isLoading = true);
    try {
      final types = await _organizationService.getOrganizationTypes();
      if (mounted) {
        setState(() {
          _types = types;
          if (_types.isNotEmpty) {
            _selectedType = _types.first;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load organization types: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _logo = File(image.path));
    }
  }

  Future<void> _createOrganization() async {
    if (!_formKeyDetails.currentState!.validate()) {
      setState(() => _currentStep = 0);
      return;
    }
    
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an organization type')),
      );
      setState(() => _currentStep = 0);
      return;
    }

    setState(() => _isLoading = true);
    
    // Prepare addresses (if filled, although skippable)
    List<Map<String, dynamic>> addresses = [];
    if (_addressLine1Controller.text.trim().isNotEmpty || _cityController.text.trim().isNotEmpty) {
      addresses.add({
        'line_1': _addressLine1Controller.text.trim(),
        'line_2': _addressLine2Controller.text.trim(),
        'city': _cityController.text.trim(),
        'postal_code': _postalCodeController.text.trim(),
        'is_primary': true,
      });
    }

    try {
      await _organizationService.createOrganization(
        _nameController.text.trim(),
        _selectedType!.id,
        addresses: addresses,
        logo: _logo,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Organization'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading && _types.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep == 0) {
                  if (_formKeyDetails.currentState!.validate() && _selectedType != null) {
                    setState(() => _currentStep += 1);
                  } else if (_selectedType == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select an organization type')),
                    );
                  }
                } else {
                  _createOrganization();
                }
              },
              onStepCancel: () {
                FocusScope.of(context).unfocus();
                if (_currentStep > 0) {
                  setState(() => _currentStep -= 1);
                } else {
                  Navigator.pop(context);
                }
              },
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                final isLastStep = _currentStep == 1;
                return Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : details.onStepContinue,
                          child: _isLoading && isLastStep
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(isLastStep ? 'Create Organization' : 'Next'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : details.onStepCancel,
                            child: const Text('Back'),
                          ),
                        ),
                      if (_currentStep == 0)
                        Expanded(
                          child: TextButton(
                            onPressed: _isLoading ? null : details.onStepCancel,
                            child: const Text('Cancel'),
                          ),
                        ),
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text('Basic Details'),
                  content: Form(
                    key: _formKeyDetails,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Setup your workspace",
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: _pickLogo,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppColors.surface,
                                  backgroundImage: _logo != null ? FileImage(_logo!) : null,
                                  child: _logo == null
                                      ? const Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.textMuted)
                                      : null,
                                ),
                              ),
                              if (_logo != null)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: GestureDetector(
                                    onTap: () => setState(() => _logo = null),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "ORGANIZATION NAME",
                          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(hintText: "e.g., Acme Corp", prefixIcon: Icon(Icons.business_rounded, size: 20)),
                          validator: (value) => value == null || value.trim().isEmpty ? "Organization name is required" : null,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "ORGANIZATION TYPE",
                          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.15)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<OrganizationTypeModel>(
                              value: _selectedType,
                              isExpanded: true,
                              hint: const Text("Select type"),
                              items: _types.map((type) => DropdownMenuItem(value: type, child: Text(type.name))).toList(),
                              onChanged: (value) => setState(() => _selectedType = value),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Address (Optional)'),
                  subtitle: const Text('You can skip this step'),
                  content: Form(
                    key: _formKeyAddress,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ADDRESS LINE 1",
                          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _addressLine1Controller,
                          decoration: const InputDecoration(hintText: "Street address, P.O. box, company name, c/o"),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "ADDRESS LINE 2",
                          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _addressLine2Controller,
                          decoration: const InputDecoration(hintText: "Apartment, suite, unit, building, floor, etc."),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "CITY",
                                    style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.2),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _cityController,
                                    decoration: const InputDecoration(hintText: "City"),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "POSTAL CODE",
                                    style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textSecondary, fontSize: 11, letterSpacing: 1.2),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _postalCodeController,
                                    decoration: const InputDecoration(hintText: "ZIP/Postal code"),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                ),
              ],
            ),
      ),
    );
  }
}
