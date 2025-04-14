import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FuelRecord {
  final String id;
  final String vehicleId;
  final double odometerReading;
  final double fuelGauge;
  final double fuelAmount;
  final String status;
  final DateTime timestamp;
  final String? notes;
  final String organizationId;
  final String createdBy;

  FuelRecord({
    required this.id,
    required this.vehicleId,
    required this.odometerReading,
    required this.fuelGauge,
    required this.fuelAmount,
    required this.status,
    required this.timestamp,
    this.notes,
    required this.organizationId,
    required this.createdBy,
  });

  factory FuelRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FuelRecord(
      id: doc.id,
      vehicleId: data['vehicleId'] ?? '',
      odometerReading: (data['odometerReading'] ?? 0.0).toDouble(),
      fuelGauge: (data['fuelGauge'] ?? 0.0).toDouble(),
      fuelAmount: (data['fuelAmount'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      notes: data['notes'],
      organizationId: data['organizationId'] ?? 'ddu-fleet',
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'odometerReading': odometerReading,
      'fuelGauge': fuelGauge,
      'fuelAmount': fuelAmount,
      'status': status,
      'timestamp': timestamp,
      'notes': notes,
      'organizationId': organizationId,
      'createdBy': createdBy,
    };
  }
}

class FuelTrackingService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RxList<FuelRecord> fuelRecords = <FuelRecord>[].obs;
  final RxBool isLoading = false.obs;

  // Using a constant for organization ID since it's fixed for now
  String get _organizationId => 'ddu-fleet';
  String get _userId => _auth.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    loadFuelRecords();
  }

  Future<void> loadFuelRecords() async {
    try {
      isLoading.value = true;
      print('Loading fuel records...');
      print('Organization ID: $_organizationId');
      print('User ID: $_userId');

      if (_userId.isEmpty) {
        print('Error: User ID is empty');
        return;
      }

      _firestore
          .collection('organizations')
          .doc(_organizationId)
          .collection('fuel_records')
          .where('createdBy', isEqualTo: _userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          print('Received ${snapshot.docs.length} fuel records');
          final records = snapshot.docs
              .map((doc) => FuelRecord.fromFirestore(doc))
              .toList();
          print('Processed ${records.length} records');
          fuelRecords.value = records;
        },
        onError: (error) {
          print('Error in fuel records stream: $error');
        },
      );
    } catch (e) {
      print('Error loading fuel records: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createFuelRecord({
    required String vehicleId,
    required double odometerReading,
    required double fuelGauge,
    required double fuelAmount,
    String? notes,
  }) async {
    try {
      print('Creating fuel record...');
      print('Organization ID: $_organizationId');
      print('User ID: $_userId');

      if (_userId.isEmpty) {
        throw Exception('User ID is empty');
      }

      final record = await _firestore
          .collection('organizations')
          .doc(_organizationId)
          .collection('fuel_records')
          .add({
        'vehicleId': vehicleId,
        'odometerReading': odometerReading,
        'fuelGauge': fuelGauge,
        'fuelAmount': fuelAmount,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'notes': notes,
        'organizationId': _organizationId,
        'createdBy': _userId,
      });

      print('Successfully created fuel record with ID: ${record.id}');
    } catch (e) {
      print('Error creating fuel record: $e');
      rethrow;
    }
  }

  Future<void> updateFuelRecordStatus(String recordId, String status) async {
    try {
      await _firestore
          .collection('organizations')
          .doc(_organizationId)
          .collection('fuel_records')
          .doc(recordId)
          .update({'status': status});
    } catch (e) {
      print('Error updating fuel record status: $e');
      rethrow;
    }
  }
}
