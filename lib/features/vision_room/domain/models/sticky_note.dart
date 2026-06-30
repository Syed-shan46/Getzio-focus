import 'package:hive/hive.dart';

part 'sticky_note.g.dart';

@HiveType(typeId: 21) // Assuming 21 is free, 20 is used by VisionItem
class StickyNote extends HiveObject {
  @HiveField(0)
  String id; // Will map to _id in MongoDB

  @HiveField(1)
  String userId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String description;

  @HiveField(4)
  int progress; // 0-100

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  String priority; // 'Low', 'Medium', 'High'

  @HiveField(7)
  String category;

  @HiveField(8)
  double x;

  @HiveField(9)
  double y;

  @HiveField(10)
  int zIndex;

  @HiveField(11)
  double rotation;

  @HiveField(12)
  double scale;

  @HiveField(13)
  String pinStyle;

  @HiveField(14)
  String color;

  @HiveField(15)
  int syncVersion;

  @HiveField(16)
  bool deleted;

  @HiveField(17)
  bool pendingSync; // Local only, to mark if it needs syncing

  StickyNote({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.progress = 0,
    this.dueDate,
    this.priority = 'Low',
    this.category = 'Personal',
    this.x = 0.0,
    this.y = 0.0,
    this.zIndex = 0,
    this.rotation = 0.0,
    this.scale = 1.0,
    this.pinStyle = 'default',
    this.color = '#FFFFFF',
    this.syncVersion = 1,
    this.deleted = false,
    this.pendingSync = false,
  });

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': userId,
        'title': title,
        'description': description,
        'progress': progress,
        'dueDate': dueDate?.toIso8601String(),
        'priority': priority,
        'category': category,
        'position': {
          'x': x,
          'y': y,
          'zIndex': zIndex,
        },
        'rotation': rotation,
        'scale': scale,
        'pinStyle': pinStyle,
        'color': color,
        'syncVersion': syncVersion,
        'deleted': deleted,
      };

  factory StickyNote.fromJson(Map<String, dynamic> json) => StickyNote(
        id: json['_id'] ?? json['id'] ?? '',
        userId: json['userId'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        progress: json['progress'] ?? 0,
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        priority: json['priority'] ?? 'Low',
        category: json['category'] ?? 'Personal',
        x: (json['position']?['x'] as num?)?.toDouble() ?? 0.0,
        y: (json['position']?['y'] as num?)?.toDouble() ?? 0.0,
        zIndex: json['position']?['zIndex'] ?? 0,
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
        scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
        pinStyle: json['pinStyle'] ?? 'default',
        color: json['color'] ?? '#FFFFFF',
        syncVersion: json['syncVersion'] ?? 1,
        deleted: json['deleted'] ?? false,
        pendingSync: false, // from server, so not pending
      );

  StickyNote copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    int? progress,
    DateTime? dueDate,
    String? priority,
    String? category,
    double? x,
    double? y,
    int? zIndex,
    double? rotation,
    double? scale,
    String? pinStyle,
    String? color,
    int? syncVersion,
    bool? deleted,
    bool? pendingSync,
  }) {
    return StickyNote(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      x: x ?? this.x,
      y: y ?? this.y,
      zIndex: zIndex ?? this.zIndex,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      pinStyle: pinStyle ?? this.pinStyle,
      color: color ?? this.color,
      syncVersion: syncVersion ?? this.syncVersion,
      deleted: deleted ?? this.deleted,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }
}
