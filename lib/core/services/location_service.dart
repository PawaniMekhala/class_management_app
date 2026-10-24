import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../../models/district_model.dart';
import '../../models/city_model.dart';

class LocationService {
  Future<List<DistrictModel>> getDistricts() async {
    final response = await http
        .get(
          Uri.parse(ApiConfig.districts),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Failed to load districts.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json['isSuccess'] != true) {
      throw Exception(json['message'] ?? 'Failed to load districts.');
    }

    final data = json['data']['data'] as List<dynamic>;

    return data
        .map((item) => DistrictModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<CityModel>> getCities(String districtId) async {
    final uri = Uri.parse(ApiConfig.cities)
        .replace(queryParameters: {'districtId': districtId});

    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Failed to load cities.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json['isSuccess'] != true) {
      throw Exception(json['message'] ?? 'Failed to load cities.');
    }

    final data = json['data']['data'] as List<dynamic>;

    return data
        .map((item) => CityModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
