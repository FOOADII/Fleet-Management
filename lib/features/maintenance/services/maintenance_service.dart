import '../../../core/services/mock_maintenance_service.dart';
import '../../../core/services/mock_maintenance_service.dart' as models;

class MaintenanceService {
  final MockMaintenanceService _maintenanceService = MockMaintenanceService();

  Future<List<models.MaintenanceRequest>> getMaintenanceRequests() async {
    return await _maintenanceService.getMaintenanceRequests();
  }

  Future<models.MaintenanceRequest> createMaintenanceRequest(
    String vehicleId,
    String title,
    String description, {
    DateTime? scheduledDate,
    String? assignedTo,
    double? estimatedCost,
  }) async {
    return await _maintenanceService.createMaintenanceRequest(
      vehicleId,
      title,
      description,
      scheduledDate: scheduledDate,
      assignedTo: assignedTo,
      estimatedCost: estimatedCost,
    );
  }

  Future<void> updateMaintenanceRequest(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _maintenanceService.updateMaintenanceRequest(id, data);
  }

  Future<void> deleteMaintenanceRequest(String id) async {
    await _maintenanceService.deleteMaintenanceRequest(id);
  }
}
