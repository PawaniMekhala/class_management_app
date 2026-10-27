class TuteDistributionModel {
  final int id;
  final int instituteId;
  final int tuteId;
  final int studentId;
  final DateTime receivedAt;

  TuteDistributionModel({
    required this.id,
    required this.instituteId,
    required this.tuteId,
    required this.studentId,
    required this.receivedAt,
  });
}
