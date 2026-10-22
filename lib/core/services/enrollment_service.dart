import '../../models/enrollment_model.dart';
import '../../models/class_model.dart';
import 'class_service.dart';

class EnrollmentService {
  static final List<EnrollmentModel> _records = [];
  static final Set<int> _initializedInstitutes = {};

  final ClassService _classService = ClassService();

  Future<void> _initialize(int instituteId) async {
    if (_initializedInstitutes.contains(instituteId)) return;

    final classes = await _classService.getClasses(instituteId);

    for (final item in classes) {
      for (final student in item.students) {
        _records.add(
          EnrollmentModel(
            id: _records.length + 1,
            instituteId: instituteId,
            studentId: student.id,
            classId: item.id,
            studentName: student.name,
            studentCode: student.studentCode,
            className: item.name,
            classCode: item.code,
            subject: item.subject,
            teacherName: item.teachers.isEmpty
                ? 'Not assigned'
                : item.teachers.first.name,
            paymentPlan: student.paymentPlan,
            enrolledAt: item.startDate,
            charged: null,
            paid: null,
            grade: item.grade,
          ),
        );
      }
    }

    _initializedInstitutes.add(instituteId);
  }

  Future<List<EnrollmentModel>> getEnrollments(int instituteId) async {
    // TO DO BACKEND:
    // GET /api/institutes/{instituteId}/enrollments

    await _initialize(instituteId);

    return _records
        .where((record) => record.instituteId == instituteId)
        .toList();
  }

  Future<EnrollmentModel> enroll({
    required int instituteId,
    required int studentId,
    required String studentName,
    required String studentCode,
    required String? studentPhone,
    required String studentGrade,
    required InstituteClass selectedClass,
    required String paymentPlan,
  }) async {
    // TO DO BACKEND:
    // POST /api/institutes/{instituteId}/enrollments
    // The backend must save the class enrollment atomically.

    await _initialize(instituteId);

    if (selectedClass.instituteId != instituteId) {
      throw Exception('Class does not belong to this institute.');
    }

    final currentClass = await _classService.getClass(
      instituteId,
      selectedClass.id,
    );

    final alreadyEnrolled = _records.any(
      (record) =>
          record.instituteId == instituteId &&
          record.studentId == studentId &&
          record.classId == selectedClass.id &&
          record.status == 'enrolled',
    );

    if (alreadyEnrolled ||
        currentClass.students.any((student) => student.id == studentId)) {
      throw Exception('Student is already enrolled in this class.');
    }

    if (currentClass.students.length >= currentClass.maxStudents) {
      throw Exception('This class is full.');
    }

    await _classService.enrollStudent(
      currentClass,
      ClassStudent(
        id: studentId,
        name: studentName,
        studentCode: studentCode,
        paymentPlan: paymentPlan,
      ),
    );

    final nextId = _records.isEmpty
        ? 1
        : _records.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1;

    final record = EnrollmentModel(
      id: nextId,
      instituteId: instituteId,
      studentId: studentId,
      classId: currentClass.id,
      studentName: studentName,
      studentCode: studentCode,
      className: currentClass.name,
      classCode: currentClass.code,
      subject: currentClass.subject,
      teacherName: currentClass.teachers.isEmpty
          ? 'Not assigned'
          : currentClass.teachers.first.name,
      paymentPlan: paymentPlan,
      enrolledAt: DateTime.now(),
      phone: studentPhone,
      grade: studentGrade,
    );

    _records.add(record);
    return record;
  }

  Future<EnrollmentModel> updateStatus(
    int instituteId,
    int enrollmentId,
    String status,
  ) async {
    // TO DO BACKEND:
    // PATCH /api/institutes/{instituteId}/enrollments/{enrollmentId}/status

    const allowed = {'enrolled', 'suspended', 'dropped', 'completed'};

    if (!allowed.contains(status)) {
      throw Exception('Invalid enrollment status.');
    }

    await _initialize(instituteId);

    final index = _records.indexWhere(
      (record) =>
          record.instituteId == instituteId && record.id == enrollmentId,
    );

    if (index == -1) throw Exception('Enrollment not found.');

    final updated = _records[index].copyWith(status: status);
    _records[index] = updated;
    return updated;
  }
}
