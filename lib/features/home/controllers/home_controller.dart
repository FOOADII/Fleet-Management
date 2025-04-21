import 'package:get/get.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/routes/app_pages.dart';

class HomeController extends GetxController {
  final FirebaseAuthService _authService;
  final RxInt currentIndex = 0.obs;
  final RxList<Map<String, dynamic>> recentActivities =
      <Map<String, dynamic>>[].obs;
  final RxMap<String, int> quickStats = <String, int>{
    'activeVehicles': 0,
    'pendingTasks': 0,
    'maintenanceDue': 0,
    'totalExpenses': 0,
  }.obs;

  HomeController(this._authService);

  void changeIndex(int index) {
    if (index >= 0 && index <= 4) {
      // Update to include fuel tracking view
      currentIndex.value = index;
    }
  }

  Future<void> handleSignOut() async {
    try {
      await _authService.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred during sign out',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  Future<void> loadQuickStats() async {
    try {
      // TODO: Load real stats from your backend
      quickStats.value = {
        'activeVehicles': 5,
        'pendingTasks': 3,
        'maintenanceDue': 2,
        'totalExpenses': 1500,
      };
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load statistics. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadRecentActivities() async {
    try {
      // TODO: Load real activities from your backend
      recentActivities.value = [
        {
          'title': 'New Task Assigned',
          'description': 'Delivery to Central Warehouse',
          'time': DateTime.now().subtract(const Duration(hours: 1)),
          'type': 'task',
        },
        {
          'title': 'Maintenance Due',
          'description': 'Vehicle DDU-001 needs service',
          'time': DateTime.now().subtract(const Duration(hours: 2)),
          'type': 'maintenance',
        },
        {
          'title': 'Expense Reported',
          'description': 'Fuel refill - \$50',
          'time': DateTime.now().subtract(const Duration(hours: 3)),
          'type': 'expense',
        },
        {
          'title': 'Route Updated',
          'description': 'New optimized route available',
          'time': DateTime.now().subtract(const Duration(hours: 4)),
          'type': 'tracking',
        },
        {
          'title': 'Task Completed',
          'description': 'Delivery to North Branch completed',
          'time': DateTime.now().subtract(const Duration(hours: 5)),
          'type': 'task',
        },
      ];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load activities. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadQuickStats();
    loadRecentActivities();
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}
