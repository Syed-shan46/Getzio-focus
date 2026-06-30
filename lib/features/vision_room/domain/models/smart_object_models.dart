import 'dart:math';
import 'vision_item.dart';

/// Represents a universal checklist item inside any Smart Object.
class SmartChecklistItem {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? completionDate;

  const SmartChecklistItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completionDate,
  });

  SmartChecklistItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? completionDate,
  }) {
    return SmartChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completionDate: completionDate ?? this.completionDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'completionDate': completionDate?.toIso8601String(),
      };

  factory SmartChecklistItem.fromJson(Map<String, dynamic> json) =>
      SmartChecklistItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        isCompleted: json['isCompleted'] ?? false,
        completionDate: json['completionDate'] != null
            ? DateTime.tryParse(json['completionDate'])
            : null,
      );
}

/// Represents a milestone inside Goals, Roadmaps, Plans, Images, etc.
class SmartMilestone {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? completionDate;
  final List<SmartChecklistItem> tasks;

  const SmartMilestone({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.completionDate,
    this.tasks = const [],
  });

  SmartMilestone copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completionDate,
    List<SmartChecklistItem>? tasks,
  }) {
    return SmartMilestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      completionDate: completionDate ?? this.completionDate,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'completionDate': completionDate?.toIso8601String(),
        'tasks': tasks.map((t) => t.toJson()).toList(),
      };

  factory SmartMilestone.fromJson(Map<String, dynamic> json) => SmartMilestone(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        isCompleted: json['isCompleted'] ?? false,
        completionDate: json['completionDate'] != null
            ? DateTime.tryParse(json['completionDate'])
            : null,
        tasks: (json['tasks'] as List<dynamic>?)
                ?.map((t) => SmartChecklistItem.fromJson(t))
                .toList() ??
            const [],
      );
}

/// Universal Progress Engine: Shared by all Vision Room Smart Objects.
class ProgressEngine {
  /// Calculates the progress ratio (0.0 to 1.0) dynamically from object metadata.
  static double calculateProgress(VisionItem item) {
    final metadata = item.metadata ?? {};

    // 1. Finance Goal progress
    if (item.type == VisionItemType.financeGoal.name) {
      final target = (metadata['targetAmount'] as num?)?.toDouble() ?? 1000.0;
      final current = (metadata['currentAmount'] as num?)?.toDouble() ?? 0.0;
      if (target <= 0) return 0.0;
      return (current / target).clamp(0.0, 1.0);
    }

    // 2. Countdown progress
    if (item.type == VisionItemType.countdown.name) {
      final targetStr = metadata['targetDate'] as String?;
      final targetDate = targetStr != null
          ? DateTime.tryParse(targetStr) ?? item.countdownDate
          : item.countdownDate;
      if (targetDate == null) return 0.0;
      final totalDays = (metadata['totalDays'] as num?)?.toDouble() ?? 30.0;
      final remaining = targetDate.difference(DateTime.now()).inDays.toDouble();
      if (totalDays <= 0) return 0.0;
      final elapsed = totalDays - max(0.0, remaining);
      return (elapsed / totalDays).clamp(0.0, 1.0);
    }

    // 3. Checklists & Milestones calculation
    final checklistRaw = metadata['checklist'] as List<dynamic>?;
    final milestonesRaw = metadata['milestones'] as List<dynamic>?;

    final checklists = checklistRaw
            ?.map((c) => SmartChecklistItem.fromJson(Map<String, dynamic>.from(c)))
            .toList() ??
        [];

    final milestones = milestonesRaw
            ?.map((m) => SmartMilestone.fromJson(Map<String, dynamic>.from(m)))
            .toList() ??
        [];

    int totalUnits = 0;
    int completedUnits = 0;

    if (checklists.isNotEmpty) {
      totalUnits += checklists.length;
      completedUnits += checklists.where((c) => c.isCompleted).length;
    }

    if (milestones.isNotEmpty) {
      totalUnits += milestones.length;
      completedUnits += milestones.where((m) => m.isCompleted).length;
      for (final m in milestones) {
        if (m.tasks.isNotEmpty) {
          totalUnits += m.tasks.length;
          completedUnits += m.tasks.where((t) => t.isCompleted).length;
        }
      }
    }

    if (totalUnits > 0) {
      return (completedUnits / totalUnits).clamp(0.0, 1.0);
    }

    // Default stored progress override if available (stored as 0-100, normalize to 0.0-1.0)
    final storedProgress = (metadata['progress'] as num?)?.toDouble() ?? 0.0;
    return (storedProgress / 100.0).clamp(0.0, 1.0);
  }

  /// Returns progress as a percentage integer (0 to 100).
  static int getPercentage(VisionItem item) {
    return (calculateProgress(item) * 100).round();
  }
}

/// Helper extension on VisionItem for seamless Smart Object accessors.
extension SmartVisionItemExtension on VisionItem {
  List<SmartChecklistItem> get smartChecklist {
    final raw = metadata?['checklist'] as List<dynamic>?;
    if (raw == null) return [];
    return raw
        .map((c) => SmartChecklistItem.fromJson(Map<String, dynamic>.from(c)))
        .toList();
  }

  List<SmartMilestone> get smartMilestones {
    final raw = metadata?['milestones'] as List<dynamic>?;
    if (raw == null) return [];
    return raw
        .map((m) => SmartMilestone.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  double get smartProgress => ProgressEngine.calculateProgress(this);
  int get smartProgressPercent => ProgressEngine.getPercentage(this);
}
