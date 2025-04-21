import 'mock_firestore_service.dart';

class Report {
  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime createdAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? vehicleId;
  final Map<String, dynamic>? data;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
    this.startDate,
    this.endDate,
    this.vehicleId,
    this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'vehicleId': vehicleId,
      'data': data,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      type: map['type'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'] as String)
          : null,
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'] as String)
          : null,
      vehicleId: map['vehicleId'] as String?,
      data: map['data'] as Map<String, dynamic>?,
    );
  }
}

class MockReportsService {
  final MockFirestoreService _firestore;

  MockReportsService({
    MockFirestoreService? firestore,
  }) : _firestore = firestore ?? MockFirestoreService();

  Future<List<Report>> getReports() async {
    final snapshot = await _firestore.collection('reports').get();
    return snapshot.documents.map((doc) {
      final data = doc.data;
      data['id'] = doc.id;
      return Report.fromMap(data);
    }).toList();
  }

  Future<Report> createReport(
    String title,
    String description,
    String type, {
    DateTime? startDate,
    DateTime? endDate,
    String? vehicleId,
    Map<String, dynamic>? data,
  }) async {
    final reportData = {
      'title': title,
      'description': description,
      'type': type,
      'createdAt': DateTime.now().toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'vehicleId': vehicleId,
      'data': data,
    };

    final docRef = await _firestore.collection('reports').add(reportData);
    final doc = await docRef.get();
    final docData = doc.data;
    docData['id'] = doc.id;
    return Report.fromMap(docData);
  }

  Future<void> updateReport(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('reports').doc(id).update(data);
  }

  Future<void> deleteReport(String id) async {
    await _firestore.collection('reports').doc(id).delete();
  }
}
