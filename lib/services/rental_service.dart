import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentease/models/rental_model.dart';
import 'package:rentease/core/api_config.dart';
import 'package:rentease/core/supabase_config.dart';

class RentalService {
  static String get baseUrl => ApiConfig.baseUrl;

  Map<String, String> get _headers {
    final token = supabase.auth.currentSession?.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> addRental(RentalModel rental) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rentals'),
      headers: _headers,
      body: jsonEncode(rental.toJson()),
    );
    _checkResponse(response);
  }

  Future<List<RentalModel>> getRentals() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final response = await http.get(
      Uri.parse('$baseUrl/rentals?t=$timestamp'),
      headers: _headers,
    );
    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    final List<dynamic> data = decoded['data'] ?? [];

    return data
        .map((json) => RentalModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<RentalModel>> getUserRentalHistory(String userId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final response = await http.get(
      Uri.parse('$baseUrl/rentals/history/$userId?t=$timestamp'),
      headers: _headers,
    );
    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    final List<dynamic> data = decoded['data'] ?? [];

    return data
        .map((json) => RentalModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<dynamic>> getRawUserRentalHistory(String userId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final response = await http.get(
      Uri.parse('$baseUrl/rentals/history/$userId?t=$timestamp'),
      headers: _headers,
    );
    _checkResponse(response);
    final decoded = jsonDecode(response.body);
    return decoded['data'] ?? [];
  }

  Future<List<dynamic>> getRawRentals() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final response = await http.get(
      Uri.parse('$baseUrl/rentals?t=$timestamp'),
      headers: _headers,
    );
    _checkResponse(response);
    final decoded = jsonDecode(response.body);
    return decoded['data'] ?? [];
  }

  Future<void> verifyVehicle(String rentalId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/rentals/$rentalId/pickup'),
      headers: _headers,
    );
    _checkResponse(response);
  }

  Future<void> returnRental(String rentalId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/rentals/$rentalId/return'),
      headers: _headers,
    );
    _checkResponse(response);
  }

  Future<void> cancelRental(String rentalId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/rentals/$rentalId/cancel'),
      headers: _headers,
    );
    _checkResponse(response);
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    String errorMessage;
    try {
      final decoded = jsonDecode(response.body);
      errorMessage = decoded['message'] ?? decoded['error'] ?? response.body;
    } catch (_) {
      errorMessage = 'Request gagal: ${response.statusCode}';
    }
    throw Exception(errorMessage);
  }
}
