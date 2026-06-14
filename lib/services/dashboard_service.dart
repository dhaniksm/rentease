import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentease/models/dashboard_model.dart';
import 'package:rentease/core/api_config.dart';
import 'package:rentease/core/supabase_config.dart';

class DashboardService {
  static String get baseUrl => ApiConfig.baseUrl;

  Future<DashboardModel> getDashboardSummary() async {
    final token = supabase.auth.currentSession?.accessToken;
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/summary'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    final data = decoded['data'] ?? {};

    return DashboardModel.fromJson(data);
  }

  Future<List<dynamic>> getRecentTransactions() async {
    final token = supabase.auth.currentSession?.accessToken;
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/recent-transactions'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    return decoded['data'] ?? [];
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
