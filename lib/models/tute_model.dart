enum TuteStatus { active, archived }

class TuteModel {
  final int id;
  final int instituteId;
  final int classId;

  final String name;
  final String unitName;
  final DateTime releaseDate;

  TuteStatus status;

  TuteModel({
    required this.id,
    required this.instituteId,
    required this.classId,
    required this.name,
    required this.unitName,
    required this.releaseDate,
    this.status = TuteStatus.active,
  });
}
