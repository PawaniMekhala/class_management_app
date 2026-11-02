import 'package:flutter/foundation.dart';

import '../core/services/hall_service.dart';
import '../models/hall_model.dart';

class HallProvider extends ChangeNotifier {
  final HallService _service = HallService();

  List<HallModel> _halls = [];
  String _searchQuery = '';
  int? _currentInstituteId;

  bool isLoading = false;
  String? errorMessage;
  final Set<int> _updatingHallIds = {};

  List<HallModel> get allHalls => List.unmodifiable(_halls);

  List<HallModel> get halls {
    final query = _searchQuery.trim().toLowerCase();

    return _halls.where((hall) {
      return hall.name.toLowerCase().contains(query) ||
          hall.number.toLowerCase().contains(query) ||
          hall.building.toLowerCase().contains(query);
    }).toList();
  }

  bool isUpdating(int hallId) => _updatingHallIds.contains(hallId);

  void searchHalls(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadHalls(int instituteId) async {
    _currentInstituteId = instituteId;
    _halls = [];
    _searchQuery = '';
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getHalls(instituteId);

      if (_currentInstituteId != instituteId) return;

      _halls = result;
    } catch (_) {
      if (_currentInstituteId != instituteId) return;
      errorMessage = 'Unable to load halls.';
    } finally {
      if (_currentInstituteId == instituteId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> changeStatus(HallModel hall, String status) async {
    if (_updatingHallIds.contains(hall.id)) return;

    _updatingHallIds.add(hall.id);
    notifyListeners();

    try {
      final updated = await _service.updateHallStatus(
        instituteId: hall.instituteId,
        hallId: hall.id,
        status: status,
      );

      if (_currentInstituteId != hall.instituteId) return;

      final index = _halls.indexWhere((item) => item.id == hall.id);
      if (index != -1) {
        _halls[index] = updated;
      }
    } finally {
      _updatingHallIds.remove(hall.id);
      notifyListeners();
    }
  }

  Future<void> addHall(HallModel hall) async {
    final created = await _service.createHall(hall);

    if (_currentInstituteId == hall.instituteId) {
      _halls.add(created);
      notifyListeners();
    }
  }
}
