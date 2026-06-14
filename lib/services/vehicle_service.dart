import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:rentease/models/vehicle_model.dart';
import 'package:rentease/core/supabase_config.dart';

import 'package:rentease/core/api_config.dart';

class VehicleService {
  static String get baseUrl => ApiConfig.baseUrl;
  static const String storageBucket = 'vehicle-images';

  Map<String, String> get _headers {
    final token = supabase.auth.currentSession?.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> addVehicle(VehicleModel vehicle) async {
    final response = await http.post(
      Uri.parse('$baseUrl/vehicles'),
      headers: _headers,
      body: jsonEncode(vehicle.toJson()),
    );

    _checkResponse(response);
  }

  Future<List<VehicleModel>> getVehicles() async {
    final response = await http.get(Uri.parse('$baseUrl/vehicles'), headers: _headers);
    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    final List<dynamic> data;

    if (decoded is List) {
      data = decoded;
    } else if (decoded is Map<String, dynamic>) {
      data = decoded['data'] ?? decoded['vehicles'] ?? [];
    } else {
      data = [];
    }

    return data
        .map((json) => VehicleModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateVehicle(VehicleModel vehicle) async {
    final response = await http.put(
      Uri.parse('$baseUrl/vehicles/${vehicle.id}'),
      headers: _headers,
      body: jsonEncode(vehicle.toJson()),
    );

    _checkResponse(response);
  }

  Future<void> deleteVehicle(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/vehicles/$id'), headers: _headers);
    _checkResponse(response);
  }

  Future<void> updateStatus(String id, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/vehicles/$id/status'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );
    _checkResponse(response);
  }

  Future<List<dynamic>> getVehicleRentalHistory(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/vehicles/$id/history'));
    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    return decoded['data'] ?? [];
  }

  Future<String> uploadVehicleImage(File imageFile) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storagePath = 'vehicles/$fileName';

    await supabase.storage.from(storageBucket).upload(storagePath, imageFile);

    return supabase.storage.from(storageBucket).getPublicUrl(storagePath);
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
