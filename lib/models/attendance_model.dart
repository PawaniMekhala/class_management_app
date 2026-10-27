enum AttendanceStatus { notEntered, inside, left, done, absent }

class AttendanceRecord {
  final int instituteId;
  final int classId;
  final int studentId;
  final DateTime sessionDate;
  final String sessionStartTime;

  AttendanceStatus status;
  DateTime? entryTime;
  DateTime? exitTime;

  AttendanceRecord({
    required this.instituteId,
    required this.classId,
    required this.studentId,
    required this.sessionDate,
    required this.sessionStartTime,
    this.status = AttendanceStatus.notEntered,
    this.entryTime,
    this.exitTime,
  });
}
