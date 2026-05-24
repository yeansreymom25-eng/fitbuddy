import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_reminder.dart';
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
    await NotificationService.instance
        .scheduleDaily(reminder.copyWith(id: doc.id));
    return doc.id;
  }

  Future<void> updateReminder(AppReminder reminder) async {
    await _collection().doc(reminder.id).set(
        reminder.toFirestore(includeCreatedAt: false), SetOptions(merge: true));
    await NotificationService.instance.scheduleDaily(reminder);
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
        await NotificationService.instance.scheduleDaily(reminder);
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
      await _userDoc().set(
        {
          'remindersSeeded': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      return;
    }

    final defaults = [
      const AppReminder(
        id: '',
        title: 'Drink Water',
        note: 'Drink a glass of water',
        time: '8 AM',
        category: 'Water',
      ),
      const AppReminder(
        id: '',
        title: 'Drink Water',
        note: 'Drink a glass of water',
        time: '10 AM',
        category: 'Water',
      ),
      const AppReminder(
        id: '',
        title: 'Lunch Time',
        note: 'Eat a healthy and balanced meal',
        time: '11 AM',
        category: 'Nutrition',
      ),
      const AppReminder(
        id: '',
        title: 'Sleep Reminder',
        note: 'Wind down and get ready for bed',
        time: '10:30 PM',
        category: 'Sleep',
      ),
      const AppReminder(
        id: '',
        title: 'Wakeup Reminder',
        note: 'Wake up early for exercise',
        time: '6:30 AM',
        category: 'Sleep',
      ),
      const AppReminder(
        id: '',
        title: 'Activity Time',
        note: 'Time to move your body',
        time: '6 PM',
        category: 'Activity',
      ),
    ];

    final batch = _firestore.batch();
    final scheduled = <AppReminder>[];
    for (final reminder in defaults) {
      final doc = _collection().doc();
      batch.set(doc, reminder.toFirestore());
      scheduled.add(reminder.copyWith(id: doc.id));
    }
    batch.set(
      _userDoc(),
      {
        'remindersSeeded': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
    for (final reminder in scheduled) {
      await NotificationService.instance.scheduleDaily(reminder);
    }
  }

  Future<void> _scheduleEnabledReminders() async {
    final reminders =
        await _collection().where('enabled', isEqualTo: true).get();
    for (final doc in reminders.docs) {
      await NotificationService.instance
          .scheduleDaily(AppReminder.fromFirestore(doc));
    }
  }
}
