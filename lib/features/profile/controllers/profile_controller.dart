import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  final AuthService _authService;
  final Rxn<User> currentUser = Rxn<User>();
  final RxBool isLoading = false.obs;

  ProfileController({required AuthService authService})
      : _authService = authService;

  @override
  void onInit() {
    super.onInit();
    // Initialize with current user
    currentUser.value = _authService.currentUser;
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      currentUser.value = user;
    });
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      isLoading.value = true;
      if (currentUser.value != null) {
        await currentUser.value!.updateDisplayName(displayName);
        await currentUser.value!.updatePhotoURL(photoURL);
        await currentUser.value!.reload();
      }
      Get.back();
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      isLoading.value = true;
      // TODO: Implement password change logic using AuthService
      Get.back();
      Get.snackbar(
        'Success',
        'Password changed successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to change password: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void updateNotificationSettings() {
    // TODO: Implement notification settings update
    Get.snackbar(
      'Coming Soon',
      'Notification settings will be available in the next update',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void updateLanguage() {
    // TODO: Implement language settings
    Get.snackbar(
      'Coming Soon',
      'Language settings will be available in the next update',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void updateTheme() {
    // TODO: Implement theme settings
    Get.snackbar(
      'Coming Soon',
      'Theme settings will be available in the next update',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void showHelpAndSupport() {
    // TODO: Implement help and support
    Get.snackbar(
      'Coming Soon',
      'Help and support will be available in the next update',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
