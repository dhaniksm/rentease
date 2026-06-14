import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rentease/models/payment_model.dart';
import 'package:rentease/core/api_config.dart';

class PaymentService {
  static String get baseUrl => ApiConfig.baseUrl;

  Future<List<PaymentModel>> getPayments() async {
    final response = await http.get(Uri.parse('$baseUrl/payments'));
    _checkResponse(response);

    final decoded = jsonDecode(response.body);
    final List<dynamic> data = decoded['data'] ?? [];

    return data
        .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<dynamic>> getRawPayments() async {
    final response = await http.get(Uri.parse('$baseUrl/payments'));
    _checkResponse(response);
    final decoded = jsonDecode(response.body);
    return decoded['data'] ?? [];
  }

  Future<void> confirmPayment(String id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/payments/confirm/$id'),
    );
    _checkResponse(response);
  }

  Future<void> verifyPayment(String id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/payments/verify/$id'),
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
