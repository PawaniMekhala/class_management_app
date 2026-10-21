import '../../models/class_model.dart';

class ClassService {
  static final List<InstituteClass> _classes = [
    InstituteClass(
      id: 1,
      instituteId: 1,
      code: 'SIPGAM-CL0001',
      name: '2027 A/L Combined Maths (Theory)',
      level: 'Advanced Level',
      grade: 'Grade 12',
      subject: 'Combined Mathematics',
      maxStudents: 150,
      paymentPlanName: 'A/L monthly fee',
      startDate: DateTime(2026, 9, 1),
      slots: const [
        ClassSlot(
          weekday: 3,
          startTime: '16:00',
          endTime: '18:00',
          hallId: 4,
          hallName: 'Main Hall',
        ),
        ClassSlot(
          weekday: 6,
          startTime: '08:00',
          endTime: '12:00',
          hallId: 4,
          hallName: 'Main Hall',
        ),
      ],
      teachers: const [ClassTeacher(id: 1, name: 'Prasad Wijesinghe')],
      students: const [
        ClassStudent(
          id: 1,
          name: 'Kavindu Perera',
          studentCode: 'SIPGAM-ST0002',
          paymentPlan: 'A/L monthly fee',
          outstandingAmount: 1800,
        ),
        ClassStudent(
          id: 2,
          name: 'Nethmi Silva',
          studentCode: 'SIPGAM-ST0001',
          paymentPlan: 'A/L monthly fee',
        ),
      ],
    ),
    InstituteClass(
      id: 2,
      instituteId: 1,
      code: 'SIPGAM-CL0002',
      name: '2027 A/L Physics',
      level: 'Advanced Level',
      grade: 'Grade 12',
      subject: 'Physics',
      maxStudents: 60,
      startDate: DateTime(2026, 9, 1),
      slots: const [
        ClassSlot(
          weekday: 7,
          startTime: '08:00',
          endTime: '11:00',
          hallId: 2,
          hallName: 'Hall A',
        ),
      ],
      teachers: const [ClassTeacher(id: 1, name: 'Prasad Wijesinghe')],
    ),
    InstituteClass(
      id: 3,
      instituteId: 1,
      code: 'SIPGAM-CL0003',
      name: '2026 A/L Chemistry (Revision)',
      level: 'Advanced Level',
      grade: 'Grade 13',
      subject: 'Chemistry',
      maxStudents: 60,
      startDate: DateTime(2026, 9, 1),
      slots: const [
        ClassSlot(
          weekday: 6,
          startTime: '13:00',
          endTime: '16:00',
          hallId: 3,
          hallName: 'Hall B',
        ),
      ],
      teachers: const [ClassTeacher(id: 2, name: 'Anoma Herath')],
    ),
    InstituteClass(
      id: 4,
      instituteId: 1,
      code: 'SIPGAM-CL0004',
      name: '2026 A/L Biology (Revision)',
      level: 'Advanced Level',
      grade: 'Grade 13',
      subject: 'Biology',
      maxStudents: 60,
      startDate: DateTime(2026, 9, 1),
      slots: const [
        ClassSlot(
          weekday: 7,
          startTime: '13:00',
          endTime: '16:00',
          hallId: 3,
          hallName: 'Hall B',
        ),
      ],
      teachers: const [ClassTeacher(id: 2, name: 'Anoma Herath')],
    ),
  ];

  Future<List<InstituteClass>> getClasses(int instituteId) async {
    // TO DO BACKEND:
    // GET /api/institutes/{instituteId}/classes
    await Future.delayed(const Duration(milliseconds: 250));
    return _classes.where((item) => item.instituteId == instituteId).toList();
  }

  Future<InstituteClass> createClass(InstituteClass item) async {
    // TO DO BACKEND:
    // POST /api/institutes/{item.instituteId}/classes
    // Backend must validate hall/teacher schedule conflicts.

    await Future.delayed(const Duration(milliseconds: 250));

    final id = _classes.isEmpty
        ? 1
        : _classes.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;

    final created = item.copyWith(id: id);
    _classes.add(created);
    return created;
  }

  Future<InstituteClass> getClass(int instituteId, int classId) async {
    // TO DO BACKEND:
    // GET /api/institutes/{instituteId}/classes/{classId}
    return _classes.firstWhere(
      (item) => item.instituteId == instituteId && item.id == classId,
    );
  }

  List<ClassSession> generateSessions(
    InstituteClass item,
    DateTime from,
    DateTime to,
  ) {
    final sessions = <ClassSession>[];

    for (
      var day = DateTime(from.year, from.month, from.day);
      !day.isAfter(to);
      day = day.add(const Duration(days: 1))
    ) {
      if (day.isBefore(item.startDate)) continue;
      if (item.endDate != null && day.isAfter(item.endDate!)) continue;

      for (final slot in item.slots) {
        if (slot.weekday == day.weekday) {
          sessions.add(
            ClassSession(
              date: day,
              startTime: slot.startTime,
              endTime: slot.endTime,
              hallName: slot.hallName,
            ),
          );
        }
      }
    }

    return sessions;
  }
}
