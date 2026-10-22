class EnrollmentModel {
  final int id;
  final int instituteId;
  final int studentId;
  final int classId;
  final String studentName;
  final String studentCode;
  final String className;
  final String classCode;
  final String subject;
  final String teacherName;
  // final int paymentPlanId;
  final String paymentPlan;
  final DateTime enrolledAt;
  final String status;
  final double? charged;
  final double? paid;
  final String? phone;
  final String? grade;

  const EnrollmentModel({
    required this.id,
    required this.instituteId,
    required this.studentId,
    required this.classId,
    required this.studentName,
    required this.studentCode,
    required this.className,
    required this.classCode,
    required this.subject,
    required this.teacherName,
    required this.paymentPlan,
    required this.enrolledAt,
    this.status = 'enrolled',
    this.charged,
    this.paid,
    this.phone,
    this.grade,
  });

  double? get balance =>
      charged == null || paid == null ? null : charged! - paid!;

  EnrollmentModel copyWith({String? status}) {
    return EnrollmentModel(
      id: id,
      instituteId: instituteId,
      studentId: studentId,
      classId: classId,
      studentName: studentName,
      studentCode: studentCode,
      className: className,
      classCode: classCode,
      subject: subject,
      teacherName: teacherName,
      paymentPlan: paymentPlan,
      enrolledAt: enrolledAt,
      status: status ?? this.status,
      charged: charged,
      paid: paid,
      phone: phone,
      grade: grade,
    );
  }
}
