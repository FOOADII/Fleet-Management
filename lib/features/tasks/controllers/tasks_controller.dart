import 'dart:async';
import 'package:get/get.dart';
import '../models/task_model.dart';
import '../../../core/services/firebase_tasks_service.dart';

class TasksController extends GetxController {
  final FirebaseTasksService _tasksService = Get.find<FirebaseTasksService>();
  final RxBool isLoading = false.obs;
  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  StreamSubscription<List<TaskModel>>? _tasksSubscription;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  @override
  void onClose() {
    _tasksSubscription?.cancel();
    super.onClose();
  }

  Future<void> loadTasks() async {
    try {
      isLoading.value = true;
      _tasksSubscription?.cancel();
      _tasksSubscription = _tasksService.getTasks().listen(
        (tasksList) {
          tasks.value = tasksList;
          isLoading.value = false;
        },
        onError: (error) {
          print('Error loading tasks: $error');
          isLoading.value = false;
        },
      );
    } catch (e) {
      print('Error in loadTasks: $e');
      isLoading.value = false;
    }
  }

  Future<List<TaskModel>> getTasksByStatus(String status) async {
    try {
      return await _tasksService.getTasksByStatus(status);
    } catch (e) {
      print('Error getting tasks by status: $e');
      return [];
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
      final task = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        dueDate: dueDate ?? DateTime.now().add(const Duration(days: 1)),
        priority: priority,
        status: 'pending',
        assignedTo: assignedTo,
        vehicleId: vehicleId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _tasksService.createTask(task);
      Get.snackbar(
        'Success',
        'Task created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
      );
    } catch (e) {
      print('Error creating task: $e');
      Get.snackbar(
        'Error',
        'Failed to create task: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    }
  }

  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    try {
      final task = tasks.firstWhere((t) => t.id == taskId);
      final updatedTask = task.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      await _tasksService.updateTask(updatedTask);
      Get.snackbar(
        'Success',
        'Task status updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
      );
    } catch (e) {
      print('Error updating task status: $e');
      Get.snackbar(
        'Error',
        'Failed to update task status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksService.deleteTask(taskId);
      Get.snackbar(
        'Success',
        'Task deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
      );
    } catch (e) {
      print('Error deleting task: $e');
      Get.snackbar(
        'Error',
        'Failed to delete task: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    }
  }
}
