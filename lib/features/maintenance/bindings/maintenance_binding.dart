import 'package:get/get.dart';
import '../controllers/maintenance_controller.dart';
import '../services/maintenance_service.dart';
import '../../../core/services/firebase_auth_service.dart';

class MaintenanceBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize FirebaseAuthService first
    Get.put<FirebaseAuthService>(FirebaseAuthService(), permanent: true);

    // Initialize MaintenanceService with its dependency
    Get.put<MaintenanceService>(
      MaintenanceService(),
      permanent: true,
    );

    // Initialize MaintenanceController with its dependency
    Get.put<MaintenanceController>(
      MaintenanceController(),
      permanent: true,
    );
  }
}
