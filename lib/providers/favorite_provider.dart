import 'package:flutter/material.dart';
import 'package:rentease/services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();
  final Set<String> _favoriteVehicleIds = {};
  bool _isLoading = false;

  Set<String> get favoriteVehicleIds => _favoriteVehicleIds;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final ids = await _favoriteService.getFavorites();
      _favoriteVehicleIds.clear();
      _favoriteVehicleIds.addAll(ids);
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(String vehicleId) {
    return _favoriteVehicleIds.contains(vehicleId);
  }

  Future<void> toggleFavorite(String vehicleId) async {
    final isFav = isFavorite(vehicleId);
    
    // Optimistic UI update
    if (isFav) {
      _favoriteVehicleIds.remove(vehicleId);
    } else {
      _favoriteVehicleIds.add(vehicleId);
    }
    notifyListeners();

    try {
      if (isFav) {
        await _favoriteService.removeFavorite(vehicleId);
      } else {
        await _favoriteService.addFavorite(vehicleId);
      }
    } catch (e) {
      // Revert on failure
      if (isFav) {
        _favoriteVehicleIds.add(vehicleId);
      } else {
        _favoriteVehicleIds.remove(vehicleId);
      }
      notifyListeners();
      debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }
}
