class StaffModel {
  final int id;
  final int instituteId;
  final String name;
  final String staffCode;
  final String role;
  final String username;
  final String mobile;
  final String? email;
  final bool isActive;

  const StaffModel({
    required this.id,
    required this.instituteId,
    required this.name,
    required this.staffCode,
    required this.role,
    required this.username,
    required this.mobile,
    this.email,
    this.isActive = true,
  });
}
