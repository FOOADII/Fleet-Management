import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.type,
  });

  factory Notification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Notification(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      type: data['type'] ?? 'info',
    );
  }
}

class NotificationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Notification> notifications = <Notification>[].obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final userId = 'current-user-id'; // TODO: Get actual user ID
      final organizationId = 'ddu-fleet'; // TODO: Get actual organization ID

      _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        notifications.value = snapshot.docs
            .map((doc) => Notification.fromFirestore(doc))
            .toList();
        unreadCount.value = notifications.where((n) => !n.isRead).length;
      });
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final organizationId = 'ddu-fleet'; // TODO: Get actual organization ID
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final organizationId = 'ddu-fleet'; // TODO: Get actual organization ID
      final batch = _firestore.batch();
      final unreadNotifications = notifications.where((n) => !n.isRead);

      for (final notification in unreadNotifications) {
        final ref = _firestore
            .collection('organizations')
            .doc(organizationId)
            .collection('notifications')
            .doc(notification.id);
        batch.update(ref, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  Future<void> createNotification({
    required String title,
    required String message,
    required String type,
    String? userId,
  }) async {
    try {
      final organizationId = 'ddu-fleet'; // TODO: Get actual organization ID
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('notifications')
          .add({
        'title': title,
        'message': message,
        'type': type,
        'userId': userId ?? 'all',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      print('Error creating notification: $e');
    }
  }
}
