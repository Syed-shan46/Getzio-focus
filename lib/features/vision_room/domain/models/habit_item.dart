import 'package:hive/hive.dart';

part 'habit_item.g.dart';

@HiveType(typeId: 21)
class HabitItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String emoji;

  @HiveField(3)
  int colorValue;

  @HiveField(4)
  int streak;

  @HiveField(5)
  bool completedToday;

  @HiveField(6)
  String category; // health, mind, body, spirit, work

  @HiveField(7)
  List<String> completedDates; // ISO date strings

  @HiveField(8)
  int targetDaysPerWeek;

  @HiveField(9)
  DateTime createdAt;

  HabitItem({
    required this.id,
    required this.name,
    required this.emoji,
    this.colorValue = 0xFF4DA3FF,
    this.streak = 0,
    this.completedToday = false,
    this.category = 'health',
    List<String>? completedDates,
    this.targetDaysPerWeek = 7,
    DateTime? createdAt,
  })  : completedDates = completedDates ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// Completion rate for the past 21 days (for heatmap)
  double get completionRate {
    final cutoff = DateTime.now().subtract(const Duration(days: 21));
    final recentDays = completedDates.where((d) {
      final date = DateTime.tryParse(d);
      return date != null && date.isAfter(cutoff);
    }).length;
    return (recentDays / 21).clamp(0, 1);
  }

  HabitItem copyWith({int? streak, bool? completedToday, List<String>? completedDates}) {
    return HabitItem(
      id: id,
      name: name,
      emoji: emoji,
      colorValue: colorValue,
      streak: streak ?? this.streak,
      completedToday: completedToday ?? this.completedToday,
      category: category,
      completedDates: completedDates ?? this.completedDates,
      targetDaysPerWeek: targetDaysPerWeek,
      createdAt: createdAt,
    );
  }
}
