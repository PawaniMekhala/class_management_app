import '../../models/student_registration_model.dart';

class StudentRegistrationService {
  // TODO: BACKEND - Search globally for existing IMS students.
  //
  // GET /api/students/search?query=...
  //
  // The backend must authorize this search and return
  // only the student information the admin is allowed to see.
  Future<List<Map<String, dynamic>>> searchExistingStudents(
    String query,
  ) async {
    await Future.delayed(const Duration(milliseconds: 350));

    // Temporary: no global student search API connected yet.
    return [];
  }

  // TODO: BACKEND - Register a new student at this institute.
  //
  // POST /api/institutes/{instituteId}/students
  //
  // Send input.toJson() and the optional profile photo.
  // Backend must validate, create student + institute registration,
  // issue QR credential, and return the created student ID.
  Future<int> registerStudent(StudentRegistrationInput input) async {
    await Future.delayed(const Duration(milliseconds: 700));

    // Demo mode: simulate a successful registration.
    // This does NOT save data permanently.
    return DateTime.now().millisecondsSinceEpoch;
  }
}
