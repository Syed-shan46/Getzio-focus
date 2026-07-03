import 'dart:math';
import 'vision_item.dart';

/// Represents a universal checklist item inside any Smart Object (Legacy / Sticky Note).
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

/// Represents a subtask inside a Milestone (Goals V2 architecture).
class SmartSubtask {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? completionDate;
  final DateTime? dueDate;
  final String? notes;
  final String? priority;
  final int order;
  final DateTime createdAt;

  const SmartSubtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completionDate,
    this.dueDate,
    this.notes,
    this.priority = 'medium',
    this.order = 0,
    required this.createdAt,
  });

  SmartSubtask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? completionDate,
    DateTime? dueDate,
    String? notes,
    String? priority,
    int? order,
    DateTime? createdAt,
  }) {
    return SmartSubtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completionDate: completionDate ?? this.completionDate,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'completed': isCompleted,
        'completedAt': completionDate?.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'notes': notes,
        'priority': priority,
        'order': order,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SmartSubtask.fromJson(Map<String, dynamic> json) => SmartSubtask(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? '',
        isCompleted: json['completed'] ?? json['isCompleted'] ?? false,
        completionDate: json['completedAt'] != null
            ? DateTime.tryParse(json['completedAt'])
            : (json['completionDate'] != null
                ? DateTime.tryParse(json['completionDate'])
                : null),
        dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
        notes: json['notes'],
        priority: json['priority'] ?? 'medium',
        order: json['order'] ?? 0,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
            : DateTime.now(),
      );
}

/// Represents a milestone inside Goals, Roadmaps, Plans, Images, etc.
class SmartMilestone {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? completionDate;
  final DateTime? dueDate;
  final String? priority;
  final int? colorValue;
  final int order;
  final List<SmartSubtask> subtasks;
  final List<SmartChecklistItem> tasks; // Legacy tasks for backwards compatibility
  final DateTime createdAt;
  final DateTime updatedAt;

  const SmartMilestone({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.completionDate,
    this.dueDate,
    this.priority = 'medium',
    this.colorValue,
    this.order = 0,
    this.subtasks = const [],
    this.tasks = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  SmartMilestone copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completionDate,
    DateTime? dueDate,
    String? priority,
    int? colorValue,
    int? order,
    List<SmartSubtask>? subtasks,
    List<SmartChecklistItem>? tasks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SmartMilestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      completionDate: completionDate ?? this.completionDate,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      colorValue: colorValue ?? this.colorValue,
      order: order ?? this.order,
      subtasks: subtasks ?? this.subtasks,
      tasks: tasks ?? this.tasks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'completed': isCompleted,
        'completionDate': completionDate?.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'priority': priority,
        'color': colorValue,
        'order': order,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory SmartMilestone.fromJson(Map<String, dynamic> json) => SmartMilestone(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        isCompleted: json['completed'] ?? json['isCompleted'] ?? false,
        completionDate: json['completionDate'] != null
            ? DateTime.tryParse(json['completionDate'])
            : (json['completedAt'] != null ? DateTime.tryParse(json['completedAt']) : null),
        dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
        priority: json['priority'] ?? 'medium',
        colorValue: json['color'] ?? json['colorValue'],
        order: json['order'] ?? 0,
        subtasks: (json['subtasks'] as List<dynamic>?)
                ?.map((s) => SmartSubtask.fromJson(Map<String, dynamic>.from(s)))
                .toList() ??
            const [],
        tasks: (json['tasks'] as List<dynamic>?)
                ?.map((t) => SmartChecklistItem.fromJson(Map<String, dynamic>.from(t)))
                .toList() ??
            const [],
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
            : DateTime.now(),
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
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
      final remaining = target.difference(today).inDays.toDouble();
      if (totalDays <= 0) return 0.0;
      final elapsed = totalDays - max(0.0, remaining);
      return (elapsed / totalDays).clamp(0.0, 1.0);
    }

    // 3. Goal V2 - Journey progress calculation
    if (item.type == VisionItemType.goal.name) {
      final milestones = item.smartMilestones;
      if (milestones.isEmpty) return 0.0;
      
      double totalMilestoneProgress = 0.0;
      for (final m in milestones) {
        if (m.subtasks.isEmpty) {
          totalMilestoneProgress += m.isCompleted ? 1.0 : 0.0;
        } else {
          final completed = m.subtasks.where((t) => t.isCompleted).length;
          totalMilestoneProgress += completed / m.subtasks.length;
        }
      }
      return (totalMilestoneProgress / milestones.length).clamp(0.0, 1.0);
    }

    // 4. Default Checklists & Milestones calculation for other objects (Sticky Note/Plans)
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
    final rawMilestones = metadata?['milestones'] as List<dynamic>?;
    final rawChecklist = metadata?['checklist'] as List<dynamic>?;

    List<SmartMilestone> list = rawMilestones != null
        ? rawMilestones
            .map((m) => SmartMilestone.fromJson(Map<String, dynamic>.from(m)))
            .toList()
        : [];

    // Migration: If there are checklist items, automatically convert them to milestones
    if (type == VisionItemType.goal.name && rawChecklist != null && rawChecklist.isNotEmpty) {
      final checklists = rawChecklist
          .map((c) => SmartChecklistItem.fromJson(Map<String, dynamic>.from(c)))
          .toList();
          
      final subtasks = checklists.map((c) {
        return SmartSubtask(
          id: c.id,
          title: c.title,
          isCompleted: c.isCompleted,
          completionDate: c.completionDate,
          createdAt: DateTime.now(),
        );
      }).toList();

      final generalMilestone = SmartMilestone(
        id: 'general_tasks_migration_${DateTime.now().millisecondsSinceEpoch}',
        title: 'General Tasks',
        description: 'Migrated from checklist',
        isCompleted: subtasks.isNotEmpty && subtasks.every((s) => s.isCompleted),
        subtasks: subtasks,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      list.insert(0, generalMilestone);
    }
    
    // Sort by order
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  double get smartProgress => ProgressEngine.calculateProgress(this);
  int get smartProgressPercent => ProgressEngine.getPercentage(this);
}

