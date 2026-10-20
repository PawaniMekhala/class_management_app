import '../../models/teacher_registration_model.dart';

class TeacherRegistrationService {
  Future<List<Map<String, dynamic>>> searchExistingTeachers(
    String query,
  ) async {
    // TO DO: BACKEND INTEGRATION
    //
    // GET /api/teachers/search?query={query}
    //
    // Search globally across IMS using:
    // NIC, mobile number, teacher number, or name.
    //
    // The backend must only return information the
    // current admin is authorized to access.

    await Future.delayed(const Duration(milliseconds: 300));

    // Global teacher search is not connected yet.
    return [];
  }

  Future<void> registerTeacher(TeacherRegistrationModel teacher) async {
    // TO DO: BACKEND INTEGRATION
    //
    // POST /api/institutes/{instituteId}/teachers
    //
    // Send teacher.toJson() with authenticated API request.
    // Upload the profile photo if teacher.photoPath != null.
    //
    // The backend must:
    // 1. Validate the teacher's details.
    // 2. Check for an existing IMS teacher.
    // 3. Create the teacher and institute registration.
    // 4. Assign selected subjects.
    // 5. Save privacy preferences.
    // 6. Queue login SMS if requested.

    await Future.delayed(const Duration(milliseconds: 700));

    // Demo only: no data is saved.
  }
}
