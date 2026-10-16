import 'package:flutter/material.dart';

import '../../core/services/institute_registration_service.dart';
import '../../models/institute_registration_model.dart';
import '../../widgets/dialogs/app_message_dialog.dart';
import '../../widgets/buttons/primary_button.dart';

class RegisterInstituteScreen extends StatefulWidget {
  const RegisterInstituteScreen({super.key});

  @override
  State<RegisterInstituteScreen> createState() =>
      _RegisterInstituteScreenState();
}

class _RegisterInstituteScreenState extends State<RegisterInstituteScreen> {
  final _formKey = GlobalKey<FormState>();

  final _instituteNameController = TextEditingController();
  final _instituteEmailController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _organizationController = TextEditingController();

  final _ownerNameController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerMobileController = TextEditingController();
  final _nicController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _registrationService = InstituteRegistrationService();

  String? _selectedDistrict;
  String? _selectedCity;

  bool _organizationExpanded = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isSubmitting = false;

  // TODO: Replace these temporary lists with your location API
  // or a complete Sri Lankan district/city dataset.
  final List<String> _districts = [
    'Colombo',
    'Gampaha',
    'Kalutara',
    'Kandy',
    'Galle',
    'Matara',
    'Ratnapura',
    'Kegalle',
    'Kurunegala',
  ];

  final Map<String, List<String>> _cities = {
    'Colombo': ['Colombo', 'Dehiwala', 'Maharagama'],
    'Gampaha': ['Gampaha', 'Negombo', 'Ja-Ela'],
    'Kalutara': ['Kalutara', 'Panadura'],
    'Kandy': ['Kandy', 'Peradeniya'],
    'Galle': ['Galle', 'Hikkaduwa'],
    'Matara': ['Matara', 'Weligama'],
    'Ratnapura': ['Ratnapura', 'Balangoda'],
    'Kegalle': ['Kegalle', 'Mawanella'],
    'Kurunegala': ['Kurunegala', 'Kuliyapitiya'],
  };

