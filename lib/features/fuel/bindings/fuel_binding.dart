import 'package:get/get.dart';
import '../services/fuel_tracking_service.dart';
import '../controllers/fuel_tracking_controller.dart';

class FuelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FuelTrackingService>(() => FuelTrackingService());
    Get.lazyPut<FuelTrackingController>(() => FuelTrackingController());
  }
}
