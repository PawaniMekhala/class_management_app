class ApiConfig {
  static const String baseUrl = 'https://mcleapi.dtl.lk/api/IMS/';

  static const String districts = '${baseUrl}ReferenceData/Districts';

  static const String cities = '${baseUrl}ReferenceData/Cities';

  static const String registerInstitute =
      '${baseUrl}Onboarding/RegisterInstitute';

  static const String login = '${baseUrl}Auth/Login';

  static const String selectInstitute = '${baseUrl}Auth/SelectInstitute';
}
