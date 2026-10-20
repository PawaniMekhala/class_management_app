import '../../models/student_detail_model.dart';

class StudentDetailService {
  Future<StudentDetailModel> getStudentDetails({
    required int instituteId,
    required int studentId,
    required String studentName,
    required String studentCode,
    required String grade,
  }) async {
    // TO DO: BACKEND INTEGRATION
    // GET /api/institutes/{instituteId}/students/{studentId}
    //
    // final response = await dio.get(
    //   '/api/institutes/$instituteId/students/$studentId',
    // );
    // return StudentDetailModel.fromJson(response.data);

    await Future.delayed(const Duration(milliseconds: 500));

    // Temporary demonstration data.
    return StudentDetailModel(
      id: studentId,
      instituteId: instituteId,
      name: studentName,
      studentCode: studentCode,
      username: 'sipgam-stu001',
      grade: grade,
      qrValue: 'STUDENT:$studentId:$studentCode',
      // isActive: true,
      instituteCount: 2,
      instituteRegistration: StudentInstituteRegistration(
        instituteId: instituteId,
        grade: grade,
        status: 'active',
        admissionDate: DateTime(2026, 9, 4),
        registrationFeePaid: 1500.00,
        currency: 'LKR',
      ),
      dateOfBirth: 'Jun 15, 2009',
      gender: 'Female',
      school: 'Local school · Sinhala · Physical Science',
      mobile: '0763000001',
      whatsapp: '0763000001',
      address: 'No. 11, Temple Road\nGampaha, Gampaha',
      // admission: 'Sep 4, 2026 · registration fee LKR 1500.00',
      guardians: const [
        StudentGuardianModel(
          name: 'Kumari Silva',
          relationship: 'Mother',
          mobile: '0773000001',
          isPrimary: true,
          isEmergency: true,
        ),
      ],
      classes: const [
        StudentEnrolledClassModel(
          id: 1,
          name: '2027 A/L Combined Maths – Sunday Paper Class',
          code: 'SIPGAM-CL0012',
          paymentType: 'Seminar – one time',
          isActive: true,
        ),
        StudentEnrolledClassModel(
          id: 2,
          name: '2027 A/L Combined Maths (Theory)',
          code: 'SIPGAM-CL0001',
          paymentType: 'A/L monthly fee',
          isActive: true,
        ),
        StudentEnrolledClassModel(
          id: 3,
          name: '2027 A/L Physics (Theory)',
          code: 'SIPGAM-CL0003',
          paymentType: 'A/L monthly fee',
          isActive: true,
        ),
      ],
    );
  }
}
