class InstituteRegistrationModel {
  final String instituteName;
  final String instituteEmail;
  final String contactNumber;
  final String address;
  final String district;
  final String city;
  final String? organizationName;

  final String ownerName;
  final String ownerEmail;
  final String ownerMobile;
  final String? ownerNic;
  final String password;

  const InstituteRegistrationModel({
    required this.instituteName,
    required this.instituteEmail,
    required this.contactNumber,
    required this.address,
    required this.district,
    required this.city,
    this.organizationName,
    required this.ownerName,
    required this.ownerEmail,
    required this.ownerMobile,
    this.ownerNic,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'institute_name': instituteName,
      'institute_email': instituteEmail,
      'contact_number': contactNumber,
      'address': address,
      'district': district,
      'city': city,
      'organization_name': organizationName,
      'owner_name': ownerName,
      'owner_email': ownerEmail,
      'owner_mobile': ownerMobile,
      'owner_nic': ownerNic,
      'password': password,
    };
  }
}
