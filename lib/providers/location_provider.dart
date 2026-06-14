import 'package:flutter/material.dart';
import 'package:rentease/models/location_model.dart';
import 'package:rentease/services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  List<LocationModel> locations = [];
  bool isLoading = false;

  Future<void> loadLocations() async {
    isLoading = true;
    notifyListeners();
    try {
      locations = await _locationService.getLocations();
    } catch (e) {
      debugPrint('Error loading locations: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLocation(LocationModel location) async {
    try {
      await _locationService.updateLocation(location);
      await loadLocations();
    } catch (e) {
      debugPrint('Error updating location: $e');
      rethrow;
    }
  }

  Future<List<LocationModel>> getLocationHistory(String rentalId) async {
    return await _locationService.getLocationHistory(rentalId);
  }

  Future<LocationModel> getLatestLocation(String rentalId) async {
    return await _locationService.getLatestLocation(rentalId);
  }
}
