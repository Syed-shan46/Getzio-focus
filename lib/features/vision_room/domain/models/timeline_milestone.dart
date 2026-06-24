import 'package:hive/hive.dart';

part 'timeline_milestone.g.dart';

@HiveType(typeId: 24)
class TimelineMilestone extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int year;

  @HiveField(2)
  int month;

  @HiveField(3)
  String title;

  @HiveField(4)
  String description;

  @HiveField(5)
  String category; // career, personal, travel, finance

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  int colorValue;

  TimelineMilestone({
    required this.id,
    required this.year,
    required this.month,
    required this.title,
    this.description = '',
    this.category = 'personal',
    this.isCompleted = false,
    this.colorValue = 0xFF4DA3FF,
  });

  TimelineMilestone copyWith({bool? isCompleted}) {
    return TimelineMilestone(
      id: id,
      year: year,
      month: month,
      title: title,
      description: description,
      category: category,
      isCompleted: isCompleted ?? this.isCompleted,
      colorValue: colorValue,
    );
  }
}
