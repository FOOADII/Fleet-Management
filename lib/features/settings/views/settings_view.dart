import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text('Settings', style: theme.textTheme.titleLarge),
        elevation: 0,
        actions: [
          // Add theme toggle button in app bar
          const ThemeToggleButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            'App Preferences',
            [
              Obx(() => SwitchListTile(
                    title:
                        Text('Dark Mode', style: theme.textTheme.titleMedium),
                    subtitle: Text(
                      'Enable dark theme',
                      style: theme.textTheme.bodyMedium,
                    ),
                    secondary: Icon(
                      Icons.dark_mode_outlined,
                      color: theme.iconTheme.color,
                    ),
                    value: Get.isDarkMode,
                    onChanged: controller.toggleDarkMode,
                    activeColor: theme.colorScheme.primary,
                  )),
              Obx(() => SwitchListTile(
                    title: Text('Push Notifications',
                        style: theme.textTheme.titleMedium),
                    subtitle: Text(
                      'Receive push notifications',
                      style: theme.textTheme.bodyMedium,
                    ),
                    secondary: Icon(
                      Icons.notifications_outlined,
                      color: theme.iconTheme.color,
                    ),
                    value: controller.isPushEnabled.value,
                    onChanged: controller.togglePushNotifications,
                    activeColor: theme.colorScheme.primary,
                  )),
              ListTile(
                title: Text('Language', style: theme.textTheme.titleMedium),
                subtitle: Obx(() => Text(
                      controller.currentLanguage.value,
                      style: theme.textTheme.bodyMedium,
                    )),
                leading: Icon(
                  Icons.language_outlined,
                  color: theme.iconTheme.color,
                ),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 16, color: theme.iconTheme.color),
                onTap: () => controller.showLanguageSelector(context),
              ),
            ],
          ),
          _buildSection(
            context,
            'Vehicle Settings',
            [
              Obx(() => SwitchListTile(
                    title: Text('Location Tracking',
                        style: theme.textTheme.titleMedium),
                    subtitle: Text(
                      'Track vehicle locations',
                      style: theme.textTheme.bodyMedium,
                    ),
                    secondary: Icon(
                      Icons.location_on_outlined,
                      color: theme.iconTheme.color,
                    ),
                    value: controller.isLocationTrackingEnabled.value,
                    onChanged: controller.toggleLocationTracking,
                    activeColor: theme.colorScheme.primary,
                  )),
              Obx(() => SwitchListTile(
                    title: Text('Maintenance Alerts',
                        style: theme.textTheme.titleMedium),
                    subtitle: Text(
                      'Get vehicle maintenance notifications',
                      style: theme.textTheme.bodyMedium,
                    ),
                    secondary: Icon(
                      Icons.build_outlined,
                      color: theme.iconTheme.color,
                    ),
                    value: controller.isMaintenanceAlertsEnabled.value,
                    onChanged: controller.toggleMaintenanceAlerts,
                    activeColor: theme.colorScheme.primary,
                  )),
              Obx(() => SwitchListTile(
                    title:
                        Text('Fuel Alerts', style: theme.textTheme.titleMedium),
                    subtitle: Text(
                      'Get low fuel notifications',
                      style: theme.textTheme.bodyMedium,
                    ),
                    secondary: Icon(
                      Icons.local_gas_station_outlined,
                      color: theme.iconTheme.color,
                    ),
                    value: controller.isFuelAlertsEnabled.value,
                    onChanged: controller.toggleFuelAlerts,
                    activeColor: theme.colorScheme.primary,
                  )),
            ],
          ),
          _buildSection(
            context,
            'Data & Storage',
            [
              ListTile(
                title: Text('Clear Cache', style: theme.textTheme.titleMedium),
                subtitle: Text(
                  'Free up space used by app cache',
                  style: theme.textTheme.bodyMedium,
                ),
                leading: Icon(
                  Icons.cleaning_services_outlined,
                  color: theme.iconTheme.color,
                ),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 16, color: theme.iconTheme.color),
                onTap: () => controller.clearCache(),
              ),
              Obx(() => ListTile(
                    title:
                        Text('Data Usage', style: theme.textTheme.titleMedium),
                    subtitle: Text(
                      'App has used ${controller.dataUsage.value} of data',
                      style: theme.textTheme.bodyMedium,
                    ),
                    leading: Icon(
                      Icons.data_usage_outlined,
                      color: theme.iconTheme.color,
                    ),
                    trailing: Icon(Icons.arrow_forward_ios,
                        size: 16, color: theme.iconTheme.color),
                    onTap: () => controller.showDataUsageDetails(),
                  )),
              Obx(() => SwitchListTile(
                    title: Text('Background Sync',
                        style: theme.textTheme.titleMedium),
                    subtitle: Text(
                      'Sync data in background',
                      style: theme.textTheme.bodyMedium,
                    ),
                    secondary: Icon(
                      Icons.sync_outlined,
                      color: theme.iconTheme.color,
                    ),
                    value: controller.isBackgroundSyncEnabled.value,
                    onChanged: controller.toggleBackgroundSync,
                    activeColor: theme.colorScheme.primary,
                  )),
            ],
          ),
          _buildSection(
            context,
            'Account Settings',
            [
              ListTile(
                title:
                    Text('Change Password', style: theme.textTheme.titleMedium),
                subtitle: Text(
                  'Update your account password',
                  style: theme.textTheme.bodyMedium,
                ),
                leading: Icon(
                  Icons.lock_outline,
                  color: theme.iconTheme.color,
                ),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 16, color: theme.iconTheme.color),
                onTap: () => controller.showChangePasswordDialog(context),
              ),
              ListTile(
                title: Text('Email Preferences',
                    style: theme.textTheme.titleMedium),
                subtitle: Text(
                  'Manage email notifications',
                  style: theme.textTheme.bodyMedium,
                ),
                leading: Icon(
                  Icons.email_outlined,
                  color: theme.iconTheme.color,
                ),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 16, color: theme.iconTheme.color),
                onTap: () => controller.showEmailPreferences(),
              ),
              ListTile(
                title: Text('Account Information',
                    style: theme.textTheme.titleMedium),
                subtitle: Obx(() => Text(
                      controller.userEmail,
                      style: theme.textTheme.bodyMedium,
                    )),
                leading: Icon(
                  Icons.person_outline,
                  color: theme.iconTheme.color,
                ),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 16, color: theme.iconTheme.color),
                onTap: () => controller.viewAccountInformation(),
              ),
            ],
          ),
          _buildSection(
            context,
            'About',
            [
              ListTile(
                title: Text('App Version', style: theme.textTheme.titleMedium),
                subtitle: Obx(() => Text(
                      controller.appVersion.value,
                      style: theme.textTheme.bodyMedium,
                    )),
                leading: Icon(
                  Icons.info_outline,
                  color: theme.iconTheme.color,
                ),
                onTap: () => controller.checkForUpdates(),
              ),
              ListTile(
                title: Text('Terms of Service',
                    style: theme.textTheme.titleMedium),
                subtitle: Text(
                  'View app terms and conditions',
                  style: theme.textTheme.bodyMedium,
                ),
                leading: Icon(
                  Icons.description_outlined,
                  color: theme.iconTheme.color,
                ),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 16, color: theme.iconTheme.color),
                onTap: () => controller.showTermsOfService(),
              ),
              ListTile(
                title:
                    Text('Privacy Policy', style: theme.textTheme.titleMedium),
                subtitle: Text(
                  'View app privacy policy',
                  style: theme.textTheme.bodyMedium,
                ),
                leading: Icon(
                  Icons.privacy_tip_outlined,
                  color: theme.iconTheme.color,
                ),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 16, color: theme.iconTheme.color),
                onTap: () => controller.showPrivacyPolicy(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Divider(),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }
}
