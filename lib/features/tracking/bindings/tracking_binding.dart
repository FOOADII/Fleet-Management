import 'package:get/get.dart';
import '../controllers/tracking_controller.dart';
import '../../../core/services/tracking_service.dart';
import '../../../core/services/auth_service.dart';

class TrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrackingService>(() => TrackingService());
    Get.lazyPut<TrackingController>(() => TrackingController());
  }
}
