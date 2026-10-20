import '../../models/academic_course_model.dart';
import 'payment_plan_service.dart';

class CoursePaymentPlanOption {
  final int id;
  final String name;

  const CoursePaymentPlanOption({required this.id, required this.name});
}

class AcademicCourseService {
  static final List<AcademicCourseModel> _courses = [
    const AcademicCourseModel(
      id: 1,
      instituteId: 1,
      name: 'Diploma in Information Technology',
      category: 'Diploma',
      durationMonths: 12,
      code: 'DIT',
      description:
          'One-year diploma covering programming, databases, '
          'web and networking.',
      paymentPlanId: 1,
      moduleIds: [101, 102, 103, 11],
    ),
  ];

  Future<List<AcademicCourseModel>> getCourses(int instituteId) async {
    // TO DO BACKEND:
    // GET /api/institutes/{instituteId}/courses

    await Future.delayed(const Duration(milliseconds: 250));

    return _courses
        .where((course) => course.instituteId == instituteId)
        .toList();
  }

  Future<List<CoursePaymentPlanOption>> getPaymentPlans(int instituteId) async {
    // TO DO BACKEND:
    // GET /api/institutes/{instituteId}/payment-plans

    // await Future.delayed(const Duration(milliseconds: 150));

    // if (instituteId != 1) return [];
    final plans = await PaymentPlanService().getPlans(instituteId);

    return plans.map((plan) {
      return CoursePaymentPlanOption(id: plan.id, name: plan.name);
    }).toList();
  }

  Future<AcademicCourseModel> saveCourse(AcademicCourseModel course) async {
    // TO DO BACKEND:
    // POST /api/institutes/{instituteId}/courses
    // PATCH /api/institutes/{instituteId}/courses/{courseId}

    await Future.delayed(const Duration(milliseconds: 350));

    if (course.id == 0) {
      final nextId = _courses.isEmpty
          ? 1
          : _courses.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;

      final created = AcademicCourseModel(
        id: nextId,
        instituteId: course.instituteId,
        name: course.name,
        category: course.category,
        durationMonths: course.durationMonths,
        code: course.code,
        description: course.description,
        paymentPlanId: course.paymentPlanId,
        moduleIds: List.of(course.moduleIds),
      );

      _courses.add(created);
      return created;
    }

    final index = _courses.indexWhere(
      (c) => c.id == course.id && c.instituteId == course.instituteId,
    );

    if (index == -1) {
      throw Exception('Course not found');
    }

    _courses[index] = course;
    return course;
  }

  Future<void> deleteCourse(int instituteId, int courseId) async {
    // TO DO BACKEND:
    // DELETE /api/institutes/{instituteId}/courses/{courseId}
    //
    // Backend must check active enrollments and payments
    // before allowing deletion.

    await Future.delayed(const Duration(milliseconds: 250));

    final index = _courses.indexWhere(
      (c) => c.id == courseId && c.instituteId == instituteId,
    );

    if (index == -1) throw Exception('Course not found');

    _courses.removeAt(index);
  }
}
