import 'package:get/get.dart';
import '../../../core/services/mock_reports_service.dart';
import '../../../core/services/mock_reports_service.dart' as models;

class ReportsController extends GetxController {
  final MockReportsService _reportsService = MockReportsService();
  final RxList<models.Report> reports = <models.Report>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  Future<void> loadReports() async {
    try {
      isLoading.value = true;
      final loadedReports = await _reportsService.getReports();
      reports.value = loadedReports;
    } catch (e) {
      print('Error loading reports: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createReport(
    String title,
    String description,
    String type, {
    DateTime? startDate,
    DateTime? endDate,
    String? vehicleId,
    Map<String, dynamic>? data,
  }) async {
    try {
      isLoading.value = true;
      final report = await _reportsService.createReport(
        title,
        description,
        type,
        startDate: startDate,
        endDate: endDate,
        vehicleId: vehicleId,
        data: data,
      );
      reports.add(report);
    } catch (e) {
      print('Error creating report: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateReport(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      isLoading.value = true;
      await _reportsService.updateReport(id, data);
      await loadReports();
    } catch (e) {
      print('Error updating report: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      isLoading.value = true;
      await _reportsService.deleteReport(id);
      reports.removeWhere((report) => report.id == id);
    } catch (e) {
      print('Error deleting report: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
