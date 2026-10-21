import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/academic_course_service.dart';
import '../../core/services/academic_subject_service.dart';
import '../../models/academic_course_model.dart';
import '../../providers/academic_course_provider.dart';
import '../../widgets/buttons/primary_button.dart';

class CourseDetailsScreen extends StatefulWidget {
  final int instituteId;
  final int? courseId;

  const CourseDetailsScreen({
    super.key,
    required this.instituteId,
    this.courseId,
  });

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AcademicCourseService();
  final _subjectService = AcademicSubjectService();

  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _categories = const [
    'Certificate',
    'Diploma',
    'Higher Diploma',
    'Degree',
    'Short Course',
    'Other',
  ];

  // Temporary module options matching the screenshot.
  // Replace with module records from AcademicSubjectService.
  final Map<int, String> _demoModuleNames = {
    101: 'Programming Fundamentals',
    102: 'Database Systems',
    103: 'Web Development',
    11: 'Computer Networks',
  };

  AcademicCourseModel? _original;
  List<CoursePaymentPlanOption> _paymentPlans = [];
  Map<int, String> _moduleNames = {};

  String? _category;
  int? _paymentPlanId;
  final List<int> _moduleIds = [];

  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isNew => widget.courseId == null;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final courses = await _service.getCourses(widget.instituteId);
      final plans = await _service.getPaymentPlans(widget.instituteId);
      final subjects = await _subjectService.getSubjects(widget.instituteId);

      AcademicCourseModel? course;

      if (!_isNew) {
        for (final item in courses) {
          if (item.id == widget.courseId) {
            course = item;
            break;
          }
        }

        if (course == null) throw Exception('Course not found');
      }

      if (!mounted) return;

      setState(() {
        _original = course;
        _paymentPlans = plans;

        // Real institute modules take priority.
        _moduleNames = {
          if (widget.instituteId == 1) ..._demoModuleNames,
          for (final subject in subjects)
            if (subject.isModule) subject.id: subject.name,
        };

        if (course != null) {
          _nameController.text = course.name;
          _durationController.text = course.durationMonths.toString();
          _codeController.text = course.code;
          _descriptionController.text = course.description;
          _category = course.category;
          _paymentPlanId = course.paymentPlanId;
          _moduleIds.addAll(course.moduleIds);
        }

        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load course details.')),
      );
    }
  }

  Future<void> _addModule() async {
    final available = _moduleNames.entries
        .where((entry) => !_moduleIds.contains(entry.key))
        .toList();

    final selectedId = await showModalBottomSheet<int>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: 350,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Add module',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: available.isEmpty
                    ? const Center(child: Text('No more modules available'))
                    : ListView.builder(
                        itemCount: available.length,
                        itemBuilder: (context, index) {
                          final module = available[index];

                          return ListTile(
                            title: Text(module.value),
                            onTap: () =>
                                Navigator.pop(sheetContext, module.key),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || selectedId == null) return;

    setState(() => _moduleIds.add(selectedId));
  }

  Future<void> _saveCourse() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    final course = AcademicCourseModel(
      id: _original?.id ?? 0,
      instituteId: widget.instituteId,
      name: _nameController.text.trim(),
      category: _category!,
      durationMonths: int.parse(_durationController.text.trim()),
      code: _codeController.text.trim(),
      description: _descriptionController.text.trim(),
      paymentPlanId: _paymentPlanId,
      moduleIds: List.of(_moduleIds),
    );

    setState(() => _isSaving = true);

    try {
      await context.read<AcademicCourseProvider>().saveCourse(course);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Demo course saved.')));

      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to save course.')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteCourse() async {
    if (_original == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete course?'),
        content: const Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await context.read<AcademicCourseProvider>().deleteCourse(
        widget.instituteId,
        _original!.id,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to delete course.')));
    }
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool requiredField = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      cursorColor: AppColors.primary,
      style: const TextStyle(fontSize: 13, color: AppColors.authHeading),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.authIcon),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.profileDivider),
        ),
      ),
      validator:
          validator ??
          (value) {
            if (requiredField && (value == null || value.trim().isEmpty)) {
              return 'Please enter $label';
            }
            return null;
          },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.profileBackground,
      appBar: AppBar(
        backgroundColor: AppColors.profileBackground,
        foregroundColor: AppColors.authHeading,
        title: Text(
          _isNew ? 'New course' : (_original?.name ?? 'Course details'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (!_isNew && _original != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteCourse,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isNew && _original == null
          ? const Center(child: Text('Course not found'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 35),
                children: [
                  _field(
                    label: 'Course name',
                    controller: _nameController,
                    requiredField: true,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _category,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(),
                          ),
                          items: _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(
                                category,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _category = value);
                          },
                          validator: (value) =>
                              value == null ? 'Select category' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _field(
                          label: 'Duration (months)',
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final months = int.tryParse(value?.trim() ?? '');
                            if (months == null || months <= 0) {
                              return 'Enter valid months';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  _field(label: 'Code (optional)', controller: _codeController),
                  const SizedBox(height: 12),
                  _field(
                    label: 'Description (optional)',
                    controller: _descriptionController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<int>(
                    initialValue: _paymentPlanId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Payment plan',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int>(
                        value: -1,
                        child: Text('No payment plan'),
                      ),
                      ..._paymentPlans.map(
                        (plan) => DropdownMenuItem(
                          value: plan.id,
                          child: Text(
                            plan.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _paymentPlanId = value == -1 ? null : value;
                      });
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 6, 0, 18),
                    child: Text(
                      'Default fee plan for the course classes',
                      style: TextStyle(fontSize: 10, color: AppColors.authIcon),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Modules (${_moduleIds.length})',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.authHeading,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addModule,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add module'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: _moduleIds.length,
                    onReorderItem: (oldIndex, newIndex) {
                      setState(() {
                        // if (newIndex > oldIndex) newIndex--;
                        final item = _moduleIds.removeAt(oldIndex);
                        _moduleIds.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final moduleId = _moduleIds[index];

                      return Row(
                        key: ValueKey(moduleId),
                        children: [
                          ReorderableDragStartListener(
                            index: index,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.drag_handle,
                                size: 19,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${index + 1}. '
                              '${_moduleNames[moduleId] ?? "Module #$moduleId"}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.authHeading,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _moduleIds.removeAt(index);
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  PrimaryButton(
                    text: 'Save course',
                    isLoading: _isSaving,
                    onPressed: _saveCourse,
                  ),
                ],
              ),
            ),
    );
  }
}
