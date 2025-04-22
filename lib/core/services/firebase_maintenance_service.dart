import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/maintenance/models/maintenance_request.dart';
import '../../features/maintenance/models/maintenance_log_model.dart';

class FirebaseMaintenanceService {
  final FirebaseFirestore _firestore;
  final String _logCollection = 'maintenance_logs';
  final String _requestCollection = 'maintenance_requests';

  FirebaseMaintenanceService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<MaintenanceRequest>> getMaintenanceRequests() async {
    try {
      final snapshot = await _firestore.collection(_requestCollection).get();
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

      final docRef = await _firestore.collection(_requestCollection).add(data);
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
      await _firestore.collection(_requestCollection).doc(id).update(data);
    } catch (e) {
      print('Error updating maintenance request: $e');
      rethrow;
    }
  }

  Future<void> deleteMaintenanceRequest(String id) async {
    try {
      await _firestore.collection(_requestCollection).doc(id).delete();
    } catch (e) {
      print('Error deleting maintenance request: $e');
      rethrow;
    }
  }

  Stream<List<MaintenanceRequest>> streamMaintenanceRequests() {
    return _firestore
        .collection(_requestCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return MaintenanceRequest.fromMap(data);
      }).toList();
    });
  }

  // Stream for real-time updates
  Stream<List<MaintenanceLog>> maintenanceLogStream() {
    return _firestore
        .collection(_logCollection)
        .orderBy('datePerformed', descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return MaintenanceLog.fromMap(doc.data(), doc.id);
        }).toList();
      },
    );
  }

  // Get all logs once
  Future<List<MaintenanceLog>> getMaintenanceLogs() async {
    try {
      final snapshot = await _firestore
          .collection(_logCollection)
          .orderBy('datePerformed', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => MaintenanceLog.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting maintenance logs: $e');
      rethrow;
    }
  }

  // Add a new maintenance log
  Future<MaintenanceLog> addMaintenanceLog(MaintenanceLog log) async {
    try {
      final Map<String, dynamic> data = log.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      data.remove('updatedAt');

      final docRef = await _firestore.collection(_logCollection).add(data);
      final docSnapshot = await docRef.get();
      return MaintenanceLog.fromMap(docSnapshot.data()!, docSnapshot.id);
    } catch (e) {
      print('Error adding maintenance log: $e');
      rethrow;
    }
  }

  // Update an existing maintenance log
  Future<void> updateMaintenanceLog(
      String id, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(_logCollection).doc(id).update(data);
    } catch (e) {
      print('Error updating maintenance log: $e');
      rethrow;
    }
  }

  // Delete a maintenance log
  Future<void> deleteMaintenanceLog(String id) async {
    try {
      await _firestore.collection(_logCollection).doc(id).delete();
    } catch (e) {
      print('Error deleting maintenance log: $e');
      rethrow;
    }
  }

  // Get logs for a specific vehicle
  Future<List<MaintenanceLog>> getLogsByVehicle(String vehicleId) async {
    try {
      final snapshot = await _firestore
          .collection(_logCollection)
          .where('vehicleId', isEqualTo: vehicleId)
          .orderBy('datePerformed', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => MaintenanceLog.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting vehicle maintenance logs: $e');
      rethrow;
    }
  }

  // Get logs by status
  Future<List<MaintenanceLog>> getLogsByStatus(MaintenanceStatus status) async {
    try {
      final snapshot = await _firestore
          .collection(_logCollection)
          .where('status', isEqualTo: status.name)
          .orderBy('datePerformed', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => MaintenanceLog.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting maintenance logs by status: $e');
      rethrow;
    }
  }
}
