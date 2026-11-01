class InstituteSettingsModel {
  final int id;
  final String name;
  final String code;
  final String organization;
  final String email;
  final String contact;
  final String address;

  final String postalCode;
  final String districtId;
  final String cityId;

  // Nullable so the date can be cleared.
  final DateTime? establishedDate;

  const InstituteSettingsModel({
    required this.id,
    required this.name,
    required this.code,
    required this.organization,
    required this.email,
    required this.contact,
    required this.address,
    this.postalCode = '',
    this.districtId = '',
    this.cityId = '',
    required this.establishedDate,
  });

  InstituteSettingsModel copyWith({
    String? name,
    String? code,
    String? organization,
    String? email,
    String? contact,
    String? address,
    String? postalCode,
    String? districtId,
    String? cityId,
    DateTime? establishedDate,
    bool clearEstablishedDate = false,
  }) {
    return InstituteSettingsModel(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      organization: organization ?? this.organization,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      districtId: districtId ?? this.districtId,
      cityId: cityId ?? this.cityId,
      establishedDate: clearEstablishedDate
          ? null
          : (establishedDate ?? this.establishedDate),
    );
  }
}
