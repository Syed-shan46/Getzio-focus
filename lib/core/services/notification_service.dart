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

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    const InitializationSettings initializationSettings =
        InitializationSettings(
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
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    }

    _isInitialized = true;
  }

  Future<void> showTestNotification() async {
    if (!_isInitialized) await init();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Channel for local notification testing',
          importance: Importance.max,
          priority: Priority.high,
        );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledTime = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(seconds: 15));

    await _notificationsPlugin.zonedSchedule(
      id: 9999,
      title: 'Getzio Focus',
      body: 'This scheduled notification arrived while the app was closed! 🚀',
      scheduledDate: scheduledTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
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
    final displayTitle = title;
    final displayContext = isSubtask ? ' (Task: $taskTitle)' : '';

    // Resolve the actual deadline DateTime
    DateTime deadline;
    if (dueTime != null) {
      final timeFormat = DateFormat('h:mm a');
      DateTime time;
      try {
        time = timeFormat.parse(dueTime);
      } catch (e) {
        return; // Invalid time format
      }
      deadline = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        time.hour,
        time.minute,
      );
    } else {
      // No specific time — treat end-of-day (11:59 PM) as the deadline
      deadline = DateTime(dueDate.year, dueDate.month, dueDate.day, 23, 59);
    }

    if (deadline.isBefore(now)) return;

    // Build notification schedule based on ReminderStyle
    // Each entry: (Duration before deadline, notification slot index 1-8, title prefix, body)
    final List<_ReminderEntry> reminders = _buildReminders(
      style: style,
      deadline: deadline,
      hasDueTime: dueTime != null,
      displayTitle: displayTitle,
      displayContext: displayContext,
    );

    // Schedule each reminder that's still in the future
    for (final reminder in reminders) {
      final scheduledTime = deadline.subtract(reminder.beforeDeadline);
      if (scheduledTime.isAfter(now)) {
        await _scheduleNotification(
          id: baseId + reminder.slot,
          title: reminder.title,
          body: reminder.body,
          scheduledDate: scheduledTime,
        );
      }
    }
  }

  List<_ReminderEntry> _buildReminders({
    required ReminderStyle style,
    required DateTime deadline,
    required bool hasDueTime,
    required String displayTitle,
    required String displayContext,
  }) {
    final timeStr = hasDueTime ? DateFormat('h:mm a').format(deadline) : null;
    final dateStr = DateFormat('MMM d').format(deadline);

    switch (style) {
      case ReminderStyle.minimal:
        // 1 notification: 30 min before (with time) or morning-of (without time)
        if (hasDueTime) {
          return [
            _ReminderEntry(
              slot: 1,
              beforeDeadline: const Duration(minutes: 30),
              title: '⏰ Heads up: $displayTitle',
              body: 'Due in 30 minutes at $timeStr$displayContext.',
            ),
          ];
        } else {
          // Morning of due date (schedule at 9 AM, i.e. ~15 hours before 11:59 PM)
          final morningOffset = Duration(
            hours: deadline.hour - 9,
            minutes: deadline.minute,
          );
          return [
            _ReminderEntry(
              slot: 1,
              beforeDeadline: morningOffset,
              title: '📋 Today\'s Target',
              body: 'Finish "$displayTitle" today$displayContext.',
            ),
          ];
        }

      case ReminderStyle.balanced:
        // 2-3 notifications: 1 day before + 1 hour before + 15 min before
        final entries = <_ReminderEntry>[];

        // 1 day before at 9 AM
        final oneDayBefore = deadline.subtract(const Duration(days: 1));
        final morning9AM = DateTime(
          oneDayBefore.year,
          oneDayBefore.month,
          oneDayBefore.day,
          9,
          0,
        );
        final dayBeforeOffset = deadline.difference(morning9AM);
        entries.add(
          _ReminderEntry(
            slot: 1,
            beforeDeadline: dayBeforeOffset,
            title: '📌 Due Tomorrow: $displayTitle',
            body:
                'Deadline: ${hasDueTime ? "$timeStr, " : ""}$dateStr$displayContext.',
          ),
        );

        if (hasDueTime) {
          // 1 hour before
          entries.add(
            _ReminderEntry(
              slot: 2,
              beforeDeadline: const Duration(hours: 1),
              title: '⏳ 1 Hour Left: $displayTitle',
              body: 'Due at $timeStr$displayContext.',
            ),
          );
          // 15 min before
          entries.add(
            _ReminderEntry(
              slot: 3,
              beforeDeadline: const Duration(minutes: 15),
              title: '🔥 Almost Due: $displayTitle',
              body: 'Only 15 minutes left! Due at $timeStr$displayContext.',
            ),
          );
        } else {
          // Morning of (9 AM on due date)
          final morningOffset = Duration(
            hours: deadline.hour - 9,
            minutes: deadline.minute,
          );
          entries.add(
            _ReminderEntry(
              slot: 2,
              beforeDeadline: morningOffset,
              title: '📋 Due Today: $displayTitle',
              body: 'This is due today$displayContext. Get it done!',
            ),
          );
          // Afternoon nudge (2 PM on due date)
          final afternoonOffset = Duration(
            hours: deadline.hour - 14,
            minutes: deadline.minute,
          );
          entries.add(
            _ReminderEntry(
              slot: 3,
              beforeDeadline: afternoonOffset,
              title: '⚡ Still Pending: $displayTitle',
              body: 'Due today — don\'t forget$displayContext!',
            ),
          );
        }
        return entries;

      case ReminderStyle.neverMiss:
        // 4-5 notifications: 1 day + morning + 2 hours + 30 min + 10 min
        final entries = <_ReminderEntry>[];

        // 1 day before at 9 AM
        final oneDayBefore = deadline.subtract(const Duration(days: 1));
        final morning9AM = DateTime(
          oneDayBefore.year,
          oneDayBefore.month,
          oneDayBefore.day,
          9,
          0,
        );
        final dayBeforeOffset = deadline.difference(morning9AM);
        entries.add(
          _ReminderEntry(
            slot: 1,
            beforeDeadline: dayBeforeOffset,
            title: '📌 Due Tomorrow: $displayTitle',
            body:
                'Deadline: ${hasDueTime ? "$timeStr, " : ""}$dateStr$displayContext.',
          ),
        );

        if (hasDueTime) {
          // 2 hours before
          entries.add(
            _ReminderEntry(
              slot: 2,
              beforeDeadline: const Duration(hours: 2),
              title: '⏳ 2 Hours Left: $displayTitle',
              body: 'Due at $timeStr$displayContext.',
            ),
          );
          // 30 min before
          entries.add(
            _ReminderEntry(
              slot: 3,
              beforeDeadline: const Duration(minutes: 30),
              title: '⚡ 30 Min Left: $displayTitle',
              body: 'Due at $timeStr$displayContext. Finish it up!',
            ),
          );
          // 10 min before
          entries.add(
            _ReminderEntry(
              slot: 4,
              beforeDeadline: const Duration(minutes: 10),
              title: '🔥 Final Warning: $displayTitle',
              body: 'Due in 10 minutes at $timeStr$displayContext!',
            ),
          );
        } else {
          // Morning of (9 AM on due date)
          final morningOffset = Duration(
            hours: deadline.hour - 9,
            minutes: deadline.minute,
          );
          entries.add(
            _ReminderEntry(
              slot: 2,
              beforeDeadline: morningOffset,
              title: '📋 Due Today: $displayTitle',
              body: 'This is due today$displayContext.',
            ),
          );
          // Midday nudge (12 PM)
          final middayOffset = Duration(
            hours: deadline.hour - 12,
            minutes: deadline.minute,
          );
          entries.add(
            _ReminderEntry(
              slot: 3,
              beforeDeadline: middayOffset,
              title: '⚡ Midday Reminder: $displayTitle',
              body: 'Still pending today$displayContext!',
            ),
          );
          // Evening nudge (6 PM)
          final eveningOffset = Duration(
            hours: deadline.hour - 18,
            minutes: deadline.minute,
          );
          entries.add(
            _ReminderEntry(
              slot: 4,
              beforeDeadline: eveningOffset,
              title: '🔥 Evening Push: $displayTitle',
              body: 'Due today — wrap it up$displayContext!',
            ),
          );
        }
        return entries;

      case ReminderStyle.none:
        return [];
    }
  }

  Future<void> cancelReminders(String id) async {
    if (!_isInitialized) await init();
    final int baseId = (id.hashCode.abs() % 100000) * 10;
    for (int i = 1; i <= 8; i++) {
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
      debugPrint(
        '[Notification] Scheduled "$title" at $scheduledDate (id=$id)',
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }
}

class _ReminderEntry {
  final int slot;
  final Duration beforeDeadline;
  final String title;
  final String body;

  const _ReminderEntry({
    required this.slot,
    required this.beforeDeadline,
    required this.title,
    required this.body,
  });
}
