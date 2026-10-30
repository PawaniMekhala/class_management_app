import 'package:flutter/material.dart';

import '../core/services/staff_service.dart';
import '../models/staff_model.dart';

class StaffProvider extends ChangeNotifier {
  final StaffService _service = StaffService();

  List<StaffModel> _staff = [];

  bool isLoading = false;
  String? errorMessage;

  String _searchQuery = '';

  List<StaffModel> get staff {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return List.unmodifiable(_staff);
    }

    return _staff.where((member) {
      return member.name.toLowerCase().contains(query) ||
          member.username.toLowerCase().contains(query) ||
          member.mobile.contains(query) ||
          member.staffCode.toLowerCase().contains(query) ||
          member.role.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> loadStaff(int instituteId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _staff = await _service.getStaff(instituteId);
    } catch (error) {
      errorMessage = 'Unable to load staff.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void searchStaff(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
