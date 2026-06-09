import 'package:flutter/material.dart';
import 'package:rentease/models/user_model.dart';
import 'package:rentease/services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  UserModel? profile;
  bool isLoading = false;

  Future<void> loadProfile() async {
    isLoading = true;
    notifyListeners();

    try {
      profile = await _profileService.getProfile();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
