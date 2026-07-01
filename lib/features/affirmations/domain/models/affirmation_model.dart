import 'package:uuid/uuid.dart';

enum SyncStatus { synced, pending, failed }

class DailyAffirmation {
  final String id;
  final String title;
  final String text; // Affirmation content
  final String? author;
  final String category;
  final String colorTheme;
  final bool isPinned;
  final bool isFavorite;
  final String? emoji;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SyncStatus syncStatus;

  DailyAffirmation({
    required this.id,
    this.title = 'Affirmation',
    required this.text,
    this.author,
    this.category = 'General',
    this.colorTheme = 'Warm Amber',
    this.isPinned = false,
    this.isFavorite = false,
    this.emoji,
    this.createdAt,
    this.updatedAt,
    this.syncStatus = SyncStatus.synced,
  });

  DailyAffirmation copyWith({
    String? id,
    String? title,
    String? text,
    String? author,
    String? category,
    String? colorTheme,
    bool? isPinned,
    bool? isFavorite,
    String? emoji,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return DailyAffirmation(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      author: author ?? this.author,
      category: category ?? this.category,
      colorTheme: colorTheme ?? this.colorTheme,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'text': text,
        'author': author,
        'category': category,
        'colorTheme': colorTheme,
        'isPinned': isPinned,
        'isFavorite': isFavorite,
        'emoji': emoji,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'syncStatus': syncStatus.name,
      };

  factory DailyAffirmation.fromMap(Map<String, dynamic> map) => DailyAffirmation(
        id: map['id'] ?? (map['_id'] ?? const Uuid().v4()),
        title: map['title'] ?? 'Affirmation',
        text: map['text'] ?? '',
        author: map['author'],
        category: map['category'] ?? 'General',
        colorTheme: map['colorTheme'] ?? map['theme'] ?? 'Warm Amber',
        isPinned: map['isPinned'] ?? map['pinned'] ?? false,
        isFavorite: map['isFavorite'] ?? map['favorite'] ?? false,
        emoji: map['emoji'],
        createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
        updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
        syncStatus: map['syncStatus'] != null
            ? SyncStatus.values.firstWhere((e) => e.name == map['syncStatus'], orElse: () => SyncStatus.synced)
            : SyncStatus.synced,
      );
}

class AffirmationCategoryGroup {
  final String id;
  final String category;
  final String icon;
  final String color;
  final bool pinned;
  final bool archived;
  final int order;
  final List<DailyAffirmation> affirmations;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AffirmationCategoryGroup({
    required this.id,
    required this.category,
    this.icon = '✨',
    this.color = 'Minimal White',
    this.pinned = false,
    this.archived = false,
    this.order = 0,
    required this.affirmations,
    this.createdAt,
    this.updatedAt,
  });

  AffirmationCategoryGroup copyWith({
    String? id,
    String? category,
    String? icon,
    String? color,
    bool? pinned,
    bool? archived,
    int? order,
    List<DailyAffirmation>? affirmations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AffirmationCategoryGroup(
      id: id ?? this.id,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      order: order ?? this.order,
      affirmations: affirmations ?? this.affirmations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category,
        'icon': icon,
        'color': color,
        'pinned': pinned,
        'archived': archived,
        'order': order,
        'affirmations': affirmations.map((x) => x.toMap()).toList(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory AffirmationCategoryGroup.fromMap(Map<String, dynamic> map) =>
      AffirmationCategoryGroup(
        id: map['id'] ?? map['_id'] ?? const Uuid().v4(),
        category: map['category'] ?? 'General',
        icon: map['icon'] ?? '✨',
        color: map['color'] ?? 'Minimal White',
        pinned: map['pinned'] ?? false,
        archived: map['archived'] ?? false,
        order: map['order'] ?? 0,
        affirmations: map['affirmations'] != null
            ? List<DailyAffirmation>.from(
                map['affirmations'].map((x) => DailyAffirmation.fromMap(x)))
            : [],
        createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
        updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
      );
}
