import '../../models/staff_model.dart';

class StaffService {
  // TODO: BACKEND INTEGRATION
  // Replace dummy data with the Get Institute Staff API.

  static final List<StaffModel> _staff = [
    const StaffModel(
      id: 1,
      instituteId: 1,
      name: 'Nimal Perera',
      staffCode: 'SIPGAM-SF0001',
      role: 'Owner',
      username: 'nimal',
      mobile: '0771234567',
    ),
    const StaffModel(
      id: 2,
      instituteId: 1,
      name: 'Kamala Jayasinghe',
      staffCode: 'SIPGAM-SF0002',
      role: 'Institute Admin',
      username: 'kamala',
      mobile: '0771234568',
    ),
    const StaffModel(
      id: 3,
      instituteId: 1,
      name: 'Sunil Fernando',
      staffCode: 'SIPGAM-SF0003',
      role: 'Cashier',
      username: 'sunil',
      mobile: '0771234569',
    ),
    const StaffModel(
      id: 4,
      instituteId: 1,
      name: 'Ruwan Bandara',
      staffCode: 'SIPGAM-SF0004',
      role: 'Gate Officer',
      username: 'ruwan',
      mobile: '0771234570',
    ),
    const StaffModel(
      id: 5,
      instituteId: 1,
      name: 'Dilani Wickramasinghe',
      staffCode: 'SIPGAM-SF0005',
      role: 'Learning Material Distributor',
      username: 'dilani',
      mobile: '0771234571',
    ),
    const StaffModel(
      id: 6,
      instituteId: 1,
      name: 'Ishara Silva',
      staffCode: 'SIPGAM-SF0006',
      role: 'Front Desk',
      username: 'ishara',
      mobile: '0771234572',
    ),
  ];

  Future<List<StaffModel>> getStaff(int instituteId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _staff.where((staff) => staff.instituteId == instituteId).toList();
  }
}
