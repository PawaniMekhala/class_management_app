import 'package:flutter/material.dart';

import '../models/institute_model.dart';

class SelectedInstituteProvider extends ChangeNotifier {
  final List<InstituteModel> institutes;

  InstituteModel _selectedInstitute;

  SelectedInstituteProvider({
    required this.institutes,
    required InstituteModel selectedInstitute,
  }) : _selectedInstitute = selectedInstitute;

  InstituteModel get selectedInstitute => _selectedInstitute;

  int get selectedInstituteId => _selectedInstitute.id;

  void selectInstitute(InstituteModel institute) {
    if (_selectedInstitute.id == institute.id) return;

    // Only allow selection from this admin's institute list.
    if (!institutes.any((item) => item.id == institute.id)) return;

    _selectedInstitute = institute;
    notifyListeners();
  }
}
