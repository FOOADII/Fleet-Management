import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../core/services/firebase_auth_service.dart';

class LocationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = Get.find<FirebaseAuthService>();

  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  Future<void> updateDriverLocation(Position position) async {
    try {
      await _firestore
          .collection('organizations')
          .doc(_authService.organizationId)
          .collection('driver_locations')
          .doc(_authService.currentUser?.uid)
          .set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'driverId': _authService.currentUser?.uid,
        'driverName': _authService.currentUser?.displayName ?? 'Unknown Driver',
      });
    } catch (e) {
      print('Error updating driver location: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> getDriverLocations() {
    return _firestore
        .collection('organizations')
        .doc(_authService.organizationId)
        .collection('driver_locations')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'driverId': doc.id,
          'driverName': data['driverName'] ?? 'Unknown Driver',
          'latitude': data['latitude'] ?? 0.0,
          'longitude': data['longitude'] ?? 0.0,
          'timestamp': data['timestamp'],
        };
      }).toList();
    });
  }
}
