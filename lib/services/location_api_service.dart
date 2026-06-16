import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentease/core/api_config.dart';
import 'package:rentease/core/supabase_config.dart';
import 'package:latlong2/latlong.dart';

class LocationApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  Map<String, String> get _headers {
    final token = supabase.auth.currentSession?.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'API Error ${response.statusCode}';
      try {
        final decoded = jsonDecode(response.body);
        message = decoded['message'] ?? message;
      } catch (_) {}
      throw Exception(message);
    }
  }

  Future<void> sendLocation(String rentalId, double lat, double lng) async {
    final response = await http.post(
      Uri.parse('$baseUrl/locations'),
      headers: _headers,
      body: jsonEncode({
        'rental_id': rentalId,
        'latitude': lat,
        'longitude': lng,
      }),
    );
    _checkResponse(response);
  }

  Future<LatLng?> getLatestLocation(String rentalId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final response = await http.get(
      Uri.parse('$baseUrl/locations/$rentalId/latest?t=$timestamp'),
      headers: _headers,
    );
    
    if (response.statusCode == 404) return null; // No location yet
    
    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    final data = decoded['data'];
    
    if (data != null && data['latitude'] != null && data['longitude'] != null) {
      return LatLng(
        (data['latitude'] as num).toDouble(),
        (data['longitude'] as num).toDouble(),
      );
    }
    return null;
  }
}
