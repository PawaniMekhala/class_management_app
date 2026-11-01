import 'package:flutter/material.dart';

import '../core/services/institute_settings_service.dart';
import '../models/institute_settings_model.dart';

class InstituteSettingsProvider extends ChangeNotifier {
  final InstituteSettingsService _service = InstituteSettingsService();

  InstituteSettingsModel? _institute;
  InstituteSettingsModel? get institute => _institute;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _requestId = 0;

  Future<void> loadInstitute(int instituteId) async {
    final requestId = ++_requestId;

    _institute = null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getInstitute(instituteId);

      if (requestId != _requestId) return;

      _institute = result;

      if (result == null) {
        _errorMessage = 'Institute information not found.';
      }
    } catch (error) {
      if (requestId != _requestId) return;
      _errorMessage = error.toString();
    } finally {
      if (requestId == _requestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> updateInstitute(InstituteSettingsModel updated) async {
    if (_isSaving || _institute == null || updated.id != _institute!.id) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.updateInstitute(updated);
      _institute = updated;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
