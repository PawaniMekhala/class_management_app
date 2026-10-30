class StaffRoleModel {
  final int id;
  final int instituteId;
  final String name;
  final String description;
  final bool isSystemRole;
  final int moduleCount;

  const StaffRoleModel({
    required this.id,
    required this.instituteId,
    required this.name,
    required this.description,
    required this.isSystemRole,
    required this.moduleCount,
  });
}
