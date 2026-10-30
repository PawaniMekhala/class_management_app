class TuteDistributionModel {
  final int id;
  final int instituteId;
  final int tuteId;
  final int studentId;
  final DateTime receivedAt;
  final int? issuedById;
  final String? issuedByName;

  TuteDistributionModel({
    required this.id,
    required this.instituteId,
    required this.tuteId,
    required this.studentId,
    required this.receivedAt,
    this.issuedById,
    this.issuedByName,
  });
}
