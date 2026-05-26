import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_reminder.dart';
import 'app_notification_service.dart';
import 'notification_service.dart';

class ReminderService {
  ReminderService._();

  static final ReminderService instance = ReminderService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> _collection() {
    return _firestore.collection('users').doc(_uid).collection('reminders');
  }

  DocumentReference<Map<String, dynamic>> _userDoc() {
    return _firestore.collection('users').doc(_uid);
  }

  Stream<List<AppReminder>> watchReminders() {
    return _collection().orderBy('createdAt').snapshots().map(
        (snapshot) => snapshot.docs.map(AppReminder.fromFirestore).toList());
  }

  Future<String> createReminder(AppReminder reminder) async {
    final doc = await _collection().add(reminder.toFirestore());
    final newReminder = reminder.copyWith(id: doc.id);
    await _trySchedule(newReminder);
    
    // Create in-app notification
    await AppNotificationService.instance.createReminderNotification(
      title: 'Reminder Set: ${newReminder.title}',
      message: 'Scheduled for ${newReminder.time}',
    );
    
    return doc.id;
  }

  Future<void> updateReminder(AppReminder reminder) async {
    await _collection().doc(reminder.id).set(
        reminder.toFirestore(includeCreatedAt: false), SetOptions(merge: true));
    await _trySchedule(reminder);
    
    // Create in-app notification
    await AppNotificationService.instance.createReminderNotification(
      title: 'Reminder Updated: ${reminder.title}',
      message: 'Now set for ${reminder.time}',
    );
  }

  Future<void> setEnabled(String reminderId, bool enabled) async {
    await _collection().doc(reminderId).set(
      {
        'enabled': enabled,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    final snapshot = await _collection().doc(reminderId).get();
    if (snapshot.exists) {
      final reminder =
          AppReminder.fromFirestore(snapshot).copyWith(enabled: enabled);
      if (enabled) {
        await _trySchedule(reminder);
        // Create in-app notification
        await AppNotificationService.instance.createReminderNotification(
          title: 'Reminder Active: ${reminder.title}',
          message: 'Notification scheduled for ${reminder.time}',
        );
      } else {
        await NotificationService.instance.cancel(reminder);
      }
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    final snapshot = await _collection().doc(reminderId).get();
    if (snapshot.exists) {
      await NotificationService.instance
          .cancel(AppReminder.fromFirestore(snapshot));
    }
    await _collection().doc(reminderId).delete();
  }

  Future<void> ensureDefaultReminders() async {
    final userSnapshot = await _userDoc().get();
    final userData = userSnapshot.data();
    if (userData?['remindersSeeded'] == true) {
      await _scheduleEnabledReminders();
      return;
    }

    final existing = await _collection().limit(1).get();
    if (existing.docs.isNotEmpty) {
      await _scheduleEnabledReminders();
    }
    await _userDoc().set(
      {
        'remindersSeeded': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> _scheduleEnabledReminders() async {
    final reminders =
        await _collection().where('enabled', isEqualTo: true).get();
    for (final doc in reminders.docs) {
      await _trySchedule(AppReminder.fromFirestore(doc));
    }
  }

  Future<void> _trySchedule(AppReminder reminder) async {
    try {
      await NotificationService.instance.scheduleDaily(reminder);
    } catch (_) {
      // Keep Firestore reminder changes working even when Android notification
      // permission, exact-alarm permission, or channel setup is unavailable.
    }
  }
}
