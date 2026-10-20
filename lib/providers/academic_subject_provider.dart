import 'package:flutter/foundation.dart';

import '../core/services/academic_subject_service.dart';
import '../models/academic_subject_model.dart';

class AcademicSubjectProvider extends ChangeNotifier {
  final AcademicSubjectService _service = AcademicSubjectService();

  List<AcademicSubjectModel> _allSubjects = [];
  String _search = '';
  int? _currentInstituteId;

  bool isLoading = false;
  String? errorMessage;

  List<AcademicSubjectModel> get subjects {
    final query = _search.trim().toLowerCase();

    return _allSubjects.where((subject) {
      return subject.name.toLowerCase().contains(query) ||
          subject.code.toLowerCase().contains(query) ||
          subject.educationLevel.toLowerCase().contains(query) ||
          subject.nationalSubject.toLowerCase().contains(query);
    }).toList();
  }

  void searchSubjects(String query) {
    _search = query;
    notifyListeners();
  }

  Future<void> loadSubjects(int instituteId) async {
    _currentInstituteId = instituteId;
    _allSubjects = [];
    _search = '';
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getSubjects(instituteId);

      if (_currentInstituteId != instituteId) return;
      _allSubjects = result;
    } catch (_) {
      if (_currentInstituteId != instituteId) return;
      errorMessage = 'Unable to load subjects.';
    } finally {
      if (_currentInstituteId == instituteId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> saveSubject(AcademicSubjectModel subject) async {
    await _service.saveSubject(subject);
    await loadSubjects(subject.instituteId);
  }

  Future<void> deleteSubject(int instituteId, int subjectId) async {
    await _service.deleteSubject(instituteId, subjectId);
    await loadSubjects(instituteId);
  }
}
