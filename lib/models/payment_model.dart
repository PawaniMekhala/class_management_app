class PaymentCharge {
  final int id;
  final int instituteId;
  final int studentId;
  final int enrollmentId;
  final int classId;
  final String className;
  final String description;
  final DateTime dueDate;
  final double originalAmount;
  final double discountAmount;
  final double paidAmount;
  final String? discountDescription;
  final String? tuteDescription;

  const PaymentCharge({
    required this.id,
    required this.instituteId,
    required this.studentId,
    required this.enrollmentId,
    required this.classId,
    required this.className,
    required this.description,
    required this.dueDate,
    required this.originalAmount,
    this.discountAmount = 0,
    this.paidAmount = 0,
    this.discountDescription,
    this.tuteDescription,
  });

  double get netAmount =>
      (originalAmount - discountAmount).clamp(0.0, double.infinity).toDouble();

  double get balance =>
      (netAmount - paidAmount).clamp(0.0, double.infinity).toDouble();

  bool get isPaid => balance <= 0.001;

  bool get isOverdue =>
      !isPaid &&
      DateTime(dueDate.year, dueDate.month, dueDate.day).isBefore(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      );

  PaymentCharge copyWith({double? paidAmount}) {
    return PaymentCharge(
      id: id,
      instituteId: instituteId,
      studentId: studentId,
      enrollmentId: enrollmentId,
      classId: classId,
      className: className,
      description: description,
      dueDate: dueDate,
      originalAmount: originalAmount,
      discountAmount: discountAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      discountDescription: discountDescription,
      tuteDescription: tuteDescription,
    );
  }
}

class PaymentAllocation {
  final int chargeId;
  final double amount;

  const PaymentAllocation({required this.chargeId, required this.amount});
}

class StudentPayment {
  final int id;
  final int instituteId;
  final int studentId;
  final DateTime paidAt;
  final String method;
  final double amount;
  final List<PaymentAllocation> allocations;
  final String receiptNumber;

  const StudentPayment({
    required this.id,
    required this.instituteId,
    required this.studentId,
    required this.paidAt,
    required this.method,
    required this.amount,
    required this.allocations,
    required this.receiptNumber,
  });
}
