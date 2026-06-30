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
    this.attachmentType = 'tape',
    this.attachmentStyle = 'beige',
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
    int? colorValue,
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
      colorValue: colorValue ?? this.colorValue,
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'content': content,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'rotation': rotation,
        'colorValue': colorValue,
        'isPinned': isPinned,
        'emoji': emoji,
        'countdownDate': countdownDate?.toIso8601String(),
        'secondaryContent': secondaryContent,
        'zIndex': zIndex,
        'attachmentType': attachmentType,
        'attachmentStyle': attachmentStyle,
        'materialStyle': materialStyle,
        'metadata': metadata,
      };

  factory VisionItem.fromJson(Map<String, dynamic> json) => VisionItem(
        id: json['id'] ?? '',
        type: json['type'] ?? '',
        content: json['content'] ?? '',
        x: (json['x'] as num?)?.toDouble() ?? 0.0,
        y: (json['y'] as num?)?.toDouble() ?? 0.0,
        width: (json['width'] as num?)?.toDouble() ?? 180.0,
        height: (json['height'] as num?)?.toDouble() ?? 120.0,
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
        colorValue: json['colorValue'] ?? 0xFF1E1B4B,
        isPinned: json['isPinned'] ?? false,
        emoji: json['emoji'],
        countdownDate: json['countdownDate'] != null ? DateTime.parse(json['countdownDate']) : null,
        secondaryContent: json['secondaryContent'],
        zIndex: json['zIndex'] ?? 0,
        attachmentType: json['attachmentType'] ?? 'pin',
        attachmentStyle: json['attachmentStyle'] ?? 'redPin',
        materialStyle: json['materialStyle'] ?? 'default',
        metadata: json['metadata'],
      );
}
