class StudentDetailModel {
  final int id;
  final int instituteId;
  final String name;
  final String studentCode;
  final String username;
  final String grade;
  final String qrValue;
  // final bool isActive;
  final int instituteCount;

  final String dateOfBirth;
  final String gender;
  final String school;
  final String mobile;
  final String whatsapp;
  final String address;
  // final String admission;
  final StudentInstituteRegistration instituteRegistration;

  final List<StudentGuardianModel> guardians;
  final List<StudentEnrolledClassModel> classes;

  const StudentDetailModel({
    required this.id,
    required this.instituteId,
    required this.name,
    required this.studentCode,
    required this.username,
    required this.grade,
    required this.qrValue,
    // required this.isActive,
    required this.instituteCount,
    required this.dateOfBirth,
    required this.gender,
    required this.school,
    required this.mobile,
    required this.whatsapp,
    required this.address,
    // required this.admission,
    required this.guardians,
    required this.classes,
    required this.instituteRegistration,
  });

  factory StudentDetailModel.fromJson(Map<String, dynamic> json) {
    return StudentDetailModel(
      id: json['id'] as int,
      instituteId: json['institute_id'] as int,
      name: json['name'] as String,
      studentCode: json['student_code'] as String,
      username: json['username'] as String,
      grade: json['grade'] as String,
      qrValue: json['qr_value'] as String,
      // isActive: json['is_active'] as bool,
      instituteCount: json['institute_count'] as int,
      dateOfBirth: json['date_of_birth'] as String,
      gender: json['gender'] as String,
      school: json['school'] as String,
      mobile: json['mobile'] as String,
      whatsapp: json['whatsapp'] as String,
      address: json['address'] as String,
      // admission: json['admission'] as String,
      guardians: (json['guardians'] as List)
          .map((item) => StudentGuardianModel.fromJson(item))
          .toList(),
      classes: (json['classes'] as List)
          .map((item) => StudentEnrolledClassModel.fromJson(item))
          .toList(),
      instituteRegistration: StudentInstituteRegistration.fromJson(
        json['institute_registration'] as Map<String, dynamic>,
      ),
    );
  }
}

class StudentGuardianModel {
  final String name;
  final String relationship;
  final String mobile;
  final bool isPrimary;
  final bool isEmergency;

  const StudentGuardianModel({
    required this.name,
    required this.relationship,
    required this.mobile,
    required this.isPrimary,
    required this.isEmergency,
  });

  factory StudentGuardianModel.fromJson(Map<String, dynamic> json) {
    return StudentGuardianModel(
      name: json['name'] as String,
      relationship: json['relationship'] as String,
      mobile: json['mobile'] as String,
      isPrimary: json['is_primary'] as bool,
      isEmergency: json['is_emergency'] as bool,
    );
  }
}

class StudentEnrolledClassModel {
  final int id;
  final String name;
  final String code;
  final String paymentType;
  final bool isActive;

  const StudentEnrolledClassModel({
    required this.id,
    required this.name,
    required this.code,
    required this.paymentType,
    required this.isActive,
  });

  factory StudentEnrolledClassModel.fromJson(Map<String, dynamic> json) {
    return StudentEnrolledClassModel(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      paymentType: json['payment_type'] as String,
      isActive: json['is_active'] as bool,
    );
  }
}

class StudentInstituteRegistration {
  final int instituteId;
  final String grade;
  final String status;
  final DateTime admissionDate;
  final double registrationFeePaid;
  final String currency;

  const StudentInstituteRegistration({
    required this.instituteId,
    required this.grade,
    required this.status,
    required this.admissionDate,
    required this.registrationFeePaid,
    required this.currency,
  });

  bool get isActive => status.toLowerCase() == 'active';

  factory StudentInstituteRegistration.fromJson(Map<String, dynamic> json) {
    return StudentInstituteRegistration(
      instituteId: json['institute_id'] as int,
      grade: json['grade'] as String,
      status: json['status'] as String,
      admissionDate: DateTime.parse(json['admission_date'] as String),
      registrationFeePaid: (json['registration_fee_paid'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }
}
