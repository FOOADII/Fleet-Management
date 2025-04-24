import 'package:get/get.dart';
import '../../../core/services/firebase_auth_service.dart';
import 'package:flutter/foundation.dart';

class DashboardController extends GetxController {
  final FirebaseAuthService _authService = Get.find<FirebaseAuthService>();

  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxString userName = ''.obs;
  final RxInt totalTasks = 0.obs;
  final RxInt completedTasks = 0.obs;
  final RxInt pendingMaintenance = 0.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('DashboardController onInit called');
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      debugPrint('DashboardController: Loading dashboard data');
      isLoading.value = true;
      error.value = '';

      // Set user name
      final user = _authService.currentUser;
      debugPrint('DashboardController: Current user: ${user?.uid}');
      userName.value = user?.displayName ?? 'Driver';

      // TODO: Load actual data from Firebase
      totalTasks.value = 5;
      completedTasks.value = 2;
      pendingMaintenance.value = 3;

      debugPrint('DashboardController: Dashboard data loaded successfully');
    } catch (e, stackTrace) {
      debugPrint('DashboardController: Error loading dashboard data: $e');
      debugPrint('DashboardController: Stack trace: $stackTrace');
      error.value = 'Error loading dashboard data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  double get taskCompletionRate {
    if (totalTasks.value == 0) return 0.0;
    return completedTasks.value / totalTasks.value;
  }

  @override
  void onClose() {
    debugPrint('DashboardController onClose called');
    super.onClose();
  }
}
