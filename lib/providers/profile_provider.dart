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

  Future<void> editProfile({String? fullName, String? phoneNumber, String? avatarUrl}) async {
    isLoading = true;
    notifyListeners();

    try {
      await _profileService.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
      );
      // Reload profile to get updated data
      profile = await _profileService.getProfile();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAvatar(dynamic file, String extension) async {
    isLoading = true;
    notifyListeners();

    try {
      final imageUrl = await _profileService.uploadAvatar(file, extension);
      await _profileService.updateProfile(avatarUrl: imageUrl);
      // Reload profile
      profile = await _profileService.getProfile();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
