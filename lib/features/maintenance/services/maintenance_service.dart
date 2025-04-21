import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firebase_auth_service.dart';

class MaintenanceService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = Get.find<FirebaseAuthService>();
  final isIndexing = false.obs;

  Future<List<Map<String, dynamic>>> getMaintenanceRecords() async {
    try {
      print('=== Maintenance Service Debug ===');
      print('Fetching maintenance records...');
      print('Organization ID: ${_authService.organizationId}');
      print('Current user: ${_authService.currentUser?.uid}');
      print('Current user email: ${_authService.currentUser?.email}');
      isIndexing.value = false;

      if (_authService.organizationId == null) {
        print('ERROR: Organization ID is null');
        throw Exception('Organization ID is not set');
      }

      // First try to get the total count of maintenance records
      final countSnapshot = await _firestore
          .collection('maintenance')
          .where('organizationId', isEqualTo: _authService.organizationId)
          .count()
          .get();

      print('Total records count: ${countSnapshot.count}');

      final querySnapshot = await _firestore
          .collection('maintenance')
          .where('organizationId', isEqualTo: _authService.organizationId)
          .orderBy('maintenanceDate', descending: true)
          .get();

      print('Found ${querySnapshot.docs.length} records in query');
      print(
          'Query metadata - fromCache: ${querySnapshot.metadata.isFromCache}');
      print(
          'Query metadata - hasPendingWrites: ${querySnapshot.metadata.hasPendingWrites}');

      if (querySnapshot.docs.isEmpty) {
        print(
            'No records found for organization: ${_authService.organizationId}');
        return [];
      }

      final records = querySnapshot.docs.map((doc) {
        final data = doc.data();
        print('Processing record ID: ${doc.id}');
        print('Record data: $data');
        return {
          'id': doc.id,
          'vehicleId': data['vehicleId'] ?? 'Unknown Vehicle',
          'type': data['type'] ?? 'General Maintenance',
          'description': data['description'] ?? 'No description provided',
          'status': data['status'] ?? 'pending',
          'maintenanceDate': data['maintenanceDate'] != null
              ? (data['maintenanceDate'] as Timestamp).toDate()
              : DateTime.now(),
          'priority': data['priority'] ?? 'medium',
          'cost': data['cost'] ?? 0.0,
          'notes': data['notes'] ?? '',
          'createdAt': data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          'createdBy': data['createdBy'] ?? 'Unknown User',
        };
      }).toList();

      print('Successfully processed ${records.length} records');
      print('=== End Maintenance Service Debug ===');
      return records;
    } catch (e) {
      print('=== Maintenance Service Error ===');
      print('Error fetching maintenance records: $e');
      if (e is FirebaseException) {
        print('Firebase Exception Code: ${e.code}');
        print('Firebase Exception Message: ${e.message}');
        print('Firebase Exception Stack Trace: ${e.stackTrace}');

        if (e.code == 'failed-precondition') {
          isIndexing.value = true;
          print('Index is being created, trying simpler query...');

          // Try a simpler query while index is being built
          final querySnapshot = await _firestore
              .collection('maintenance')
              .where('organizationId', isEqualTo: _authService.organizationId)
              .get();

          print('Found ${querySnapshot.docs.length} records with simple query');

          final records = querySnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'vehicleId': data['vehicleId'] ?? 'Unknown Vehicle',
              'type': data['type'] ?? 'General Maintenance',
              'description': data['description'] ?? 'No description provided',
              'status': data['status'] ?? 'pending',
              'maintenanceDate': data['maintenanceDate'] != null
                  ? (data['maintenanceDate'] as Timestamp).toDate()
                  : DateTime.now(),
              'priority': data['priority'] ?? 'medium',
              'cost': data['cost'] ?? 0.0,
              'notes': data['notes'] ?? '',
              'createdAt': data['createdAt'] != null
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.now(),
              'createdBy': data['createdBy'] ?? 'Unknown User',
            };
          }).toList();

          print(
              'Successfully processed ${records.length} records with simple query');
          print('=== End Maintenance Service Debug ===');
          return records;
        }
      }
      print('=== End Maintenance Service Error ===');
      rethrow;
    }
  }

  Future<void> createMaintenanceRecord(Map<String, dynamic> data) async {
    try {
      print('=== Maintenance Service Debug ===');
      print('Creating maintenance record with data: $data');
      print('Organization ID from auth: ${_authService.organizationId}');
      print('Current user: ${_authService.currentUser?.uid}');

      if (_authService.organizationId == null) {
        print('ERROR: Organization ID is null');
        throw Exception('Organization ID is not set');
      }

      final maintenanceData = {
        'vehicleId': data['vehicleId'] ?? 'Unknown Vehicle',
        'type': data['type'] ?? 'General Maintenance',
        'description': data['description'] ?? 'No description provided',
        'status': data['status'] ?? 'pending',
        'maintenanceDate':
            Timestamp.fromDate(data['maintenanceDate'] as DateTime),
        'priority': data['priority'] ?? 'medium',
        'cost': data['cost'] ?? 0.0,
        'notes': data['notes'] ?? '',
        'organizationId': _authService.organizationId,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _authService.currentUser?.uid ?? 'Unknown User',
      };

      print('Converted maintenance data: $maintenanceData');
      print('Attempting to add document to Firestore...');

      final docRef =
          await _firestore.collection('maintenance').add(maintenanceData);
      print('Document created successfully with ID: ${docRef.id}');
      print('=== End Maintenance Service Debug ===');
    } catch (e) {
      print('=== Maintenance Service Error ===');
      print('Error creating maintenance record: $e');
      if (e is FirebaseException) {
        print('Firebase Exception Code: ${e.code}');
        print('Firebase Exception Message: ${e.message}');
        print('Firebase Exception Stack Trace: ${e.stackTrace}');
      }
      print('=== End Maintenance Service Error ===');
      throw 'Failed to create maintenance record: ${e.toString()}';
    }
  }

  Future<void> updateMaintenanceRecord(
      String id, Map<String, dynamic> data) async {
    try {
      final updateData = {
        'vehicleId': data['vehicleId'],
        'type': data['type'],
        'description': data['description'],
        'status': data['status'],
        'maintenanceDate': data['maintenanceDate'] != null
            ? Timestamp.fromDate(data['maintenanceDate'] as DateTime)
            : null,
        'nextMaintenanceDate': data['nextMaintenanceDate'] != null
            ? Timestamp.fromDate(data['nextMaintenanceDate'] as DateTime)
            : null,
        'cost': data['cost'],
        'notes': data['notes'],
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _authService.currentUser?.uid,
      };

      await _firestore.collection('maintenance').doc(id).update(updateData);
    } catch (e) {
      throw 'Failed to update maintenance record: ${e.toString()}';
    }
  }

  Future<void> deleteMaintenanceRecord(String id) async {
    try {
      await _firestore.collection('maintenance').doc(id).delete();
    } catch (e) {
      throw 'Failed to delete maintenance record: ${e.toString()}';
    }
  }

  Future<List<Map<String, dynamic>>> getMaintenanceHistory(
      String vehicleId) async {
    try {
      final querySnapshot = await _firestore
          .collection('maintenance')
          .where('vehicleId', isEqualTo: vehicleId)
          .where('organizationId', isEqualTo: _authService.organizationId)
          .orderBy('maintenanceDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'vehicleId': data['vehicleId'] ?? 'Unknown Vehicle',
          'type': data['type'] ?? 'General Maintenance',
          'description': data['description'] ?? 'No description provided',
          'status': data['status'] ?? 'pending',
          'maintenanceDate': data['maintenanceDate'] != null
              ? (data['maintenanceDate'] as Timestamp).toDate()
              : DateTime.now(),
          'nextMaintenanceDate': data['nextMaintenanceDate'] != null
              ? (data['nextMaintenanceDate'] as Timestamp).toDate()
              : null,
          'createdAt': data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          'createdBy': data['createdBy'] ?? 'Unknown User',
          'cost': data['cost'] ?? 0.0,
          'notes': data['notes'] ?? '',
        };
      }).toList();
    } catch (e) {
      throw 'Failed to load maintenance history: ${e.toString()}';
    }
  }
}
