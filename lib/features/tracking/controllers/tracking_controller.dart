import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/tracking_service.dart';
import '../../../core/services/auth_service.dart';

class TrackingController extends GetxController {
  final TrackingService _trackingService = Get.find<TrackingService>();
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoading = false.obs;
  final Rx<LatLng> currentLocation = const LatLng(9.0084, 38.7648).obs;
  final RxMap<String, Marker> markers = <String, Marker>{}.obs;
  final RxList<Map<String, dynamic>> activeDrivers =
      <Map<String, dynamic>>[].obs;
  final RxString selectedDriverId = ''.obs;

  late GoogleMapController mapController;

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      isLoading.value = true;

      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Permission Denied',
            'Location permissions are required to track vehicles',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission Denied',
          'Location permissions are permanently denied. Please enable them in settings.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Location Disabled',
          'Please enable location services to track vehicles',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition();
      currentLocation.value = LatLng(position.latitude, position.longitude);

      // Add current user marker
      updateCurrentLocationMarker();

      // Load active drivers
      await loadActiveDrivers();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initialize location: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void updateCurrentLocationMarker() {
    markers['current_location'] = Marker(
      markerId: const MarkerId('current_location'),
      position: currentLocation.value,
      infoWindow: const InfoWindow(
        title: 'Your Location',
        snippet: 'Your current position',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Move camera to current location when map is created
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(currentLocation.value, 15),
    );
  }

  Future<void> focusOnLocation(LatLng location) async {
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(location, 16),
    );
  }

  Future<void> loadActiveDrivers() async {
    try {
      final drivers = await _trackingService.getAllActiveDrivers();
      activeDrivers.value = drivers;

      // Update markers for each driver
      for (final driver in drivers) {
        final locationData = driver['currentLocation'] as Map<String, dynamic>?;
        if (locationData != null &&
            locationData.containsKey('latitude') &&
            locationData.containsKey('longitude')) {
          final lat = locationData['latitude'] as double;
          final lng = locationData['longitude'] as double;

          markers[driver['id']] = Marker(
            markerId: MarkerId(driver['id']),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: driver['name'],
              snippet: 'Vehicle: ${driver['vehicleName']}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load active drivers: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refreshLocations() async {
    try {
      isLoading.value = true;

      // Get current position again
      Position position = await Geolocator.getCurrentPosition();
      currentLocation.value = LatLng(position.latitude, position.longitude);
      updateCurrentLocationMarker();

      // Reload active drivers
      await loadActiveDrivers();

      Get.snackbar(
        'Success',
        'Locations refreshed',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh locations: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void trackDriver(String driverId) {
    if (driverId.isEmpty) return;

    selectedDriverId.value = driverId;
    _trackingService.getDriverLocation(driverId).listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('currentLocation')) {
          final locationData = data['currentLocation'] as Map<String, dynamic>;
          if (locationData.containsKey('latitude') &&
              locationData.containsKey('longitude')) {
            final lat = locationData['latitude'] as double;
            final lng = locationData['longitude'] as double;
            final location = LatLng(lat, lng);

            // Update marker
            markers[driverId] = Marker(
              markerId: MarkerId(driverId),
              position: location,
              infoWindow: InfoWindow(
                title: data['name'] ?? 'Driver',
                snippet: 'Vehicle: ${data['vehicleName'] ?? 'Unknown'}',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen),
            );

            // Focus map on driver if they're selected
            if (selectedDriverId.value == driverId) {
              focusOnLocation(location);
            }
          }
        }
      }
    });
  }

  @override
  void onClose() {
    mapController.dispose();
    super.onClose();
  }
}
