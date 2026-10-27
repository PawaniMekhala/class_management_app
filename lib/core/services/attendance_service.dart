import '../../models/attendance_model.dart';

class AttendanceService {
  static final List<AttendanceRecord> _records = [];

  static final Set<String> _endedSessions = {};

  String _sessionKey({
    required int instituteId,
    required int classId,
    required DateTime date,
    required String startTime,
  }) {
    final day = DateTime(date.year, date.month, date.day);

    return '$instituteId-$classId-${day.toIso8601String()}-$startTime';
  }

  List<AttendanceRecord> getRecords({
    required int instituteId,
    required int classId,
    required DateTime date,
    required String startTime,
  }) {
    return _records.where((record) {
      return record.instituteId == instituteId &&
          record.classId == classId &&
          record.sessionDate.year == date.year &&
          record.sessionDate.month == date.month &&
          record.sessionDate.day == date.day &&
          record.sessionStartTime == startTime;
    }).toList();
  }

  bool isSessionEnded({
    required int instituteId,
    required int classId,
    required DateTime date,
    required String startTime,
  }) {
    return _endedSessions.contains(
      _sessionKey(
        instituteId: instituteId,
        classId: classId,
        date: date,
        startTime: startTime,
      ),
    );
  }

  Future<void> checkIn(AttendanceRecord record) async {
    if (isSessionEnded(
      instituteId: record.instituteId,
      classId: record.classId,
      date: record.sessionDate,
      startTime: record.sessionStartTime,
    )) {
      throw Exception('This class session has already ended.');
    }

    final existing = _records.where((item) {
      return item.instituteId == record.instituteId &&
          item.classId == record.classId &&
          item.studentId == record.studentId &&
          item.sessionDate.year == record.sessionDate.year &&
          item.sessionDate.month == record.sessionDate.month &&
          item.sessionDate.day == record.sessionDate.day &&
          item.sessionStartTime == record.sessionStartTime;
    }).toList();

    if (existing.isNotEmpty &&
        existing.first.status == AttendanceStatus.inside) {
      throw Exception('Student is already inside.');
    }

    if (existing.isNotEmpty) {
      throw Exception('Attendance has already been recorded for this session.');
    }

    record.status = AttendanceStatus.inside;
    record.entryTime = DateTime.now();

    _records.add(record);
  }

  Future<void> checkOut(AttendanceRecord record) async {
    if (record.status != AttendanceStatus.inside) {
      throw Exception('Student is not currently inside.');
    }

    record.status = AttendanceStatus.left;
    record.exitTime = DateTime.now();
  }

  Future<void> endSession({
    required int instituteId,
    required int classId,
    required DateTime date,
    required String startTime,
    required List<int> enrolledStudentIds,
  }) async {
    if (isSessionEnded(
      instituteId: instituteId,
      classId: classId,
      date: date,
      startTime: startTime,
    )) {
      throw Exception('This session has already ended.');
    }

    final records = getRecords(
      instituteId: instituteId,
      classId: classId,
      date: date,
      startTime: startTime,
    );

    for (final record in records) {
      if (record.status == AttendanceStatus.inside ||
          record.status == AttendanceStatus.left) {
        record.status = AttendanceStatus.done;

        record.exitTime ??= DateTime.now();
      }
    }

    final recordedIds = records.map((record) => record.studentId).toSet();

    for (final studentId in enrolledStudentIds) {
      if (!recordedIds.contains(studentId)) {
        _records.add(
          AttendanceRecord(
            instituteId: instituteId,
            classId: classId,
            studentId: studentId,
            sessionDate: date,
            sessionStartTime: startTime,
            status: AttendanceStatus.absent,
          ),
        );
      }
    }

    _endedSessions.add(
      _sessionKey(
        instituteId: instituteId,
        classId: classId,
        date: date,
        startTime: startTime,
      ),
    );
  }

  AttendanceRecord? getActiveAttendance({
    required int instituteId,
    required int studentId,
  }) {
    for (final record in _records) {
      if (record.instituteId == instituteId &&
          record.studentId == studentId &&
          record.status == AttendanceStatus.inside) {
        return record;
      }
    }

    return null;
  }
}
