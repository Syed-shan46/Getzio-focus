import 'package:uuid/uuid.dart';

enum TaskPriority { high, medium, low }
enum TaskStatus { pending, inProgress, completed, overdue, cancelled }

class ChecklistItem {
  final String id;
  final String title;
  final bool completed;
  final DateTime? completedAt;

  ChecklistItem({
    required this.id,
    required this.title,
    this.completed = false,
    this.completedAt,
  });

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] ?? const Uuid().v4(),
      title: map['title'] ?? '',
      completed: map['completed'] ?? false,
      completedAt: map['completedAt'] != null ? DateTime.tryParse(map['completedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  ChecklistItem copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? completedAt,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
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
  final bool completed;
  final bool pinned;
  final String? color;
  final String? goalId;
  final List<ChecklistItem> checklist;
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
    this.completed = false,
    this.pinned = false,
    this.color,
    this.goalId,
    this.checklist = const [],
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

  double get checklistProgress {
    if (checklist.isEmpty) return 0.0;
    int completedCount = checklist.where((item) => item.completed).length;
    return completedCount / checklist.length;
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['_id'] ?? map['id'] ?? const Uuid().v4(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Personal',
      priority: _priorityFromString(map['priority']),
      status: _statusFromString(map['status']),
      completed: map['completed'] ?? false,
      pinned: map['pinned'] ?? false,
      color: map['color'],
      goalId: map['goalId'],
      checklist: map['checklist'] != null 
          ? List<ChecklistItem>.from((map['checklist'] as List).map((x) => ChecklistItem.fromMap(Map<String, dynamic>.from(x))))
          : [],
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
      'title': title,
      'description': description,
      'category': category,
      'priority': _priorityToString(priority),
      'status': _statusToString(status),
      'completed': completed,
      'pinned': pinned,
      'color': color,
      'goalId': goalId,
      'checklist': checklist.map((x) => x.toMap()).toList(),
      'notes': notes,
      'estimatedMinutes': estimatedMinutes,
      'dueDate': dueDate?.toIso8601String(),
      'dueTime': dueTime,
      'reminder': reminder,
      'repeat': repeat,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    TaskPriority? priority,
    TaskStatus? status,
    bool? completed,
    bool? pinned,
    String? color,
    String? goalId,
    List<ChecklistItem>? checklist,
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
      completed: completed ?? this.completed,
      pinned: pinned ?? this.pinned,
      color: color ?? this.color,
      goalId: goalId ?? this.goalId,
      checklist: checklist ?? this.checklist,
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

  static TaskPriority _priorityFromString(String? priorityStr) {
    switch (priorityStr?.toLowerCase()) {
      case 'high': return TaskPriority.high;
      case 'low': return TaskPriority.low;
      case 'medium':
      default: return TaskPriority.medium;
    }
  }

  static String _priorityToString(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high: return 'High';
      case TaskPriority.low: return 'Low';
      case TaskPriority.medium:
      default: return 'Medium';
    }
  }

  static TaskStatus _statusFromString(String? statusStr) {
    switch (statusStr?.toLowerCase()) {
      case 'in_progress': return TaskStatus.inProgress;
      case 'completed': return TaskStatus.completed;
      case 'overdue': return TaskStatus.overdue;
      case 'cancelled': return TaskStatus.cancelled;
      case 'pending':
      default: return TaskStatus.pending;
    }
  }

  static String _statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress: return 'in_progress';
      case TaskStatus.completed: return 'completed';
      case TaskStatus.overdue: return 'overdue';
      case TaskStatus.cancelled: return 'cancelled';
      case TaskStatus.pending:
      default: return 'pending';
    }
  }
}
