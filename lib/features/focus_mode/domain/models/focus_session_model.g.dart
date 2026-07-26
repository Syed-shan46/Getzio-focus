// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FocusSessionModelAdapter extends TypeAdapter<FocusSessionModel> {
  @override
  final int typeId = 10;

  @override
  FocusSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FocusSessionModel(
      id: fields[0] as String,
      mode: fields[1] as String,
      startTime: fields[2] as DateTime,
      endTime: fields[3] as DateTime?,
      duration: fields[4] as int,
      remainingSeconds: fields[5] as int,
      completed: fields[6] as bool,
      interrupted: fields[7] as bool,
      isRunning: fields[8] as bool,
      isPaused: fields[9] as bool,
      sessionTitle: fields[10] as String,
      date: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FocusSessionModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.mode)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.remainingSeconds)
      ..writeByte(6)
      ..write(obj.completed)
      ..writeByte(7)
      ..write(obj.interrupted)
      ..writeByte(8)
      ..write(obj.isRunning)
      ..writeByte(9)
      ..write(obj.isPaused)
      ..writeByte(10)
      ..write(obj.sessionTitle)
      ..writeByte(11)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
