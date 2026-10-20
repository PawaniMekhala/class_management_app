import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/dialogs/app_message_dialog.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onVisibilityPressed,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      validator: validator,
      style: const TextStyle(fontSize: 13, color: AppColors.authHeading),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: AppColors.authHint),
        prefixIcon: const Icon(
          Icons.lock_outline,
          size: 19,
          color: AppColors.authIcon,
        ),
        suffixIcon: IconButton(
          onPressed: onVisibilityPressed,
          icon: Icon(
            isVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.authIcon,
            size: 19,
          ),
        ),
        filled: true,
        fillColor: AppColors.authFieldBackground,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.authFieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      await AppMessageDialog.show(
        context,
        title: 'Incomplete Form',
        message: 'Please fill in all password fields correctly.',
        type: AppMessageType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TO DO: BACKEND API INTEGRATION
      //
      // This screen currently demonstrates a change-password form.
      //
      // For a signed-in user, the backend should:
      // 1. Authenticate the user.
      // 2. Verify the current password.
      // 3. Validate the new password.
      // 4. Update the stored password hash securely.
      //
      // Never store passwords in SharedPreferences or logs.

      // TEMPORARY: Simulate a request.
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // Demo feedback only: no password has been changed.
      await AppMessageDialog.show(
        context,
        title: 'Demo Completed',
        message: 'The password form is valid. Connect the backend API to change the password.',
        type: AppMessageType.info,
      );
    } catch (error) {
      if (!mounted) return;

      await AppMessageDialog.show(
        context,
        title: 'Password Change Failed',
        message: 'Unable to change password. Please try again.',
        type: AppMessageType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      appBar: AppBar(
        backgroundColor: AppColors.authBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Change password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.authHeading,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Large top space matching your screenshot.
                      SizedBox(height: constraints.maxHeight * 0.28),

                      _passwordField(
                        controller: _currentPasswordController,
                        hint: 'Current password',
                        isVisible: _showCurrentPassword,
                        onVisibilityPressed: () {
                          setState(() {
                            _showCurrentPassword = !_showCurrentPassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter your current password';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      _passwordField(
                        controller: _newPasswordController,
                        hint: 'New password',
                        isVisible: _showNewPassword,
                        onVisibilityPressed: () {
                          setState(() {
                            _showNewPassword = !_showNewPassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter a new password';
                          }
                          if (value.length < 8) {
                            return 'Use at least 8 characters';
                          }
                          if (value == _currentPasswordController.text) {
                            return 'Choose a different password';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      _passwordField(
                        controller: _confirmPasswordController,
                        hint: 'Confirm new password',
                        isVisible: _showConfirmPassword,
                        onVisibilityPressed: () {
                          setState(() {
                            _showConfirmPassword = !_showConfirmPassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirm your new password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      PrimaryButton(
                        text: 'Change password',
                        isLoading: _isLoading,
                        onPressed: _changePassword,
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
