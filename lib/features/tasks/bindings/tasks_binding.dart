import 'package:get/get.dart';
import '../controllers/tasks_controller.dart';
import '../../../core/services/firebase_tasks_service.dart';

class TasksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FirebaseTasksService>(() => FirebaseTasksService());
    Get.lazyPut<TasksController>(
        () => TasksController(Get.find<FirebaseTasksService>()));
  }
}
