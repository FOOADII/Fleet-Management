import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TasksService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RxList<Map<String, dynamic>> tasks = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isIndexing = false.obs;

  // Get the current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    print('TasksService initialized');
    print('Current user ID: ${currentUserId}');
  }

  Future<void> loadTasks() async {
    try {
      print('Loading tasks...');
      isLoading.value = true;
      error.value = '';
      isIndexing.value = false;

      final userId = currentUserId;
      if (userId == null) {
        error.value = 'User not authenticated';
        print('No user authenticated');
        return;
      }

      print('Loading tasks for user: $userId');

      try {
        final querySnapshot = await _firestore
            .collection('tasks')
            .where('assignedTo', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();

        print('Query completed. Found ${querySnapshot.docs.length} tasks');

        final loadedTasks = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'title': data['title'] ?? '',
            'description': data['description'] ?? '',
            'status': data['status'] ?? 'pending',
            'priority': data['priority'] ?? 'medium',
            'dueDate': data['dueDate']?.toDate(),
            'createdAt': data['createdAt']?.toDate() ?? DateTime.now(),
            'vehicleId': data['vehicleId'],
            'assignedTo': data['assignedTo'],
          };
        }).toList();

        tasks.assignAll(loadedTasks);
        print('Successfully loaded ${loadedTasks.length} tasks');
      } catch (e) {
        print('Error in query: $e');
        if (e.toString().contains('failed-precondition') &&
            e.toString().contains('requires an index')) {
          print('Index is being created...');
          isIndexing.value = true;

          // Load tasks without ordering while index is being created
          final simpleQuery = await _firestore
              .collection('tasks')
              .where('assignedTo', isEqualTo: userId)
              .get();

          final tempTasks = simpleQuery.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'title': data['title'] ?? '',
              'description': data['description'] ?? '',
              'status': data['status'] ?? 'pending',
              'priority': data['priority'] ?? 'medium',
              'dueDate': data['dueDate']?.toDate(),
              'createdAt': data['createdAt']?.toDate() ?? DateTime.now(),
              'vehicleId': data['vehicleId'],
              'assignedTo': data['assignedTo'],
            };
          }).toList();

          // Sort tasks locally
          tempTasks.sort((a, b) => (b['createdAt'] as DateTime)
              .compareTo(a['createdAt'] as DateTime));

          tasks.assignAll(tempTasks);
          error.value =
              'Setting up database indexes. This may take a few minutes.';
          print(
              'Using simple query while index is being created. Found ${tempTasks.length} tasks');
        } else {
          throw e;
        }
      }
    } catch (e) {
      print('Error loading tasks: $e');
      error.value = 'Error loading tasks: ${e.toString()}';
      tasks.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Stream tasks in real-time
  Stream<List<Map<String, dynamic>>> streamTasks() {
    final userId = currentUserId;
    if (userId == null) {
      print('No user authenticated for streaming tasks'); // Debug print
      return Stream.value([]);
    }

    print('Starting task stream for user: $userId'); // Debug print
    return _firestore
        .collection('tasks')
        .where('assignedTo', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final tasks = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? '',
          'description': data['description'] ?? '',
          'status': data['status'] ?? 'pending',
          'priority': data['priority'] ?? 'medium',
          'dueDate': data['dueDate']?.toDate(),
          'createdAt': data['createdAt']?.toDate() ?? DateTime.now(),
          'vehicleId': data['vehicleId'],
          'assignedTo': data['assignedTo'],
        };
      }).toList();

      print('Streamed ${tasks.length} tasks'); // Debug print
      return tasks;
    });
  }

  // Update a task
  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      final updatesForFirestore = {
        ...updates,
        if (updates['dueDate'] != null)
          'dueDate': Timestamp.fromDate(updates['dueDate'] as DateTime),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('tasks')
          .doc(taskId)
          .update(updatesForFirestore);

      print('Updated task: $taskId'); // Debug print
      await loadTasks();
    } catch (e) {
      print('Error updating task: $e'); // Debug print
      error.value = 'Failed to update task: ${e.toString()}';
      throw Exception('Failed to update task: ${e.toString()}');
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      print('Deleted task: $taskId'); // Debug print
      await loadTasks();
    } catch (e) {
      print('Error deleting task: $e'); // Debug print
      error.value = 'Failed to delete task: ${e.toString()}';
      throw Exception('Failed to delete task: ${e.toString()}');
    }
  }

  // Update task status
  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Updated status for task: $taskId to $status'); // Debug print
      await loadTasks();
    } catch (e) {
      print('Error updating task status: $e'); // Debug print
      error.value = 'Failed to update task status: ${e.toString()}';
      throw Exception('Failed to update task status: ${e.toString()}');
    }
  }
}
