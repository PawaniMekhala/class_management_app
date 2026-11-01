import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../models/institute_settings_model.dart';
import '../../providers/institute_settings_provider.dart';
import '../../widgets/buttons/primary_button.dart';

class EditInstituteProfileScreen extends StatefulWidget {
  final InstituteSettingsModel institute;

  const EditInstituteProfileScreen({super.key, required this.institute});

  @override
  State<EditInstituteProfileScreen> createState() =>
      _EditInstituteProfileScreenState();
}

class _EditInstituteProfileScreenState
    extends State<EditInstituteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _organizationController;
  late final TextEditingController _emailController;
  late final TextEditingController _contactController;
  late final TextEditingController _addressController;

  late DateTime _establishedDate;

  @override
  void initState() {
    super.initState();

    final institute = widget.institute;

    _nameController = TextEditingController(text: institute.name);
    _organizationController = TextEditingController(
      text: institute.organization,
    );
    _emailController = TextEditingController(text: institute.email);
    _contactController = TextEditingController(text: institute.contact);
    _addressController = TextEditingController(text: institute.address);
    _establishedDate = institute.establishedDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _organizationController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 13, color: AppColors.authHeading),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _chooseDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _establishedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selected != null && mounted) {
      setState(() => _establishedDate = selected);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.institute.copyWith(
      name: _nameController.text.trim(),
      organization: _organizationController.text.trim(),
      email: _emailController.text.trim(),
      contact: _contactController.text.trim(),
      address: _addressController.text.trim(),
      establishedDate: _establishedDate,
    );

    final success = await context
        .read<InstituteSettingsProvider>()
        .updateInstitute(updated);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update institute profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        title: const Text('Edit institute profile'),
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
      ),
      body: Consumer<InstituteSettingsProvider>(
        builder: (context, provider, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _field(label: 'Institute name', controller: _nameController),
                _field(
                  label: 'Organization',
                  controller: _organizationController,
                ),
                _field(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                _field(
                  label: 'Contact',
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                ),
                _field(
                  label: 'Address',
                  controller: _addressController,
                  maxLines: 3,
                ),

                const SizedBox(height: 5),

                ListTile(
                  tileColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: const Text(
                    'Established date',
                    style: TextStyle(fontSize: 12),
                  ),
                  subtitle: Text(
                    DateFormat('d MMMM yyyy').format(_establishedDate),
                  ),
                  trailing: const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.primary,
                  ),
                  onTap: _chooseDate,
                ),

                const SizedBox(height: 24),

                PrimaryButton(
                  text: 'Save changes',
                  icon: Icons.save_outlined,
                  isLoading: provider.isSaving,
                  onPressed: provider.isSaving ? null : _save,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
