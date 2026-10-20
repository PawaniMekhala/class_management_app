class AcademicSubjectModel {
  final int id;
  final int instituteId;
  final String name;
  final String educationLevel;
  final String nationalSubject;
  final String code;
  final String description;
  final int classCount;
  final bool isModule;

  const AcademicSubjectModel({
    required this.id,
    required this.instituteId,
    required this.name,
    required this.educationLevel,
    required this.nationalSubject,
    required this.code,
    required this.description,
    required this.classCount,
    this.isModule = false,
  });

  AcademicSubjectModel copyWith({
    String? name,
    String? nationalSubject,
    String? code,
    String? description,
  }) {
    return AcademicSubjectModel(
      id: id,
      instituteId: instituteId,
      name: name ?? this.name,
      educationLevel: educationLevel,
      nationalSubject: nationalSubject ?? this.nationalSubject,
      code: code ?? this.code,
      description: description ?? this.description,
      classCount: classCount,
      isModule: isModule,
    );
  }

  factory AcademicSubjectModel.fromJson(Map<String, dynamic> json) {
    return AcademicSubjectModel(
      id: (json['id'] as num).toInt(),
      instituteId: (json['institute_id'] as num).toInt(),
      name: json['name'] as String,
      educationLevel: json['education_level'] as String,
      nationalSubject: json['national_subject'] as String? ?? '',
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      classCount: (json['class_count'] as num?)?.toInt() ?? 0,
      isModule: json['is_module'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'education_level': educationLevel,
    'national_subject': nationalSubject,
    'code': code,
    'description': description,
    'is_module': isModule,
  };
}
