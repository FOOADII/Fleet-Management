import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildSection(
              context,
              'Account Settings',
              [
                _buildSettingTile(
                  context,
                  'Change Password',
                  'Update your account password',
                  Icons.lock_outline,
                  onTap: () => controller.showChangePasswordDialog(),
                ),
                _buildSettingTile(
                  context,
                  'Language',
                  'English',
                  Icons.language,
                  onTap: () => controller.showLanguageSelection(),
                ),
                _buildSettingTile(
                  context,
                  'Time Zone',
                  'UTC+3 East Africa Time',
                  Icons.access_time,
                  onTap: () => controller.showTimeZoneSelection(),
                ),
              ],
            ),
            _buildSection(
              context,
              'Notifications',
              [
                Obx(() => _buildSwitchTile(
                      context,
                      'Push Notifications',
                      'Receive push notifications',
                      Icons.notifications_outlined,
                      controller.pushNotifications.value,
                      controller.togglePushNotifications,
                    )),
                Obx(() => _buildSwitchTile(
                      context,
                      'Email Notifications',
                      'Receive email updates',
                      Icons.email_outlined,
                      controller.emailNotifications.value,
                      controller.toggleEmailNotifications,
                    )),
                Obx(() => _buildSwitchTile(
                      context,
                      'Schedule Reminders',
                      'Get reminded of upcoming schedules',
                      Icons.schedule,
                      controller.scheduleReminders.value,
                      controller.toggleScheduleReminders,
                    )),
              ],
            ),
            _buildSection(
              context,
              'App Settings',
              [
                _buildSettingTile(
                  context,
                  'Theme',
                  'Light',
                  Icons.palette_outlined,
                  onTap: () => controller.showThemeSelection(),
                ),
                Obx(() => _buildSwitchTile(
                      context,
                      'Location Services',
                      'Enable location tracking',
                      Icons.location_on_outlined,
                      controller.locationServices.value,
                      controller.toggleLocationServices,
                    )),
                _buildSettingTile(
                  context,
                  'Data Usage',
                  'Manage how the app uses data',
                  Icons.data_usage,
                  onTap: () => controller.showDataUsage(),
                ),
              ],
            ),
            _buildSection(
              context,
              'Support',
              [
                _buildSettingTile(
                  context,
                  'Help Center',
                  'Get help with the app',
                  Icons.help_outline,
                  onTap: () => controller.showHelpCenter(),
                ),
                _buildSettingTile(
                  context,
                  'Contact Support',
                  'Reach out to our support team',
                  Icons.support_agent,
                  onTap: () => controller.showContactSupport(),
                ),
                _buildSettingTile(
                  context,
                  'About',
                  'App version and information',
                  Icons.info_outline,
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(
            children: children,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF4CAF50),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DDU Fleet Management',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '© 2024 DDU. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
