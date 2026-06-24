// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinanceGoalAdapter extends TypeAdapter<FinanceGoal> {
  @override
  final int typeId = 23;

  @override
  FinanceGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FinanceGoal(
      id: fields[0] as String,
      title: fields[1] as String,
      targetAmount: fields[2] as double,
      currentAmount: fields[3] as double,
      deadline: fields[4] as DateTime?,
      icon: fields[5] as String,
      colorValue: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FinanceGoal obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.targetAmount)
      ..writeByte(3)
      ..write(obj.currentAmount)
      ..writeByte(4)
      ..write(obj.deadline)
      ..writeByte(5)
      ..write(obj.icon)
      ..writeByte(6)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinanceGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
