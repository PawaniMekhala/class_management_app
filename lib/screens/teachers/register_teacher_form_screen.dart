import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/teacher_registration_service.dart';
import '../../models/teacher_registration_model.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/common/privacy_setting_tile.dart';

class RegisterTeacherFormScreen extends StatefulWidget {
  final int instituteId;

  const RegisterTeacherFormScreen({super.key, required this.instituteId});

  @override
  State<RegisterTeacherFormScreen> createState() =>
      _RegisterTeacherFormScreenState();
}

class _RegisterTeacherFormScreenState extends State<RegisterTeacherFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = TeacherRegistrationService();
  final _imagePicker = ImagePicker();

  final _nameController = TextEditingController();
  final _nicController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _aboutController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  // Demo options. Later load these from the backend.
  final List<String> _districts = [
    'Colombo',
    'Gampaha',
    'Kalutara',
    'Kandy',
    'Galle',
    'Matara',
    'Kurunegala',
    'Ratnapura',
    'Kegalle',
    'Anuradhapura',
  ];

  final List<String> _availableSubjects = [
    'Accounting',
    'Biology',
    'Business Studies',
    'Chemistry',
    'Combined Mathematics',
    'Economics',
    'English Language',
    'General English',
    'ICT',
    'Mathematics',
    'Physics',
    'Science',
  ];

  final List<String> _selectedSubjects = [];

  String? _district;
  XFile? _photo;

  bool _publishMobile = false;
  bool _publishAddress = false;
  bool _sendLoginSms = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nicController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _qualificationsController.dispose();
    _aboutController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1000,
      );

      if (photo != null && mounted) {
        setState(() => _photo = photo);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to select profile photo.')),
      );
    }
  }

  Future<void> _addSubject() async {
    final remaining = _availableSubjects
        .where((s) => !_selectedSubjects.contains(s))
        .toList();

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        String query = '';

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = remaining
                .where(
                  (subject) =>
                      subject.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  MediaQuery.viewInsetsOf(context).bottom + 16,
                ),
                child: SizedBox(
                  height: 380,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select subject',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        autofocus: true,
                        onChanged: (value) {
                          setSheetState(() => query = value);
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search subjects',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(child: Text('No subjects available'))
                            : ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final subject = filtered[index];

                                  return ListTile(
                                    title: Text(subject),
                                    onTap: () {
                                      Navigator.pop(sheetContext, subject);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || selected == null) return;

    setState(() {
      if (!_selectedSubjects.contains(selected)) {
        _selectedSubjects.add(selected);
      }
    });
  }

  Future<void> _registerTeacher() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    if (_selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one subject.')),
      );
      return;
    }

    final input = TeacherRegistrationModel(
      instituteId: widget.instituteId,
      fullName: _nameController.text.trim(),
      nic: _nicController.text.trim(),
      mobile: _mobileController.text.trim(),
      publishMobile: _publishMobile,
      email: _emailController.text.trim(),
      qualifications: _qualificationsController.text.trim(),
      about: _aboutController.text.trim(),
      address: _addressController.text.trim(),
      district: _district!,
      city: _cityController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      publishAddress: _publishAddress,
      subjects: List.of(_selectedSubjects),
      sendLoginSms: _sendLoginSms,
      photoPath: _photo?.path,
    );

    setState(() => _isSubmitting = true);

    try {
      await _service.registerTeacher(input);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demo registration completed. No data saved yet.'),
        ),
      );

      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to register teacher.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool requiredField = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        cursorColor: AppColors.primary,
        style: const TextStyle(fontSize: 13, color: AppColors.authHeading),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 19, color: AppColors.authIcon),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.profileDivider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
        validator: (value) {
          final text = value?.trim() ?? '';

          if (requiredField && text.isEmpty) {
            return 'Please enter $label';
          }

          if (text.isNotEmpty &&
              label == 'Email' &&
              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
            return 'Enter a valid email address';
          }

          if (text.isNotEmpty &&
              label == 'Mobile number' &&
              !RegExp(r'^\+?[0-9]{9,15}$').hasMatch(text)) {
            return 'Enter a valid mobile number';
          }

          return null;
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.authHeading,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        title: const Text(
          'Register teacher',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile photo
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickPhoto,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: AppColors.moduleIconBackground,
                            child: _photo == null
                                ? const Text(
                                    '?',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.authHeading,
                                    ),
                                  )
                                : const Icon(
                                    Icons.check,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: -3,
                            child: CircleAvatar(
                              radius: 13,
                              backgroundColor: AppColors.primary,
                              child: const Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _photo == null
                          ? 'Profile photo (optional)'
                          : 'Photo selected — tap to change',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.authHeading,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _field(
                controller: _nameController,
                label: 'Full name',
                icon: Icons.person_outline,
                requiredField: true,
              ),
              _field(
                controller: _nicController,
                label: 'NIC',
                icon: Icons.badge_outlined,
                requiredField: true,
              ),
              _field(
                controller: _mobileController,
                label: 'Mobile number',
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
                requiredField: true,
              ),

              PrivacySettingTile(
                title: 'Publish mobile number',
                description: _publishMobile
                    ? 'Public — visible on the teacher profile'
                    : 'Private — teacher and authorized admins only',
                isPublic: _publishMobile,
                onChanged: (value) {
                  setState(() => _publishMobile = value);
                },
              ),

              const SizedBox(height: 12),

              _field(
                controller: _emailController,
                label: 'Email',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              _field(
                controller: _qualificationsController,
                label: 'Qualifications',
                icon: Icons.workspace_premium_outlined,
                maxLines: 2,
              ),
              _field(
                controller: _aboutController,
                label: 'About (optional)',
                icon: Icons.info_outline,
                maxLines: 3,
              ),

              _sectionTitle('Address'),

              _field(
                controller: _addressController,
                label: 'Street address',
                icon: Icons.home_work_outlined,
                maxLines: 2,
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: DropdownButtonFormField<String>(
                  initialValue: _district,
                  decoration: InputDecoration(
                    labelText: 'District',
                    prefixIcon: const Icon(
                      Icons.map_outlined,
                      color: AppColors.authIcon,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _districts
                      .map(
                        (district) => DropdownMenuItem(
                          value: district,
                          child: Text(district),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _district = value);
                  },
                  validator: (value) =>
                      value == null ? 'Select a district' : null,
                ),
              ),

              _field(
                controller: _cityController,
                label: 'City / town',
                icon: Icons.location_city_outlined,
                requiredField: true,
              ),
              _field(
                controller: _postalCodeController,
                label: 'ZIP / Postal code',
                icon: Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.text,
              ),

              PrivacySettingTile(
                title: 'Publish address',
                description: _publishAddress
                    ? 'Public — visible on the teacher profile'
                    : 'Private — teacher and authorized admins only',
                isPublic: _publishAddress,
                onChanged: (value) {
                  setState(() => _publishAddress = value);
                },
              ),

              _sectionTitle('Subjects'),

              const Text(
                'Select the subjects this teacher will teach '
                'at the current institute.',
                style: TextStyle(fontSize: 11, color: AppColors.authIcon),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _addSubject,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add subject'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              if (_selectedSubjects.isEmpty)
                const Text(
                  'No subjects selected',
                  style: TextStyle(fontSize: 11, color: AppColors.authIcon),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedSubjects.map((subject) {
                    return InputChip(
                      label: Text(
                        subject,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onDeleted: () {
                        setState(() {
                          _selectedSubjects.remove(subject);
                        });
                      },
                      deleteIconColor: AppColors.primary,
                      backgroundColor: AppColors.moduleIconBackground,
                    );
                  }).toList(),
                ),

              const SizedBox(height: 22),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Send login details by SMS',
                  style: TextStyle(fontSize: 12, color: AppColors.authHeading),
                ),
                value: _sendLoginSms,
                activeThumbColor: AppColors.primary,
                onChanged: (value) {
                  setState(() => _sendLoginSms = value);
                },
              ),

              const SizedBox(height: 16),

              PrimaryButton(
                text: 'Register teacher',
                icon: Icons.person_add_alt_1,
                isLoading: _isSubmitting,
                onPressed: _registerTeacher,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
