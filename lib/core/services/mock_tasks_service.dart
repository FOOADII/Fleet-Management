import 'mock_firestore_service.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String? assignedTo;
  final String? vehicleId;
  final String priority;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.dueDate,
    this.assignedTo,
    this.vehicleId,
    required this.priority,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'assignedTo': assignedTo,
      'vehicleId': vehicleId,
      'priority': priority,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      assignedTo: map['assignedTo'] as String?,
      vehicleId: map['vehicleId'] as String?,
      priority: map['priority'] as String,
    );
  }
}

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
