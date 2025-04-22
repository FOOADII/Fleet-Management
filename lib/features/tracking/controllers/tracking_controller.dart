import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/mock_tracking_service.dart';

class TrackingController extends GetxController {
  final MockTrackingService _trackingService = MockTrackingService();
  final RxBool isLoading = false.obs;
  final Rx<LatLng> currentLocation = const LatLng(9.0084, 38.7648).obs;
  final RxMap<String, Marker> markers = <String, Marker>{}.obs;
  final RxList<Map<String, dynamic>> vehicles = <Map<String, dynamic>>[].obs;
  late GoogleMapController mapController;

  @override
  void onInit() {
    super.onInit();
    loadVehicles();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> loadVehicles() async {
    try {
      isLoading.value = true;
      // TODO: Implement API call to fetch vehicles
      // For now, using mock data
      vehicles.value = [
        {
          'id': '1',
          'name': 'DDU-1001',
          'location': 'Addis Ababa, Ethiopia',
          'status': 'active',
          'speed': '60 km/h',
          'lat': 9.0084,
          'lng': 38.7648,
        },
        {
          'id': '2',
          'name': 'DDU-1002',
          'location': 'Adama, Ethiopia',
          'status': 'active',
          'speed': '45 km/h',
          'lat': 8.5466,
          'lng': 39.2683,
        },
        {
          'id': '3',
          'name': 'DDU-1003',
          'location': 'Hawassa, Ethiopia',
          'status': 'inactive',
          'speed': '0 km/h',
          'lat': 7.0584,
          'lng': 38.4764,
        },
      ];

      // Update markers
      for (final vehicle in vehicles) {
        markers[vehicle['id']] = Marker(
          markerId: MarkerId(vehicle['id']),
          position: LatLng(vehicle['lat'], vehicle['lng']),
          infoWindow: InfoWindow(
            title: vehicle['name'],
            snippet: '${vehicle['speed']} - ${vehicle['location']}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            vehicle['status'] == 'active'
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueRed,
          ),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load vehicles: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshLocations() async {
    try {
      isLoading.value = true;
      // TODO: Implement API call to refresh vehicle locations
      await loadVehicles();
      Get.snackbar(
        'Success',
        'Locations refreshed',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh locations: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateVehicleLocation(
    String vehicleId,
    double lat,
    double lng,
  ) async {
    try {
      // TODO: Implement API call to update vehicle location
      final index = vehicles.indexWhere((v) => v['id'] == vehicleId);
      if (index != -1) {
        vehicles[index]['lat'] = lat;
        vehicles[index]['lng'] = lng;
        markers[vehicleId] = Marker(
          markerId: MarkerId(vehicleId),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: vehicles[index]['name'],
            snippet:
                '${vehicles[index]['speed']} - ${vehicles[index]['location']}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            vehicles[index]['status'] == 'active'
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueRed,
          ),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update location: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    _trackingService.dispose();
    super.onClose();
  }
}
