import 'package:flutter/material.dart';

import '../core/services/student_service.dart';
import '../models/student_model.dart';

class StudentProvider extends ChangeNotifier {
  final StudentService _service = StudentService();

  List<StudentModel> _students = [];
  String _searchQuery = '';

  bool isLoading = false;
  String? errorMessage;

  int? _currentInstituteId;

  List<StudentModel> get students {
    final query = _searchQuery.trim().toLowerCase();

    return _students.where((student) {
      return student.name.toLowerCase().contains(query) ||
          student.studentCode.toLowerCase().contains(query) ||
          student.grade.toLowerCase().contains(query) ||
          (student.mobile?.contains(query) ?? false) ||
          (student.nic?.toLowerCase().contains(query) ?? false) ||
          (student.qrCode?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void searchStudents(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadStudents(int instituteId) async {
    _currentInstituteId = instituteId;
    _students = [];
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getStudents(instituteId);

      // Ignore an old response if the institute changed.
      if (_currentInstituteId != instituteId) return;

      _students = result
        ..sort((a, b) {
          final dateOrder = b.admittedAt.compareTo(a.admittedAt);
          return dateOrder != 0 ? dateOrder : b.id.compareTo(a.id);
        });
    } catch (error) {
      if (_currentInstituteId != instituteId) return;
      errorMessage = 'Unable to load students.';
    } finally {
      if (_currentInstituteId == instituteId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  // Later, after successful student registration,
  // call loadStudents(instituteId) to refresh the list.
}
