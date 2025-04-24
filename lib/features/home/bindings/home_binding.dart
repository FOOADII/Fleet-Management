import 'package:get/get.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController(Get.find<FirebaseAuthService>()));
  }
}
