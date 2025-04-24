import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_pages.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildSettingsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            children: [
              Obx(() => CircleAvatar(
                    radius: 50,
                    backgroundImage: controller.profileImageUrl.value.isNotEmpty
                        ? NetworkImage(controller.profileImageUrl.value)
                        : null,
                    child: controller.profileImageUrl.value.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  )),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(Get.context!).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    onPressed: controller.updateProfilePicture,
                    tooltip: 'set_profile_picture'.tr,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Text(
                controller.currentUser.value?.displayName ?? 'User',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )),
          const SizedBox(height: 8),
          Obx(() => Text(
                controller.currentUser.value?.email ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(Get.context!).colorScheme.secondary,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.notifications),
          title: Text('notifications'.tr),
          subtitle: Text('manage_notifications'.tr),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Get.toNamed('/notifications'),
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text('language'.tr),
          subtitle: Obx(() => Text('current_language'.trParams({
                'language':
                    controller.getLanguageName(controller.currentLanguage.value)
              }))),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLanguageDialog(context),
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode),
          title: Text('theme'.tr),
          subtitle: Obx(() => Text(
              controller.isDarkMode.value ? 'dark_mode'.tr : 'light_mode'.tr)),
          trailing: Obx(() => Switch(
                value: controller.isDarkMode.value,
                onChanged: (_) => controller.toggleTheme(),
              )),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.help),
          title: Text('help_support'.tr),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showHelpSupportDialog(context),
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: Text('sign_out'.tr, style: const TextStyle(color: Colors.red)),
          onTap: () => _showSignOutDialog(context),
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('select_language'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                controller.updateLanguage('en');
                Get.back();
              },
            ),
            ListTile(
              title: const Text('አማርኛ'),
              onTap: () {
                controller.updateLanguage('am');
                Get.back();
              },
            ),
            ListTile(
              title: const Text('Afaan Oromoo'),
              onTap: () {
                controller.updateLanguage('or');
                Get.back();
              },
            ),
            ListTile(
              title: const Text('Español'),
              onTap: () {
                controller.updateLanguage('es');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('help_support'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.contact_support),
              title: Text('contact_support'.tr),
              onTap: () {
                Get.back();
                controller.contactSupport();
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_answer),
              title: Text('faqs'.tr),
              onTap: () {
                Get.back();
                controller.showFAQs();
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: Text('user_guide'.tr),
              onTap: () {
                Get.back();
                controller.showUserGuide();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('sign_out'.tr),
        content: Text('sign_out_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.signOut();
            },
            child:
                Text('sign_out'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
