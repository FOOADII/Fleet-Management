import 'package:get/get.dart';
import '../../../core/services/firebase_auth_service.dart';

class DashboardController extends GetxController {
  final FirebaseAuthService _authService = Get.find<FirebaseAuthService>();

  final isLoading = true.obs;
  final error = ''.obs;
  final userName = ''.obs;
  final totalTasks = 0.obs;
  final completedTasks = 0.obs;
  final pendingMaintenance = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Set user name
      userName.value = _authService.currentUser?.displayName ?? 'Driver';

      // TODO: Load actual data from Firebase
      totalTasks.value = 5;
      completedTasks.value = 2;
      pendingMaintenance.value = 3;
    } catch (e) {
      error.value = 'Error loading dashboard data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  double get taskCompletionRate {
    if (totalTasks.value == 0) return 0.0;
    return completedTasks.value / totalTasks.value;
  }
}
