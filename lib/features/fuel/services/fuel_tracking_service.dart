import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/fuel_record.dart';

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
          .orderBy('timestamp', descending: true)
          .where('createdBy', isEqualTo: _userId)
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
