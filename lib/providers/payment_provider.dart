import 'package:flutter/foundation.dart';

import '../core/services/payment_service.dart';
import '../models/payment_model.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _service = PaymentService();

  List<PaymentCharge> _charges = [];
  List<StudentPayment> _payments = [];

  bool isLoading = false;
  bool isCollecting = false;
  String? errorMessage;

  List<PaymentCharge> get charges => List.unmodifiable(_charges);

  List<PaymentCharge> get unpaidCharges =>
      _charges.where((charge) => !charge.isPaid).toList();

  List<StudentPayment> get payments => List.unmodifiable(_payments);

  double get totalDue =>
      _charges.fold(0.0, (sum, charge) => sum + charge.balance);

  double get overdue => _charges
      .where((charge) => charge.isOverdue)
      .fold(0.0, (sum, charge) => sum + charge.balance);

  Future<void> loadStudentCharges(int instituteId, int studentId) async {
    isLoading = true;
    errorMessage = null;
    _charges = [];
    notifyListeners();

    try {
      _charges = await _service.getStudentCharges(instituteId, studentId);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPayments(int instituteId) async {
    _payments = await _service.getPayments(instituteId);
    notifyListeners();
  }

  Future<StudentPayment> collect({
    required int instituteId,
    required int studentId,
    required String method,
    required List<PaymentAllocation> allocations,
  }) async {
    if (isCollecting) {
      throw StateError('Payment is already being processed.');
    }

    isCollecting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final payment = await _service.collectPayment(
        instituteId: instituteId,
        studentId: studentId,
        method: method,
        allocations: allocations,
      );

      _charges = await _service.getStudentCharges(instituteId, studentId);

      _payments = await _service.getPayments(instituteId);

      return payment;
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    } finally {
      isCollecting = false;
      notifyListeners();
    }
  }
}
