class StudentModel {
  final int id;
  final int instituteId;
  final String name;
  final String studentCode;
  final String grade;
  final String? mobile;
  final DateTime admittedAt;
  final String? photoUrl;
  final int instituteCount;
  final String? nic;
  final String? qrCode;

  const StudentModel({
    required this.id,
    required this.instituteId,
    required this.name,
    required this.studentCode,
    required this.grade,
    required this.admittedAt,
    this.mobile,
    this.photoUrl,
    this.instituteCount = 1,
    this.nic,
    this.qrCode,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as int,
      instituteId: json['institute_id'] as int,
      name: json['name'] as String,
      studentCode: json['student_code'] as String,
      grade: json['grade'] as String,
      mobile: json['mobile'] as String?,
      admittedAt: DateTime.parse(json['admitted_at'] as String),
      photoUrl: json['photo_url'] as String?,
      instituteCount: (json['institute_count'] as int?) ?? 1,
      nic: json['nic'] as String?,
      qrCode: json['qr_code'] as String?,
    );
  }
}
