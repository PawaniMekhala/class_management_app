import 'package:flutter/material.dart';

import '../core/services/outstanding_service.dart';
import '../models/outstanding_model.dart';

class OutstandingProvider extends ChangeNotifier {
  final OutstandingService _service = OutstandingService();

  List<OutstandingModel> _outstanding = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<OutstandingModel> get outstanding => List.unmodifiable(_outstanding);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> loadOutstanding(int instituteId) async {
    _isLoading = true;
    _errorMessage = null;
    _outstanding = [];
    notifyListeners();

    try {
      _outstanding = await _service.getOutstanding(instituteId);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
