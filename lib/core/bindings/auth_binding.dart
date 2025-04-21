import 'package:get/get.dart';
import '../services/firebase_auth_service.dart';
import '../../features/auth/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize FirebaseAuthService as a singleton if not already initialized
    if (!Get.isRegistered<FirebaseAuthService>()) {
      Get.put<FirebaseAuthService>(
        FirebaseAuthService(),
        permanent: true,
      );
    }

    // Initialize AuthController if not already initialized
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(
        AuthController(Get.find<FirebaseAuthService>()),
        permanent: true,
      );
    }
  }
}
