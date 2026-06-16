import 'package:flutter/material.dart';
import 'package:rentease/models/rental_model.dart';
import 'package:rentease/services/rental_service.dart';

class RentalProvider extends ChangeNotifier {
  final RentalService _rentalService = RentalService();

  List<RentalModel> rentals = [];
  List<dynamic> rawRentals = [];
  bool isLoading = false;

  Future<void> loadRentals() async {
    isLoading = true;
    notifyListeners();

    try {
      rentals = await _rentalService.getRentals();
      rawRentals = await _rentalService.getRawRentals();
    } catch (e) {
      debugPrint('Error loading rentals: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRental(RentalModel rental) async {
    try {
      await _rentalService.addRental(rental);
      // loadRentals() is strictly for admin usage
    } catch (e) {
      debugPrint('Error adding rental: $e');
      rethrow;
    }
  }

  Future<void> loadUserRentals(String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      rentals = await _rentalService.getUserRentalHistory(userId);
      rawRentals = await _rentalService.getRawUserRentalHistory(userId);
    } catch (e) {
      debugPrint('Error loading user rentals: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyVehicle(String rentalId) async {
    try {
      await _rentalService.verifyVehicle(rentalId);
      await loadRentals();
    } catch (e) {
      debugPrint('Error verifying vehicle: $e');
      rethrow;
    }
  }

  Future<void> returnRental(String rentalId) async {
    try {
      await _rentalService.returnRental(rentalId);
      await loadRentals();
    } catch (e) {
      debugPrint('Error returning rental: $e');
      rethrow;
    }
  }

  Future<void> cancelRental(String rentalId) async {
    try {
      await _rentalService.cancelRental(rentalId);
      // loadRentals() is strictly for admin usage
    } catch (e) {
      debugPrint('Error canceling rental: $e');
      rethrow;
    }
  }
}
