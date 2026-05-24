import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/app_reminder.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> initialize() async {
    if (_ready) {
      return;
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    tz.initializeTimeZones();
    await _plugin.initialize(settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _ready = true;
  }

  Future<void> showReminder(AppReminder reminder) async {
    await initialize();
    await _plugin.show(
      reminder.id.hashCode,
      reminder.title,
      '${reminder.time} - ${reminder.note}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fitbuddy_reminders',
          'FitBuddy reminders',
          channelDescription: 'Meal, water, activity, and sleep reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> scheduleDaily(AppReminder reminder) async {
    await initialize();
    if (!reminder.enabled) {
      await cancel(reminder);
      return;
    }
    await _plugin.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.note,
      _nextReminderTime(reminder.time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fitbuddy_reminders',
          'FitBuddy reminders',
          channelDescription: 'Meal, water, activity, and sleep reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancel(AppReminder reminder) async {
    await _plugin.cancel(reminder.id.hashCode);
  }

  tz.TZDateTime _nextReminderTime(String label) {
    final now = tz.TZDateTime.now(tz.local);
    final parsed =
        RegExp(r'^(\d{1,2})(?::(\d{2}))?\s*(AM|PM)?$', caseSensitive: false)
            .firstMatch(label.trim());
    var hour = int.tryParse(parsed?.group(1) ?? '') ?? 8;
    final minute = int.tryParse(parsed?.group(2) ?? '0') ?? 0;
    final period = parsed?.group(3)?.toUpperCase();
    if (period == 'PM' && hour < 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
