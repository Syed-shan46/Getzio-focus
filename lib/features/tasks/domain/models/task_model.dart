import 'package:uuid/uuid.dart';

enum TaskPriority { high, medium, low }
enum TaskStatus { pending, inProgress, completed, overdue, cancelled }

class SubtaskModel {
  final String id;
  final String title;
  final String? description;
  final bool completed;
  final DateTime? dueDate;
  final String? dueTime;
  final bool reminder;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  SubtaskModel({
    required this.id,
    required this.title,
    this.description,
    this.completed = false,
    this.dueDate,
    this.dueTime,
    this.reminder = false,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  factory SubtaskModel.fromMap(Map<String, dynamic> map) {
    return SubtaskModel(
      id: map['id'] ?? const Uuid().v4(),
      title: map['title'] ?? '',
      description: map['description'],
      completed: map['completed'] ?? false,
      dueDate: map['dueDate'] != null ? DateTime.tryParse(map['dueDate'].toString()) : null,
      dueTime: map['dueTime'],
      reminder: map['reminder'] ?? false,
      sortOrder: map['sortOrder'] ?? 0,
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) : null,
      completedAt: map['completedAt'] != null ? DateTime.tryParse(map['completedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'dueDate': dueDate?.toIso8601String(),
      'dueTime': dueTime,
      'reminder': reminder,
      'sortOrder': sortOrder,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  SubtaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? dueDate,
    String? dueTime,
    bool? reminder,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return SubtaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      reminder: reminder ?? this.reminder,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class TaskModel {
  final String id; // maps to _id from MongoDB
  final String title;
  final String description;
  final String category;
  final TaskPriority priority;
  final TaskStatus status;
  final double progress; // 0 to 100
  final double manualProgress; // 0 to 100
  final bool completed;
  final bool pinned;
  final String? color;
  final String? goalId;
  final List<SubtaskModel> subtasks;
  final String? notes;
  final int? estimatedMinutes;
  final DateTime? dueDate;
  final String? dueTime;
  final bool reminder;
  final String? repeat;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.category = 'Personal',
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.progress = 0,
    this.manualProgress = 0,
    this.completed = false,
    this.pinned = false,
    this.color,
    this.goalId,
    this.subtasks = const [],
    this.notes,
    this.estimatedMinutes,
    this.dueDate,
    this.dueTime,
    this.reminder = false,
    this.repeat,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  // Calculate optimistic progress locally to keep UI instant offline
  double get effectiveProgress {
    if (subtasks.isEmpty) return manualProgress;
    int completedCount = subtasks.where((item) => item.completed).length;
    return (completedCount / subtasks.length) * 100;
  }
  
  bool get effectiveCompleted {
    return effectiveProgress >= 100;
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    TaskPriority priority = TaskPriority.medium;
    if (map['priority'] != null) {
      final p = map['priority'].toString().toLowerCase();
      if (p == 'high') priority = TaskPriority.high;
      if (p == 'low') priority = TaskPriority.low;
    }

    TaskStatus status = TaskStatus.pending;
    if (map['status'] != null) {
      final s = map['status'].toString().toLowerCase();
      if (s == 'in_progress') status = TaskStatus.inProgress;
      if (s == 'completed') status = TaskStatus.completed;
      if (s == 'overdue') status = TaskStatus.overdue;
      if (s == 'cancelled') status = TaskStatus.cancelled;
    }

    List<SubtaskModel> parsedSubtasks = [];
    if (map['subtasks'] != null) {
      parsedSubtasks = List<SubtaskModel>.from(
        map['subtasks'].map((x) => SubtaskModel.fromMap(x)),
      );
    } else if (map['checklist'] != null) {
      // Backwards compatibility for older local data
      parsedSubtasks = List<SubtaskModel>.from(
        map['checklist'].map((x) => SubtaskModel.fromMap(x)),
      );
    }

    return TaskModel(
      id: map['_id'] ?? map['id'] ?? const Uuid().v4(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Personal',
      priority: priority,
      status: status,
      progress: (map['progress'] ?? 0).toDouble(),
      manualProgress: (map['manualProgress'] ?? 0).toDouble(),
      completed: map['completed'] ?? false,
      pinned: map['pinned'] ?? false,
      color: map['color'],
      goalId: map['goalId'],
      subtasks: parsedSubtasks,
      notes: map['notes'],
      estimatedMinutes: map['estimatedMinutes'],
      dueDate: map['dueDate'] != null ? DateTime.tryParse(map['dueDate'].toString()) : null,
      dueTime: map['dueTime'],
      reminder: map['reminder'] ?? false,
      repeat: map['repeat'],
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) : null,
      completedAt: map['completedAt'] != null ? DateTime.tryParse(map['completedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      '_id': id, // Send back _id for mongoose sync consistency
      'title': title,
      'description': description,
      'category': category,
      'priority': '${priority.name[0].toUpperCase()}${priority.name.substring(1)}',
      'status': status == TaskStatus.inProgress ? 'in_progress' : status.name,
      'progress': effectiveProgress,
      'manualProgress': manualProgress,
      'completed': effectiveCompleted,
      'pinned': pinned,
      'color': color,
      'goalId': goalId,
      'subtasks': subtasks.map((x) => x.toMap()).toList(),
      'notes': notes,
      'estimatedMinutes': estimatedMinutes,
      'dueDate': dueDate?.toIso8601String(),
      'dueTime': dueTime,
      'reminder': reminder,
      'repeat': repeat,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': effectiveCompleted ? (completedAt ?? DateTime.now()).toIso8601String() : null,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    TaskPriority? priority,
    TaskStatus? status,
    double? progress,
    double? manualProgress,
    bool? completed,
    bool? pinned,
    String? color,
    String? goalId,
    List<SubtaskModel>? subtasks,
    String? notes,
    int? estimatedMinutes,
    DateTime? dueDate,
    String? dueTime,
    bool? reminder,
    String? repeat,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      manualProgress: manualProgress ?? this.manualProgress,
      completed: completed ?? this.completed,
      pinned: pinned ?? this.pinned,
      color: color ?? this.color,
      goalId: goalId ?? this.goalId,
      subtasks: subtasks ?? this.subtasks,
      notes: notes ?? this.notes,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      reminder: reminder ?? this.reminder,
      repeat: repeat ?? this.repeat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
