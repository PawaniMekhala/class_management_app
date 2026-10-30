class StaffModel {
  final int id;
  final int instituteId;
  final String name;
  final String staffCode;
  final String role;
  final String username;
  final String mobile;
  final String? email;
  final String? designation;
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
    this.designation,
    this.isActive = true,
  });

  StaffModel copyWith({
    String? name,
    String? role,
    String? mobile,
    String? email,
    String? designation,
    bool? isActive,
  }) {
    return StaffModel(
      id: id,
      instituteId: instituteId,
      name: name ?? this.name,
      staffCode: staffCode,
      role: role ?? this.role,
      username: username,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      designation: designation ?? this.designation,
      isActive: isActive ?? this.isActive,
    );
  }
}
