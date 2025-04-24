import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../services/notifications_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsController extends GetxController {
  final NotificationsService _notificationsService =
      Get.find<NotificationsService>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxBool isLoading = false.obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (_auth.currentUser != null) {
      loadNotifications();
    }
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadNotifications();
      } else {
        notifications.clear();
        unreadCount.value = 0;
      }
    });
  }

  Future<void> loadNotifications() async {
    if (_auth.currentUser == null) {
      print('No user logged in');
      return;
    }

    isLoading.value = true;
    try {
      final notificationsList = await _notificationsService.getNotifications();
      notifications.value = notificationsList;
      _updateUnreadCount();
    } catch (e) {
      print('Error loading notifications: $e');
      Get.snackbar(
        'Error',
        'Failed to load notifications',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAllAsRead() async {
    if (_auth.currentUser == null) {
      print('No user logged in');
      return;
    }

    try {
      await _notificationsService.markAllAsRead();
      await loadNotifications();
    } catch (e) {
      print('Error marking all as read: $e');
      Get.snackbar(
        'Error',
        'Failed to mark notifications as read',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteNotification(String? id) async {
    if (id == null) {
      print('Notification ID is null');
      return;
    }

    if (_auth.currentUser == null) {
      print('No user logged in');
      return;
    }

    try {
      await _notificationsService.deleteNotification(id);
      notifications.removeWhere((notification) => notification.id == id);
      _updateUnreadCount();
    } catch (e) {
      print('Error deleting notification: $e');
      Get.snackbar(
        'Error',
        'Failed to delete notification',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> handleNotificationTap(NotificationModel? notification) async {
    if (notification == null) {
      print('Notification is null');
      return;
    }

    if (_auth.currentUser == null) {
      print('No user logged in');
      return;
    }

    try {
      if (!notification.isRead) {
        await _notificationsService.markAsRead(notification.id);
        await loadNotifications();
      }

      // Navigate based on notification type
      switch (notification.type) {
        case 'task':
          if (notification.referenceId.isNotEmpty) {
            Get.toNamed('/tasks/${notification.referenceId}');
          } else {
            Get.toNamed('/tasks');
          }
          break;
        case 'maintenance':
          if (notification.referenceId.isNotEmpty) {
            Get.toNamed('/maintenance/${notification.referenceId}');
          } else {
            Get.toNamed('/maintenance');
          }
          break;
        case 'fuel':
          if (notification.referenceId.isNotEmpty) {
            Get.toNamed('/fuel/${notification.referenceId}');
          } else {
            Get.toNamed('/fuel');
          }
          break;
        case 'alert':
          if (notification.referenceId.isNotEmpty) {
            Get.toNamed('/alerts/${notification.referenceId}');
          } else {
            Get.toNamed('/alerts');
          }
          break;
        default:
          print('Unknown notification type: ${notification.type}');
      }
    } catch (e) {
      print('Error handling notification tap: $e');
      Get.snackbar(
        'Error',
        'Failed to process notification',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
