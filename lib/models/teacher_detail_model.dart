class TeacherDetailModel {
  final int id;
  final int instituteId;
  final String name;
  final String teacherId;
  final String teacherCode;
  final String? nic;
  final String? mobile;
  final bool publishMobile;
  final String? email;
  final String? qualifications;
  final String? about;
  final String? address;
  final String? photoUrl;
  final int instituteCount;
  final List<String> subjects;

  const TeacherDetailModel({
    required this.id,
    required this.instituteId,
    required this.name,
    required this.teacherId,
    required this.teacherCode,
    required this.publishMobile,
    required this.instituteCount,
    required this.subjects,
    this.nic,
    this.mobile,
    this.email,
    this.qualifications,
    this.about,
    this.address,
    this.photoUrl,
  });

  bool get isSharedProfile => instituteCount > 1;

  factory TeacherDetailModel.fromJson(Map<String, dynamic> json) {
    return TeacherDetailModel(
      id: (json['id'] as num).toInt(),
      instituteId: (json['institute_id'] as num).toInt(),
      name: json['name'] as String,
      teacherId: json['teacher_id'] as String,
      teacherCode: json['teacher_code'] as String,
      nic: json['nic'] as String?,
      mobile: json['mobile'] as String?,
      publishMobile: json['publish_mobile'] as bool? ?? false,
      email: json['email'] as String?,
      qualifications: json['qualifications'] as String?,
      about: json['about'] as String?,
      address: json['address'] as String?,
      photoUrl: json['photo_url'] as String?,
      instituteCount: (json['institute_count'] as num?)?.toInt() ?? 1,
      subjects: (json['subjects'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}
