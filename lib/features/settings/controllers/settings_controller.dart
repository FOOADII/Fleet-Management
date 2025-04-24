import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/firebase_auth_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsController extends GetxController {
  final FirebaseAuthService _authService;
  final SharedPreferences _prefs;

  // App Preferences
  final isPushEnabled = true.obs;
  final currentLanguage = 'English'.obs;

  // Vehicle Settings
  final isLocationTrackingEnabled = true.obs;
  final isMaintenanceAlertsEnabled = true.obs;
  final isFuelAlertsEnabled = true.obs;

  // Data & Storage
  final dataUsage = '0 MB'.obs;
  final isBackgroundSyncEnabled = true.obs;
  final cacheSize = '0 MB'.obs;

  // User Info
  final RxString _userEmail = 'No email found'.obs;

  // App Info
  final appVersion = '1.0.0'.obs;

  SettingsController(this._authService, this._prefs);

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    loadAppVersion();
    calculateDataUsage();
    calculateCacheSize();
    updateUserEmail();
  }

  void updateUserEmail() {
    _userEmail.value = _authService.currentUser?.email ?? 'No email found';
  }

  Future<void> loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = '${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (e) {
      appVersion.value = '1.0.0';
    }
  }

  void loadSettings() {
    // Load saved settings from SharedPreferences
    isPushEnabled.value = _prefs.getBool('isPushEnabled') ?? true;
    currentLanguage.value = _prefs.getString('language') ?? 'English';
    isLocationTrackingEnabled.value =
        _prefs.getBool('isLocationTrackingEnabled') ?? true;
    isMaintenanceAlertsEnabled.value =
        _prefs.getBool('isMaintenanceAlertsEnabled') ?? true;
    isFuelAlertsEnabled.value = _prefs.getBool('isFuelAlertsEnabled') ?? true;
    isBackgroundSyncEnabled.value =
        _prefs.getBool('isBackgroundSyncEnabled') ?? true;
  }

  void toggleDarkMode(bool value) {
    // Implementation using Get's theme system
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    _prefs.setBool('isDarkMode', value);
  }

  void togglePushNotifications(bool value) {
    isPushEnabled.value = value;
    _prefs.setBool('isPushEnabled', value);
    // Show a confirmation message
    Get.snackbar(
      'Notifications ${value ? 'Enabled' : 'Disabled'}',
      value
          ? 'You will now receive push notifications'
          : 'Push notifications have been disabled',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.7),
      colorText: Colors.white,
    );
  }

  void toggleLocationTracking(bool value) {
    isLocationTrackingEnabled.value = value;
    _prefs.setBool('isLocationTrackingEnabled', value);
    // Show a confirmation message
    Get.snackbar(
      'Location Tracking ${value ? 'Enabled' : 'Disabled'}',
      value
          ? 'Vehicle location tracking is now enabled'
          : 'Vehicle location tracking has been disabled',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.7),
      colorText: Colors.white,
    );
  }

  void toggleMaintenanceAlerts(bool value) {
    isMaintenanceAlertsEnabled.value = value;
    _prefs.setBool('isMaintenanceAlertsEnabled', value);
    // Show a confirmation message
    Get.snackbar(
      'Maintenance Alerts ${value ? 'Enabled' : 'Disabled'}',
      value
          ? 'You will now receive maintenance alerts'
          : 'Maintenance alerts have been disabled',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.7),
      colorText: Colors.white,
    );
  }

  void toggleFuelAlerts(bool value) {
    isFuelAlertsEnabled.value = value;
    _prefs.setBool('isFuelAlertsEnabled', value);
    // Show a confirmation message
    Get.snackbar(
      'Fuel Alerts ${value ? 'Enabled' : 'Disabled'}',
      value
          ? 'You will now receive low fuel alerts'
          : 'Low fuel alerts have been disabled',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.7),
      colorText: Colors.white,
    );
  }

  void toggleBackgroundSync(bool value) {
    isBackgroundSyncEnabled.value = value;
    _prefs.setBool('isBackgroundSyncEnabled', value);
    // Show a confirmation message
    Get.snackbar(
      'Background Sync ${value ? 'Enabled' : 'Disabled'}',
      value
          ? 'App will now sync data in the background'
          : 'Background data sync has been disabled',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.7),
      colorText: Colors.white,
    );
  }

  void showLanguageSelector(BuildContext context) {
    final theme = Theme.of(context);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Select Language',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('English', style: theme.textTheme.titleMedium),
              trailing: currentLanguage.value == 'English'
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () {
                currentLanguage.value = 'English';
                _prefs.setString('language', 'English');
                Get.back();
                Get.snackbar(
                  'Language Changed',
                  'App language has been set to English',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              title: Text('Swahili', style: theme.textTheme.titleMedium),
              trailing: currentLanguage.value == 'Swahili'
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () {
                currentLanguage.value = 'Swahili';
                _prefs.setString('language', 'Swahili');
                Get.back();
                Get.snackbar(
                  'Language Changed',
                  'App language has been set to Swahili',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              title: Text('French', style: theme.textTheme.titleMedium),
              trailing: currentLanguage.value == 'French'
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () {
                currentLanguage.value = 'French';
                _prefs.setString('language', 'French');
                Get.back();
                Get.snackbar(
                  'Language Changed',
                  'App language has been set to French',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void showChangePasswordDialog(BuildContext context) {
    final theme = Theme.of(context);
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Change Password', style: theme.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                labelStyle: theme.textTheme.bodyMedium,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: theme.textTheme.bodyMedium,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                labelStyle: theme.textTheme.bodyMedium,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel',
                style: TextStyle(color: theme.colorScheme.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            onPressed: () {
              // Check if passwords match
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                Get.snackbar(
                  'Error',
                  'New passwords do not match',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: theme.colorScheme.error,
                  colorText: theme.colorScheme.onError,
                );
                return;
              }

              // Implement password change
              _changePassword(
                currentPasswordController.text,
                newPasswordController.text,
              );
              Get.back();
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword(
      String currentPassword, String newPassword) async {
    try {
      // Here you would connect to your authentication service
      // For demo purposes, we'll just show a success message

      Get.snackbar(
        'Success',
        'Password changed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to change password: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  void showEmailPreferences() {
    Get.toNamed('/settings/email-preferences');
  }

  void showTermsOfService() {
    Get.toNamed('/settings/terms');
  }

  void showPrivacyPolicy() {
    Get.toNamed('/settings/privacy');
  }

  String get userEmail => _userEmail.value;

  void viewAccountInformation() {
    Get.toNamed('/profile');
  }

  Future<void> calculateDataUsage() async {
    // This would typically involve checking actual data usage from the device
    // For demo purposes, we'll simulate some data usage values
    await Future.delayed(const Duration(milliseconds: 500));
    int usage = _prefs.getInt('dataUsage') ?? 0;
    if (usage == 0) {
      // Initialize with a random value first time
      usage = 10 + (DateTime.now().millisecondsSinceEpoch % 100);
      _prefs.setInt('dataUsage', usage);
    }

    dataUsage.value = '${usage} MB';
  }

  Future<void> calculateCacheSize() async {
    // This would typically involve checking actual cache size
    // For demo purposes, we'll simulate some cache values
    await Future.delayed(const Duration(milliseconds: 300));
    int size = _prefs.getInt('cacheSize') ?? 0;
    if (size == 0) {
      // Initialize with a random value first time
      size = 5 + (DateTime.now().millisecondsSinceEpoch % 20);
      _prefs.setInt('cacheSize', size);
    }

    cacheSize.value = '${size} MB';
  }

  void clearCache() async {
    // Show a confirmation dialog
    Get.dialog(
      AlertDialog(
        title: Text('Clear Cache', style: Get.textTheme.titleLarge),
        content: Text(
          'This will clear ${cacheSize.value} of cached data. Continue?',
          style: Get.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel',
                style: TextStyle(color: Get.theme.colorScheme.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.primary,
              foregroundColor: Get.theme.colorScheme.onPrimary,
            ),
            onPressed: () {
              // Simulate clearing cache
              _prefs.setInt('cacheSize', 0);
              calculateCacheSize();
              Get.back();
              Get.snackbar(
                'Cache Cleared',
                'App cache has been successfully cleared',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.7),
                colorText: Colors.white,
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void showDataUsageDetails() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Get.theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Data Usage',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Data usage statistics
            ListTile(
              title: Text('Total Usage', style: Get.textTheme.titleMedium),
              trailing: Text(dataUsage.value, style: Get.textTheme.titleMedium),
            ),
            ListTile(
              title: Text('Map Data', style: Get.textTheme.titleMedium),
              trailing: Text(
                  '${(int.parse(dataUsage.value.split(' ')[0]) * 0.6).toStringAsFixed(1)} MB',
                  style: Get.textTheme.titleMedium),
            ),
            ListTile(
              title: Text('Background Sync', style: Get.textTheme.titleMedium),
              trailing: Text(
                  '${(int.parse(dataUsage.value.split(' ')[0]) * 0.3).toStringAsFixed(1)} MB',
                  style: Get.textTheme.titleMedium),
            ),
            ListTile(
              title: Text('Other', style: Get.textTheme.titleMedium),
              trailing: Text(
                  '${(int.parse(dataUsage.value.split(' ')[0]) * 0.1).toStringAsFixed(1)} MB',
                  style: Get.textTheme.titleMedium),
            ),
            const Divider(),
            TextButton(
              onPressed: () {
                // Reset usage statistics
                _prefs.setInt('dataUsage', 0);
                calculateDataUsage();
                Get.back();
                Get.snackbar(
                  'Usage Reset',
                  'Data usage statistics have been reset',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: Text(
                'Reset Statistics',
                style: TextStyle(color: Get.theme.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkForUpdates() {
    Get.dialog(
      AlertDialog(
        title: Text('Check for Updates', style: Get.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current version: ${appVersion.value}',
              style: Get.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Checking for updates...',
              style: Get.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );

    // Simulate checking for updates
    Future.delayed(const Duration(seconds: 2), () {
      Get.back();
      Get.snackbar(
        'Up to Date',
        'You are running the latest version of the app',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.7),
        colorText: Colors.white,
      );
    });
  }
}
