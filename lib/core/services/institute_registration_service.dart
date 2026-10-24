import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../../models/institute_registration_model.dart';
import '../../models/institute_registration_response_model.dart';

class InstituteRegistrationService {
  Future<InstituteRegistrationResponseModel> registerInstitute(
    InstituteRegistrationModel registration,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.registerInstitute),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(registration.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      Map<String, dynamic> responseJson;

      try {
        responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      } on FormatException {
        throw Exception('The server returned an invalid response.');
      } on TypeError {
        throw Exception('The server returned an unexpected response.');
      }

      final message =
          responseJson['message']?.toString() ??
          'Unable to register institute.';

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          responseJson['isSuccess'] != true) {
        throw Exception(message);
      }

      final wrapper = responseJson['data'];

      if (wrapper is! Map<String, dynamic>) {
        throw Exception('Registration response is missing data.');
      }

      final registrationData = wrapper['data'];

      if (registrationData is! Map<String, dynamic>) {
        throw Exception('Registration response is incomplete.');
      }

      return InstituteRegistrationResponseModel.fromJson(
        registrationData,
        message: message,
      );
    } on SocketException {
      throw Exception(
        'Unable to connect to the server. Check your internet connection.',
      );
    } on TimeoutException {
      throw Exception(
        'The request timed out. Please check whether registration succeeded before trying again.',
      );
    }
  }
}
