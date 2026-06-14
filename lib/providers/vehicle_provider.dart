import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rentease/models/vehicle_model.dart';
import 'package:rentease/services/vehicle_service.dart';

class VehicleProvider extends ChangeNotifier {
  final VehicleService _vehicleService = VehicleService();

  List<VehicleModel> vehicles = [];
  bool isLoading = false;

  int get totalVehicles => vehicles.length;
  int get availableVehicles => vehicles
      .where((vehicle) => vehicle.status.toLowerCase() == 'available')
      .length;
  int get rentedVehicles => vehicles
      .where((vehicle) => vehicle.status.toLowerCase() != 'available')
      .length;

  Future<void> loadVehicles() async {
    isLoading = true;
    notifyListeners();

    try {
      vehicles = await _vehicleService.getVehicles();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addVehicle(VehicleModel vehicle, File? imageFile) async {
    String? imageUrl = vehicle.imageUrl;

    if (imageFile != null) {
      imageUrl = await _vehicleService.uploadVehicleImage(imageFile);
    }

    await _vehicleService.addVehicle(vehicle.copyWith(imageUrl: imageUrl));
    await loadVehicles();
  }

  Future<void> updateVehicle(VehicleModel vehicle, File? imageFile) async {
    String? imageUrl = vehicle.imageUrl;

    if (imageFile != null) {
      imageUrl = await _vehicleService.uploadVehicleImage(imageFile);
    }

    await _vehicleService.updateVehicle(vehicle.copyWith(imageUrl: imageUrl));
    await loadVehicles();
  }

  Future<void> deleteVehicle(String id) async {
    await _vehicleService.deleteVehicle(id);
    await loadVehicles();
  }
}
