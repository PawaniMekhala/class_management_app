import '../../models/institute_settings_model.dart';

class InstituteSettingsService {
  static final Map<int, InstituteSettingsModel> _institutes = {
    1: InstituteSettingsModel(
      id: 1,
      name: 'Sipsala Institute - Gampaha',
      code: 'SIPGAM',
      organization: 'Sipsala Education (Pvt) Ltd',
      email: 'gampaha@sipsala.demo.ims.lk',
      contact: '0332220001',
      address: 'No. 25, Colombo Road, Gampaha, Gampaha',
      establishedDate: DateTime(2012, 1, 15),
    ),
    2: InstituteSettingsModel(
      id: 2,
      name: 'Sipsala Institute - Kandy',
      code: 'SIPKAN',
      organization: 'Sipsala Education (Pvt) Ltd',
      email: 'kandy@sipsala.demo.ims.lk',
      contact: '0812220001',
      address: 'Kandy, Sri Lanka',
      establishedDate: DateTime(2016, 3, 10),
    ),
  };

  // TO DO: API GET /institute/{id}
  Future<InstituteSettingsModel?> getInstitute(int instituteId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _institutes[instituteId];
  }

  // TO DO: API PUT /institute/{id}
  Future<void> updateInstitute(InstituteSettingsModel institute) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!_institutes.containsKey(institute.id)) {
      throw Exception('Institute not found');
    }

    _institutes[institute.id] = institute;
  }
}
