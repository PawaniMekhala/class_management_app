import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../../models/login_response_model.dart';

import 'package:flutter/foundation.dart';

class AuthService {
  Future<LoginResponseModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'username': username.trim(),
              'password': password,
              'deviceName': 'Flutter Android App',
            }),
          )
          .timeout(const Duration(seconds: 30));
      debugPrint('========== LOGIN API ==========');
      debugPrint('URL: ${ApiConfig.login}');
      debugPrint('HTTP Status: ${response.statusCode}');
      debugPrint('================================');

      final Map<String, dynamic> responseJson;

      try {
        responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      } on FormatException {
        throw Exception('The server returned an invalid response.');
      } on TypeError {
        throw Exception('The server returned an unexpected response.');
      }

      // if (response.statusCode < 200 ||
      //     response.statusCode >= 300 ||
      //     responseJson['isSuccess'] != true) {
      //   throw Exception(
      //     responseJson['message']?.toString() ??
      //         'Login failed. Please try again.',
      //   );
      // }

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          responseJson['isSuccess'] != true) {
        final errorMessage =
            responseJson['message']?.toString() ??
            'Login failed. Please try again.';

        debugPrint('LOGIN API FAILED');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Error Message: $errorMessage');

        throw Exception(errorMessage);
      }

      final wrapper = responseJson['data'];

      if (wrapper is! Map<String, dynamic>) {
        throw Exception('Login response is missing data.');
      }

      final loginData = wrapper['data'];

      if (loginData is! Map<String, dynamic>) {
        throw Exception('Login response is incomplete.');
      }

      final result = LoginResponseModel.fromJson(loginData);

      if (result.accessToken.isEmpty || result.refreshToken.isEmpty) {
        throw Exception('Authentication tokens were not returned.');
      }

      return result;
    } on SocketException {
      throw Exception(
        'Unable to connect to the server. Check your internet connection.',
      );
    } on TimeoutException {
      throw Exception('Connection timed out. Please try again.');
    }
  }
}
