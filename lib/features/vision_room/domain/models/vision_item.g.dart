// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vision_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VisionItemAdapter extends TypeAdapter<VisionItem> {
  @override
  final int typeId = 20;

  @override
  VisionItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VisionItem(
      id: fields[0] as String,
      type: fields[1] as String,
      content: fields[2] as String,
      x: fields[3] as double,
      y: fields[4] as double,
      width: fields[5] as double,
      height: fields[6] as double,
      rotation: fields[7] as double,
      colorValue: fields[8] as int,
      isPinned: fields[9] as bool,
      emoji: fields[10] as String?,
      countdownDate: fields[11] as DateTime?,
      secondaryContent: fields[12] as String?,
      zIndex: fields[13] == null ? 0 : fields[13] as int,
      attachmentType: fields[14] == null ? 'pin' : fields[14] as String,
      attachmentStyle: fields[15] == null ? 'redPin' : fields[15] as String,
      materialStyle: fields[16] == null ? 'default' : fields[16] as String,
      metadata: (fields[17] as Map?)?.cast<dynamic, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, VisionItem obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.x)
      ..writeByte(4)
      ..write(obj.y)
      ..writeByte(5)
      ..write(obj.width)
      ..writeByte(6)
      ..write(obj.height)
      ..writeByte(7)
      ..write(obj.rotation)
      ..writeByte(8)
      ..write(obj.colorValue)
      ..writeByte(9)
      ..write(obj.isPinned)
      ..writeByte(10)
      ..write(obj.emoji)
      ..writeByte(11)
      ..write(obj.countdownDate)
      ..writeByte(12)
      ..write(obj.secondaryContent)
      ..writeByte(13)
      ..write(obj.zIndex)
      ..writeByte(14)
      ..write(obj.attachmentType)
      ..writeByte(15)
      ..write(obj.attachmentStyle)
      ..writeByte(16)
      ..write(obj.materialStyle)
      ..writeByte(17)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisionItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
