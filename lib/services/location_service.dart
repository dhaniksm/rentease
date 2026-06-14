import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentease/models/location_model.dart';
import 'package:rentease/core/api_config.dart';
import 'package:rentease/core/supabase_config.dart';

class LocationService {
  static String get baseUrl => ApiConfig.baseUrl;

  Map<String, String> get _headers {
    final token = supabase.auth.currentSession?.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<LocationModel>> getLocations() async {
    final response = await http.get(Uri.parse('$baseUrl/locations'), headers: _headers);
    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    final List<dynamic> data = decoded['data'] ?? [];

    return data
        .map((json) => LocationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateLocation(LocationModel location) async {
    final response = await http.post(
      Uri.parse('$baseUrl/locations'),
      headers: _headers,
      body: jsonEncode(location.toJson()),
    );
    _checkResponse(response);
  }

  Future<List<LocationModel>> getLocationHistory(String rentalId) async {
    final response = await http.get(Uri.parse('$baseUrl/locations/$rentalId'), headers: _headers);
    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    final List<dynamic> data = decoded['data'] ?? [];

    return data
        .map((json) => LocationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<LocationModel> getLatestLocation(String rentalId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/locations/$rentalId/latest'),
      headers: _headers,
    );
    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    return LocationModel.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    try {
      final decoded = jsonDecode(response.body);
      final message = decoded['message'] ?? decoded['error'] ?? response.body;
      throw Exception(message);
    } catch (_) {
      throw Exception('Request gagal: ${response.statusCode}');
    }
  }
}
