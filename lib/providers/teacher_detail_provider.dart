import 'package:flutter/foundation.dart';

import '../core/services/teacher_detail_service.dart';
import '../models/teacher_detail_model.dart';
import '../models/teacher_model.dart';

class TeacherDetailProvider extends ChangeNotifier {
  final TeacherDetailService _service = TeacherDetailService();

  TeacherDetailModel? teacher;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadTeacher({
    required int instituteId,
    required TeacherModel selectedTeacher,
  }) async {
    isLoading = true;
    errorMessage = null;
    teacher = null;
    notifyListeners();

    try {
      teacher = await _service.getTeacherDetails(
        instituteId: instituteId,
        teacher: selectedTeacher,
      );
    } catch (_) {
      errorMessage = 'Unable to load teacher details.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
