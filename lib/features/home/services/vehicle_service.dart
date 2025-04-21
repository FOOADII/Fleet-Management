import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VehicleService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable variables for real-time updates
  final RxString vehicleId = ''.obs;
  final RxString currentRoute = ''.obs;
  final RxString status = ''.obs;
  final RxDouble speed = 0.0.obs;
  final RxDouble fuelLevel = 0.0.obs;
  final RxDouble engineTemp = 0.0.obs;
  final RxList<Map<String, dynamic>> todaySchedule =
      <Map<String, dynamic>>[].obs;

  String? _organizationId;
  String? _assignedVehicleId;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No user is currently signed in');
        return;
      }

      print('Initializing vehicle service for user: ${currentUser.uid}');

      // Get user's organization and vehicle data
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        _organizationId = userData['organizationId'];
        _assignedVehicleId = userData['assignedVehicleId'];

        print('User data found:');
        print('Organization ID: $_organizationId');
        print('Assigned Vehicle ID: $_assignedVehicleId');

        if (_organizationId != null && _assignedVehicleId != null) {
          _setupRealtimeListeners();
        } else {
          print('User is not assigned to an organization or vehicle');
        }
      } else {
        print('User document not found in Firestore');
      }
    } catch (e) {
      print('Error initializing vehicle service: $e');
    }
  }

  void _setupRealtimeListeners() {
    if (_organizationId == null || _assignedVehicleId == null) {
      print('Cannot setup listeners: organizationId or vehicleId is null');
      print('Organization ID: $_organizationId');
      print('Vehicle ID: $_assignedVehicleId');
      return;
    }

    print('Setting up real-time listeners for vehicle: $_assignedVehicleId');

    // Listen to vehicle document
    _firestore
        .collection('organizations')
        .doc(_organizationId)
        .collection('vehicles')
        .doc(_assignedVehicleId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        print('Vehicle data received: $data');

        vehicleId.value = data['id'] ?? '';
        currentRoute.value = data['currentRoute'] ?? '';
        status.value = data['status'] ?? '';
        speed.value = (data['speed'] ?? 0).toDouble();
        fuelLevel.value = (data['fuelLevel'] ?? 0).toDouble();
        engineTemp.value = (data['engineTemp'] ?? 0).toDouble();
      } else {
        print('Vehicle document not found for ID: $_assignedVehicleId');
      }
    }, onError: (error) {
      print('Error listening to vehicle data: $error');
    });

    // Listen to schedule collection
    final today = DateTime.now().toIso8601String().split('T')[0];
    print('Setting up schedule listener for date: $today');

    _firestore
        .collection('organizations')
        .doc(_organizationId)
        .collection('schedules')
        .where('date', isEqualTo: today)
        .where('vehicleId', isEqualTo: _assignedVehicleId)
        .orderBy('time')
        .snapshots()
        .listen((snapshot) {
      print('Schedule data received: ${snapshot.docs.length} documents');
      if (snapshot.docs.isEmpty) {
        print('No schedules found for today');
        print('Query parameters:');
        print('- Date: $today');
        print('- Vehicle ID: $_assignedVehicleId');
        print('- Organization ID: $_organizationId');
      } else {
        print('Schedule documents:');
        for (var doc in snapshot.docs) {
          print('Schedule: ${doc.data()}');
        }
      }
      todaySchedule.value = snapshot.docs.map((doc) {
        final data = doc.data();
        return data;
      }).toList();
    }, onError: (error) {
      print('Error listening to schedule data: $error');
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTodaySchedule() {
    if (_organizationId == null || _assignedVehicleId == null) {
      print('Cannot get schedule: organizationId or vehicleId is null');
      print('Organization ID: $_organizationId');
      print('Vehicle ID: $_assignedVehicleId');
      return Stream.empty();
    }

    final today = DateTime.now().toIso8601String().split('T')[0];
    print('Getting schedule for date: $today');
    print('Querying schedules for organization: $_organizationId');
    print('Querying schedules for vehicle: $_assignedVehicleId');

    try {
      return _firestore
          .collection('organizations')
          .doc(_organizationId)
          .collection('schedules')
          .where('date', isEqualTo: today)
          .where('vehicleId', isEqualTo: _assignedVehicleId)
          .orderBy('time')
          .snapshots();
    } catch (e) {
      print('Error getting schedules: $e');
      return Stream.empty();
    }
  }

  Future<void> startTrip() async {
    if (_organizationId == null || _assignedVehicleId == null) {
      throw Exception('Organization ID or Vehicle ID is not set');
    }

    try {
      await _firestore
          .collection('organizations')
          .doc(_organizationId)
          .collection('vehicles')
          .doc(_assignedVehicleId)
          .update({
        'status': 'On Trip',
        'lastTripStart': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error starting trip: $e');
      rethrow;
    }
  }

  Future<void> endTrip() async {
    if (_organizationId == null || _assignedVehicleId == null) {
      throw Exception('Organization ID or Vehicle ID is not set');
    }

    try {
      await _firestore
          .collection('organizations')
          .doc(_organizationId)
          .collection('vehicles')
          .doc(_assignedVehicleId)
          .update({
        'status': 'Available',
        'lastTripEnd': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error ending trip: $e');
      rethrow;
    }
  }

  Future<void> reportEmergency(String type, String details) async {
    if (_organizationId == null || _assignedVehicleId == null) {
      throw Exception('Organization ID or Vehicle ID is not set');
    }

    try {
      await _firestore
          .collection('organizations')
          .doc(_organizationId)
          .collection('emergencies')
          .add({
        'type': type,
        'details': details,
        'vehicleId': _assignedVehicleId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Pending',
      });
    } catch (e) {
      print('Error reporting emergency: $e');
      rethrow;
    }
  }
}
