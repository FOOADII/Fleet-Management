import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  final AuthService authService;
  late final SharedPreferences _prefs;

  ProfileController({required this.authService});

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxString profileImageUrl = ''.obs;
  final RxString currentLanguage = 'en'.obs;
  final RxBool isDarkMode = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _prefs = Get.find<SharedPreferences>();
    currentUser.value = authService.currentUser;
    _loadUserPreferences();
  }

  void _loadUserPreferences() {
    isDarkMode.value = _prefs.getBool('isDarkMode') ?? false;
    currentLanguage.value = _prefs.getString('language') ?? 'en';
    profileImageUrl.value = _prefs.getString('profileImageUrl') ?? '';
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

  Future<void> updateProfilePicture() async {
    // TODO: Implement image picker and upload functionality
    Get.snackbar(
      'Coming Soon',
      'Set Profile Picture feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'am':
        return 'አማርኛ';
      case 'or':
        return 'Afaan Oromoo';
      case 'es':
        return 'Español';
      default:
        return 'English';
    }
  }

  Future<void> updateLanguage(String languageCode) async {
    try {
      currentLanguage.value = languageCode;
      await _prefs.setString('language', languageCode);
      Get.updateLocale(Locale(languageCode));
      Get.snackbar(
        'Success',
        'Language updated to ${getLanguageName(languageCode)}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update language. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _prefs.setBool('isDarkMode', isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> contactSupport() async {
    // TODO: Implement support contact functionality
    Get.snackbar(
      'Coming Soon',
      'Support contact feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> showFAQs() async {
    // TODO: Implement FAQs screen
    Get.snackbar(
      'Coming Soon',
      'FAQs feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> showUserGuide() async {
    // TODO: Implement user guide screen
    Get.snackbar(
      'Coming Soon',
      'User guide feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await authService.signOut();
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
