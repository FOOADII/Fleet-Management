import 'package:get/get.dart';
import '../controllers/notifications_controller.dart';
import '../services/notifications_service.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    // First register the service
    Get.put<NotificationsService>(NotificationsService(), permanent: true);

    // Then register the controller which depends on the service
    Get.lazyPut<NotificationsController>(() => NotificationsController());
  }
}
