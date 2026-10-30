import 'package:flutter/material.dart';

import '../core/services/staff_service.dart';
import '../models/staff_model.dart';

class StaffProvider extends ChangeNotifier {
  final StaffService _service = StaffService();

  List<StaffModel> _staff = [];
  List<StaffModel> get allStaff => List.unmodifiable(_staff);

  bool isLoading = false;
  String? errorMessage;

  String _searchQuery = '';

  bool isSaving = false;

  // Register a new staff member.
  Future<bool> createStaff({
    required int instituteId,
    required String name,
    required String mobile,
    required String email,
    required String role,
    String? designation,
  }) async {
    if (isSaving) return false;

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _service.createStaff(
        instituteId: instituteId,
        name: name,
        mobile: mobile,
        email: email,
        role: role,
        designation: designation,
      );

      _staff = await _service.getStaff(instituteId);
      _searchQuery = '';

      return true;
    } catch (error) {
      errorMessage = 'Unable to register staff: $error';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // Update an existing staff member.
  Future<bool> updateStaff(StaffModel updatedStaff) async {
    if (isSaving) return false;

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _service.updateStaff(updatedStaff);

      _staff = await _service.getStaff(updatedStaff.instituteId);
      _searchQuery = '';

      return true;
    } catch (error) {
      errorMessage = 'Unable to update staff: $error';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

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
