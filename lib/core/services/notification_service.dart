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

      // Exactly 30 minutes before target time
      final thirtyMinsBefore = targetTime.subtract(const Duration(minutes: 30));
      if (thirtyMinsBefore.isAfter(now)) {
        await _scheduleNotification(
          id: baseId + 1,
          title: 'Upcoming: $displayTitle',
          body: 'Starts in 30 minutes$displayContext.',
          scheduledDate: thirtyMinsBefore,
        );
      }
    } else {
      // Only Due Date Exists (No Time) -> Schedule at 9:00 AM on due date
      final morningTime = DateTime(dueDate.year, dueDate.month, dueDate.day, 9, 0); // 9:00 AM
      if (morningTime.isAfter(now)) {
        await _scheduleNotification(
          id: baseId + 1,
          title: 'Today\'s Target',
          body: 'Finish "$displayTitle"$displayContext.',
          scheduledDate: morningTime,
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
    try {
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
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }
}
