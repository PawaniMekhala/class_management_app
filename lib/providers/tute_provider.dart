import 'package:flutter/material.dart';

import '../core/services/tute_service.dart';
import '../models/tute_model.dart';
import '../models/tute_distribution_model.dart';

class TuteProvider extends ChangeNotifier {
  final TuteService _service = TuteService();

  List<TuteModel> _tutes = [];
  List<TuteDistributionModel> _distributions = [];

  bool isLoading = false;
  String? errorMessage;

  List<TuteModel> get tutes => List.unmodifiable(_tutes);

  List<TuteDistributionModel> get distributions =>
      List.unmodifiable(_distributions);

  Future<void> loadTutes(int instituteId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _tutes = await _service.getTutes(instituteId);

      _distributions = await _service.getDistributions(instituteId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool hasReceived({required int tuteId, required int studentId}) {
    return _distributions.any(
      (record) => record.tuteId == tuteId && record.studentId == studentId,
    );
  }

  int receivedCount({
    required int tuteId,
    required List<int> enrolledStudentIds,
  }) {
    return enrolledStudentIds
        .where((studentId) => hasReceived(tuteId: tuteId, studentId: studentId))
        .length;
  }

  int pendingCount({
    required int tuteId,
    required List<int> enrolledStudentIds,
  }) {
    return enrolledStudentIds.length -
        receivedCount(tuteId: tuteId, enrolledStudentIds: enrolledStudentIds);
  }

  Future<void> markAsReceived({
    required int instituteId,
    required int tuteId,
    required List<int> studentIds,
  }) async {
    await _service.markAsReceived(
      instituteId: instituteId,
      tuteId: tuteId,
      studentIds: studentIds,
    );

    _distributions = await _service.getDistributions(instituteId);

    notifyListeners();
  }

  // Create a new tute.
  Future<void> createTute({
    required int instituteId,
    required int classId,
    required String name,
    required String unitName,
    required DateTime releaseDate,
    required TuteStatus status,
  }) async {
    final newTute = await _service.createTute(
      instituteId: instituteId,
      classId: classId,
      name: name,
      unitName: unitName,
      releaseDate: releaseDate,
      status: status,
    );

    // Add the new tute to the existing list.
    _tutes.add(newTute);

    // Refresh the UI.
    notifyListeners();
  }
}
