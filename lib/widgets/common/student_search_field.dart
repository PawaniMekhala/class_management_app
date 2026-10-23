import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/student_model.dart';
import 'qr_scan_button.dart';

class StudentSearchField extends StatefulWidget {
  final List<StudentModel> students;
  final ValueChanged<List<StudentModel>> onResultsChanged;

  const StudentSearchField({
    super.key,
    required this.students,
    required this.onResultsChanged,
  });

  @override
  State<StudentSearchField> createState() => _StudentSearchFieldState();
}

class _StudentSearchFieldState extends State<StudentSearchField> {
  final TextEditingController _controller = TextEditingController();

  bool _matches(StudentModel student, String query) {
    final q = query.trim().toLowerCase();

    return student.name.toLowerCase().contains(q) ||
        student.studentCode.toLowerCase().contains(q) ||
        (student.mobile?.toLowerCase().contains(q) ?? false) ||
        (student.nic?.toLowerCase().contains(q) ?? false) ||
        (student.qrCode?.toLowerCase().contains(q) ?? false);
  }

  void _search(String value) {
    final query = value.trim();

    if (query.isEmpty) {
      widget.onResultsChanged([]);
      return;
    }

    final results = widget.students
        .where((student) => _matches(student, query))
        .toList();

    widget.onResultsChanged(results);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _search,
      cursorColor: AppColors.primary,
      style: const TextStyle(fontSize: 13, color: AppColors.authHeading),
      decoration: InputDecoration(
        hintText: 'Search student no., code, phone or name',
        hintStyle: const TextStyle(fontSize: 11, color: AppColors.authIcon),
        prefixIcon: QrScanButton(
          scannerTitle: 'Scan student QR',
          onScanned: (code) {
            _controller.text = code;
            _search(code);
          },
        ),
        suffixIcon: const Icon(Icons.search, color: AppColors.authIcon),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
