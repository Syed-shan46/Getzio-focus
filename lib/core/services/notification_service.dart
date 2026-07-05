import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../features/tasks/domain/models/task_model.dart'; // For ReminderStyle

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification clicked: ${details.payload}');
      },
    );

    if (!kIsWeb && Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }
    }

    _isInitialized = true;
  }

  Future<void> scheduleItemReminder({
    required String id,
    required String title,
    String? taskTitle,
    required DateTime? dueDate,
    required String? dueTime,
    required ReminderStyle? style,
  }) async {
    if (!_isInitialized) await init();
    
    // Always cancel existing before scheduling new ones
    await cancelReminders(id);

    if (style == null || style == ReminderStyle.none || dueDate == null) return;

    final now = DateTime.now();
    final int baseId = (id.hashCode.abs() % 100000) * 10;
    
    final isSubtask = taskTitle != null;
    final displayTitle = isSubtask ? title : title;
    final displayContext = isSubtask ? ' (Task: $taskTitle)' : '';

    if (dueTime != null) {
      // Due Date + Due Time logic
      final timeFormat = DateFormat('h:mm a');
      DateTime time;
      try {
        time = timeFormat.parse(dueTime);
      } catch (e) {
        return; // Invalid time format
      }
      
      final targetTime = DateTime(dueDate.year, dueDate.month, dueDate.day, time.hour, time.minute);
      if (targetTime.isBefore(now)) return;

      // 1 hour before (Never Miss only)
      if (style == ReminderStyle.neverMiss) {
        final oneHourBefore = targetTime.subtract(const Duration(hours: 1));
        if (oneHourBefore.isAfter(now)) {
          await _scheduleNotification(
            id: baseId + 1,
            title: 'Upcoming: $displayTitle',
            body: 'Starts in 1 hour$displayContext.',
            scheduledDate: oneHourBefore,
          );
        }
      }

      // 30 mins before (Balanced & Never Miss)
      if (style == ReminderStyle.balanced || style == ReminderStyle.neverMiss) {
        final thirtyMinsBefore = targetTime.subtract(const Duration(minutes: 30));
        if (thirtyMinsBefore.isAfter(now)) {
          await _scheduleNotification(
            id: baseId + 2,
            title: 'Upcoming: $displayTitle',
            body: 'Starts in 30 minutes$displayContext.',
            scheduledDate: thirtyMinsBefore,
          );
        }
      }

      // Exact Due Time (Minimal, Balanced, Never Miss)
      await _scheduleNotification(
        id: baseId + 3,
        title: isSubtask ? 'Subtask Due' : 'Task Due',
        body: 'It\'s time to work on "$displayTitle".$displayContext',
        scheduledDate: targetTime,
      );

      // Overdue (30 mins after) - (Balanced, Never Miss)
      if (style == ReminderStyle.balanced || style == ReminderStyle.neverMiss) {
        final overdueTime = targetTime.add(const Duration(minutes: 30));
        await _scheduleNotification(
          id: baseId + 4,
          title: 'Overdue: $displayTitle',
          body: 'Your ${isSubtask ? 'subtask' : 'task'} is overdue. Finish it to keep your momentum!',
          scheduledDate: overdueTime,
        );
      }

    } else {
      // Only Due Date Exists (No Time)
      final morningTime = DateTime(dueDate.year, dueDate.month, dueDate.day, 9, 0); // 9:00 AM
      final eveningTime = DateTime(dueDate.year, dueDate.month, dueDate.day, 18, 0); // 6:00 PM
      
      if (morningTime.isAfter(now)) {
        await _scheduleNotification(
          id: baseId + 1,
          title: 'Today\'s Target',
          body: 'Finish "$displayTitle"$displayContext.',
          scheduledDate: morningTime,
        );
      } else if (eveningTime.isAfter(now)) {
        // If morning passed but evening hasn't, just schedule evening if incomplete
        await _scheduleNotification(
          id: baseId + 2,
          title: 'Evening Check-in',
          body: 'Don\'t forget to finish "$displayTitle"$displayContext.',
          scheduledDate: eveningTime,
        );
      }
    }
  }

  Future<void> cancelReminders(String id) async {
    if (!_isInitialized) await init();
    final int baseId = (id.hashCode.abs() % 100000) * 10;
    for (int i = 1; i <= 4; i++) {
      await _notificationsPlugin.cancel(id: baseId + i);
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'tasks_channel',
          'Task Reminders',
          channelDescription: 'Notifications for tasks and subtasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
