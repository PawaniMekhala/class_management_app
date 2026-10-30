import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/selected_institute_provider.dart';
import '../../providers/staff_role_provider.dart';

class NewRoleScreen extends StatefulWidget {
  const NewRoleScreen({super.key});

  @override
  State<NewRoleScreen> createState() => _NewRoleScreenState();
}

class _NewRoleScreenState extends State<NewRoleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveRole() async {
    if (!_formKey.currentState!.validate()) return;

    final instituteId = context
        .read<SelectedInstituteProvider>()
        .selectedInstituteId;

    final provider = context.read<StaffRoleProvider>();

    if (provider.isSaving) return;

    final success = await provider.createRole(
      instituteId: instituteId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Unable to create role.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
        elevation: 0,
        title: const Text(
          'New role',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.authHeading,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Role name',
                style: TextStyle(fontSize: 12, color: AppColors.authIcon),
              ),

              const SizedBox(height: 6),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter role name',
                  prefixIcon: const Icon(
                    Icons.badge_outlined,
                    color: AppColors.authIcon,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a role name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              const Text(
                'Description (optional)',
                style: TextStyle(fontSize: 12, color: AppColors.authIcon),
              ),

              const SizedBox(height: 6),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe this role',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Consumer<StaffRoleProvider>(
                builder: (context, provider, child) {
                  return SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: provider.isSaving ? null : _saveRole,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: provider.isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(fontWeight: FontWeight.w600),
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
