import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';

class AppNotificationService {
  AppNotificationService._();

  static final AppNotificationService instance = AppNotificationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _notificationsRef {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('notifications');
  }

  /// Watch all notifications for the current user
  Stream<List<AppNotification>> watchNotifications() {
    final ref = _notificationsRef;
    if (ref == null) {
      return Stream.value([]);
    }

    return ref
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();
    }).handleError((error) {
      debugPrint('Error watching notifications: $error');
      return <AppNotification>[];
    });
  }

  /// Get unread notification count
  Stream<int> watchUnreadCount() {
    final ref = _notificationsRef;
    if (ref == null) {
      return Stream.value(0);
    }

    return ref.where('isRead', isEqualTo: false).snapshots().map((snapshot) {
      return snapshot.docs.length;
    }).handleError((error) {
      debugPrint('Error watching unread count: $error');
      return 0;
    });
  }

  /// Create a new notification
  Future<void> createNotification({
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    final ref = _notificationsRef;
    if (ref == null) return;

    try {
      final notification = AppNotification(
        id: '',
        title: title,
        message: message,
        type: type,
        timestamp: DateTime.now(),
        isRead: false,
        data: data,
      );

      await ref.add(notification.toFirestore());
    } catch (e) {
      debugPrint('Error creating notification: $e');
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    final ref = _notificationsRef;
    if (ref == null) return;

    try {
      await ref.doc(notificationId).update({'isRead': true});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final ref = _notificationsRef;
    if (ref == null) return;

    try {
      final unreadDocs = await ref.where('isRead', isEqualTo: false).get();
      final batch = _firestore.batch();

      for (final doc in unreadDocs.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    final ref = _notificationsRef;
    if (ref == null) return;

    try {
      await ref.doc(notificationId).delete();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    final ref = _notificationsRef;
    if (ref == null) return;

    try {
      final allDocs = await ref.get();
      final batch = _firestore.batch();

      for (final doc in allDocs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing all notifications: $e');
    }
  }

  /// Create a reminder notification
  Future<void> createReminderNotification({
    required String title,
    required String message,
  }) async {
    await createNotification(
      title: title,
      message: message,
      type: NotificationType.reminder,
    );
  }

  /// Create an achievement notification
  Future<void> createAchievementNotification({
    required String title,
    required String message,
  }) async {
    await createNotification(
      title: title,
      message: message,
      type: NotificationType.achievement,
    );
  }

  /// Create a motivation notification
  Future<void> createMotivationNotification({
    required String message,
  }) async {
    await createNotification(
      title: 'Daily Motivation',
      message: message,
      type: NotificationType.motivation,
    );
  }
}
