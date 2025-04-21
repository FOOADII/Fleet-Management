import 'mock_firestore_service.dart';

class MaintenanceRequest {
  final String id;
  final String vehicleId;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final String? assignedTo;
  final double? estimatedCost;

  MaintenanceRequest({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.scheduledDate,
    this.assignedTo,
    this.estimatedCost,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'scheduledDate': scheduledDate?.toIso8601String(),
      'assignedTo': assignedTo,
      'estimatedCost': estimatedCost,
    };
  }

  factory MaintenanceRequest.fromMap(Map<String, dynamic> map) {
    return MaintenanceRequest(
      id: map['id'] as String,
      vehicleId: map['vehicleId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      scheduledDate: map['scheduledDate'] != null
          ? DateTime.parse(map['scheduledDate'] as String)
          : null,
      assignedTo: map['assignedTo'] as String?,
      estimatedCost: map['estimatedCost'] as double?,
    );
  }
}

class MockMaintenanceService {
  final MockFirestoreService _firestore;

  MockMaintenanceService({
    MockFirestoreService? firestore,
  }) : _firestore = firestore ?? MockFirestoreService();

  Future<List<MaintenanceRequest>> getMaintenanceRequests() async {
    final snapshot = await _firestore.collection('maintenance_requests').get();
    return snapshot.documents.map((doc) {
      final data = doc.data;
      data['id'] = doc.id;
      return MaintenanceRequest.fromMap(data);
    }).toList();
  }

  Future<MaintenanceRequest> createMaintenanceRequest(
    String vehicleId,
    String title,
    String description, {
    DateTime? scheduledDate,
    String? assignedTo,
    double? estimatedCost,
  }) async {
    final data = {
      'vehicleId': vehicleId,
      'title': title,
      'description': description,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
      'scheduledDate': scheduledDate?.toIso8601String(),
      'assignedTo': assignedTo,
      'estimatedCost': estimatedCost,
    };

    final docRef =
        await _firestore.collection('maintenance_requests').add(data);
    final doc = await docRef.get();
    final docData = doc.data;
    docData['id'] = doc.id;
    return MaintenanceRequest.fromMap(docData);
  }

  Future<void> updateMaintenanceRequest(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('maintenance_requests').doc(id).update(data);
  }

  Future<void> deleteMaintenanceRequest(String id) async {
    await _firestore.collection('maintenance_requests').doc(id).delete();
  }
}
