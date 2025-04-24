import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/routes/app_pages.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController extends GetxController {
  final FirebaseAuthService _authService;
  final RxInt currentIndex = 0.obs;
  final Rxn<User> currentUser = Rxn<User>();
  final RxList<Map<String, dynamic>> recentActivities =
      <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> quickStats = <String, dynamic>{
    'activeVehicles': 0,
    'pendingTasks': 0,
    'maintenanceDue': 0,
    'activeTracking': 0,
    'fuelAlerts': 0,
  }.obs;
  final vehicleStatus = 'Active'.obs;

  HomeController(this._authService);

  @override
  void onInit() {
    super.onInit();
    // Initialize with current user
    currentUser.value = _authService.currentUser;
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      currentUser.value = user;
      if (user == null) {
        // If user is logged out, redirect to login
        Get.offAllNamed(Routes.login);
      }
    });
    // Initial data loading
    loadQuickStats();
    loadRecentActivities();

    // Set up periodic refresh - update data every 5 minutes
    ever(currentIndex, (_) {
      // Refresh data when user comes back to home tab
      if (currentIndex.value == 0) {
        loadQuickStats();
        loadRecentActivities();
      }
    });
  }

  void changePage(int index) {
    if (index >= 0 && index <= 4) {
      // Update the range to match new navigation
      currentIndex.value = index;
    }
  }

  Future<void> handleSignOut() async {
    try {
      await _authService.signOut();
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

  String get userDisplayName {
    if (currentUser.value?.displayName?.isNotEmpty ?? false) {
      // If display name exists, capitalize each word
      return currentUser.value!.displayName!
          .split(' ')
          .map((word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
          .join(' ');
    } else if (currentUser.value?.email?.isNotEmpty ?? false) {
      // If no display name, use email without domain and format it
      final username = currentUser.value!.email!.split('@')[0];
      // Convert from formats like "john.doe" or "john_doe" to "John Doe"
      return username
          .replaceAll(RegExp(r'[._-]'), ' ')
          .split(' ')
          .map((word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
          .join(' ');
    }
    return 'Guest User';
  }

  String? get userEmail => currentUser.value?.email;

  String? get userPhotoUrl => currentUser.value?.photoURL;

  bool get isEmailVerified => currentUser.value?.emailVerified ?? false;

  Future<void> loadQuickStats() async {
    try {
      // TODO: Replace with actual API call to fetch real stats
      // This would be connected to your backend service

      // Simulated delay to show loading state
      await Future.delayed(const Duration(milliseconds: 800));

      quickStats.value = {
        'pendingTasks': 8,
        'maintenanceDue': 3,
        'fuelAlerts': 2,
        'routeProgress': 65,
        'mileage': 12435,
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
      // TODO: Replace with actual API call to fetch real activities
      // This would be connected to your backend service

      // Simulated delay to show loading state
      await Future.delayed(const Duration(milliseconds: 1000));

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
          'title': 'Low Fuel Alert',
          'description': 'Vehicle DDU-003 needs refueling',
          'time': DateTime.now().subtract(const Duration(hours: 3)),
          'type': 'fuel',
        },
        {
          'title': 'Vehicle Location Updated',
          'description': 'DDU-002 arrived at destination',
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
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }

  void launchPhoneCall() async {
    final Uri url = Uri.parse('tel:+251911123456');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        Get.snackbar(
          'Error',
          'Could not launch phone call',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to make phone call',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void launchEmail() async {
    final Uri url =
        Uri.parse('mailto:support@ddufleet.com?subject=Support Request');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        Get.snackbar(
          'Error',
          'Could not launch email',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open email',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void openLiveChat() {
    // TODO: Implement live chat functionality
    Get.snackbar(
      'Coming Soon',
      'Live chat support will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
