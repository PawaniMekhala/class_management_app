class ClassSlot {
  final int weekday; // 1 = Monday, 7 = Sunday
  final String startTime; // HH:mm
  final String endTime;
  final int hallId;
  final String hallName;

  const ClassSlot({
    required this.weekday,
    required this.startTime,
    required this.endTime,
    required this.hallId,
    required this.hallName,
  });
}

class ClassStudent {
  final int id;
  final String name;
  final String studentCode;
  final String paymentPlan;
  final double? outstandingAmount;

  const ClassStudent({
    required this.id,
    required this.name,
    required this.studentCode,
    required this.paymentPlan,
    this.outstandingAmount,
  });
}

class ClassTeacher {
  final int id;
  final String name;
  final String role;

  const ClassTeacher({
    required this.id,
    required this.name,
    this.role = 'Main teacher',
  });
}

class ClassSession {
  final DateTime date;
  final String startTime;
  final String endTime;
  final String hallName;
  final String status;

  const ClassSession({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.hallName,
    this.status = 'scheduled',
  });
}

class InstituteClass {
  final int id;
  final int instituteId;
  final String code;
  final String name;
  final String level;
  final String grade;
  final String subject;
  final int? subjectId;
  final int? teacherId;
  final int? paymentPlanId;
  final String paymentPlanName;
  final int maxStudents;
  final DateTime startDate;
  final DateTime? endDate;
  final String description;
  final String status;
  final List<ClassSlot> slots;
  final List<ClassStudent> students;
  final List<ClassTeacher> teachers;
  final List<ClassSession> sessions;

  const InstituteClass({
    required this.id,
    required this.instituteId,
    required this.code,
    required this.name,
    required this.level,
    required this.grade,
    required this.subject,
    required this.maxStudents,
    required this.startDate,
    this.subjectId,
    this.teacherId,
    this.paymentPlanId,
    this.paymentPlanName = 'None',
    this.endDate,
    this.description = '',
    this.status = 'active',
    this.slots = const [],
    this.students = const [],
    this.teachers = const [],
    this.sessions = const [],
  });

  int get enrolledCount => students.length;

  InstituteClass copyWith({
    int? id,
    List<ClassSlot>? slots,
    List<ClassStudent>? students,
    List<ClassTeacher>? teachers,
    List<ClassSession>? sessions,
  }) {
    return InstituteClass(
      id: id ?? this.id,
      instituteId: instituteId,
      code: code,
      name: name,
      level: level,
      grade: grade,
      subject: subject,
      subjectId: subjectId,
      teacherId: teacherId,
      paymentPlanId: paymentPlanId,
      paymentPlanName: paymentPlanName,
      maxStudents: maxStudents,
      startDate: startDate,
      endDate: endDate,
      description: description,
      status: status,
      slots: slots ?? this.slots,
      students: students ?? this.students,
      teachers: teachers ?? this.teachers,
      sessions: sessions ?? this.sessions,
    );
  }
}
