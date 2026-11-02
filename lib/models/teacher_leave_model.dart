enum TeacherLeaveStatus { pending, approved, rejected }

enum LeaveClassAction { cancel, substitute, move }

class LeaveAffectedClassModel {
  final int id;
  final String className;
  final DateTime classDate;
  final String startTime;
  final String endTime;
  final int hallId;
  final String hallName;
  final int studentCount;

  // Selected arrangement
  final LeaveClassAction action;

  // Substitute option
  final int? substituteTeacherId;

  // Move option
  final DateTime? movedDate;
  final String? movedStartTime;
  final String? movedEndTime;
  final int? movedHallId;

  const LeaveAffectedClassModel({
    required this.id,
    required this.className,
    required this.classDate,
    required this.startTime,
    required this.endTime,
    required this.hallId,
    required this.hallName,
    required this.studentCount,
    this.action = LeaveClassAction.cancel,
    this.substituteTeacherId,
    this.movedDate,
    this.movedStartTime,
    this.movedEndTime,
    this.movedHallId,
  });

  LeaveAffectedClassModel copyWith({
    LeaveClassAction? action,
    int? substituteTeacherId,
    DateTime? movedDate,
    String? movedStartTime,
    String? movedEndTime,
    int? movedHallId,
    bool clearArrangement = false,
  }) {
    return LeaveAffectedClassModel(
      id: id,
      className: className,
      classDate: classDate,
      startTime: startTime,
      endTime: endTime,
      hallId: hallId,
      hallName: hallName,
      studentCount: studentCount,
      action: action ?? this.action,
      substituteTeacherId: clearArrangement
          ? null
          : substituteTeacherId ?? this.substituteTeacherId,
      movedDate: clearArrangement ? null : movedDate ?? this.movedDate,
      movedStartTime: clearArrangement
          ? null
          : movedStartTime ?? this.movedStartTime,
      movedEndTime: clearArrangement ? null : movedEndTime ?? this.movedEndTime,
      movedHallId: clearArrangement ? null : movedHallId ?? this.movedHallId,
    );
  }
}

class TeacherLeaveModel {
  final int id;
  final int instituteId;
  final int teacherId;
  final String teacherName;

  final DateTime startDate;
  final DateTime endDate;
  final String reason;

  final TeacherLeaveStatus status;
  final List<LeaveAffectedClassModel> affectedClasses;

  final String? decisionComment;
  final DateTime? decidedAt;

  const TeacherLeaveModel({
    required this.id,
    required this.instituteId,
    required this.teacherId,
    required this.teacherName,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.affectedClasses,
    this.decisionComment,
    this.decidedAt,
  });

  int get affectedClassCount => affectedClasses.length;

  TeacherLeaveModel copyWith({
    TeacherLeaveStatus? status,
    List<LeaveAffectedClassModel>? affectedClasses,
    String? decisionComment,
    DateTime? decidedAt,
  }) {
    return TeacherLeaveModel(
      id: id,
      instituteId: instituteId,
      teacherId: teacherId,
      teacherName: teacherName,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      status: status ?? this.status,
      affectedClasses: affectedClasses ?? this.affectedClasses,
      decisionComment: decisionComment ?? this.decisionComment,
      decidedAt: decidedAt ?? this.decidedAt,
    );
  }
}
