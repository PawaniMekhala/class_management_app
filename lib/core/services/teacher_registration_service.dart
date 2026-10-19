class TeacherRegistrationService {
  Future<List<Map<String, dynamic>>> searchExistingTeachers(
    String query,
  ) async {
    // BACKEND INTEGRATION
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
}
