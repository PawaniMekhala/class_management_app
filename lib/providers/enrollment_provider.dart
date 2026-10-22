import 'package:flutter/foundation.dart';

import '../core/services/enrollment_service.dart';
import '../models/enrollment_model.dart';
import '../models/class_model.dart';

class EnrollmentProvider extends ChangeNotifier {
  final EnrollmentService _service = EnrollmentService();

  List<EnrollmentModel> _records = [];
  String _query = '';
  String _status = 'enrolled';
  int? _instituteId;

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  String get selectedStatus => _status;

  List<EnrollmentModel> get enrollments {
    final query = _query.trim().toLowerCase();

    return _records.where((record) {
      final matchesStatus = record.status == _status;
      final matchesSearch =
          record.studentName.toLowerCase().contains(query) ||
          record.studentCode.toLowerCase().contains(query) ||
          record.className.toLowerCase().contains(query) ||
          record.classCode.toLowerCase().contains(query) ||
          record.subject.toLowerCase().contains(query) ||
          (record.phone?.contains(query) ?? false);

      return matchesStatus && matchesSearch;
    }).toList();
  }

  EnrollmentModel? getById(int id) {
    for (final record in _records) {
      if (record.id == id) return record;
    }
    return null;
  }

  void setStatus(String value) {
    _status = value;
    notifyListeners();
  }

  void search(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> load(int instituteId) async {
    _instituteId = instituteId;
    _records = [];
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getEnrollments(instituteId);
      if (_instituteId != instituteId) return;
      _records = result;
    } catch (_) {
      if (_instituteId == instituteId) {
        errorMessage = 'Unable to load enrollments.';
      }
    } finally {
      if (_instituteId == instituteId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> enroll({
    required int instituteId,
    required int studentId,
    required String studentName,
    required String studentCode,
    required String? studentPhone,
    required String studentGrade,
    required InstituteClass selectedClass,
    required String paymentPlan,
  }) async {
    isSaving = true;
    notifyListeners();

    try {
      await _service.enroll(
        instituteId: instituteId,
        studentId: studentId,
        studentName: studentName,
        studentCode: studentCode,
        studentPhone: studentPhone,
        studentGrade: studentGrade,
        selectedClass: selectedClass,
        paymentPlan: paymentPlan,
      );

      if (_instituteId == instituteId) {
        _records = await _service.getEnrollments(instituteId);
        _status = 'enrolled';
        _query = '';
      }
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> changeStatus(EnrollmentModel record, String status) async {
    final updated = await _service.updateStatus(
      record.instituteId,
      record.id,
      status,
    );

    final index = _records.indexWhere((r) => r.id == updated.id);

    if (index != -1) {
      _records[index] = updated;
      notifyListeners();
    }
  }
}
