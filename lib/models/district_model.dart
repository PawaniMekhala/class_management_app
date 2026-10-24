class DistrictModel {
  final String id;
  final String name;
  final String province;

  const DistrictModel({
    required this.id,
    required this.name,
    required this.province,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'] as String,
      name: json['name'] as String,
      province: json['province'] as String,
    );
  }
}
