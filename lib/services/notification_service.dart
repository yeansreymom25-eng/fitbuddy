import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import '../models/app_reminder.dart';
import 'app_notification_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> initialize() async {
    if (_ready || kIsWeb) {
      return;
    }
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: android);

      tz.initializeTimeZones();
      final timeZone = await FlutterTimezone.getLocalTimezone();
      // Handle both String and TimezoneInfo (some versions return an object)
      final String timeZoneName = timeZone is String ? timeZone : (timeZone as dynamic).name;
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      await _plugin.initialize(settings);

      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();

      _ready = true;
    } catch (e) {
      debugPrint('Notification initialization failed: $e');
    }
  }

  Future<void> showReminder(AppReminder reminder) async {
    if (kIsWeb) return;
    await initialize();
    await _plugin.show(
      reminder.id.hashCode,
      reminder.title,
      '${reminder.time} - ${reminder.note}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fitbuddy_reminders_quiet',
          'FitBuddy reminders',
          channelDescription: 'Meal, water, activity, and sleep reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );

    // Also create an in-app notification
    await AppNotificationService.instance.createReminderNotification(
      title: reminder.title,
      message: reminder.note,
    );
  }

  Future<void> scheduleDaily(AppReminder reminder) async {
    if (kIsWeb) return;
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
          'fitbuddy_reminders_quiet',
          'FitBuddy reminders',
          channelDescription: 'Meal, water, activity, and sleep reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancel(AppReminder reminder) async {
    if (kIsWeb) return;
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
