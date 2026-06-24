// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_milestone.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimelineMilestoneAdapter extends TypeAdapter<TimelineMilestone> {
  @override
  final int typeId = 24;

  @override
  TimelineMilestone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimelineMilestone(
      id: fields[0] as String,
      year: fields[1] as int,
      month: fields[2] as int,
      title: fields[3] as String,
      description: fields[4] as String,
      category: fields[5] as String,
      isCompleted: fields[6] as bool,
      colorValue: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TimelineMilestone obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.year)
      ..writeByte(2)
      ..write(obj.month)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimelineMilestoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
