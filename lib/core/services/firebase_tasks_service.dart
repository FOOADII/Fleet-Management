import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/tasks/models/task_model.dart';

class FirebaseTasksService {
  final FirebaseFirestore _firestore;
  final String _collection = 'tasks';

  FirebaseTasksService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Task>> getTasks() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Task.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting tasks: $e');
      rethrow;
    }
  }

  Future<Task> createTask(
    String title,
    String description,
    String priority, {
    DateTime? dueDate,
    String? assignedTo,
    String? vehicleId,
  }) async {
    try {
      final data = {
        'title': title,
        'description': description,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'assignedTo': assignedTo,
        'vehicleId': vehicleId,
        'priority': priority,
      };

      final docRef = await _firestore.collection(_collection).add(data);

      // Fetch the created document to return complete data
      final docSnapshot = await docRef.get();
      final docData = docSnapshot.data()!;
      docData['id'] = docSnapshot.id;

      return Task.fromMap(docData);
    } catch (e) {
      print('Error creating task: $e');
      rethrow;
    }
  }

  Future<void> updateTask(String id, Map<String, dynamic> data) async {
    try {
      // Add updatedAt timestamp automatically
      data['updatedAt'] = DateTime.now().toIso8601String();

      await _firestore.collection(_collection).doc(id).update(data);
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  Stream<List<Task>> tasksStream() {
    return _firestore.collection(_collection).snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Task.fromMap(data);
        }).toList();
      },
    );
  }

  Future<List<Task>> getTasksByVehicle(String vehicleId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('vehicleId', isEqualTo: vehicleId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Task.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting vehicle tasks: $e');
      rethrow;
    }
  }

  Future<List<Task>> getTasksByStatus(String status) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: status)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Task.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting tasks by status: $e');
      rethrow;
    }
  }
}
