import 'package:flutter/foundation.dart';

import '../core/services/teacher_service.dart';
import '../models/teacher_model.dart';

class TeacherProvider extends ChangeNotifier {
  final TeacherService _service = TeacherService();

  List<TeacherModel> _teachers = [];
  String _searchQuery = '';
  int? _currentInstituteId;

  bool isLoading = false;
  String? errorMessage;

  List<TeacherModel> get teachers {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) return List.unmodifiable(_teachers);

    return _teachers.where((teacher) {
      return teacher.name.toLowerCase().contains(query) ||
          teacher.teacherCode.toLowerCase().contains(query) ||
          (teacher.nic?.toLowerCase().contains(query) ?? false) ||
          (teacher.mobile?.contains(query) ?? false);
    }).toList();
  }

  void searchTeachers(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadTeachers(int instituteId) async {
    _currentInstituteId = instituteId;
    _teachers = [];
    _searchQuery = '';
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getTeachers(instituteId);

      // Ignore old responses if the admin switched institutes.
      if (_currentInstituteId != instituteId) return;

      _teachers = result;
    } catch (_) {
      if (_currentInstituteId != instituteId) return;

      errorMessage = 'Unable to load teachers.';
    } finally {
      if (_currentInstituteId == instituteId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }
}
