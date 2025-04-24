import 'dart:async';
import 'package:get/get.dart';
import '../../../core/services/firebase_maintenance_service.dart';
import '../models/maintenance_log_model.dart';

class MaintenanceController extends GetxController {
  final FirebaseMaintenanceService _maintenanceService;
  final RxBool isLoading = false.obs;
  final RxList<MaintenanceLog> maintenanceLogs = <MaintenanceLog>[].obs;
  StreamSubscription<List<MaintenanceLog>>? _logSubscription;

  MaintenanceController(this._maintenanceService);

  @override
  void onInit() {
    super.onInit();
    _subscribeToMaintenanceLogs();
  }

  @override
  void onClose() {
    _logSubscription?.cancel();
    super.onClose();
  }

  void _subscribeToMaintenanceLogs() {
    isLoading.value = true;
    _logSubscription = _maintenanceService.maintenanceLogStream().listen(
      (logs) {
        maintenanceLogs.value = logs;
        isLoading.value = false;
      },
      onError: (error) {
        print('Error subscribing to maintenance logs: $error');
        isLoading.value = false;
        Get.snackbar(
          'Error Loading Data',
          'Failed to load maintenance records: ${error.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      },
    );
  }

  // Manually fetch all logs (e.g., for pull-to-refresh)
  Future<void> loadMaintenanceLogs() async {
    try {
      isLoading.value = true;
      maintenanceLogs.value = await _maintenanceService.getMaintenanceLogs();
    } catch (e) {
      Get.snackbar(
        'Error Refreshing',
        'Failed to refresh maintenance records: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new log
  Future<void> addMaintenanceLog({
    required String vehicleId,
    required String description,
    required String maintenanceType,
    required DateTime datePerformed,
    int? odometerReading,
    double? cost,
    String? notes,
    required MaintenanceStatus status,
    DateTime? nextDueDate,
  }) async {
    try {
      // Create a temporary log object (ID will be assigned by service)
      final newLog = MaintenanceLog(
        id: '', // Temporary, will be replaced by Firestore ID
        vehicleId: vehicleId,
        description: description,
        maintenanceType: maintenanceType,
        datePerformed: datePerformed,
        odometerReading: odometerReading,
        cost: cost,
        notes: notes,
        status: status,
        nextDueDate: nextDueDate,
        createdAt: DateTime.now(), // Will be replaced by server timestamp
      );

      isLoading.value = true; // Optional: show loading while adding
      await _maintenanceService.addMaintenanceLog(newLog);
      // No need to manually add to list, stream will update it
      Get.snackbar(
        'Success',
        'Maintenance log added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error Adding Log',
        'Failed to add maintenance record: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false; // Optional: hide loading
    }
  }

  // Update log status or other details
  Future<void> updateMaintenanceLog(
      String logId, Map<String, dynamic> data) async {
    try {
      isLoading.value = true; // Optional
      await _maintenanceService.updateMaintenanceLog(logId, data);
      // Stream updates the list
      Get.snackbar(
        'Success',
        'Maintenance log updated',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error Updating Log',
        'Failed to update maintenance record: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false; // Optional
    }
  }

  // Delete a log
  Future<void> deleteMaintenanceLog(String logId) async {
    try {
      isLoading.value = true; // Optional
      await _maintenanceService.deleteMaintenanceLog(logId);
      // Stream updates the list
      Get.snackbar(
        'Success',
        'Maintenance log deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error Deleting Log',
        'Failed to delete maintenance record: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false; // Optional
    }
  }

  // Filter logs by status
  Future<void> filterLogsByStatus(MaintenanceStatus? status) async {
    if (status == null) {
      // If null, load all logs (rely on stream or fetch all)
      _subscribeToMaintenanceLogs(); // Re-subscribe to get all
      return;
    }
    try {
      isLoading.value = true;
      maintenanceLogs.value = await _maintenanceService.getLogsByStatus(status);
    } catch (e) {
      Get.snackbar(
        'Error Filtering',
        'Failed to filter records: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Filter logs by vehicle ID
  Future<void> filterLogsByVehicle(String? vehicleId) async {
    if (vehicleId == null || vehicleId.isEmpty) {
      _subscribeToMaintenanceLogs(); // Re-subscribe to get all
      return;
    }
    try {
      isLoading.value = true;
      maintenanceLogs.value =
          await _maintenanceService.getLogsByVehicle(vehicleId);
    } catch (e) {
      Get.snackbar(
        'Error Filtering',
        'Failed to load records for vehicle: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
