import 'package:get/get.dart';
import '../../../core/services/tasks_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class TasksController extends GetxController {
  late final TasksService _tasksService;
  StreamSubscription? _tasksSubscription;

  final RxList<Map<String, dynamic>> tasks = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString filterStatus = 'all'.obs;
  final RxString error = ''.obs;

  // Getters for the observable values
  bool get isLoadingService => isLoading.value;
  bool get isIndexing => _tasksService.isIndexing.value;
  List<Map<String, dynamic>> get filteredTasks {
    if (filterStatus.value == 'all') {
      return tasks.toList();
    }
    return tasks.where((task) => task['status'] == filterStatus.value).toList();
  }

  @override
  void onInit() {
    super.onInit();
    print('TasksController onInit called');
    try {
      _tasksService = Get.find<TasksService>();
      print('TasksService found');
      _setupTasksListener();
      loadTasks();
    } catch (e) {
      print('Error initializing TasksController: $e');
      error.value = 'Failed to initialize tasks: ${e.toString()}';
    }
  }

  @override
  void onReady() {
    super.onReady();
    print('TasksController onReady called');
  }

  @override
  void onClose() {
    print('TasksController onClose called');
    _tasksSubscription?.cancel();
    super.onClose();
  }

  void _setupTasksListener() {
    try {
      isLoading.value = true;
      _tasksSubscription = _tasksService.streamTasks().listen(
        (updatedTasks) {
          tasks.assignAll(updatedTasks);
          isLoading.value = false;
          error.value = '';
        },
        onError: (e) {
          error.value = e.toString();
          isLoading.value = false;
          Get.snackbar(
            'Error',
            'Failed to load tasks: ${e.toString()}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100],
            colorText: Colors.red[900],
          );
        },
      );
    } catch (e) {
      error.value = e.toString();
      isLoading.value = false;
    }
  }

  Future<void> loadTasks() async {
    try {
      isLoading.value = true;
      error.value = '';
      await _tasksService.loadTasks();
      tasks.assignAll(_tasksService.tasks);
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load tasks: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> taskData) async {
    try {
      isLoading.value = true;
      error.value = '';

      final updates = {
        ...taskData,
        'updatedAt': DateTime.now(),
      };

      await _tasksService.updateTask(taskId, updates);
      await loadTasks();

      Get.snackbar(
        'Success',
        'Task updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _tasksService.deleteTask(taskId);
      await loadTasks();
      Get.snackbar(
        'Success',
        'Task deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to delete task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _tasksService.updateTaskStatus(taskId, status);
      await loadTasks();
      Get.snackbar(
        'Success',
        'Task status updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update task status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  void setFilterStatus(String status) {
    filterStatus.value = status;
    loadTasks();
  }
}
