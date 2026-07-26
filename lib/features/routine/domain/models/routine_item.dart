class RoutineItem {
  final String id;
  final String title;
  final String? subtitle;
  final List<String> completedDates; // List of 'yyyy-MM-dd' strings
  final DateTime createdAt;

  RoutineItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.completedDates,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'completedDates': completedDates,
    'createdAt': createdAt.toIso8601String(),
  };

  factory RoutineItem.fromMap(Map<String, dynamic> map) => RoutineItem(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    subtitle: map['subtitle'],
    completedDates: List<String>.from(map['completedDates'] ?? []),
    createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
  );

  RoutineItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    List<String>? completedDates,
    DateTime? createdAt,
  }) => RoutineItem(
    id: id ?? this.id,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    completedDates: completedDates ?? this.completedDates,
    createdAt: createdAt ?? this.createdAt,
  );
}
