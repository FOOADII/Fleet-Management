import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_tasks_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/auth_service.dart';
import '../services/firebase_storage_service.dart';
import '../services/tracking_service.dart';
import '../services/firebase_maintenance_service.dart';
import '../../features/tasks/controllers/tasks_controller.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/notifications/controllers/notifications_controller.dart';
import '../../features/profile/controllers/profile_controller.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../features/maintenance/controllers/maintenance_controller.dart';
import '../../features/tracking/controllers/tracking_controller.dart';
import '../../features/fuel/controllers/fuel_controller.dart';
import '../../features/fuel/services/fuel_tracking_service.dart';

class InitialBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    // Register SharedPreferences if not already registered
    if (!Get.isRegistered<SharedPreferences>()) {
      try {
        final sharedPreferences = await SharedPreferences.getInstance();
        Get.put<SharedPreferences>(sharedPreferences, permanent: true);
        print('SharedPreferences registered in InitialBinding');
      } catch (e) {
        print('Error registering SharedPreferences in InitialBinding: $e');
      }
    } else {
      print('SharedPreferences already registered, skipping in InitialBinding');
    }

    // Core Services
    try {
      // Register FirebaseAuthService first
      final authService = FirebaseAuthService();
      Get.put<FirebaseAuthService>(authService, permanent: true);
      // Register it as AuthService interface as well
      Get.put<AuthService>(authService, permanent: true);

      final storageService = FirebaseStorageService();
      final trackingService = TrackingService();
      final tasksService = FirebaseTasksService();
      final maintenanceService = FirebaseMaintenanceService();
      final fuelTrackingService = FuelTrackingService();

      Get.put<FirebaseStorageService>(storageService, permanent: true);
      Get.put<TrackingService>(trackingService, permanent: true);
      Get.put<FirebaseTasksService>(tasksService, permanent: true);
      Get.put<FirebaseMaintenanceService>(maintenanceService, permanent: true);
      Get.put<FuelTrackingService>(fuelTrackingService, permanent: true);

      // Controllers
      Get.put<NotificationsController>(NotificationsController(),
          permanent: true);
      Get.put<AuthController>(AuthController(authService), permanent: true);
      Get.put<ProfileController>(ProfileController(authService: authService),
          permanent: true);
      Get.put<HomeController>(HomeController(authService), permanent: true);
      Get.put<TasksController>(TasksController(), permanent: true);
      Get.put<MaintenanceController>(
        MaintenanceController(maintenanceService),
        permanent: true,
      );
      Get.put<TrackingController>(
        TrackingController(),
        permanent: true,
      );
      Get.put<FuelController>(FuelController(), permanent: true);

      print('All services and controllers registered successfully');
    } catch (e) {
      print('Error during service registration: $e');
    }
  }
}
