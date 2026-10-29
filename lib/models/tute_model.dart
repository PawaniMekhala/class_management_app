enum TuteStatus { active, archived }

enum TuteType { tute, material }

class TuteModel {
  final int id;
  final int instituteId;
  final int classId;

  final String name;
  final String unitName;
  final DateTime releaseDate;

  final TuteType type;
  final String? description;

  // Digital copy information
  final String? attachmentName;
  final String? attachmentPath;
  final int? attachmentSize;

  TuteStatus status;

  TuteModel({
    required this.id,
    required this.instituteId,
    required this.classId,
    required this.name,
    required this.unitName,
    required this.releaseDate,

    this.type = TuteType.tute,
    this.description,

    this.attachmentName,
    this.attachmentPath,
    this.attachmentSize,

    this.status = TuteStatus.active,
  });
}
