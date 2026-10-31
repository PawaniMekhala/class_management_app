import 'package:flutter/material.dart';

import '../core/services/staff_role_service.dart';
import '../models/staff_role_model.dart';

class StaffRoleProvider extends ChangeNotifier {
  final StaffRoleService _service = StaffRoleService();

  List<StaffRoleModel> _roles = [];

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  String _searchQuery = '';

  List<StaffRoleModel> get roles {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return List.unmodifiable(_roles);
    }

    return _roles.where((role) {
      return role.name.toLowerCase().contains(query) ||
          role.description.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> loadRoles(int instituteId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _roles = await _service.getRoles(instituteId);
    } catch (error) {
      errorMessage = 'Unable to load roles: $error';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void searchRoles(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Future<bool> createRole({
    required int instituteId,
    required String name,
    required String description,
  }) async {
    if (isSaving) return false;

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _service.createRole(
        instituteId: instituteId,
        name: name,
        description: description,
      );

      _roles = await _service.getRoles(instituteId);
      _searchQuery = '';

      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateRole(StaffRoleModel updatedRole) async {
    if (isSaving) return false;

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _service.updateRole(updatedRole);

      _roles = await _service.getRoles(updatedRole.instituteId);

      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRole({
    required int instituteId,
    required int roleId,
    required bool hasAssignedStaff,
  }) async {
    if (isSaving) return false;

    errorMessage = null;

    if (hasAssignedStaff) {
      errorMessage =
          'This role is assigned to staff members. '
          'Please reassign them before deleting the role.';

      notifyListeners();
      return false;
    }

    isSaving = true;
    notifyListeners();

    try {
      await _service.deleteRole(instituteId: instituteId, roleId: roleId);

      _roles = await _service.getRoles(instituteId);

      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');

      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
