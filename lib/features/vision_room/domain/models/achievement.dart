import 'package:hive/hive.dart';

part 'achievement.g.dart';

enum AchievementTier { common, rare, epic, legendary }

@HiveType(typeId: 22)
class Achievement extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String icon;

  @HiveField(4)
  bool isUnlocked;

  @HiveField(5)
  DateTime? unlockedAt;

  @HiveField(6)
  int tierIndex;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
    this.tierIndex = 0,
  });

  AchievementTier get tier => AchievementTier.values[tierIndex];

  Achievement copyWith({bool? isUnlocked, DateTime? unlockedAt}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      tierIndex: tierIndex,
    );
  }
}
