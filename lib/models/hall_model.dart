class HallModel {
  final int id;
  final int instituteId;
  final String name;
  final String number;
  final int capacity;
  final String building;
  final String floor;
  final String status;
  final List<String> facilities;
  final int weeklyClassCount;

  const HallModel({
    required this.id,
    required this.instituteId,
    required this.name,
    required this.number,
    required this.capacity,
    required this.building,
    required this.floor,
    required this.status,
    this.facilities = const [],
    this.weeklyClassCount = 0,
  });

  HallModel copyWith({
    int? id,
    String? name,
    String? number,
    int? capacity,
    String? building,
    String? floor,
    String? status,
    List<String>? facilities,
    int? weeklyClassCount,
  }) {
    return HallModel(
      id: id ?? this.id,
      instituteId: instituteId,
      name: name ?? this.name,
      number: number ?? this.number,
      capacity: capacity ?? this.capacity,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      status: status ?? this.status,
      facilities: facilities ?? this.facilities,
      weeklyClassCount: weeklyClassCount ?? this.weeklyClassCount,
    );
  }

  factory HallModel.fromJson(Map<String, dynamic> json) {
    return HallModel(
      id: (json['id'] as num).toInt(),
      instituteId: (json['institute_id'] as num).toInt(),
      name: json['name'] as String,
      number: json['number'] as String,
      capacity: (json['capacity'] as num).toInt(),
      building: json['building'] as String,
      floor: json['floor'] as String,
      status: json['status'] as String,
      facilities: (json['facilities'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      weeklyClassCount: (json['weekly_class_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': number,
      'capacity': capacity,
      'building': building,
      'floor': floor,
      'status': status,
      'facilities': facilities,
    };
  }
}
