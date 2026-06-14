import 'package:flutter/material.dart';
import 'package:rentease/models/dashboard_model.dart';
import 'package:rentease/services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();

  DashboardModel? dashboardSummary;
  List<dynamic> recentTransactions = [];
  bool isLoading = false;

  Future<void> loadDashboardSummary() async {
    isLoading = true;
    notifyListeners();
    try {
      dashboardSummary = await _dashboardService.getDashboardSummary();
      recentTransactions = await _dashboardService.getRecentTransactions();
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
