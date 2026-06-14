import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentease/models/rental_model.dart';
import 'package:rentease/core/api_config.dart';

class RentalService {
  static String get baseUrl => ApiConfig.baseUrl;

  Future<void> addRental(RentalModel rental) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rentals'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(rental.toJson()),
    );
    _checkResponse(response);
  }

  Future<List<RentalModel>> getRentals() async {
    final response = await http.get(Uri.parse('$baseUrl/rentals'));
    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    final List<dynamic> data = decoded['data'] ?? [];

    return data
        .map((json) => RentalModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<RentalModel>> getUserRentalHistory(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rentals/history/$userId'),
    );
    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    final List<dynamic> data = decoded['data'] ?? [];

    return data
        .map((json) => RentalModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<dynamic>> getRawUserRentalHistory(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rentals/history/$userId'),
    );
    _checkResponse(response);
    final decoded = jsonDecode(response.body);
    return decoded['data'] ?? [];
  }

  Future<List<dynamic>> getRawRentals() async {
    final response = await http.get(Uri.parse('$baseUrl/rentals'));
    _checkResponse(response);
    final decoded = jsonDecode(response.body);
    return decoded['data'] ?? [];
  }

  Future<void> verifyVehicle(String rentalId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rentals/verify-vehicle'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'rentalId': rentalId}),
    );
    _checkResponse(response);
  }

  Future<void> returnRental(String rentalId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/rentals/$rentalId/return'),
    );
    _checkResponse(response);
  }

  Future<void> cancelRental(String rentalId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/rentals/$rentalId/cancel'),
    );
    _checkResponse(response);
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
