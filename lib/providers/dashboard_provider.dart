import 'package:flutter/material.dart';

import '../core/services/dashboard_service.dart';
import '../models/dashboard_stat_model.dart';
import '../models/notice_model.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _service = DashboardService();

  bool isLoading = false;
  String? errorMessage;

  List<NoticeModel> notices = [];

  Map<String, List<DashboardStatModel>> stats = {};

  Future<void> loadDashboard(int instituteId) async {
    isLoading = true;
    errorMessage = null;

    // Clear previous institute's data
    notices = [];
    stats = {};

    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getNotices(instituteId),
        _service.getDashboardStats(instituteId),
      ]);

      notices = results[0] as List<NoticeModel>;
      stats = results[1] as Map<String, List<DashboardStatModel>>;
    } catch (e) {
      errorMessage = 'Failed to load dashboard data.';
      debugPrint('Dashboard error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
