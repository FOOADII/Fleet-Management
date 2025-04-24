import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';

class NotificationsService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  Future<List<NotificationModel>> getNotifications() async {
    try {
      if (_userId == null) {
        print('No user logged in');
        return [];
      }

      QuerySnapshot querySnapshot;
      try {
        // Try with ordering first
        querySnapshot = await _firestore
            .collection('notifications')
            .where('userId', isEqualTo: _userId)
            .orderBy('timestamp', descending: true)
            .get();
      } catch (e) {
        if (e is FirebaseException && e.code == 'failed-precondition') {
          // If index doesn't exist, fetch without ordering
          print('Index not ready, fetching without ordering');
          querySnapshot = await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: _userId)
              .get();
        } else {
          rethrow;
        }
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = data['timestamp'];
        return NotificationModel.fromJson({
          'id': doc.id,
          ...data,
          'timestamp': timestamp != null
              ? (timestamp as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
        });
      }).toList()
        ..sort((a, b) =>
            b.timestamp.compareTo(a.timestamp)); // Sort in memory if needed
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      if (_userId == null) {
        print('No user logged in');
        return;
      }

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
      throw e;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      if (_userId == null) {
        print('No user logged in');
        return;
      }

      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: _userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      throw e;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      if (_userId == null) {
        print('No user logged in');
        return;
      }

      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
      throw e;
    }
  }

  Future<void> createNotification({
    required String title,
    required String message,
    required String type,
    required String referenceId,
  }) async {
    try {
      if (_userId == null) {
        print('No user logged in');
        return;
      }

      await _firestore.collection('notifications').add({
        'userId': _userId,
        'title': title,
        'message': message,
        'type': type,
        'referenceId': referenceId,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      print('Error creating notification: $e');
      throw e;
    }
  }
}
