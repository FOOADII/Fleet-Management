import 'package:get/get.dart';
import '../../../core/services/tasks_service.dart';
import '../controllers/tasks_controller.dart';
import '../../../core/services/firebase_auth_service.dart';

class TasksBinding extends Bindings {
  @override
  void dependencies() {
    print('Initializing TasksBinding...');

    // Ensure FirebaseAuthService is available
    if (!Get.isRegistered<FirebaseAuthService>()) {
      print('Initializing FirebaseAuthService...');
      Get.put(FirebaseAuthService(), permanent: true);
    }

    // Initialize TasksService first
    print('Initializing TasksService...');
    if (!Get.isRegistered<TasksService>()) {
      Get.put<TasksService>(TasksService(), permanent: true);
    }

    // Initialize TasksController last since it depends on TasksService
    print('Initializing TasksController...');
    if (!Get.isRegistered<TasksController>()) {
      Get.put<TasksController>(TasksController(), permanent: true);
    }
  }
}
