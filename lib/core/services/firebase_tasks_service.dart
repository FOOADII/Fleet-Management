import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../features/tasks/models/task_model.dart';

class FirebaseTasksService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TaskModel>> getTasks() {
    return _firestore
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TaskModel.fromJson(data);
      }).toList();
    });
  }

  Future<void> createTask(TaskModel task) async {
    await _firestore.collection('tasks').add(task.toJson());
  }

  Future<void> updateTask(TaskModel task) async {
    await _firestore.collection('tasks').doc(task.id).update(task.toJson());
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  Future<List<TaskModel>> getTasksByStatus(String status) async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return TaskModel.fromJson(data);
    }).toList();
  }

  Future<List<TaskModel>> getTasksByVehicle(String vehicleId) async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('vehicleId', isEqualTo: vehicleId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return TaskModel.fromJson(data);
    }).toList();
  }

  Future<List<TaskModel>> getTasksByAssignee(String assigneeId) async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('assignedTo', isEqualTo: assigneeId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return TaskModel.fromJson(data);
    }).toList();
  }
}
