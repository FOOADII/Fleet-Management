import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/services/firebase_auth_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // First, ensure FirebaseAuthService is available
    Get.lazyPut<FirebaseAuthService>(() => FirebaseAuthService(), fenix: true);

    // Then create AuthController with the FirebaseAuthService
    Get.lazyPut<AuthController>(
      () => AuthController(Get.find<FirebaseAuthService>()),
      fenix: true,
    );
  }
}
