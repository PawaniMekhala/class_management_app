class PaymentDiscount {
  final String name;
  final String type; // percentage or fixed
  final double value;

  const PaymentDiscount({
    required this.name,
    required this.type,
    required this.value,
  });

  factory PaymentDiscount.fromJson(Map<String, dynamic> json) {
    return PaymentDiscount(
      name: json['name'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'type': type, 'value': value};
}

class PaymentPlanModel {
  final int id;
  final int instituteId;
  final String name;
  final String type;
  final double amount;
  final String? period;
  final String? paymentDue;
  final DateTime? dueDate;
  final int? sessionCount;
  final DateTime? creditExpiry;
  final int? installmentCount;
  final List<double> installmentAmounts;
  final String description;
  final String? reason;
  final List<PaymentDiscount> discounts;
  final double teacherPercentage;
  final double institutePercentage;
  final int classCount;

  const PaymentPlanModel({
    required this.id,
    required this.instituteId,
    required this.name,
    required this.type,
    required this.amount,
    this.period,
    this.paymentDue,
    this.dueDate,
    this.sessionCount,
    this.creditExpiry,
    this.installmentCount,
    this.installmentAmounts = const [],
    this.description = '',
    this.reason,
    this.discounts = const [],
    this.teacherPercentage = 70,
    this.institutePercentage = 30,
    this.classCount = 0,
  });

  factory PaymentPlanModel.fromJson(Map<String, dynamic> json) {
    DateTime? date(dynamic value) =>
        value == null ? null : DateTime.tryParse(value.toString());

    return PaymentPlanModel(
      id: (json['id'] as num).toInt(),
      instituteId: (json['institute_id'] as num).toInt(),
      name: json['name'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      period: json['period'] as String?,
      paymentDue: json['payment_due'] as String?,
      dueDate: date(json['due_date']),
      sessionCount: (json['session_count'] as num?)?.toInt(),
      creditExpiry: date(json['credit_expiry']),
      installmentCount: (json['installment_count'] as num?)?.toInt(),
      installmentAmounts: (json['installment_amounts'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
      description: json['description'] as String? ?? '',
      reason: json['reason'] as String?,
      discounts: (json['discounts'] as List<dynamic>? ?? [])
          .map(
            (e) =>
                PaymentDiscount.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      teacherPercentage: (json['teacher_percentage'] as num?)?.toDouble() ?? 70,
      institutePercentage:
          (json['institute_percentage'] as num?)?.toDouble() ?? 30,
      classCount: (json['class_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'amount': amount,
    'period': period,
    'payment_due': paymentDue,
    'due_date': dueDate?.toIso8601String(),
    'session_count': sessionCount,
    'credit_expiry': creditExpiry?.toIso8601String(),
    'installment_count': installmentCount,
    'installment_amounts': installmentAmounts,
    'description': description,
    'reason': reason,
    'discounts': discounts.map((e) => e.toJson()).toList(),
    'teacher_percentage': teacherPercentage,
    'institute_percentage': institutePercentage,
  };
}
