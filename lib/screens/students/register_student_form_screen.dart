import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/student_registration_service.dart';
import '../../models/student_registration_model.dart';
import '../../widgets/common/registration_form_field.dart';

class RegisterStudentFormScreen extends StatefulWidget {
  final int instituteId;

  const RegisterStudentFormScreen({super.key, required this.instituteId});

  @override
  State<RegisterStudentFormScreen> createState() =>
      _RegisterStudentFormScreenState();
}

class _GuardianFields {
  final name = TextEditingController();
  final mobile = TextEditingController();
  String relationship = 'Mother';

  void dispose() {
    name.dispose();
    mobile.dispose();
  }
}

class _RegisterStudentFormScreenState extends State<RegisterStudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = StudentRegistrationService();

  final _name = TextEditingController();
  final _school = TextEditingController();
  final _mobile = TextEditingController();
  final _whatsapp = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _fee = TextEditingController();

  final List<_GuardianFields> _guardians = [];

  String? _educationLevel = 'Secondary (Grade 6–11)';
  String? _gender;
  String? _grade;
  String? _medium = 'Sinhala';
  String? _district;
  // String? _city;

  DateTime? _dateOfBirth;
  DateTime _admissionDate = DateTime.now();

  bool _sendSms = true;
  bool _isSubmitting = false;
  XFile? _profilePhoto;

  final _districts = const [
    'Ampara',
    'Anuradhapura',
    'Badulla',
    'Batticaloa',
    'Colombo',
    'Galle',
    'Gampaha',
    'Hambantota',
    'Jaffna',
    'Kalutara',
    'Kandy',
    'Kegalle',
    'Kilinochchi',
    'Kurunegala',
    'Mannar',
    'Matale',
    'Matara',
    'Monaragala',
    'Mullaitivu',
    'Nuwara Eliya',
    'Polonnaruwa',
    'Puttalam',
    'Ratnapura',
    'Trincomalee',
    'Vavuniya',
  ];

  List<String> get _grades {
    switch (_educationLevel) {
      case 'Early Childhood (Nursery)':
        return ['Nursery', 'Kindergarten'];
      case 'Primary (Grade 1–5)':
        return ['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5'];
      case 'Secondary (Grade 6–11)':
        return [
          'Grade 6',
          'Grade 7',
          'Grade 8',
          'Grade 9',
          'Grade 10',
          'Grade 11',
        ];
      case 'Advanced Level (Grade 12–13)':
        return ['Grade 12', 'Grade 13'];
      case 'Higher Education (University / College)':
        return ['Certificate', 'Diploma', 'Degree', 'Postgraduate'];
      default:
        return ['Other'];
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _school,
      _mobile,
      _whatsapp,
      _email,
      _address,
      _fee,
      _cityController,
    ]) {
      controller.dispose();
    }

    for (final guardian in _guardians) {
      guardian.dispose();
    }

    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final photo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1000,
      );

      if (photo != null && mounted) {
        setState(() => _profilePhoto = photo);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to select profile photo.')),
      );
    }
  }

  Future<void> _pickDate({required bool admission}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: admission
          ? _admissionDate
          : (_dateOfBirth ?? DateTime(2010)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (admission) {
        _admissionDate = picked;
      } else {
        _dateOfBirth = picked;

        // TODO: Add institute-approved grade calculation.
        // Keep manual grade selection available.
      }
    });
  }

  Widget _sectionHeading(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
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

  Widget _smallLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: AppColors.authIcon),
      ),
    );
  }

  Widget _dateField({
    required String hint,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 49,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.profileDivider),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              size: 19,
              color: AppColors.authIcon,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value == null ? hint : DateFormat('MMM d, yyyy').format(value),
                style: TextStyle(
                  fontSize: 12,
                  color: value == null
                      ? AppColors.authIcon
                      : AppColors.authHeading,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _guardianEditor(_GuardianFields guardian, int index) {
    return Container(
      key: ObjectKey(guardian),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Parent / guardian ${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.authHeading,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() => _guardians.remove(guardian));
                  // Dispose after the widget has been removed.
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => guardian.dispose(),
                  );
                },
                icon: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.authIcon,
                ),
              ),
            ],
          ),
          RegistrationTextField(
            hint: 'Guardian full name',
            icon: Icons.person_outline,
            controller: guardian.name,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter guardian name'
                : null,
          ),
          const SizedBox(height: 8),
          RegistrationDropdown(
            hint: 'Relationship',
            value: guardian.relationship,
            items: const ['Mother', 'Father', 'Guardian', 'Other'],
            onChanged: (value) {
              setState(() => guardian.relationship = value ?? 'Guardian');
            },
          ),
          const SizedBox(height: 8),
          RegistrationTextField(
            hint: 'Guardian mobile',
            icon: Icons.phone_outlined,
            controller: guardian.mobile,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter guardian mobile';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Future<void> _registerStudent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth.')),
      );
      return;
    }

    if (_gender == null || _grade == null || _district == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the required selections.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final input = StudentRegistrationInput(
        instituteId: widget.instituteId,
        fullName: _name.text.trim(),
        educationLevel: _educationLevel!,
        dateOfBirth: _dateOfBirth!,
        gender: _gender!,
        grade: _grade!,
        medium: _medium!,
        schoolName: _school.text.trim(),
        mobile: _mobile.text.trim(),
        whatsapp: _whatsapp.text.trim(),
        email: _email.text.trim(),
        address: _address.text.trim(),
        district: _district!,
        // city: _city ?? '',
        city: _cityController.text.trim(),
        admissionDate: _admissionDate,
        registrationFee: _fee.text.trim().isEmpty
            ? null
            : double.parse(_fee.text.trim()),
        sendLoginSms: _sendSms,
        guardians: [
          for (var i = 0; i < _guardians.length; i++)
            StudentGuardianInput(
              name: _guardians[i].name.text.trim(),
              relationship: _guardians[i].relationship,
              mobile: _guardians[i].mobile.text.trim(),
              isPrimary: i == 0,
              isEmergency: i == 0,
            ),
        ],
      );

      // TODO: Upload _profilePhoto with the registration request
      // once the backend is connected.
      await _service.registerStudent(input);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Demo registration completed. '
            'Student is not yet saved to a database.',
          ),
        ),
      );

      // Return to the Students screen after successful submission.
      // Navigator.of(context).popUntil((route) => route.isFirst);

      // TODO: Replace with navigation to the Students screen
      // and refresh StudentProvider after real API success.
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to register student. Please try again.'),
        ),
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
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
        elevation: 0,
        title: const Text(
          'Register student',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
          children: [
            _sectionHeading('Student'),

            Center(
              child: InkWell(
                onTap: _pickPhoto,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColors.moduleIconBackground,
                      backgroundImage: _profilePhoto == null
                          ? null
                          : FileImage(File(_profilePhoto!.path)),
                      child: _profilePhoto == null
                          ? const Text(
                              '?',
                              style: TextStyle(
                                color: AppColors.authHeading,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primary,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            const Center(
              child: Text(
                'Profile photo',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: AppColors.authIcon),
              ),
            ),

            const SizedBox(height: 12),

            RegistrationTextField(
              hint: 'Full name',
              icon: Icons.person_outline,
              controller: _name,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter student full name'
                  : null,
            ),

            const SizedBox(height: 8),
            _smallLabel('Education level'),

            RegistrationDropdown(
              hint: 'Education level',
              value: _educationLevel,
              items: const [
                'Early Childhood (Nursery)',
                'Primary (Grade 1–5)',
                'Secondary (Grade 6–11)',
                'Advanced Level (Grade 12–13)',
                'Higher Education (University / College)',
                'Other',
              ],
              onChanged: (value) {
                setState(() {
                  _educationLevel = value;
                  _grade = null;
                });
              },
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _dateField(
                    hint: 'Date of birth',
                    value: _dateOfBirth,
                    onTap: () => _pickDate(admission: false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RegistrationDropdown(
                    hint: 'Gender',
                    value: _gender,
                    items: const ['Female', 'Male', 'Other'],
                    onChanged: (value) {
                      setState(() => _gender = value);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            RegistrationDropdown(
              hint: 'Grade',
              value: _grade,
              items: _grades,
              onChanged: (value) {
                setState(() => _grade = value);
              },
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(12, 5, 0, 0),
              child: Text(
                'Calculated from date of birth; change if needed',
                style: TextStyle(fontSize: 10, color: AppColors.authIcon),
              ),
            ),

            _sectionHeading('School'),
            _smallLabel('Medium'),

            RegistrationDropdown(
              hint: 'Medium',
              value: _medium,
              items: const ['Sinhala', 'Tamil', 'English'],
              onChanged: (value) {
                setState(() => _medium = value);
              },
            ),

            const SizedBox(height: 8),

            RegistrationTextField(
              hint: 'School name',
              icon: Icons.school_outlined,
              controller: _school,
            ),

            _sectionHeading('Contact'),

            RegistrationTextField(
              hint: 'Student mobile (optional for children)',
              icon: Icons.phone_android_outlined,
              controller: _mobile,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 8),

            RegistrationTextField(
              hint: 'WhatsApp number',
              icon: Icons.message_outlined,
              controller: _whatsapp,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 8),

            RegistrationTextField(
              hint: 'Email',
              icon: Icons.mail_outline,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isNotEmpty && !text.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: 8),

            RegistrationTextField(
              hint: 'Address',
              icon: Icons.home_work_outlined,
              controller: _address,
            ),

            const SizedBox(height: 8),

            RegistrationDropdown(
              hint: 'District',
              value: _district,
              items: _districts,
              icon: Icons.map_outlined,
              onChanged: (value) {
                setState(() {
                  _district = value;
                  // _city = null;
                });
              },
            ),

            const SizedBox(height: 8),

            // Temporary city selection. Replace with district-based
            // cities from backend/reference data later.
            RegistrationTextField(
              hint: 'City / town',
              icon: Icons.location_city_outlined,
              controller: _cityController,
            ),

            _sectionHeading('Parents / guardians'),

            ..._guardians.asMap().entries.map(
              (entry) => _guardianEditor(entry.value, entry.key),
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _guardians.add(_GuardianFields());
                  });
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Add parent / guardian',
                  style: TextStyle(fontSize: 12),
                ),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ),

            _sectionHeading('Admission'),
            _smallLabel('Admission date'),

            _dateField(
              hint: 'Admission date',
              value: _admissionDate,
              onTap: () => _pickDate(admission: true),
            ),

            const SizedBox(height: 8),

            RegistrationTextField(
              hint: 'Registration fee (LKR)',
              icon: Icons.payments_outlined,
              controller: _fee,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return null;
                }

                final fee = double.tryParse(value.trim());

                if (fee == null || !fee.isFinite || fee < 0) {
                  return 'Enter a valid registration fee';
                }

                return null;
              },
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(12, 5, 0, 0),
              child: Text(
                "Leave empty to use the institute's default fee",
                style: TextStyle(fontSize: 10, color: AppColors.authIcon),
              ),
            ),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Send login details by SMS',
                style: TextStyle(fontSize: 12, color: AppColors.authHeading),
              ),
              activeThumbColor: AppColors.primary,
              value: _sendSms,
              onChanged: (value) {
                setState(() => _sendSms = value);
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _registerStudent,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.person_add_alt_1, size: 18),
                label: Text(
                  _isSubmitting ? 'Registering...' : 'Register student',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final TextEditingController _cityController = TextEditingController();
}
