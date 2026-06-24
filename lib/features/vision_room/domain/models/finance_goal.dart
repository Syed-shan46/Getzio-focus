import 'package:hive/hive.dart';

part 'finance_goal.g.dart';

@HiveType(typeId: 23)
class FinanceGoal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double targetAmount;

  @HiveField(3)
  double currentAmount;

  @HiveField(4)
  DateTime? deadline;

  @HiveField(5)
  String icon;

  @HiveField(6)
  int colorValue;

  FinanceGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    this.icon = '💰',
    this.colorValue = 0xFF2CE38C, // Emerald
  });

  double get progress => (currentAmount / targetAmount).clamp(0.0, 1.0);

  FinanceGoal copyWith({double? currentAmount}) {
    return FinanceGoal(
      id: id,
      title: title,
      targetAmount: targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline,
      icon: icon,
      colorValue: colorValue,
    );
  }
}
