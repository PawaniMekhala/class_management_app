class StaffRoleModel {
  final int id;
  final int instituteId;
  final String name;
  final String description;
  final bool isSystemRole;
  // final int moduleCount;

  // Module name -> permission name -> allowed/denied
  final Map<String, Map<String, bool>> permissions;

  const StaffRoleModel({
    required this.id,
    required this.instituteId,
    required this.name,
    required this.description,
    required this.isSystemRole,
    // required this.moduleCount,
    required this.permissions,
  });

  int get moduleCount {
    return permissions.values
        .where(
          (modulePermissions) =>
              modulePermissions.values.any((allowed) => allowed),
        )
        .length;
  }

  bool get isProtected =>
      isSystemRole &&
      (name.toLowerCase() == 'owner' ||
          name.toLowerCase() == 'institute admin');

  StaffRoleModel copyWith({
    String? name,
    String? description,
    Map<String, Map<String, bool>>? permissions,
  }) {
    return StaffRoleModel(
      id: id,
      instituteId: instituteId,
      name: name ?? this.name,
      description: description ?? this.description,
      isSystemRole: isSystemRole,
      permissions: permissions ?? this.permissions,
    );
  }
}
