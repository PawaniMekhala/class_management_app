class InstituteRegistrationResponseModel {
  final String organizationId;
  final String instituteId;
  final String instituteCode;
  final String username;
  final String status;
  final String message;

  const InstituteRegistrationResponseModel({
    required this.organizationId,
    required this.instituteId,
    required this.instituteCode,
    required this.username,
    required this.status,
    required this.message,
  });

  factory InstituteRegistrationResponseModel.fromJson(
    Map<String, dynamic> json, {
    required String message,
  }) {
    return InstituteRegistrationResponseModel(
      organizationId: json['organizationId'] as String,
      instituteId: json['instituteId'] as String,
      instituteCode: json['instituteCode'] as String,
      username: json['username'] as String,
      status: json['status'] as String,
      message: message,
    );
  }
}
