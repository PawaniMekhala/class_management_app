class UserProfileModel {
  final int id;
  final String name;
  final String role;
  final String username;
  final String email;
  final String mobile;
  final String instituteName;
  final String? googleEmail;
  final String? photoUrl;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.role,
    required this.username,
    required this.email,
    required this.mobile,
    required this.instituteName,
    this.googleEmail,
    required this.photoUrl,
  });

  bool get isStudent => role == 'student';

  UserProfileModel copyWith({String? photoUrl}) {
    return UserProfileModel(
      id: id,
      name: name,
      role: role,
      username: username,
      email: email,
      mobile: mobile,
      instituteName: instituteName,
      googleEmail: googleEmail,
      photoUrl: photoUrl,
    );
  }

  //TODO: Match these keys to your actual backend response.
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as int,
      name: json['name'] as String,
      role: json['role'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      mobile: json['mobile'] as String,
      instituteName: json['institute_name'] as String,
      googleEmail: json['google_email'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }
}
