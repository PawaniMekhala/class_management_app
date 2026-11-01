import 'package:flutter/material.dart';

import '../core/services/institute_branch_service.dart';
import '../models/institute_branch_model.dart';

class InstituteBranchProvider extends ChangeNotifier {
  final InstituteBranchService _service = InstituteBranchService();

  List<InstituteBranchModel> _branches = [];

  List<InstituteBranchModel> get branches => _branches;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadBranches() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _branches = await _service.getBranches();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
