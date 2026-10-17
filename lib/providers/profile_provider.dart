import 'package:flutter/material.dart';

import '../core/services/profile_service.dart';
import '../models/user_profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  UserProfileModel? profile;
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  Future<void> loadProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await _service.getProfile();
    } catch (error) {
      errorMessage = 'Unable to load profile.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> savePhoto(String path) async {
    if (profile == null || isSaving || profile!.isStudent) {
      return false;
    }

    isSaving = true;
    notifyListeners();

    try {
      profile = await _service.updatePhoto(path);
      return true;
    } catch (error) {
      errorMessage = 'Unable to update photo.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> removePhoto() async {
    if (profile == null || profile!.isStudent || isSaving) {
      return false;
    }

    isSaving = true;
    notifyListeners();

    try {
      profile = await _service.removePhoto();
      return true;
    } catch (error) {
      errorMessage = 'Unable to remove photo.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> requestPhotoChange(String path) async {
    if (profile == null || !profile!.isStudent || isSaving) {
      return false;
    }

    isSaving = true;
    notifyListeners();

    try {
      await _service.requestStudentPhotoChange(path);

      // Do not update profile.photoUrl.
      // The admin must approve the request first.
      return true;
    } catch (error) {
      errorMessage = 'Unable to send photo request.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
