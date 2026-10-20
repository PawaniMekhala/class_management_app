import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/academic_subject_service.dart';
import '../../models/academic_subject_model.dart';
import '../../providers/academic_subject_provider.dart';
import '../../widgets/buttons/primary_button.dart';

class SubjectDetailsScreen extends StatefulWidget {
  final int instituteId;
  final int? subjectId;

  const SubjectDetailsScreen({
    super.key,
    required this.instituteId,
    this.subjectId,
  });

  @override
  State<SubjectDetailsScreen> createState() => _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends State<SubjectDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AcademicSubjectService();

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _levels = const [
    'Early Childhood (Nursery)',
    'Primary (Grade 1–5)',
    'Secondary (Grade 6–11)',
    'Advanced Level',
    'Higher Education',
    'Other',
  ];

  // Demo national catalog. Later fetch from backend.
  final Map<String, List<String>> _nationalSubjects = {
    'Secondary (Grade 6–11)': [
      'English Language',
      'Information & Communication Technology',
      'Mathematics',
      'Science',
    ],
    'Advanced Level': [
      'Accounting',
      'Biology',
      'Chemistry',
      'Combined Mathematics (Physical Science)',
      'Economics',
      'Physics',
    ],
  };

  AcademicSubjectModel? _original;
  String? _educationLevel;
  String? _nationalSubject;
  bool _isModule = false;
  bool _isLoading = false;
  bool _isSaving = false;

  bool get _isNew => widget.subjectId == null;

  @override
  void initState() {
    super.initState();

    if (!_isNew) {
      _loadSubject();
    }
  }

  Future<void> _loadSubject() async {
    setState(() => _isLoading = true);

    try {
      final subjects = await _service.getSubjects(widget.instituteId);

      final matches = subjects.where((s) => s.id == widget.subjectId);

      if (matches.isEmpty) {
        throw Exception('Subject not found');
      }

      final subject = matches.first;

      if (!mounted) return;

      setState(() {
        _original = subject;
        _educationLevel = subject.educationLevel;
        _nationalSubject = subject.nationalSubject.isEmpty
            ? null
            : subject.nationalSubject;
        _isModule = subject.isModule;

        _nameController.text = subject.name;
        _codeController.text = subject.code;
        _descriptionController.text = subject.description;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to load subject.')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    if (_educationLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an education level.')),
      );
      return;
    }

    final subject = AcademicSubjectModel(
      id: _original?.id ?? 0,
      instituteId: widget.instituteId,
      name: _nameController.text.trim(),
      educationLevel: _educationLevel!,
      nationalSubject: _nationalSubject ?? '',
      code: _codeController.text.trim(),
      description: _descriptionController.text.trim(),
      classCount: _original?.classCount ?? 0,
      isModule: _isModule,
    );

    setState(() => _isSaving = true);

    try {
      await context.read<AcademicSubjectProvider>().saveSubject(subject);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demo subject saved successfully.')),
      );

      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to save subject.')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete subject?'),
        content: const Text(
          'This subject will be removed from the institute. '
          'Subjects used by classes cannot be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted || _original == null) return;

    try {
      await context.read<AcademicSubjectProvider>().deleteSubject(
        widget.instituteId,
        _original!.id,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    bool requiredField = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        cursorColor: AppColors.primary,
        style: const TextStyle(fontSize: 13, color: AppColors.authHeading),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: AppColors.authIcon),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 17,
          ),
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
          if (requiredField && (value == null || value.trim().isEmpty)) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableNationalSubjects =
        _nationalSubjects[_educationLevel] ?? <String>[];

    final nationalOptions = [
      ...availableNationalSubjects,
      if (_nationalSubject != null &&
          !availableNationalSubjects.contains(_nationalSubject))
        _nationalSubject!,
    ];

    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
        elevation: 0,
        title: Text(
          _isNew ? 'New subject' : (_original?.name ?? 'Subject details'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (!_isNew && _original != null)
            IconButton(
              tooltip: 'Delete subject',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isNew && _original == null
          ? const Center(child: Text('Subject not found'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 35),
                children: [
                  DropdownButtonFormField<String>(
                    key: ValueKey('level-$_educationLevel'),
                    initialValue: _educationLevel,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Education level',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _levels.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text(
                          level,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                    onChanged: _isNew
                        ? (value) {
                            setState(() {
                              _educationLevel = value;
                              _nationalSubject = null;
                            });
                          }
                        : null,
                    validator: (value) =>
                        value == null ? 'Select education level' : null,
                  ),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 6, 0, 15),
                    child: Text(
                      'Used by classes or courses — level and type '
                      'are fixed for existing subjects',
                      style: TextStyle(fontSize: 10, color: AppColors.authIcon),
                    ),
                  ),

                  if (_isNew) ...[
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'This is a module',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _isModule,
                      activeThumbColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() => _isModule = value);
                      },
                    ),
                    const SizedBox(height: 10),
                  ],

                  DropdownButtonFormField<String>(
                    key: ValueKey(
                      'national-$_educationLevel-$_nationalSubject',
                    ),
                    initialValue: _nationalSubject,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'National subject (optional)',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: '',
                        child: Text('No national subject'),
                      ),
                      ...nationalOptions.map((subject) {
                        return DropdownMenuItem(
                          value: subject,
                          child: Text(
                            subject,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _nationalSubject = value == null || value.isEmpty
                            ? null
                            : value;
                      });
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 6, 0, 15),
                    child: Text(
                      'Links your subject to the national catalog '
                      '(for search and teacher matching)',
                      style: TextStyle(fontSize: 10, color: AppColors.authIcon),
                    ),
                  ),

                  _textField(
                    label: 'Subject name',
                    controller: _nameController,
                    requiredField: true,
                  ),

                  _textField(
                    label: 'Code (optional)',
                    controller: _codeController,
                  ),

                  _textField(
                    label: 'Description (optional)',
                    controller: _descriptionController,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 5),

                  PrimaryButton(
                    text: 'Save',
                    isLoading: _isSaving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }
}
