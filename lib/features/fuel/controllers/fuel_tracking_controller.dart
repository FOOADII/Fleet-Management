import 'package:get/get.dart';
import '../services/fuel_tracking_service.dart';

class FuelTrackingController extends GetxController {
  final FuelTrackingService _fuelService = Get.find<FuelTrackingService>();

  @override
  void onInit() {
    super.onInit();
    _fuelService.loadFuelRecords();
  }

  void refreshRecords() {
    _fuelService.loadFuelRecords();
  }
}
