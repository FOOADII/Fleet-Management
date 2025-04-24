import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(authService: Get.find()),
    );
  }
}
