import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class TrackingService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  StreamSubscription<Position>? _positionSubscription;
  final RxBool isTracking = false.obs;
  final RxBool isLocationSaved = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    // Check if user is authenticated
    final user = _authService.currentUser;
    if (user == null) {
      print('User not authenticated, tracking not started');
      return;
    }

    // Request location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions permanently denied');
      return;
    }

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services disabled');
      return;
    }

    // Start tracking
    isTracking.value = true;

    // Get initial position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Update initial position in Firestore
    await updateDriverLocation(position);

    // Start position stream for real-time updates
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
        timeLimit: Duration(seconds: 10), // Max time between updates
      ),
    ).listen((Position position) {
      updateDriverLocation(position);
    });
  }

  Future<void> updateDriverLocation(Position position) async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final locationData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'speed': position.speed,
        'heading': position.heading,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Update or create driver document
      await _firestore.collection('drivers').doc(user.uid).set({
        'currentLocation': locationData,
        'isOnline': true,
        'lastUpdated': FieldValue.serverTimestamp(),
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName ?? 'Unknown Driver',
      }, SetOptions(merge: true));

      // Add to location history
      await _firestore
          .collection('drivers')
          .doc(user.uid)
          .collection('locationHistory')
          .add(locationData);

      // Verify location was saved
      final doc = await _firestore.collection('drivers').doc(user.uid).get();
      if (doc.exists && doc.data()?['currentLocation'] != null) {
        isLocationSaved.value = true;
      } else {
        isLocationSaved.value = false;
        print('Location not saved in database');
      }
    } catch (e) {
      isLocationSaved.value = false;
      print('Error updating location: $e');
    }
  }

  Stream<DocumentSnapshot> getDriverLocation(String driverId) {
    return _firestore.collection('drivers').doc(driverId).snapshots();
  }

  Future<List<Map<String, dynamic>>> getAllActiveDrivers() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return [];

      // Only get the current driver's data
      final doc = await _firestore.collection('drivers').doc(user.uid).get();
      if (!doc.exists) return [];

      final data = doc.data()!;
      return [
        {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown Driver',
          'vehicleId': data['vehicleId'] ?? '',
          'vehicleName': data['vehicleName'] ?? '',
          'currentLocation': data['currentLocation'] ?? {},
          'lastUpdated': data['lastUpdated'],
        }
      ];
    } catch (e) {
      print('Error getting active drivers: $e');
      return [];
    }
  }

  @override
  void onClose() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    isTracking.value = false;
    super.onClose();
  }
}
