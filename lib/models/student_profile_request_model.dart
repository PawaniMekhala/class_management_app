enum ProfileRequestStatus { pending, approved, rejected }

class ProfileFieldChange {
  final String fieldName;
  final String oldValue;
  final String newValue;

  const ProfileFieldChange({
    required this.fieldName,
    required this.oldValue,
    required this.newValue,
  });

  factory ProfileFieldChange.fromJson(Map<String, dynamic> json) {
    return ProfileFieldChange(
      fieldName: json['field_name'] as String,
      oldValue: json['old_value'] as String? ?? '',
      newValue: json['new_value'] as String? ?? '',
    );
  }
}

class StudentProfileRequestModel {
  final int id;
  final int studentId;
  final int instituteId;
  final String studentName;
  final String studentCode;
  final DateTime requestedAt;
  final List<ProfileFieldChange> changes;

  ProfileRequestStatus status;
  DateTime? reviewedAt;

  StudentProfileRequestModel({
    required this.id,
    required this.studentId,
    required this.instituteId,
    required this.studentName,
    required this.studentCode,
    required this.requestedAt,
    required this.changes,
    this.status = ProfileRequestStatus.pending,
    this.reviewedAt,
  });

  factory StudentProfileRequestModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileRequestModel(
      id: json['id'] as int,
      studentId: json['student_id'] as int,
      instituteId: json['institute_id'] as int,
      studentName: json['student_name'] as String,
      studentCode: json['student_code'] as String,
      requestedAt: DateTime.parse(json['requested_at'] as String),
      changes: (json['changes'] as List)
          .map(
            (item) => ProfileFieldChange.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      status: ProfileRequestStatus.values.byName(json['status'] as String),
      reviewedAt: json['reviewed_at'] == null
          ? null
          : DateTime.parse(json['reviewed_at'] as String),
    );
  }
}
