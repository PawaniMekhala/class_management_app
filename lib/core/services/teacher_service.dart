import '../../models/teacher_model.dart';

class TeacherService {
  Future<List<TeacherModel>> getTeachers(int instituteId) async {
    // TO DO: BACKEND INTEGRATION
    //
    // GET /api/institutes/{instituteId}/teachers
    //
    // Replace the demo data with an authenticated API request.
    // The backend must check that the logged-in admin
    // has permission to view this institute.

    await Future.delayed(const Duration(milliseconds: 350));

    // Temporary sample data for Gampaha institute (ID 1).
    final demoTeachers = <TeacherModel>[
      const TeacherModel(
        id: 1,
        instituteId: 1,
        name: 'Anoma Herath',
        teacherCode: 'SIPGAM-TC0002',
        nic: '198567890123',
        mobile: '0771234567',
        subjects: ['Chemistry', 'Biology'],
      ),
      const TeacherModel(
        id: 2,
        instituteId: 1,
        name: 'Chathura Dissanayake',
        teacherCode: 'SIPGAM-TC0006',
        nic: '199012345678',
        mobile: '0772345678',
        subjects: [
          'Information & Communication Technology',
          'Information & Communication Technology',
        ],
      ),
      const TeacherModel(
        id: 3,
        instituteId: 1,
        name: 'Lahiru Gamage',
        teacherCode: 'SIPGAM-TC0005',
        nic: '199345678901',
        mobile: '0773456789',
        subjects: ['Accounting', 'Economics'],
      ),
      const TeacherModel(
        id: 4,
        instituteId: 1,
        name: 'Malini Senanayake',
        teacherCode: 'SIPGAM-TC0004',
        nic: '198945678901',
        mobile: '0774567890',
        subjects: ['English Language', 'General English'],
      ),
      const TeacherModel(
        id: 5,
        instituteId: 1,
        name: 'Prasad Wejesinghe',
        teacherCode: 'SIPGAM-TC0001',
        nic: '198812345678',
        mobile: '0775678901',
        subjects: ['Combined Mathematics', 'Physics'],
        instituteCount: 2,
      ),
      const TeacherModel(
        id: 6,
        instituteId: 1,
        name: 'Ruwan Kumarasinghe',
        teacherCode: 'SIPGAM-TC0003',
        nic: '198712345678',
        mobile: '0776789012',
        subjects: ['Mathematics', 'Science'],
        instituteCount: 2,
      ),
      const TeacherModel(
        id: 7,
        instituteId: 2,
        name: 'Anoma Herath',
        teacherCode: 'SIPGAM-TC0002',
        nic: '198567890123',
        mobile: '0771234567',
        subjects: ['Chemistry', 'Biology'],
      ),
      const TeacherModel(
        id: 8,
        instituteId: 2,
        name: 'Chathura Dissanayake',
        teacherCode: 'SIPGAM-TC0006',
        nic: '199012345678',
        mobile: '0772345678',
        subjects: [
          'Information & Communication Technology',
          'Information & Communication Technology',
        ],
      ),
      const TeacherModel(
        id: 9,
        instituteId: 2,
        name: 'Lahiru Gamage',
        teacherCode: 'SIPGAM-TC0005',
        nic: '199345678901',
        mobile: '0773456789',
        subjects: ['Accounting', 'Economics'],
      ),
      const TeacherModel(
        id: 10,
        instituteId: 2,
        name: 'Malini Senanayake',
        teacherCode: 'SIPGAM-TC0004',
        nic: '198945678901',
        mobile: '0774567890',
        subjects: ['English Language', 'General English'],
      ),
      const TeacherModel(
        id: 11,
        instituteId: 2,
        name: 'Prasad Wejesinghe',
        teacherCode: 'SIPGAM-TC0001',
        nic: '198812345678',
        mobile: '0775678901',
        subjects: ['Combined Mathematics', 'Physics'],
        instituteCount: 2,
      ),
      const TeacherModel(
        id: 12,
        instituteId: 2,
        name: 'Ruwan Kumarasinghe',
        teacherCode: 'SIPGAM-TC0003',
        nic: '198712345678',
        mobile: '0776789012',
        subjects: ['Mathematics', 'Science'],
        instituteCount: 2,
      ),
    ];

    return demoTeachers
        .where((teacher) => teacher.instituteId == instituteId)
        .toList();
  }
}
