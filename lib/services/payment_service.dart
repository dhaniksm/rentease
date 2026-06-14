import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentease/models/payment_model.dart';
import 'package:rentease/core/api_config.dart';
import 'package:rentease/core/supabase_config.dart';

class PaymentService {
  static String get baseUrl => ApiConfig.baseUrl;

  Map<String, String> get _headers {
    final token = supabase.auth.currentSession?.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<PaymentModel>> getPayments() async {
    final response = await http.get(Uri.parse('$baseUrl/payments'), headers: _headers);
    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    final List<dynamic> data = decoded['data'] ?? [];

    return data
        .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<dynamic>> getRawPayments() async {
    final response = await http.get(Uri.parse('$baseUrl/payments'), headers: _headers);
    _checkResponse(response);
    final decoded = jsonDecode(response.body);
    return decoded['data'] ?? [];
  }

  Future<void> confirmPayment(String id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/payments/confirm/$id'),
      headers: _headers,
    );
    _checkResponse(response);
  }

  Future<void> verifyPayment(String id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/payments/verify/$id'),
      headers: _headers,
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
