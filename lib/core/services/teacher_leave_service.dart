import '../../models/teacher_leave_model.dart';

class TeacherLeaveService {
  // Dummy data stored in memory.
  // TODO: Replace with backend API calls later.
  static final Map<int, TeacherLeaveModel> _leaveRequests = {
    1: TeacherLeaveModel(
      id: 1,
      instituteId: 1,
      teacherId: 1,
      teacherName: 'Lahiru Gamage',
      startDate: DateTime(2026, 10, 13),
      endDate: DateTime(2026, 10, 17),
      reason: 'Family wedding',
      status: TeacherLeaveStatus.pending,
      affectedClasses: [
        LeaveAffectedClassModel(
          id: 101,
          className: '2026 A/L Economics',
          classDate: DateTime(2026, 10, 13),
          startTime: '4:00 PM',
          endTime: '6:00 PM',
          hallId: 1,
          hallName: 'Hall B',
          studentCount: 1,
        ),
        LeaveAffectedClassModel(
          id: 102,
          className: '2027 A/L Accounting',
          classDate: DateTime(2026, 10, 17),
          startTime: '8:00 AM',
          endTime: '11:00 AM',
          hallId: 1,
          hallName: 'Hall B',
          studentCount: 1,
        ),
      ],
    ),

    2: TeacherLeaveModel(
      id: 2,
      instituteId: 1,
      teacherId: 2,
      teacherName: 'Nimali Perera',
      startDate: DateTime(2026, 10, 20),
      endDate: DateTime(2026, 10, 21),
      reason: 'Personal leave',
      status: TeacherLeaveStatus.approved,
      decidedAt: DateTime(2026, 10, 18),
      affectedClasses: [
        LeaveAffectedClassModel(
          id: 103,
          className: '2026 A/L Mathematics',
          classDate: DateTime(2026, 10, 20),
          startTime: '9:00 AM',
          endTime: '11:00 AM',
          hallId: 2,
          hallName: 'Hall A',
          studentCount: 12,
          action: LeaveClassAction.cancel,
        ),
      ],
    ),

    3: TeacherLeaveModel(
      id: 3,
      instituteId: 1,
      teacherId: 3,
      teacherName: 'Kasun Silva',
      startDate: DateTime(2026, 10, 24),
      endDate: DateTime(2026, 10, 24),
      reason: 'Medical appointment',
      status: TeacherLeaveStatus.rejected,
      decisionComment: 'Class schedule cannot be changed.',
      decidedAt: DateTime(2026, 10, 22),
      affectedClasses: [
        LeaveAffectedClassModel(
          id: 104,
          className: '2027 A/L Physics',
          classDate: DateTime(2026, 10, 24),
          startTime: '1:00 PM',
          endTime: '3:00 PM',
          hallId: 2,
          hallName: 'Hall A',
          studentCount: 8,
        ),
      ],
    ),

    4: TeacherLeaveModel(
      id: 4,
      instituteId: 2,
      teacherId: 4,
      teacherName: 'Amila Fernando',
      startDate: DateTime(2026, 11, 5),
      endDate: DateTime(2026, 11, 6),
      reason: 'Family function',
      status: TeacherLeaveStatus.pending,
      affectedClasses: [
        LeaveAffectedClassModel(
          id: 105,
          className: '2027 A/L Chemistry',
          classDate: DateTime(2026, 11, 5),
          startTime: '10:00 AM',
          endTime: '12:00 PM',
          hallId: 3,
          hallName: 'Hall C',
          studentCount: 15,
        ),
      ],
    ),
  };

  // TO DO: API GET /teacher-leaves?instituteId={instituteId}
  Future<List<TeacherLeaveModel>> getLeaveRequests(int instituteId) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final requests = _leaveRequests.values
        .where((leave) => leave.instituteId == instituteId)
        .toList();

    requests.sort((a, b) => b.startDate.compareTo(a.startDate));

    return requests;
  }

  // TO DO: API PUT /teacher-leaves/{id}/decision
  Future<TeacherLeaveModel> updateLeaveDecision({
    required int instituteId,
    required int leaveId,
    required TeacherLeaveStatus status,
    required List<LeaveAffectedClassModel> affectedClasses,
    String? decisionComment,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final existing = _leaveRequests[leaveId];

    if (existing == null || existing.instituteId != instituteId) {
      throw Exception('Leave request not found.');
    }

    if (existing.status != TeacherLeaveStatus.pending) {
      throw Exception('This leave request has already been decided.');
    }

    if (status == TeacherLeaveStatus.pending) {
      throw Exception('Please approve or reject the request.');
    }

    if (status == TeacherLeaveStatus.rejected &&
        (decisionComment == null || decisionComment.trim().isEmpty)) {
      throw Exception('A rejection reason is required.');
    }

    if (status == TeacherLeaveStatus.approved) {
      for (final affectedClass in affectedClasses) {
        if (affectedClass.action == LeaveClassAction.substitute &&
            affectedClass.substituteTeacherId == null) {
          throw Exception(
            'Please select a substitute teacher for every substituted class.',
          );
        }

        if (affectedClass.action == LeaveClassAction.move &&
            (affectedClass.movedDate == null ||
                affectedClass.movedStartTime == null ||
                affectedClass.movedEndTime == null ||
                affectedClass.movedHallId == null)) {
          throw Exception(
            'Please complete the new schedule for every moved class.',
          );
        }
      }
    }

    final updated = existing.copyWith(
      status: status,
      affectedClasses: status == TeacherLeaveStatus.approved
          ? affectedClasses
          : existing.affectedClasses,
      decisionComment: decisionComment,
      decidedAt: DateTime.now(),
    );

    _leaveRequests[leaveId] = updated;

    return updated;
  }
}
