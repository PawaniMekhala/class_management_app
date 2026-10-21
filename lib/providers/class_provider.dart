import 'package:flutter/foundation.dart';

import '../core/services/class_service.dart';
import '../models/class_model.dart';

class ClassProvider extends ChangeNotifier {
  final ClassService _service = ClassService();

  List<InstituteClass> _classes = [];
  String _query = '';
  int? _instituteId;

  bool isLoading = false;
  String? errorMessage;

  List<InstituteClass> get classes {
    final search = _query.trim().toLowerCase();

    return _classes.where((item) {
      return item.name.toLowerCase().contains(search) ||
          item.code.toLowerCase().contains(search) ||
          item.subject.toLowerCase().contains(search) ||
          item.teachers.any(
            (teacher) => teacher.name.toLowerCase().contains(search),
          );
    }).toList();
  }

  List<InstituteClass> get allClasses => List.unmodifiable(_classes);

  void searchClasses(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> loadClasses(int instituteId) async {
    _instituteId = instituteId;
    _classes = [];
    _query = '';
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getClasses(instituteId);
      if (_instituteId != instituteId) return;
      _classes = result;
    } catch (_) {
      if (_instituteId != instituteId) return;
      errorMessage = 'Unable to load classes.';
    } finally {
      if (_instituteId == instituteId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> addClass(InstituteClass item) async {
    final created = await _service.createClass(item);

    if (_instituteId == item.instituteId) {
      _classes.add(created);
      notifyListeners();
    }
  }

  List<ClassSession> upcomingSessions(InstituteClass item, {int days = 28}) {
    final today = DateTime.now();
    return _service.generateSessions(
      item,
      today,
      today.add(Duration(days: days)),
    );
  }
}
