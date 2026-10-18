import '../../models/student_model.dart';

class StudentService {
  Future<List<StudentModel>> getStudents(int instituteId) async {
    // TODO: BACKEND API
    // GET /api/institutes/{instituteId}/students
    //
    // Send the logged-in user's authentication token.
    // The backend must verify access to instituteId.
    //
    // Replace the temporary list below with the API response.

    await Future.delayed(const Duration(milliseconds: 300));

    final students = [
      StudentModel(
        id: 1,
        instituteId: 1,
        name: 'Amila Senarath',
        studentCode: 'SIPGAM-ST0011',
        grade: 'Diploma',
        admittedAt: DateTime(2026, 9, 4, 11, 0),
        photoUrl: 'https://example.com/photo.jpg',
      ),
      StudentModel(
        id: 2,
        instituteId: 1,
        name: 'Dinithi Weerasinghe',
        studentCode: 'SIPGAM-ST0012',
        grade: 'Diploma',
        admittedAt: DateTime(2026, 9, 4, 10, 0),
        photoUrl: 'https://example.com/photo.jpg',
      ),
      StudentModel(
        id: 3,
        instituteId: 1,
        name: 'Dulaj Rathnayake',
        studentCode: 'SIPGAM-ST0004',
        grade: 'Grade 13',
        admittedAt: DateTime(2026, 9, 4, 9, 0),
        photoUrl: 'https://example.com/photo.jpg',
      ),
      StudentModel(
        id: 4,
        instituteId: 1,
        name: 'Hiruni Jayasuriya',
        studentCode: 'SIPGAM-ST0005',
        grade: 'Grade 12',
        admittedAt: DateTime(2026, 9, 4, 8, 0),
        photoUrl: 'https://example.com/photo.jpg',
      ),
      StudentModel(
        id: 5,
        instituteId: 1,
        name: 'Ishini Karunaratne',
        studentCode: 'SIPGAM-ST0010',
        grade: 'Grade 10',
        admittedAt: DateTime(2026, 9, 4, 7, 0),
        photoUrl: 'https://example.com/photo.jpg',
      ),
      StudentModel(
        id: 6,
        instituteId: 1,
        name: 'Kavindu Perera',
        studentCode: 'SIPGAM-ST0002',
        grade: 'Grade 12',
        admittedAt: DateTime(2026, 9, 4, 6, 0),
        photoUrl: 'https://example.com/photo.jpg',
      ),
      StudentModel(
        id: 7,
        instituteId: 1,
        name: 'Nethmi Silva',
        studentCode: 'SIPGAM-ST0001',
        grade: 'Grade 12',
        admittedAt: DateTime(2026, 9, 4, 5, 0),
        instituteCount: 2,
        photoUrl: 'https://example.com/photo.jpg',
      ),
      StudentModel(
        id: 8,
        instituteId: 1,
        name: 'Pasindu Dias',
        studentCode: 'SIPGAM-ST0009',
        grade: 'Grade 10',
        admittedAt: DateTime(2026, 9, 4, 4, 0),
        photoUrl: 'https://example.com/photo.jpg',
      ),
      StudentModel(
        id: 9,
        instituteId: 1,
        name: 'Sachini Fernando',
        studentCode: 'SIPGAM-ST0003',
        grade: 'Grade 12',
        admittedAt: DateTime(2026, 9, 4, 3, 0),
        photoUrl: 'https://example.com/photo.jpg',
      ),
    ];

    // Demo data belongs to institute 1 only.
    return students
        .where((student) => student.instituteId == instituteId)
        .toList();
  }
}
