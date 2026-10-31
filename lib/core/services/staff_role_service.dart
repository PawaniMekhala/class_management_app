import '../../models/staff_role_model.dart';
import '../constants/permission_constants.dart';

class StaffRoleService {
  // TO DO: BACKEND INTEGRATION
  // Replace these records with the Roles and Permissions APIs.

  static final List<StaffRoleModel> _roles = [
    StaffRoleModel(
      id: 1,
      instituteId: 1,
      name: 'Cashier',
      description: 'Manage student payments and receipts.',
      isSystemRole: true,
      permissions: PermissionConstants.createPermissions(
        allowed: {
          'Dashboard': ['View'],
          'Students': ['View'],
          'Classes': ['View'],
          'Enrollment': ['View'],
          'Payments': ['View', 'Create', 'Edit'],
          'Reports': ['View'],
          'Notices': ['View'],
        },
      ),
    ),
    StaffRoleModel(
      id: 2,
      instituteId: 1,
      name: 'Gate Officer',
      description: 'Manage student entry and exit.',
      isSystemRole: true,
      permissions: PermissionConstants.createPermissions(
        allowed: {
          'Dashboard': ['View'],
          'Students': ['View'],
          'Classes': ['View'],
          'Enrollment': ['View'],
          'Attendance': ['View', 'Create', 'Edit'],
        },
      ),
    ),
    StaffRoleModel(
      id: 3,
      instituteId: 1,
      name: 'Institute Admin',
      description: 'Manage daily institute operations.',
      isSystemRole: true,
      permissions: PermissionConstants.createPermissions(
        allowed: {
          for (final module in PermissionConstants.modules)
            module: PermissionConstants.actions,
        },
      ),
    ),
    StaffRoleModel(
      id: 4,
      instituteId: 1,
      name: 'Learning Material Distributor',
      description: 'Manage learning material distribution.',
      isSystemRole: true,
      permissions: PermissionConstants.createPermissions(
        allowed: {
          'Dashboard': ['View'],
          'Students': ['View'],
          'Classes': ['View'],
          'Enrollment': ['View'],
          'Tutes & materials': ['View', 'Create', 'Edit'],
          'Notices': ['View'],
        },
      ),
    ),
    StaffRoleModel(
      id: 5,
      instituteId: 1,
      name: 'Owner',
      description: 'Manage the institute.',
      isSystemRole: true,
      permissions: PermissionConstants.createPermissions(
        allowed: {
          for (final module in PermissionConstants.modules)
            module: PermissionConstants.actions,
        },
      ),
    ),
    StaffRoleModel(
      id: 6,
      instituteId: 1,
      name: 'Front Desk',
      description: 'Registers students and enrollments; read-only elsewhere.',
      isSystemRole: false,
      permissions: PermissionConstants.createPermissions(
        allowed: {
          'Dashboard': ['View'],
          'Students': ['View', 'Create', 'Edit'],
          'Classes': ['View'],
          'Enrollment': ['View', 'Create', 'Edit'],
          'Payments': ['View'],
        },
      ),
    ),
    StaffRoleModel(
      id: 3,
      instituteId: 2,
      name: 'Institute Admin',
      description: 'Manage daily institute operations.',
      isSystemRole: true,
      permissions: PermissionConstants.createPermissions(
        allowed: {
          for (final module in PermissionConstants.modules)
            module: PermissionConstants.actions,
        },
      ),
    ),
  ];

  // TO DO: BACKEND INTEGRATION
  // The backend must create these roles when an institute is registered.
  // This method is only for the dummy frontend implementation.

  void _ensureDefaultRoles(int instituteId) {
    for (final roleName in ['Owner', 'Institute Admin']) {
      final index = _roles.indexWhere(
        (role) =>
            role.instituteId == instituteId &&
            role.name == roleName &&
            role.isSystemRole,
      );

      final fullPermissions = PermissionConstants.createPermissions(
        allowed: {
          for (final module in PermissionConstants.modules)
            module: PermissionConstants.actions,
        },
      );

      if (index != -1) {
        // Keep protected roles at full access.
        _roles[index] = _roles[index].copyWith(permissions: fullPermissions);
        continue;
      }

      final nextId = _roles.isEmpty
          ? 1
          : _roles.map((role) => role.id).reduce((a, b) => a > b ? a : b) + 1;

      _roles.add(
        StaffRoleModel(
          id: nextId,
          instituteId: instituteId,
          name: roleName,
          description: roleName == 'Owner'
              ? 'Full access to institute management.'
              : 'Full access to institute operations.',
          isSystemRole: true,
          permissions: fullPermissions,
        ),
      );
    }
  }

  Future<List<StaffRoleModel>> getRoles(int instituteId) async {
    await Future.delayed(const Duration(milliseconds: 250));

    // Ensure every institute has Owner and Institute Admin roles.
    _ensureDefaultRoles(instituteId);

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
      permissions: PermissionConstants.emptyPermissions(),
    );

    _roles.add(role);

    return role;
  }

  // TO DO: BACKEND INTEGRATION
  // Replace with Update Role and Permissions API.
  Future<StaffRoleModel> updateRole(StaffRoleModel updatedRole) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _roles.indexWhere(
      (role) =>
          role.id == updatedRole.id &&
          role.instituteId == updatedRole.instituteId,
    );

    final existingRole = _roles[index];

    if (index == -1) {
      throw Exception('Role not found.');
    }

    // Protect Owner and Institute Admin.
    if (existingRole.isProtected) {
      throw Exception('Owner and Institute Admin roles cannot be modified.');
    }

    final duplicateName = _roles.any(
      (role) =>
          role.id != updatedRole.id &&
          role.instituteId == updatedRole.instituteId &&
          role.name.toLowerCase() == updatedRole.name.trim().toLowerCase(),
    );

    if (duplicateName) {
      throw Exception('A role with this name already exists.');
    }

    final savedRole = updatedRole.copyWith(
      permissions: PermissionConstants.copyPermissions(updatedRole.permissions),
    );

    _roles[index] = savedRole;

    return savedRole;
  }

  // TO DO: BACKEND INTEGRATION
  // Replace with the Delete Role API.
  //
  // The backend must:
  // 1. Verify that the user has permission to delete roles.
  // 2. Reject deletion of Owner and Institute Admin.
  // 3. Reject deletion when staff members are assigned.
  // 4. Delete the role only from the selected institute.

  Future<void> deleteRole({
    required int instituteId,
    required int roleId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _roles.indexWhere(
      (role) => role.id == roleId && role.instituteId == instituteId,
    );

    if (index == -1) {
      throw Exception('Role not found.');
    }

    final role = _roles[index];

    if (role.isProtected) {
      throw Exception('Owner and Institute Admin roles cannot be deleted.');
    }

    _roles.removeAt(index);
  }
}
