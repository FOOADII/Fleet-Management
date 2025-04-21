import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/mock_tracking_service.dart';

class TrackingController extends GetxController {
  final MockTrackingService _trackingService = MockTrackingService();
  final RxBool isLoading = false.obs;
  final Rx<Position?> currentLocation = Rx<Position?>(null);
  final RxList<Position> locationHistory = <Position>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      isLoading.value = true;
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final request = await Geolocator.requestPermission();
        if (request == LocationPermission.denied) {
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      currentLocation.value = position;
      locationHistory.add(position);
    } catch (e) {
      print('Error initializing location: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateVehicleLocation(
      String vehicleId, Position position) async {
    try {
      isLoading.value = true;
      await _trackingService.updateLocation(vehicleId, position);
      currentLocation.value = position;
      locationHistory.add(position);
    } catch (e) {
      print('Error updating vehicle location: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Stream<Position> getVehicleLocationStream(String vehicleId) {
    return _trackingService.getLocationStream(vehicleId);
  }

  @override
  void onClose() {
    _trackingService.dispose();
    super.onClose();
  }
}
