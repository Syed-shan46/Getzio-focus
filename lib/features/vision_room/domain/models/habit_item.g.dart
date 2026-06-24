// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitItemAdapter extends TypeAdapter<HabitItem> {
  @override
  final int typeId = 21;

  @override
  HabitItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitItem(
      id: fields[0] as String,
      name: fields[1] as String,
      emoji: fields[2] as String,
      colorValue: fields[3] as int,
      streak: fields[4] as int,
      completedToday: fields[5] as bool,
      category: fields[6] as String,
      completedDates: (fields[7] as List?)?.cast<String>(),
      targetDaysPerWeek: fields[8] as int,
      createdAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.emoji)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.streak)
      ..writeByte(5)
      ..write(obj.completedToday)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.completedDates)
      ..writeByte(8)
      ..write(obj.targetDaysPerWeek)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
