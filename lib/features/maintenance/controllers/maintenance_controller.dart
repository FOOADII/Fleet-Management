import 'dart:async';
import 'package:get/get.dart';
import '../services/maintenance_service.dart';
import 'package:flutter/material.dart';

class MaintenanceController extends GetxController {
  late final MaintenanceService _maintenanceService;
  final error = ''.obs;
  final filterStatus = 'all'.obs;
  final records = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  MaintenanceService get maintenanceService => _maintenanceService;

  @override
  void onInit() {
    super.onInit();
    _maintenanceService = Get.find<MaintenanceService>();
    loadMaintenanceRecords();
  }

  Future<void> loadMaintenanceRecords() async {
    try {
      print('=== Maintenance Controller Debug ===');
      print('Loading maintenance records...');
      isLoading.value = true;
      error.value = '';

      final result = await _maintenanceService.getMaintenanceRecords();
      print('Received ${result.length} records from service');

      records.value = result;
      print('Successfully updated records list with ${records.length} items');
      print('=== End Maintenance Controller Debug ===');
    } catch (e) {
      print('=== Maintenance Controller Error ===');
      print('Error loading maintenance records: $e');
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load maintenance records: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 5),
      );
      print('=== End Maintenance Controller Error ===');
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filteredRecords {
    if (filterStatus.value == 'all') {
      return records;
    }
    return records
        .where((record) => record['status'] == filterStatus.value)
        .toList();
  }

  void setFilterStatus(String status) {
    filterStatus.value = status;
  }

  Future<void> createMaintenanceRecord(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _maintenanceService.createMaintenanceRecord(data);
      Get.snackbar(
        'Success',
        'Maintenance record created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
        colorText: const Color(0xFF4CAF50),
      );
      loadMaintenanceRecords();
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to create maintenance record',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateMaintenanceRecord(
      String id, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _maintenanceService.updateMaintenanceRecord(id, data);
      Get.snackbar(
        'Success',
        'Maintenance record updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
        colorText: const Color(0xFF4CAF50),
      );
      loadMaintenanceRecords();
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update maintenance record',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMaintenanceRecord(String id) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _maintenanceService.deleteMaintenanceRecord(id);
      Get.snackbar(
        'Success',
        'Maintenance record deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
        colorText: const Color(0xFF4CAF50),
      );
      loadMaintenanceRecords();
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to delete maintenance record',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }
}
