import 'package:hive/hive.dart';

part 'vision_item.g.dart';

enum VisionItemType { 
  image, stickyNote, quote, goal, plan, task, visionCard, memoryCard, 
  habitCard, countdown, financeGoal, journalEntry, voiceNote, linkPreview, document, decoration 
}

@HiveType(typeId: 20)
class VisionItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // VisionItemType.name

  @HiveField(2)
  String content; // text / image path / url

  @HiveField(3)
  double x;

  @HiveField(4)
  double y;

  @HiveField(5)
  double width;

  @HiveField(6)
  double height;

  @HiveField(7)
  double rotation; // radians

  @HiveField(8)
  int colorValue; // background color

  @HiveField(9)
  bool isPinned;

  @HiveField(10)
  String? emoji;

  @HiveField(11)
  DateTime? countdownDate;

  @HiveField(12)
  String? secondaryContent; // subtitle / category label

  @HiveField(13, defaultValue: 0)
  int zIndex;

  @HiveField(14, defaultValue: 'pin')
  String attachmentType; // 'pin', 'tape', 'none'

  @HiveField(15, defaultValue: 'redPin')
  String attachmentStyle; // 'redPin', 'washiTape', etc.

  @HiveField(16, defaultValue: 'default')
  String materialStyle; // 'polaroid', 'kraft', 'glossy', etc.

  @HiveField(17)
  Map<dynamic, dynamic>? metadata; // Generic storage for widgets

  VisionItem({
    required this.id,
    required this.type,
    required this.content,
    this.x = 0,
    this.y = 0,
    this.width = 180,
    this.height = 120,
    this.rotation = 0,
    this.colorValue = 0xFF1E1B4B,
    this.isPinned = false,
    this.emoji,
    this.countdownDate,
    this.secondaryContent,
    this.zIndex = 0,
    this.attachmentType = 'pin',
    this.attachmentStyle = 'redPin',
    this.materialStyle = 'default',
    this.metadata,
  });

  VisionItem copyWith({
    String? id,
    String? content,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    bool? isPinned,
    int? zIndex,
    String? attachmentType,
    String? attachmentStyle,
    String? materialStyle,
    Map<dynamic, dynamic>? metadata,
  }) {
    return VisionItem(
      id: id ?? this.id,
      type: type,
      content: content ?? this.content,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      colorValue: colorValue,
      isPinned: isPinned ?? this.isPinned,
      emoji: emoji,
      countdownDate: countdownDate,
      secondaryContent: secondaryContent,
      zIndex: zIndex ?? this.zIndex,
      attachmentType: attachmentType ?? this.attachmentType,
      attachmentStyle: attachmentStyle ?? this.attachmentStyle,
      materialStyle: materialStyle ?? this.materialStyle,
      metadata: metadata ?? this.metadata,
    );
  }
}
