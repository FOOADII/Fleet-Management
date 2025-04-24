import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/help_controller.dart';
import '../../../core/theme/colors.dart';

class HelpView extends GetView<HelpController> {
  const HelpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContactSection(),
              const SizedBox(height: 24),
              _buildFAQSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              icon: Icons.phone,
              title: 'Phone',
              content: '+251 912 345 678',
              onTap: () => controller.callSupport(),
            ),
            const Divider(),
            _buildContactItem(
              icon: Icons.email,
              title: 'Email',
              content: 'support@ddufleet.com',
              onTap: () => controller.emailSupport(),
            ),
            const Divider(),
            _buildContactItem(
              icon: Icons.location_on,
              title: 'Address',
              content: 'Dire Dawa University, Dire Dawa, Ethiopia',
              onTap: () => controller.openMap(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildExpansionTile(
              'How do I request a vehicle?',
              'To request a vehicle, go to the Vehicles tab, select the desired vehicle, '
                  'and click on the "Request" button. Fill in the required details and submit your request.',
            ),
            _buildExpansionTile(
              'How can I track my vehicle request status?',
              'You can track your vehicle request status in the Requests tab. '
                  'The status will be updated in real-time as your request is processed.',
            ),
            _buildExpansionTile(
              'What should I do if I encounter a vehicle issue?',
              'If you encounter any vehicle issues, immediately report it through the '
                  'Report Issue button in the vehicle details screen. Provide as much detail as possible.',
            ),
            _buildExpansionTile(
              'How do I update my profile information?',
              'To update your profile information, go to Settings > Profile. '
                  'Click on the edit button next to the information you want to update.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(String title, String content) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
