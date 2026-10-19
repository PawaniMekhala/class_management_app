class TeacherModel {
  final int id;
  final int instituteId;
  final String name;
  final String teacherCode;
  final String? nic;
  final String? mobile;
  final String? photoUrl;
  final List<String> subjects;
  final int instituteCount;

  const TeacherModel({
    required this.id,
    required this.instituteId,
    required this.name,
    required this.teacherCode,
    required this.subjects,
    this.nic,
    this.mobile,
    this.photoUrl,
    this.instituteCount = 1,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: (json['id'] as num).toInt(),
      instituteId: (json['institute_id'] as num).toInt(),
      name: json['name'] as String,
      teacherCode: json['teacher_code'] as String,
      nic: json['nic'] as String?,
      mobile: json['mobile'] as String?,
      photoUrl: json['photo_url'] as String?,
      subjects: (json['subjects'] as List<dynamic>? ?? [])
          .map((subject) => subject.toString())
          .toList(),
      instituteCount: (json['institute_count'] as num?)?.toInt() ?? 1,
    );
  }
}
