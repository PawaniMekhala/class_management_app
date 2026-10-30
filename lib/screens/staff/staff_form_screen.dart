import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/staff_model.dart';
import '../../providers/staff_provider.dart';
import '../../providers/selected_institute_provider.dart';

class StaffFormScreen extends StatefulWidget {
  final StaffModel? staff;

  const StaffFormScreen({super.key, this.staff});

  @override
  State<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends State<StaffFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _designationController;

  String? _selectedRole;

  bool get _isEditing => widget.staff != null;

  final List<String> _roles = [
    'Institute Admin',
    'Cashier',
    'Gate Officer',
    'Learning Material Distributor',
    'Front Desk',
    'Owner',
  ];

  @override
  void initState() {
    super.initState();

    final staff = widget.staff;

    _nameController = TextEditingController(text: staff?.name ?? '');

    _mobileController = TextEditingController(text: staff?.mobile ?? '');

    _emailController = TextEditingController(text: staff?.email ?? '');

    _designationController = TextEditingController(
      text: staff?.designation ?? '',
    );

    _selectedRole = staff?.role;

    // Keep an existing role visible even if it is not
    // in the temporary dummy role list.
    if (_selectedRole != null && !_roles.contains(_selectedRole)) {
      _roles.add(_selectedRole!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.authIcon),
      prefixIcon: Icon(icon, color: AppColors.authIcon, size: 19),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 5),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppColors.authIcon),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13, color: AppColors.authHeading),
          decoration: _inputDecoration(hint: hint, icon: icon),
          validator: validator,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _mobileValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }

    final mobile = value.trim();

    if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
      return 'Enter a valid 10-digit mobile number';
    }

    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final email = value.trim();

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  Future<void> _saveStaff() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<StaffProvider>();

    if (provider.isSaving) return;

    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final email = _emailController.text.trim();
    final designation = _designationController.text.trim();

    bool success;

    if (_isEditing) {
      final updatedStaff = widget.staff!.copyWith(
        name: name,
        mobile: mobile,
        email: email,
        role: _selectedRole!,
        designation: designation,
      );

      success = await provider.updateStaff(updatedStaff);
    } else {
      final instituteId = context
          .read<SelectedInstituteProvider>()
          .selectedInstituteId;

      success = await provider.createStaff(
        instituteId: instituteId,
        name: name,
        mobile: mobile,
        email: email,
        role: _selectedRole!,
        designation: designation,
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Unable to save staff.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,

      appBar: AppBar(
        backgroundColor: AppColors.authBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.authHeading),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit staff' : 'Register staff',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.authHeading,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Full name
              _buildTextField(
                label: 'Full name',
                hint: 'Enter full name',
                icon: Icons.person_outline,
                controller: _nameController,
                validator: _requiredValidator,
              ),

              // Mobile number
              _buildTextField(
                label: 'Mobile number',
                hint: 'Enter mobile number',
                icon: Icons.phone_android_outlined,
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                validator: _mobileValidator,
              ),

              // Email
              _buildTextField(
                label: 'Email',
                hint: 'Enter email address',
                icon: Icons.email_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: _emailValidator,
              ),

              // Role dropdown
              _buildLabel('Role'),

              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                isExpanded: true,
                decoration: _inputDecoration(
                  hint: 'Select role',
                  icon: Icons.admin_panel_settings_outlined,
                ),
                hint: const Text(
                  'Select role',
                  style: TextStyle(fontSize: 12, color: AppColors.authIcon),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(
                      role,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.authHeading,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Designation
              _buildTextField(
                label: 'Designation (optional)',
                hint: 'Designation (optional)',
                icon: Icons.work_outline,
                controller: _designationController,
              ),

              const SizedBox(height: 4),

              // Save button
              Consumer<StaffProvider>(
                builder: (context, provider, child) {
                  return SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: provider.isSaving ? null : _saveStaff,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: provider.isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
