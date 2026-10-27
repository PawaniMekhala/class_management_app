import 'package:flutter/foundation.dart';

import '../core/services/attendance_service.dart';
import '../models/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _service = AttendanceService();

  List<AttendanceRecord> getSessionRecords({
    required int instituteId,
    required int classId,
    required DateTime date,
    required String startTime,
  }) {
    return _service.getRecords(
      instituteId: instituteId,
      classId: classId,
      date: date,
      startTime: startTime,
    );
  }

  bool isSessionEnded({
    required int instituteId,
    required int classId,
    required DateTime date,
    required String startTime,
  }) {
    return _service.isSessionEnded(
      instituteId: instituteId,
      classId: classId,
      date: date,
      startTime: startTime,
    );
  }

  AttendanceRecord? getActiveAttendance({
    required int instituteId,
    required int studentId,
  }) {
    return _service.getActiveAttendance(
      instituteId: instituteId,
      studentId: studentId,
    );
  }

  Future<void> checkIn(AttendanceRecord record) async {
    await _service.checkIn(record);
    notifyListeners();
  }

  Future<void> checkOut(AttendanceRecord record) async {
    await _service.checkOut(record);
    notifyListeners();
  }

  Future<void> endSession({
    required int instituteId,
    required int classId,
    required DateTime date,
    required String startTime,
    required List<int> enrolledStudentIds,
  }) async {
    await _service.endSession(
      instituteId: instituteId,
      classId: classId,
      date: date,
      startTime: startTime,
      enrolledStudentIds: enrolledStudentIds,
    );

    notifyListeners();
  }
}