  @override
  void dispose() {
    _instituteNameController.dispose();
    _instituteEmailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _organizationController.dispose();
    _ownerNameController.dispose();
    _ownerEmailController.dispose();
    _ownerMobileController.dispose();
    _nicController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (_requiredValidator(value) != null) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _phoneValidator(String? value) {
    if (_requiredValidator(value) != null) {
      return 'Mobile number is required';
    }

    final phone = value!.replaceAll(RegExp(r'[\s-]'), '');

    if (!RegExp(r'^0\d{9}$').hasMatch(phone)) {
      return 'Enter a valid 10-digit phone number';
    }

    return null;
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF929BB2)),
      prefixIcon: Icon(icon, size: 19, color: const Color(0xFF7E8AA8)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4E7F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF435BFF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator ?? _requiredValidator,
      style: const TextStyle(fontSize: 13, color: Color(0xFF293B78)),
      decoration: _inputDecoration(hint, icon, suffixIcon: suffixIcon),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF44547F),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: _inputDecoration(hint, icon),
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF7E8AA8)),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item, style: const TextStyle(fontSize: 12)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select $hint' : null,
    );
  }

  Future<void> _registerInstitute() async {
    // Check every required field before calling the API.
    if (!_formKey.currentState!.validate()) {
      await AppMessageDialog.show(
        context,
        title: 'Incomplete Form',
        message: 'Please fill in all required fields correctly.',
        type: AppMessageType.error,
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      await AppMessageDialog.show(
        context,
        title: 'Password Mismatch',
        message: 'Password and confirm password must match.',
        type: AppMessageType.error,
      );
      return;
    }

    final registration = InstituteRegistrationModel(
      instituteName: _instituteNameController.text.trim(),
      instituteEmail: _instituteEmailController.text.trim(),
      contactNumber: _contactController.text.trim(),
      address: _addressController.text.trim(),
      district: _selectedDistrict!,
      city: _selectedCity!,
      organizationName: _organizationController.text.trim().isEmpty
          ? null
          : _organizationController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      ownerEmail: _ownerEmailController.text.trim(),
      ownerMobile: _ownerMobileController.text.trim(),
      ownerNic: _nicController.text.trim().isEmpty
          ? null
          : _nicController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isSubmitting = true);

    try {
      // API INTEGRATION POINT:
      // The service currently simulates registration.
      final success = await _registrationService.registerInstitute(
        registration,
      );

      if (!mounted) return;

      if (success) {
        await AppMessageDialog.show(
          context,
          title: 'Registration Successful',
          message: 'Institute registered successfully.',
          type: AppMessageType.success,
        );

        if (!mounted) return;

        // Return to Sign In after successful registration.
        Navigator.pop(context);
      }
    } catch (error) {
      if (!mounted) return;

      await AppMessageDialog.show(
        context,
        title: 'Registration Failed',
        message: 'Unable to register institute. Please try again.',
        type: AppMessageType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F5FC),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF293B78)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Register your institute',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF293B78),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  children: [
                    _sectionTitle('Institute'),

                    _textField(
                      controller: _instituteNameController,
                      hint: 'Institute name',
                      icon: Icons.account_balance_outlined,
                    ),
                    const SizedBox(height: 10),

                    _textField(
                      controller: _instituteEmailController,
                      hint: 'Institute email',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: _emailValidator,
                    ),
                    const SizedBox(height: 10),

                    _textField(
                      controller: _contactController,
                      hint: 'Contact number',
                      icon: Icons.call_outlined,
                      keyboardType: TextInputType.phone,
                      validator: _phoneValidator,
                    ),
                    const SizedBox(height: 10),

                    _textField(
                      controller: _addressController,
                      hint: 'Address',
                      icon: Icons.home_work_outlined,
                    ),
                    const SizedBox(height: 10),

                    _dropdown(
                      hint: 'District',
                      icon: Icons.map_outlined,
                      value: _selectedDistrict,
                      items: _districts,
                      onChanged: (value) {
                        setState(() {
                          _selectedDistrict = value;
                          _selectedCity = null;
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    _dropdown(
                      hint: 'City / town',
                      icon: Icons.location_city_outlined,
                      value: _selectedCity,
                      items: _selectedDistrict == null
                          ? []
                          : _cities[_selectedDistrict] ?? [],
                      onChanged: _selectedDistrict == null
                          ? (_) {}
                          : (value) {
                              setState(() {
                                _selectedCity = value;
                              });
                            },
                    ),

                    // Optional Organization section
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _organizationExpanded = !_organizationExpanded;
                        });
                      },
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Organization (optional)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF44547F),
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'For a business running several institutes',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF75809C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _organizationExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: const Color(0xFF75809C),
                          ),
                        ],
                      ),
                    ),

                    if (_organizationExpanded) ...[
                      const SizedBox(height: 10),
                      _textField(
                        controller: _organizationController,
                        hint: 'Organization name (optional)',
                        icon: Icons.business_outlined,
                        validator: (_) => null,
                      ),
                    ],

                    const SizedBox(height: 14),
                    _sectionTitle('Owner'),

                    _textField(
                      controller: _ownerNameController,
                      hint: 'Full name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 10),

                    _textField(
                      controller: _ownerEmailController,
                      hint: 'Email',
                      icon: Icons.alternate_email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _emailValidator,
                    ),

                    const Padding(
                      padding: EdgeInsets.only(left: 12, top: 5, bottom: 10),
                      child: Text(
                        'You will sign in with this email',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF929BB2),
                        ),
                      ),
                    ),

                    _textField(
                      controller: _ownerMobileController,
                      hint: 'Mobile number',
                      icon: Icons.smartphone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: _phoneValidator,
                    ),
                    const SizedBox(height: 10),

                    _textField(
                      controller: _nicController,
                      hint: 'NIC (optional)',
                      icon: Icons.badge_outlined,
                      validator: (_) => null,
                    ),
                    const SizedBox(height: 10),

                    _textField(
                      controller: _passwordController,
                      hint: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: !_showPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 8) {
                          return 'Use at least 8 characters';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 19,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    _textField(
                      controller: _confirmPasswordController,
                      hint: 'Confirm password',
                      icon: Icons.lock_outline,
                      obscureText: !_showConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 19,
                        ),
                        onPressed: () {
                          setState(() {
                            _showConfirmPassword = !_showConfirmPassword;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Fixed registration button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: PrimaryButton(
                  text: 'Register Institute',
                  isLoading: _isSubmitting,
                  onPressed: _registerInstitute,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
