import 'mock_firestore_service.dart';
import '../../features/tasks/models/task_model.dart';

class MockTasksService {
  final MockFirestoreService _firestore;

  MockTasksService({
    MockFirestoreService? firestore,
  }) : _firestore = firestore ?? MockFirestoreService();

  Future<List<Task>> getTasks() async {
    final snapshot = await _firestore.collection('tasks').get();
    return snapshot.documents.map((doc) {
      final data = doc.data;
      data['id'] = doc.id;
      return Task.fromMap(data);
    }).toList();
  }

  Future<Task> createTask(
    String title,
    String description,
    String priority, {
    DateTime? dueDate,
    String? assignedTo,
    String? vehicleId,
  }) async {
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

    final docRef = await _firestore.collection('tasks').add(data);
    final doc = await docRef.get();
    final docData = doc.data;
    docData['id'] = doc.id;
    return Task.fromMap(docData);
  }

  Future<void> updateTask(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('tasks').doc(id).update(data);
  }

  Future<void> deleteTask(String id) async {
    await _firestore.collection('tasks').doc(id).delete();
  }
}
