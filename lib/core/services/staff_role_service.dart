import '../../models/staff_role_model.dart';

class StaffRoleService {
  // TODO: BACKEND INTEGRATION
  // Replace these records with the institute roles API.

  static final List<StaffRoleModel> _roles = [
    const StaffRoleModel(
      id: 1,
      instituteId: 1,
      name: 'Cashier',
      description: 'Manage student payments and receipts.',
      isSystemRole: true,
      moduleCount: 7,
    ),
    const StaffRoleModel(
      id: 2,
      instituteId: 1,
      name: 'Gate Officer',
      description: 'Manage student entry and exit.',
      isSystemRole: true,
      moduleCount: 5,
    ),
    const StaffRoleModel(
      id: 3,
      instituteId: 1,
      name: 'Institute Admin',
      description: 'Manage daily institute operations.',
      isSystemRole: true,
      moduleCount: 16,
    ),
    const StaffRoleModel(
      id: 4,
      instituteId: 1,
      name: 'Learning Material Distributor',
      description: 'Manage learning material distribution.',
      isSystemRole: true,
      moduleCount: 6,
    ),
    const StaffRoleModel(
      id: 5,
      instituteId: 1,
      name: 'Owner',
      description: 'Manage the institute.',
      isSystemRole: true,
      moduleCount: 16,
    ),
    const StaffRoleModel(
      id: 6,
      instituteId: 1,
      name: 'Front Desk',
      description: 'Assist with front desk operations.',
      isSystemRole: false,
      moduleCount: 6,
    ),
  ];

  Future<List<StaffRoleModel>> getRoles(int instituteId) async {
    await Future.delayed(const Duration(milliseconds: 250));

    return _roles.where((role) => role.instituteId == instituteId).toList();
  }

  Future<StaffRoleModel> createRole({
    required int instituteId,
    required String name,
    required String description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw Exception('Role name is required.');
    }

    final alreadyExists = _roles.any(
      (role) =>
          role.instituteId == instituteId &&
          role.name.toLowerCase() == normalizedName.toLowerCase(),
    );

    if (alreadyExists) {
      throw Exception('A role with this name already exists.');
    }

    final nextId = _roles.isEmpty
        ? 1
        : _roles.map((role) => role.id).reduce((a, b) => a > b ? a : b) + 1;

    final role = StaffRoleModel(
      id: nextId,
      instituteId: instituteId,
      name: normalizedName,
      description: description.trim(),
      isSystemRole: false,
      moduleCount: 0,
    );

    _roles.add(role);

    return role;
  }
}
