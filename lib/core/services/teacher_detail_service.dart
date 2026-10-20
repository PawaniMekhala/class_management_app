import '../../models/teacher_detail_model.dart';
import '../../models/teacher_model.dart';

class TeacherDetailService {
  Future<TeacherDetailModel> getTeacherDetails({
    required int instituteId,
    required TeacherModel teacher,
  }) async {
    // TO DO: BACKEND INTEGRATION
    //
    // GET /api/institutes/{instituteId}/teachers/{teacher.id}
    //
    // Replace demo data with:
    // TeacherDetailModel.fromJson(response.data)
    //
    // The backend must return institute-specific teacher code,
    // subjects and institute count, along with global profile details.

    await Future.delayed(const Duration(milliseconds: 350));

    // Temporary details matching the supplied screenshot.
    // Other teachers use their list information with demo defaults.
    final isPrasad = teacher.name == 'Prasad Wejesinghe';

    return TeacherDetailModel(
      id: teacher.id,
      instituteId: instituteId,
      name: teacher.name,
      teacherId: isPrasad ? 'TC26000001' : 'TC2600000${teacher.id}',
      teacherCode: teacher.teacherCode,
      nic: isPrasad ? '197501230011' : teacher.nic,
      mobile: isPrasad ? '0712000001' : teacher.mobile,
      publishMobile: false,
      email: isPrasad ? 'prasad.w@teacher.demo.ims.lk' : null,
      qualifications: isPrasad ? 'BSc (Physical Science), Colombo' : null,
      about: isPrasad
          ? '15 years teaching A/L Combined Maths and Physics.'
          : null,
      address: isPrasad ? 'Gampaha, Sri Lanka' : null,
      photoUrl: teacher.photoUrl,
      instituteCount: teacher.instituteCount,
      subjects: teacher.subjects,
    );
  }
}
