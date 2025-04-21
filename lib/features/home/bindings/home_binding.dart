import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../features/maintenance/bindings/maintenance_binding.dart';
import '../services/vehicle_service.dart';
import '../services/sample_data_service.dart';
import '../services/notification_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    final authService = Get.find<FirebaseAuthService>();
    Get.put(HomeController(authService));

    // Initialize maintenance dependencies
    MaintenanceBinding().dependencies();

    Get.put(VehicleService(), permanent: true);
    Get.lazyPut<SampleDataService>(() => SampleDataService());
    Get.lazyPut<NotificationService>(() => NotificationService());
  }
}
