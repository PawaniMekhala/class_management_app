class CityModel {
  final String id;
  final String districtId;
  final String name;

  const CityModel({
    required this.id,
    required this.districtId,
    required this.name,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as String,
      districtId: json['districtId'] as String,
      name: json['name'] as String,
    );
  }
}
