import 'package:get/get.dart';
import '../controllers/maintenance_controller.dart';
import '../../../core/services/firebase_maintenance_service.dart';

class MaintenanceBinding extends Bindings {
  @override
  void dependencies() {
    // Register the service (if not already globally registered)
    // Use fenix: true if you want it to be re-created if disposed
    Get.lazyPut<FirebaseMaintenanceService>(() => FirebaseMaintenanceService(),
        fenix: true);

    // Register the controller, providing the service dependency
    Get.lazyPut<MaintenanceController>(
      () => MaintenanceController(Get.find<FirebaseMaintenanceService>()),
      fenix: true, // Optional: re-create controller if needed
    );
  }
}
