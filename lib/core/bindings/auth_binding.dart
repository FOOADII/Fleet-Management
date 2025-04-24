import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/firebase_auth_service.dart';
import '../../features/auth/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Only register if not already registered
    if (!Get.isRegistered<FirebaseAuthService>()) {
      final authService = FirebaseAuthService();
      Get.put<FirebaseAuthService>(authService, permanent: true);
      Get.put<AuthService>(authService, permanent: true);
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
