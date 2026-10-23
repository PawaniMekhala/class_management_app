import 'package:flutter/material.dart';

import '../core/services/refund_service.dart';
import '../models/refund_model.dart';

class RefundProvider extends ChangeNotifier {
  final RefundService _service = RefundService();

  List<RefundModel> _refunds = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<RefundModel> get refunds => List.unmodifiable(_refunds);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> loadRefunds(int instituteId) async {
    _isLoading = true;
    _errorMessage = null;
    _refunds = [];
    notifyListeners();

    try {
      _refunds = await _service.getRefunds(instituteId);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
