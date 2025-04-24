import 'package:get/get.dart';
import '../controllers/fuel_controller.dart';
import '../controllers/fuel_tracking_controller.dart';
import '../services/fuel_tracking_service.dart';

class FuelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FuelTrackingService>(() => FuelTrackingService());
    Get.lazyPut<FuelTrackingController>(() => FuelTrackingController());
    Get.lazyPut<FuelController>(() => FuelController());
  }
}
