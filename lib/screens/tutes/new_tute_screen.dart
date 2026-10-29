import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/class_provider.dart';
import '../../providers/tute_provider.dart';
import '../../models/tute_model.dart';
import '../../core/theme/app_colors.dart';

class NewTuteScreen extends StatefulWidget {
  const NewTuteScreen({super.key});

  @override
  State<NewTuteScreen> createState() => _NewTuteScreenState();
}

class _NewTuteScreenState extends State<NewTuteScreen> {
  final _titleController = TextEditingController();
  final _unitController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'Tute';
  String? _selectedClass;
  bool _isActive = true;

  DateTime _releaseDate = DateTime.now();

  // Temporary classes for UI testing.
  // Later, these will come from ClassProvider.
  // final List<String> _classes = [
  //   '2026 A/L Biology',
  //   '2026 A/L Chemistry',
  //   '2026 A/L Combined Maths',
  //   '2026 A/L Physics',
  // ];

  @override
  void dispose() {
    _titleController.dispose();
    _unitController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectReleaseDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _releaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (selectedDate != null) {
      setState(() {
        _releaseDate = selectedDate;
      });
    }
  }

  Future<void> _saveTute() async {
    if (_titleController.text.trim().isEmpty ||
        _selectedClass == null ||
        _unitController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    try {
      await context.read<TuteProvider>().createTute(
        instituteId: 1, // Temporary institute ID
        classId: int.parse(_selectedClass!),
        name: _titleController.text.trim(),
        unitName: _unitController.text.trim(),
        releaseDate: _releaseDate,
        status: _isActive ? TuteStatus.active : TuteStatus.archived,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tute created successfully!')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to create tute: $e')));
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.authHint),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.profileDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _buildStatusButton(String title, bool active) {
    final selected = _isActive == active;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _isActive = active;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : AppColors.authIcon,
              ),
            ),
          ),
        ),
      ),
    );
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
          'New tute',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            TextField(
              controller: _titleController,
              decoration: _inputDecoration('Title'),
            ),

            const SizedBox(height: 12),

            // Type and Unit Number
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: _inputDecoration('Type'),
                    items: const [
                      DropdownMenuItem(value: 'Tute', child: Text('Tute')),
                      DropdownMenuItem(
                        value: 'Material',
                        child: Text('Material'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    controller: _unitController,
                    decoration: _inputDecoration('Unit no.'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Class
            // DropdownButtonFormField<String>(
            //   initialValue: _selectedClass,
            //   isExpanded: true,
            //   decoration: _inputDecoration('Class'),
            //   items: _classes.map((className) {
            //     return DropdownMenuItem(
            //       value: className,
            //       child: Text(className, overflow: TextOverflow.ellipsis),
            //     );
            //   }).toList(),
            //   onChanged: (value) {
            //     setState(() {
            //       _selectedClass = value;
            //     });
            //   },
            // ),

            // Class
            Consumer<ClassProvider>(
              builder: (context, classProvider, child) {
                final classes = classProvider.allClasses
                    .where((classItem) => classItem.instituteId == 1)
                    .toList();

                return DropdownButtonFormField<String>(
                  initialValue: _selectedClass,
                  isExpanded: true,
                  decoration: _inputDecoration('Class'),
                  items: classes.map((classItem) {
                    return DropdownMenuItem<String>(
                      value: classItem.id.toString(),
                      child: Text(
                        classItem.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClass = value;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 12),

            // Release Date
            InkWell(
              onTap: _selectReleaseDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAF0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_available, color: AppColors.primary),

                    const SizedBox(width: 10),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Release on ${_releaseDate.day}/${_releaseDate.month}/${_releaseDate.year}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.authHeading,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Not handed out before this date',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.authIcon,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Description
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: _inputDecoration('Description (optional)'),
            ),

            const SizedBox(height: 12),

            // Active / Archived
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.profileDivider),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _buildStatusButton('✓  Active', true),
                  _buildStatusButton('Archived', false),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Digital Copy
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),

                  SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No digital copy',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Optional PDF or image, up to 25 MB',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.authIcon,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    'Attach',
                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Save Button
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: _saveTute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save tute',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
