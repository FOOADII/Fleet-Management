import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/maintenance/models/maintenance_request.dart';

class FirebaseMaintenanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MaintenanceRequest>> getMaintenanceRequests() async {
    try {
      final snapshot =
          await _firestore.collection('maintenance_requests').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return MaintenanceRequest.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting maintenance requests: $e');
      return [];
    }
  }

  Future<MaintenanceRequest> createMaintenanceRequest(
    String vehicleId,
    String title,
    String description, {
    DateTime? scheduledDate,
    String? assignedTo,
    double? estimatedCost,
  }) async {
    try {
      final data = {
        'vehicleId': vehicleId,
        'title': title,
        'description': description,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'scheduledDate':
            scheduledDate != null ? Timestamp.fromDate(scheduledDate) : null,
        'assignedTo': assignedTo,
        'estimatedCost': estimatedCost,
      };

      final docRef =
          await _firestore.collection('maintenance_requests').add(data);
      final doc = await docRef.get();
      final docData = doc.data()!;
      docData['id'] = doc.id;
      return MaintenanceRequest.fromMap(docData);
    } catch (e) {
      print('Error creating maintenance request: $e');
      rethrow;
    }
  }

  Future<void> updateMaintenanceRequest(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('maintenance_requests').doc(id).update(data);
    } catch (e) {
      print('Error updating maintenance request: $e');
      rethrow;
    }
  }

  Future<void> deleteMaintenanceRequest(String id) async {
    try {
      await _firestore.collection('maintenance_requests').doc(id).delete();
    } catch (e) {
      print('Error deleting maintenance request: $e');
      rethrow;
    }
  }

  Stream<List<MaintenanceRequest>> streamMaintenanceRequests() {
    return _firestore
        .collection('maintenance_requests')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return MaintenanceRequest.fromMap(data);
      }).toList();
    });
  }
}
