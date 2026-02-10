import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  String? _userRole;

  // Theme Colors
  final Color primaryBlue = const Color(0xFF0066FF);
  final Color bgLight = const Color(0xFFF5F9FF);
  final Color surfaceWhite = Colors.white;
  final Color textNavy = const Color(0xFF1A202C);
  final Color textGrey = const Color(0xFF718096);

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: primaryBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dobController.text = "${picked.day}/${picked.month}/${picked.year}");
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textNavy, size: 20),
          onPressed: () => _currentStep > 0
              ? _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn)
              : Navigator.pop(context),
        ),
        title: _buildStepIndicator(),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) => setState(() => _currentStep = page),
        children: [
          _buildRoleStep(),
          _buildDetailsStep(),
          _buildPasswordStep(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        bool isActive = index <= _currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: index == _currentStep ? 24 : 8,
          decoration: BoxDecoration(
            // UPDATED: .withValues() instead of .withOpacity()
            color: isActive ? primaryBlue : primaryBlue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  Widget _buildRoleStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Text("Join Us", style: TextStyle(color: textNavy, fontSize: 32, fontWeight: FontWeight.bold)),
          Text("Select how you want to use the platform", style: TextStyle(color: textGrey, fontSize: 16)),
          const SizedBox(height: 40),
          _roleCard("Job Seeker", "Finding opportunities", Icons.person_search_rounded),
          const SizedBox(height: 20),
          _roleCard("Owner", "Hiring and managing", Icons.business_rounded),
        ],
      ),
    );
  }

  Widget _roleCard(String title, String subtitle, IconData icon) {
    bool isSelected = _userRole == title;
    return GestureDetector(
      onTap: () {
        setState(() => _userRole = title);
        Future.delayed(const Duration(milliseconds: 400), _nextStep);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? primaryBlue : Colors.transparent, width: 2),
          boxShadow: [
            BoxShadow(
              // UPDATED: .withValues()
              color: primaryBlue.withValues(alpha: isSelected ? 0.1 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // UPDATED: .withValues()
                color: isSelected ? primaryBlue : primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : primaryBlue),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: textNavy, fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(subtitle, style: TextStyle(color: textGrey, fontSize: 14)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded,
              // UPDATED: .withValues()
              color: isSelected ? primaryBlue : textGrey.withValues(alpha: 0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsStep() {
    return _stepWrapper(
      title: "Personal Info",
      subtitle: "Let's get to know you better",
      fields: [
        Row(
          children: [
            Expanded(child: _customField("First Name", _firstNameController, Icons.person_outline_rounded)),
            const SizedBox(width: 16),
            Expanded(child: _customField("Last Name", _lastNameController, Icons.person_outline_rounded)),
          ],
        ),
        const SizedBox(height: 20),
        _customField("Email Address", _emailController, Icons.mail_outline_rounded),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _customField("Mobile", _mobileController, Icons.phone_iphone_rounded)),
            const SizedBox(width: 16),
            Expanded(child: _customField("Birthday", _dobController, Icons.calendar_today_rounded, isReadOnly: true, onTap: () => _selectDate(context))),
          ],
        ),
      ],
      onNext: _nextStep,
    );
  }

  Widget _buildPasswordStep() {
    return _stepWrapper(
      title: "Security",
      subtitle: "Protect your account with a password",
      isFinal: true,
      fields: [
        _customField("Create Password", _passwordController, Icons.lock_outline_rounded, isPassword: true),
        const SizedBox(height: 20),
        _customField("Confirm Password", _confirmPasswordController, Icons.shield_outlined, isPassword: true),
      ],
      onNext: () {
        // Final Registration Logic
      },
    );
  }

  Widget _customField(String label, TextEditingController controller, IconData icon, {bool isPassword = false, bool isReadOnly = false, VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textNavy, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          readOnly: isReadOnly,
          onTap: onTap,
          decoration: InputDecoration(
            filled: true,
            fillColor: surfaceWhite,
            prefixIcon: Icon(icon, color: primaryBlue, size: 20),
            hintText: label,
            // UPDATED: .withValues()
            hintStyle: TextStyle(color: textGrey.withValues(alpha: 0.5), fontSize: 14),
            // UPDATED: .withValues()
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryBlue, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _stepWrapper({required String title, required String subtitle, required List<Widget> fields, required VoidCallback onNext, bool isFinal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Text(title, style: TextStyle(color: textNavy, fontSize: 32, fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(color: textGrey, fontSize: 16)),
          const SizedBox(height: 32),
          ...fields,
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: Text(isFinal ? "Finish Registration" : "Continue", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}