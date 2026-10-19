class TeacherRegistrationModel {
  final int instituteId;
  final String fullName;
  final String nic;
  final String mobile;
  final bool publishMobile;
  final String email;
  final String qualifications;
  final String about;
  final String address;
  final String district;
  final String city;
  final String postalCode;
  final bool publishAddress;
  final List<String> subjects;
  final bool sendLoginSms;
  final String? photoPath;

  const TeacherRegistrationModel({
    required this.instituteId,
    required this.fullName,
    required this.nic,
    required this.mobile,
    required this.publishMobile,
    required this.email,
    required this.qualifications,
    required this.about,
    required this.address,
    required this.district,
    required this.city,
    required this.postalCode,
    required this.publishAddress,
    required this.subjects,
    required this.sendLoginSms,
    this.photoPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'institute_id': instituteId,
      'full_name': fullName,
      'nic': nic,
      'mobile': mobile,
      'publish_mobile': publishMobile,
      'email': email,
      'qualifications': qualifications,
      'about': about,
      'address': address,
      'district': district,
      'city': city,
      'postal_code': postalCode,
      'publish_address': publishAddress,
      'subjects': subjects,
      'send_login_sms': sendLoginSms,
    };
  }
}
