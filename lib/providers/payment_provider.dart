import 'package:flutter/material.dart';
import 'package:rentease/models/payment_model.dart';
import 'package:rentease/services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  List<PaymentModel> payments = [];
  List<dynamic> rawPayments = [];
  bool isLoading = false;

  Future<void> loadPayments() async {
    isLoading = true;
    notifyListeners();

    try {
      payments = await _paymentService.getPayments();
      rawPayments = await _paymentService.getRawPayments();
    } catch (e) {
      debugPrint('Error loading payments: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmPayment(String id) async {
    try {
      await _paymentService.confirmPayment(id);
      // Removed loadPayments() because user doesn't have permission to fetch all rentals
    } catch (e) {
      debugPrint('Error confirming payment: $e');
      rethrow;
    }
  }

  Future<void> verifyPayment(String id, String method) async {
    try {
      await _paymentService.verifyPayment(id, method);
      await loadPayments();
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      rethrow;
    }
  }
}
