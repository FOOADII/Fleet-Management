import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpController extends GetxController {
  Future<void> callSupport() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+251912345678');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch phone call',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> emailSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@ddufleet.com',
      queryParameters: {
        'subject': 'Support Request',
        'body': 'Hello, I need assistance with...',
      },
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch email client',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> openMap() async {
    final Uri mapUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=Dire+Dawa+University',
    );
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not open map',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
