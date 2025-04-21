import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';

class LocationController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();
  final markers = <MarkerId, Marker>{}.obs;
  final isLoading = true.obs;
  final error = ''.obs;
  StreamSubscription? _locationSubscription;
  StreamSubscription? _driversSubscription;
  final Completer<GoogleMapController> mapController = Completer();

  // Default to Dire Dawa coordinates
  final initialCameraPosition = const CameraPosition(
    target: LatLng(9.5897, 41.8547),
    zoom: 15,
  );

  @override
  void onInit() {
    super.onInit();
    print('LocationController initialized');
    initializeLocation();
  }

  @override
  void onClose() {
    print('LocationController closing');
    _locationSubscription?.cancel();
    _driversSubscription?.cancel();
    super.onClose();
  }

  Future<void> initializeLocation() async {
    try {
      print('Initializing location...');
      isLoading.value = true;
      error.value = '';

      final hasPermission = await _locationService.requestLocationPermission();
      if (!hasPermission) {
        error.value = 'Location permission denied';
        print('Location permission denied');
        return;
      }

      // Get initial position
      final position = await Geolocator.getCurrentPosition();
      print(
          'Got initial position: ${position.latitude}, ${position.longitude}');

      // Start tracking current user's location
      _locationSubscription = _locationService.getLocationStream().listen(
        (Position position) {
          print('Location update: ${position.latitude}, ${position.longitude}');
          _updateCurrentLocation(position);
        },
        onError: (e) {
          print('Error in location stream: $e');
          error.value = 'Error getting location: $e';
        },
      );

      // Start tracking other drivers' locations
      _driversSubscription = _locationService.getDriverLocations().listen(
        (drivers) {
          print('Driver locations update: ${drivers.length} drivers');
          _updateDriverMarkers(drivers);
        },
        onError: (e) {
          print('Error in drivers stream: $e');
          error.value = 'Error getting driver locations: $e';
        },
      );
    } catch (e) {
      print('Error in initializeLocation: $e');
      error.value = 'Error initializing location: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateCurrentLocation(Position position) async {
    try {
      // Update current user's location in Firebase
      await _locationService.updateDriverLocation(position);

      // Move camera to current location
      final controller = await mapController.future;
      controller.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    } catch (e) {
      error.value = 'Error updating location: $e';
    }
  }

  void _updateDriverMarkers(List<Map<String, dynamic>> drivers) {
    final newMarkers = <MarkerId, Marker>{};

    for (final driver in drivers) {
      final markerId = MarkerId(driver['driverId']);
      final marker = Marker(
        markerId: markerId,
        position: LatLng(
          driver['latitude'],
          driver['longitude'],
        ),
        infoWindow: InfoWindow(
          title: driver['driverName'],
          snippet: 'Last updated: ${_formatTimestamp(driver['timestamp'])}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
      );
      newMarkers[markerId] = marker;
    }

    markers.value = newMarkers;
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    final dateTime = timestamp.toDate();
    return '${dateTime.hour}:${dateTime.minute}';
  }

  Future<void> centerOnCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final controller = await mapController.future;
      controller.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    } catch (e) {
      error.value = 'Error centering on current location: $e';
    }
  }
}
