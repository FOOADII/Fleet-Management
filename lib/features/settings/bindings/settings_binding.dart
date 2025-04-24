import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../../core/services/firebase_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController(
          Get.find<FirebaseAuthService>(),
          Get.find<SharedPreferences>(),
        ));
  }
}
