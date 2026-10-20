import 'package:flutter/foundation.dart';

import '../core/services/academic_course_service.dart';
import '../models/academic_course_model.dart';

class AcademicCourseProvider extends ChangeNotifier {
  final AcademicCourseService _service = AcademicCourseService();

  List<AcademicCourseModel> _courses = [];
  String _searchQuery = '';
  int? _currentInstituteId;

  bool isLoading = false;
  String? errorMessage;

  List<AcademicCourseModel> get courses {
    final query = _searchQuery.trim().toLowerCase();

    return _courses.where((course) {
      return course.name.toLowerCase().contains(query) ||
          course.category.toLowerCase().contains(query) ||
          course.code.toLowerCase().contains(query);
    }).toList();
  }

  void searchCourses(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadCourses(int instituteId) async {
    _currentInstituteId = instituteId;
    _courses = [];
    _searchQuery = '';
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getCourses(instituteId);

      if (_currentInstituteId != instituteId) return;

      _courses = result;
    } catch (_) {
      if (_currentInstituteId != instituteId) return;
      errorMessage = 'Unable to load courses.';
    } finally {
      if (_currentInstituteId == instituteId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> saveCourse(AcademicCourseModel course) async {
    await _service.saveCourse(course);
    await loadCourses(course.instituteId);
  }

  Future<void> deleteCourse(int instituteId, int courseId) async {
    await _service.deleteCourse(instituteId, courseId);
    await loadCourses(instituteId);
  }
}
