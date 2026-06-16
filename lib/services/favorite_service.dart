import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentease/core/api_config.dart';
import 'package:rentease/core/supabase_config.dart';

class FavoriteService {
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
      throw Exception('Request failed with status: ${response.statusCode}, body: ${response.body}');
    }
  }

  Future<void> addFavorite(String vehicleId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/favorites'),
      headers: _headers,
      body: jsonEncode({'vehicleId': vehicleId}),
    );
    _checkResponse(response);
  }

  Future<void> removeFavorite(String vehicleId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/favorites/$vehicleId'),
      headers: _headers,
    );
    _checkResponse(response);
  }

  Future<List<String>> getFavorites() async {
    final response = await http.get(
      Uri.parse('$baseUrl/favorites'),
      headers: _headers,
    );
    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic> && decoded['data'] != null) {
      final List<dynamic> data = decoded['data'];
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }
}
