import 'package:flutter/foundation.dart';

import '../core/services/payment_plan_service.dart';
import '../models/payment_plan_model.dart';

class PaymentPlanProvider extends ChangeNotifier {
  final PaymentPlanService _service = PaymentPlanService();

  List<PaymentPlanModel> _plans = [];
  String _search = '';
  int? _currentInstituteId;

  bool isLoading = false;
  String? errorMessage;

  List<PaymentPlanModel> get plans {
    final query = _search.trim().toLowerCase();

    return _plans.where((plan) {
      return plan.name.toLowerCase().contains(query) ||
          plan.type.toLowerCase().contains(query) ||
          plan.description.toLowerCase().contains(query);
    }).toList();
  }

  void searchPlans(String query) {
    _search = query;
    notifyListeners();
  }

  Future<void> loadPlans(int instituteId) async {
    _currentInstituteId = instituteId;
    _plans = [];
    _search = '';
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getPlans(instituteId);
      if (_currentInstituteId != instituteId) return;
      _plans = result;
    } catch (_) {
      if (_currentInstituteId != instituteId) return;
      errorMessage = 'Unable to load payment plans.';
    } finally {
      if (_currentInstituteId == instituteId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> savePlan(PaymentPlanModel plan) async {
    await _service.savePlan(plan);
    await loadPlans(plan.instituteId);
  }

  Future<void> deletePlan(int instituteId, int planId) async {
    await _service.deletePlan(instituteId, planId);
    await loadPlans(instituteId);
  }
}
