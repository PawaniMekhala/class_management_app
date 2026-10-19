import 'package:flutter/foundation.dart';

import '../core/services/student_profile_request_service.dart';
import '../models/student_profile_request_model.dart';

class StudentProfileRequestProvider extends ChangeNotifier {
  final StudentProfileRequestService _service = StudentProfileRequestService();

  List<StudentProfileRequestModel> _requests = [];
  String _searchQuery = '';
  int? _instituteId;

  bool isLoading = false;
  String? errorMessage;

  final Set<int> _processingIds = {};

  bool isProcessing(int requestId) => _processingIds.contains(requestId);

  List<StudentProfileRequestModel> get pendingRequests =>
      _filtered(ProfileRequestStatus.pending);

  List<StudentProfileRequestModel> get historyRequests {
    final result = _requests.where((request) {
      return request.status != ProfileRequestStatus.pending &&
          _matchesSearch(request);
    }).toList();

    result.sort((a, b) {
      final aDate = a.reviewedAt ?? a.requestedAt;
      final bDate = b.reviewedAt ?? b.requestedAt;
      return bDate.compareTo(aDate);
    });

    return result;
  }

  List<StudentProfileRequestModel> _filtered(ProfileRequestStatus status) {
    final result = _requests.where((request) {
      return request.status == status && _matchesSearch(request);
    }).toList();

    result.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

    return result;
  }

  bool _matchesSearch(StudentProfileRequestModel request) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) return true;

    return request.studentName.toLowerCase().contains(query) ||
        request.studentCode.toLowerCase().contains(query);
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadRequests(int instituteId) async {
    _instituteId = instituteId;
    _requests = [];
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getRequests(instituteId);

      if (_instituteId != instituteId) return;

      _requests = result;
    } catch (_) {
      if (_instituteId != instituteId) return;
      errorMessage = 'Unable to load profile requests.';
    } finally {
      if (_instituteId == instituteId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> reviewRequest({
    required int requestId,
    required bool approve,
  }) async {
    final instituteId = _instituteId;

    if (instituteId == null || isProcessing(requestId)) {
      return false;
    }

    _processingIds.add(requestId);
    notifyListeners();

    try {
      await _service.reviewRequest(
        instituteId: instituteId,
        requestId: requestId,
        approve: approve,
      );

      if (_instituteId != instituteId) return false;

      // Demo service has updated the request object.
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    } finally {
      _processingIds.remove(requestId);
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final instituteId = _instituteId;
    if (instituteId == null) return;

    await loadRequests(instituteId);
  }
}
