class InstituteModel {
  final int id;
  final String name;
  final String role;
  final String company;

  const InstituteModel({
    required this.id,
    required this.name,
    required this.role,
    required this.company,
  });

  // Converts API JSON data into an InstituteModel
  factory InstituteModel.fromJson(Map<String, dynamic> json) {
    return InstituteModel(
      id: json['id'] as int,
      name: json['name'] as String,
      role: json['role'] as String,
      company: json['company'] as String,
    );
  }
}
