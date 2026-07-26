import 'package:hive/hive.dart';

part 'focus_session_model.g.dart';

@HiveType(typeId: 10) // Ensure typeId is unique
class FocusSessionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String mode; // e.g. Pomodoro, Deep Work, Reading, Study, Custom

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  final DateTime? endTime;

  @HiveField(4)
  final int duration; // total duration in seconds

  @HiveField(5)
  int remainingSeconds;

  @HiveField(6)
  bool completed;

  @HiveField(7)
  bool interrupted;

  @HiveField(8)
  bool isRunning;

  @HiveField(9)
  bool isPaused;

  @HiveField(10)
  final String sessionTitle;

  @HiveField(11)
  final DateTime date;

  FocusSessionModel({
    required this.id,
    required this.mode,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.remainingSeconds,
    this.completed = false,
    this.interrupted = false,
    this.isRunning = false,
    this.isPaused = false,
    this.sessionTitle = 'Focus Session',
    required this.date,
  });

  FocusSessionModel copyWith({
    String? id,
    String? mode,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    int? remainingSeconds,
    bool? completed,
    bool? interrupted,
    bool? isRunning,
    bool? isPaused,
    String? sessionTitle,
    DateTime? date,
  }) {
    return FocusSessionModel(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      completed: completed ?? this.completed,
      interrupted: interrupted ?? this.interrupted,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      sessionTitle: sessionTitle ?? this.sessionTitle,
      date: date ?? this.date,
    );
  }
}
