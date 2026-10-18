import 'package:flutter/foundation.dart';

import '../core/services/student_detail_service.dart';
import '../models/student_detail_model.dart';

class StudentDetailProvider extends ChangeNotifier {
  final StudentDetailService _service = StudentDetailService();

  StudentDetailModel? student;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadStudent({
    required int instituteId,
    required int studentId,
    required String studentName,
    required String studentCode,
    required String grade,
  }) async {
    isLoading = true;
    errorMessage = null;
    student = null;
    notifyListeners();

    try {
      student = await _service.getStudentDetails(
        instituteId: instituteId,
        studentId: studentId,
        studentName: studentName,
        studentCode: studentCode,
        grade: grade,
      );
    } catch (e) {
      errorMessage = 'Unable to load student details.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
