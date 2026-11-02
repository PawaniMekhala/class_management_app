import 'package:flutter/foundation.dart';

import '../core/services/teacher_leave_service.dart';
import '../models/teacher_leave_model.dart';

class TeacherLeaveProvider extends ChangeNotifier {
  final TeacherLeaveService _service = TeacherLeaveService();

  List<TeacherLeaveModel> _requests = [];

  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  int? _currentInstituteId;
  int _requestVersion = 0;

  TeacherLeaveStatus? _selectedFilter = TeacherLeaveStatus.pending;

  TeacherLeaveStatus? get selectedFilter => _selectedFilter;

  List<TeacherLeaveModel> get requests {
    if (_selectedFilter == null) {
      return List.unmodifiable(_requests);
    }

    return _requests
        .where((request) => request.status == _selectedFilter)
        .toList();
  }

  TeacherLeaveModel? getRequest(int id) {
    for (final request in _requests) {
      if (request.id == id) return request;
    }
    return null;
  }

  void setFilter(TeacherLeaveStatus? status) {
    _selectedFilter = status;
    notifyListeners();
  }

  Future<void> loadRequests(int instituteId) async {
    final version = ++_requestVersion;

    _currentInstituteId = instituteId;
    _requests = [];
    isLoading = true;
    errorMessage = null;
    _selectedFilter = TeacherLeaveStatus.pending;
    notifyListeners();

    try {
      final result = await _service.getLeaveRequests(instituteId);

      if (version != _requestVersion) return;

      _requests = result;
    } catch (error) {
      if (version != _requestVersion) return;

      errorMessage = 'Unable to load teacher leave requests.';
    } finally {
      if (version == _requestVersion) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> decideLeave({
    required int leaveId,
    required TeacherLeaveStatus status,
    required List<LeaveAffectedClassModel> affectedClasses,
    String? decisionComment,
  }) async {
    if (isSaving || _currentInstituteId == null) return false;

    final instituteId = _currentInstituteId!;
    final version = _requestVersion;

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updated = await _service.updateLeaveDecision(
        instituteId: instituteId,
        leaveId: leaveId,
        status: status,
        affectedClasses: affectedClasses,
        decisionComment: decisionComment,
      );

      if (version != _requestVersion) return false;

      final index = _requests.indexWhere((request) => request.id == leaveId);

      if (index != -1) {
        _requests[index] = updated;
      }

      notifyListeners();
      return true;
    } catch (error) {
      if (version == _requestVersion) {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      }
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
