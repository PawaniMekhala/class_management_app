import '../../models/student_profile_request_model.dart';

class StudentProfileRequestService {
  // Demo data stays in memory while this service exists.
  final List<StudentProfileRequestModel> _demoRequests = [
    StudentProfileRequestModel(
      id: 1,
      studentId: 6,
      instituteId: 1,
      studentName: 'Kavindu Perera',
      studentCode: 'SIPGAM-ST0002',
      requestedAt: DateTime(2026, 10, 3, 12),
      changes: const [
        ProfileFieldChange(
          fieldName: 'Address',
          oldValue: 'No. 12, Temple Road, Gampaha',
          newValue: 'No. 88, Kandy Road, Gampaha',
        ),
        ProfileFieldChange(
          fieldName: 'Mobile',
          oldValue: '0763000002',
          newValue: '0763000099',
        ),
      ],
    ),
  ];

  Future<List<StudentProfileRequestModel>> getRequests(int instituteId) async {
    // TO DO: BACKEND
    // GET /api/institutes/{instituteId}/student-profile-requests
    await Future.delayed(const Duration(milliseconds: 300));

    return _demoRequests
        .where((request) => request.instituteId == instituteId)
        .toList();
  }

  Future<void> reviewRequest({
    required int instituteId,
    required int requestId,
    required bool approve,
  }) async {
    // TO DO: BACKEND
    // POST /api/institutes/{instituteId}/student-profile-requests/{requestId}/review
    // Body: { "decision": "approved" } or { "decision": "rejected" }
    //
    // The backend must authorize the admin, validate the request,
    // and apply approved changes atomically with the status update.

    await Future.delayed(const Duration(milliseconds: 350));

    final request = _demoRequests.firstWhere(
      (item) =>
          item.id == requestId &&
          item.instituteId == instituteId &&
          item.status == ProfileRequestStatus.pending,
    );

    request.status = approve
        ? ProfileRequestStatus.approved
        : ProfileRequestStatus.rejected;

    request.reviewedAt = DateTime.now();
  }
}
