import '../../models/payment_plan_model.dart';

class PaymentPlanService {
  static final List<PaymentPlanModel> _plans = [
    const PaymentPlanModel(
      id: 1,
      instituteId: 1,
      name: 'Seminar — one time',
      type: 'one_time',
      amount: 1500,
      classCount: 1,
    ),
    const PaymentPlanModel(
      id: 2,
      instituteId: 1,
      name: 'A/L monthly fee',
      type: 'time_based',
      amount: 3000,
      period: 'Monthly',
      paymentDue: 'First week of the month',
      classCount: 6,
      discounts: [
        PaymentDiscount(
          name: 'Sibling discount',
          type: 'percentage',
          value: 10,
        ),
        PaymentDiscount(name: 'Early payment', type: 'fixed', value: 200),
      ],
    ),
    const PaymentPlanModel(
      id: 3,
      instituteId: 1,
      name: 'O/L monthly fee',
      type: 'time_based',
      amount: 2000,
      period: 'Monthly',
      classCount: 4,
    ),
    const PaymentPlanModel(
      id: 4,
      instituteId: 1,
      name: '10-session pack',
      type: 'attendance_based',
      amount: 2500,
      sessionCount: 10,
    ),
    const PaymentPlanModel(
      id: 5,
      instituteId: 1,
      name: 'Diploma — 6 installments',
      type: 'installments',
      amount: 60000,
      installmentCount: 6,
      installmentAmounts: [10000, 10000, 10000, 10000, 10000, 10000],
      classCount: 1,
    ),
    const PaymentPlanModel(
      id: 6,
      instituteId: 1,
      name: 'Scholarship free card',
      type: 'free_card',
      amount: 0,
      reason: 'Scholarship',
    ),
  ];

  Future<List<PaymentPlanModel>> getPlans(int instituteId) async {
    // TO DO BACKEND:
    // GET /api/institutes/{instituteId}/payment-plans
    await Future.delayed(const Duration(milliseconds: 250));

    return _plans.where((p) => p.instituteId == instituteId).toList();
  }

  Future<PaymentPlanModel> savePlan(PaymentPlanModel plan) async {
    // TO DO BACKEND:
    // POST /api/institutes/{instituteId}/payment-plans
    // PATCH /api/institutes/{instituteId}/payment-plans/{planId}
    await Future.delayed(const Duration(milliseconds: 300));

    if (plan.id == 0) {
      final nextId = _plans.isEmpty
          ? 1
          : _plans.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;

      final created = PaymentPlanModel(
        id: nextId,
        instituteId: plan.instituteId,
        name: plan.name,
        type: plan.type,
        amount: plan.amount,
        period: plan.period,
        paymentDue: plan.paymentDue,
        dueDate: plan.dueDate,
        sessionCount: plan.sessionCount,
        creditExpiry: plan.creditExpiry,
        installmentCount: plan.installmentCount,
        installmentAmounts: plan.installmentAmounts,
        description: plan.description,
        reason: plan.reason,
        discounts: plan.discounts,
        teacherPercentage: plan.teacherPercentage,
        institutePercentage: plan.institutePercentage,
      );

      _plans.add(created);
      return created;
    }

    final index = _plans.indexWhere(
      (p) => p.id == plan.id && p.instituteId == plan.instituteId,
    );

    if (index == -1) throw Exception('Payment plan not found');

    if (_plans[index].classCount > 0 && _plans[index].type != plan.type) {
      throw Exception('Plan type cannot change while in use');
    }

    _plans[index] = plan;
    return plan;
  }

  Future<void> deletePlan(int instituteId, int planId) async {
    // TO DO BACKEND:
    // DELETE /api/institutes/{instituteId}/payment-plans/{planId}
    final index = _plans.indexWhere(
      (p) => p.id == planId && p.instituteId == instituteId,
    );

    if (index == -1) throw Exception('Payment plan not found');

    if (_plans[index].classCount > 0) {
      throw Exception('Cannot delete a plan assigned to classes');
    }

    _plans.removeAt(index);
  }
}
