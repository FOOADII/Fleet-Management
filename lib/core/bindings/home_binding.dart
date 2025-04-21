import 'package:get/get.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../core/services/firebase_auth_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FirebaseAuthService>(() => FirebaseAuthService());
    Get.lazyPut<HomeController>(
        () => HomeController(Get.find<FirebaseAuthService>()));
  }
}
