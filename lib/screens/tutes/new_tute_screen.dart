import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/class_provider.dart';
import '../../providers/tute_provider.dart';
import '../../models/tute_model.dart';
import '../../core/theme/app_colors.dart';

import 'package:file_picker/file_picker.dart';

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

  PlatformFile? _selectedFile;
  int? _selectedFileSize;

  bool _isSaving = false;

  DateTime _releaseDate = DateTime.now();

  // Future<void> _pickAttachment() async {
  //   try {
  //     final result = await FilePicker.platform.pickFiles(
  //       type: FileType.custom,
  //       allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
  //       allowMultiple: false,
  //     );

  //     if (result == null || result.files.isEmpty) {
  //       return;
  //     }

  //     final file = result.files.single;

  //     const maxFileSize = 25 * 1024 * 1024;

  //     if (file.size > maxFileSize) {
  //       if (!mounted) return;

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('File size must not exceed 25 MB.')),
  //       );

  //       return;
  //     }

  //     setState(() {
  //       _selectedFile = file;
  //     });
  //   } catch (e) {
  //     if (!mounted) return;

  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text('Unable to select file: $e')));
  //   }
  // }

  Future<void> _pickAttachment() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (file == null) return;

      final fileSize = await file.length();
      const maxFileSize = 25 * 1024 * 1024;

      if (fileSize > maxFileSize) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File size must not exceed 25 MB.')),
        );
        return;
      }

      setState(() {
        _selectedFile = file;
        _selectedFileSize = fileSize;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Unable to select file: $e')));
    }
  }

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
    if (_isSaving) return;

    if (_titleController.text.trim().isEmpty ||
        _selectedClass == null ||
        _unitController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await context.read<TuteProvider>().createTute(
        instituteId: 1, // TO DO: Use selected institute ID
        classId: int.parse(_selectedClass!),
        name: _titleController.text.trim(),
        unitName: _unitController.text.trim(),
        releaseDate: _releaseDate,
        status: _isActive ? TuteStatus.active : TuteStatus.archived,
        type: _selectedType == 'Tute' ? TuteType.tute : TuteType.material,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),

        // Attachment information
        attachmentName: _selectedFile?.name,
        attachmentPath: _selectedFile?.path,
        attachmentSize: _selectedFileSize,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tute created successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to create tute: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Digital Copy (Optional)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 10),

        InkWell(
          onTap: _pickAttachment,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  _selectedFile == null
                      ? Icons.cloud_upload_outlined
                      : Icons.insert_drive_file_outlined,
                  size: 35,
                  color: AppColors.primary,
                ),

                const SizedBox(height: 10),

                Text(
                  _selectedFile == null
                      ? 'Tap to attach a file'
                      : _selectedFile!.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 5),

                Text(
                  _selectedFile == null
                      ? 'PDF, JPG or PNG (Max 25 MB)'
                      : '${((_selectedFileSize ?? 0) / (1024 * 1024)).toStringAsFixed(2)} MB',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),

        if (_selectedFile != null) ...[
          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedFile = null;
                  _selectedFileSize = null;
                });
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove file'),
            ),
          ),
        ],
      ],
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
            _buildAttachmentSection(),

            const SizedBox(height: 16),

            // Save Button
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveTute,
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
