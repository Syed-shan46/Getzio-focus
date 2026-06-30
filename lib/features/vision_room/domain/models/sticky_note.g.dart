// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticky_note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StickyNoteAdapter extends TypeAdapter<StickyNote> {
  @override
  final int typeId = 21;

  @override
  StickyNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StickyNote(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String,
      progress: fields[4] as int,
      dueDate: fields[5] as DateTime?,
      priority: fields[6] as String,
      category: fields[7] as String,
      x: fields[8] as double,
      y: fields[9] as double,
      zIndex: fields[10] as int,
      rotation: fields[11] as double,
      scale: fields[12] as double,
      pinStyle: fields[13] as String,
      color: fields[14] as String,
      syncVersion: fields[15] as int,
      deleted: fields[16] as bool,
      pendingSync: fields[17] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StickyNote obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.progress)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.priority)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.x)
      ..writeByte(9)
      ..write(obj.y)
      ..writeByte(10)
      ..write(obj.zIndex)
      ..writeByte(11)
      ..write(obj.rotation)
      ..writeByte(12)
      ..write(obj.scale)
      ..writeByte(13)
      ..write(obj.pinStyle)
      ..writeByte(14)
      ..write(obj.color)
      ..writeByte(15)
      ..write(obj.syncVersion)
      ..writeByte(16)
      ..write(obj.deleted)
      ..writeByte(17)
      ..write(obj.pendingSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StickyNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
