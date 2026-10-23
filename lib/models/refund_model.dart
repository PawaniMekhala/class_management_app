class RefundModel {
  final int id;
  final int instituteId;
  final int studentId;

  final String refundNumber;
  final String receiptNumber;
  final String studentName;
  final String studentCode;

  final double amount;
  final String reason;
  final String method;
  final String status;

  final DateTime requestedAt;
  final DateTime? processedAt;

  final String? referenceNumber;
  final String? processedBy;
  final String? notes;

  const RefundModel({
    required this.id,
    required this.instituteId,
    required this.studentId,
    required this.refundNumber,
    required this.receiptNumber,
    required this.studentName,
    required this.studentCode,
    required this.amount,
    required this.reason,
    required this.method,
    required this.status,
    required this.requestedAt,
    this.processedAt,
    this.referenceNumber,
    this.processedBy,
    this.notes,
  });

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    return RefundModel(
      id: (json['id'] as num).toInt(),
      instituteId: (json['institute_id'] as num).toInt(),
      studentId: (json['student_id'] as num).toInt(),
      refundNumber: json['refund_number'] as String,
      receiptNumber: json['receipt_number'] as String,
      studentName: json['student_name'] as String,
      studentCode: json['student_code'] as String,
      amount: (json['amount'] as num).toDouble(),
      reason: json['reason'] as String,
      method: json['method'] as String,
      status: json['status'] as String,
      requestedAt: DateTime.parse(json['requested_at'] as String),
      processedAt: json['processed_at'] == null
          ? null
          : DateTime.parse(json['processed_at'] as String),
      referenceNumber: json['reference_number'] as String?,
      processedBy: json['processed_by'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
