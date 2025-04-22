import 'dart:async';
import 'package:get/get.dart';
import '../../../core/services/firebase_tasks_service.dart';
import '../models/task_model.dart';

class TasksController extends GetxController {
  final FirebaseTasksService _tasksService;
  final RxBool isLoading = false.obs;
  final RxList<Task> tasks = <Task>[].obs;
  StreamSubscription<List<Task>>? _tasksSubscription;

  TasksController(this._tasksService);

  @override
  void onInit() {
    super.onInit();
    _subscribeToTasks();
  }

  @override
  void onClose() {
    _tasksSubscription?.cancel();
    super.onClose();
  }

  void _subscribeToTasks() {
    isLoading.value = true;
    _tasksSubscription = _tasksService.tasksStream().listen(
      (tasksList) {
        tasks.value = tasksList;
        isLoading.value = false;
      },
      onError: (error) {
        print('Error subscribing to tasks: $error');
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Failed to load tasks: ${error.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  Future<void> loadTasks() async {
    try {
      isLoading.value = true;
      tasks.value = await _tasksService.getTasks();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load tasks: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createTask(
    String title,
    String description,
    String priority, {
    DateTime? dueDate,
    String? assignedTo,
    String? vehicleId,
  }) async {
    try {
      isLoading.value = true;
      await _tasksService.createTask(
        title,
        description,
        priority,
        dueDate: dueDate,
        assignedTo: assignedTo,
        vehicleId: vehicleId,
      );

      Get.snackbar(
        'Success',
        'Task created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      isLoading.value = true;
      await _tasksService.updateTask(taskId, {'status': status});
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      isLoading.value = true;
      await _tasksService.deleteTask(taskId);
      Get.snackbar(
        'Success',
        'Task deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Task>> getTasksByVehicle(String vehicleId) async {
    try {
      return await _tasksService.getTasksByVehicle(vehicleId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load vehicle tasks: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return [];
    }
  }

  Future<List<Task>> getTasksByStatus(String status) async {
    try {
      return await _tasksService.getTasksByStatus(status);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load tasks by status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return [];
    }
  }
}
