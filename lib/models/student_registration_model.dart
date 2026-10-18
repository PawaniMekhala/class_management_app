class StudentGuardianInput {
  final String name;
  final String relationship;
  final String mobile;
  final bool isPrimary;
  final bool isEmergency;

  const StudentGuardianInput({
    required this.name,
    required this.relationship,
    required this.mobile,
    this.isPrimary = false,
    this.isEmergency = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'relationship': relationship,
    'mobile': mobile,
    'is_primary': isPrimary,
    'is_emergency': isEmergency,
  };
}

class StudentRegistrationInput {
  final int instituteId;
  final String fullName;
  final String educationLevel;
  final DateTime dateOfBirth;
  final String gender;
  final String grade;
  final String medium;
  final String schoolName;
  final String mobile;
  final String whatsapp;
  final String email;
  final String address;
  final String district;
  final String city;
  final DateTime admissionDate;
  final double? registrationFee;
  final bool sendLoginSms;
  final List<StudentGuardianInput> guardians;

  const StudentRegistrationInput({
    required this.instituteId,
    required this.fullName,
    required this.educationLevel,
    required this.dateOfBirth,
    required this.gender,
    required this.grade,
    required this.medium,
    required this.schoolName,
    required this.mobile,
    required this.whatsapp,
    required this.email,
    required this.address,
    required this.district,
    required this.city,
    required this.admissionDate,
    required this.registrationFee,
    required this.sendLoginSms,
    required this.guardians,
  });

  Map<String, dynamic> toJson() => {
    'institute_id': instituteId,
    'full_name': fullName,
    'education_level': educationLevel,
    'date_of_birth': dateOfBirth.toIso8601String().substring(0, 10),
    'gender': gender,
    'grade': grade,
    'medium': medium,
    'school_name': schoolName,
    'mobile': mobile,
    'whatsapp': whatsapp,
    'email': email,
    'address': address,
    'district': district,
    'city': city,
    'admission_date': admissionDate.toIso8601String().substring(0, 10),
    'registration_fee': registrationFee,
    'send_login_sms': sendLoginSms,
    'guardians': guardians.map((g) => g.toJson()).toList(),
  };
}
