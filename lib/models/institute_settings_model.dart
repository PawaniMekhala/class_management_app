class InstituteSettingsModel {
  final int id;
  final String name;
  final String code;
  final String organization;
  final String email;
  final String contact;
  final String address;
  final DateTime establishedDate;

  const InstituteSettingsModel({
    required this.id,
    required this.name,
    required this.code,
    required this.organization,
    required this.email,
    required this.contact,
    required this.address,
    required this.establishedDate,
  });

  InstituteSettingsModel copyWith({
    String? name,
    String? code,
    String? organization,
    String? email,
    String? contact,
    String? address,
    DateTime? establishedDate,
  }) {
    return InstituteSettingsModel(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      organization: organization ?? this.organization,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      address: address ?? this.address,
      establishedDate: establishedDate ?? this.establishedDate,
    );
  }
}
