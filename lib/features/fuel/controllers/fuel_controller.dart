import 'package:get/get.dart';
import '../services/fuel_tracking_service.dart';
import '../models/fuel_record.dart';

class FuelController extends GetxController {
  final FuelTrackingService _fuelService = Get.find<FuelTrackingService>();
  RxList<FuelRecord> get fuelRecords => _fuelService.fuelRecords;
  RxBool get isLoading => _fuelService.isLoading;

  @override
  void onInit() {
    super.onInit();
    _fuelService.loadFuelRecords();
  }

  Future<void> addFuelRecord({
    required String vehicleId,
    required double odometerReading,
    required double fuelGauge,
    required double fuelAmount,
    String? notes,
  }) async {
    try {
      await _fuelService.createFuelRecord(
        vehicleId: vehicleId,
        odometerReading: odometerReading,
        fuelGauge: fuelGauge,
        fuelAmount: fuelAmount,
        notes: notes,
      );
      Get.snackbar(
        'Success',
        'Fuel record added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add fuel record: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateFuelRecordStatus(String id, String status) async {
    try {
      await _fuelService.updateFuelRecordStatus(id, status);
      Get.snackbar(
        'Success',
        'Fuel record updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update fuel record: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
