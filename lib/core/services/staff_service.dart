import '../../models/staff_model.dart';

class StaffService {
  // TO DO: BACKEND INTEGRATION
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

  // TO DO: BACKEND INTEGRATION
  // Replace with the Create Staff API.
  Future<StaffModel> createStaff({
    required int instituteId,
    required String name,
    required String mobile,
    required String email,
    required String role,
    String? designation,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final instituteStaff = _staff
        .where((item) => item.instituteId == instituteId)
        .toList();

    final nextId = _staff.isEmpty
        ? 1
        : _staff.map((item) => item.id).reduce((a, b) => a > b ? a : b) + 1;

    final nextNumber = instituteStaff.length + 1;

    final prefix = instituteStaff.isNotEmpty
        ? instituteStaff.first.staffCode.split('-SF').first
        : 'INS$instituteId';

    final newStaff = StaffModel(
      id: nextId,
      instituteId: instituteId,
      name: name,
      staffCode: '$prefix-SF${nextNumber.toString().padLeft(4, '0')}',
      username: 'staff$nextId',
      mobile: mobile,
      email: email,
      role: role,
      designation: designation,
    );

    _staff.add(newStaff);

    return newStaff;
  }

  // TO DO: BACKEND INTEGRATION
  // Replace with the Update Staff API.
  Future<StaffModel> updateStaff(StaffModel updatedStaff) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _staff.indexWhere(
      (item) =>
          item.id == updatedStaff.id &&
          item.instituteId == updatedStaff.instituteId,
    );

    if (index == -1) {
      throw Exception('Staff member not found.');
    }

    _staff[index] = updatedStaff;

    return updatedStaff;
  }
}
