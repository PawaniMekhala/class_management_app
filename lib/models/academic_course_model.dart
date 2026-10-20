class AcademicCourseModel {
  final int id;
  final int instituteId;
  final String name;
  final String category;
  final int durationMonths;
  final String code;
  final String description;
  final int? paymentPlanId;
  final List<int> moduleIds;

  const AcademicCourseModel({
    required this.id,
    required this.instituteId,
    required this.name,
    required this.category,
    required this.durationMonths,
    required this.code,
    required this.description,
    required this.paymentPlanId,
    required this.moduleIds,
  });

  factory AcademicCourseModel.fromJson(Map<String, dynamic> json) {
    return AcademicCourseModel(
      id: (json['id'] as num).toInt(),
      instituteId: (json['institute_id'] as num).toInt(),
      name: json['name'] as String,
      category: json['category'] as String,
      durationMonths: (json['duration_months'] as num).toInt(),
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      paymentPlanId: (json['payment_plan_id'] as num?)?.toInt(),
      moduleIds: (json['module_ids'] as List<dynamic>? ?? [])
          .map((id) => (id as num).toInt())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'duration_months': durationMonths,
    'code': code,
    'description': description,
    'payment_plan_id': paymentPlanId,
    'module_ids': moduleIds,
  };
}
