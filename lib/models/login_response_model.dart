class LoginInstituteModel {
  final String instituteId;
  final String instituteName;
  final String instituteCode;
  final String organizationName;
  final String accessType;
  final String roleName;

  LoginInstituteModel({
    required this.instituteId,
    required this.instituteName,
    required this.instituteCode,
    required this.organizationName,
    required this.accessType,
    required this.roleName,
  });

  factory LoginInstituteModel.fromJson(Map<String, dynamic> json) {
    return LoginInstituteModel(
      instituteId: json['instituteId']?.toString() ?? '',
      instituteName: json['instituteName']?.toString() ?? '',
      instituteCode: json['instituteCode']?.toString() ?? '',
      organizationName: json['organizationName']?.toString() ?? '',
      accessType: json['accessType']?.toString() ?? '',
      roleName: json['roleName']?.toString() ?? '',
    );
  }
}

class LoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final String expiresAt;
  final bool mustChangePassword;
  final String username;
  final String fullName;
  final List<LoginInstituteModel> institutes;

  LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.mustChangePassword,
    required this.username,
    required this.fullName,
    required this.institutes,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final account = json['account'] as Map<String, dynamic>? ?? {};

    final institutesJson = json['institutes'] as List<dynamic>? ?? [];

    return LoginResponseModel(
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      expiresAt: json['expiresAt']?.toString() ?? '',
      mustChangePassword: json['mustChangePassword'] == true,
      username: account['username']?.toString() ?? '',
      fullName: account['fullName']?.toString() ?? '',
      institutes: institutesJson
          .map(
            (item) =>
                LoginInstituteModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
