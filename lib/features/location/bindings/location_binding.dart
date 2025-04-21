import 'package:get/get.dart';
import '../controllers/location_controller.dart';
import '../services/location_service.dart';

class LocationBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize location service first
    Get.lazyPut(() => LocationService());

    // Then initialize the controller that depends on the service
    Get.lazyPut(() => LocationController());
  }
}
