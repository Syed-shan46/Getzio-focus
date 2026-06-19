enum SyncStatus { synced, pendingCreate, pendingUpdate, pendingDelete }

class SubTodoModel {
  final String id;
  final String title;
  final bool isCompleted;

  const SubTodoModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory SubTodoModel.fromJson(Map<String, dynamic> json) {
    return SubTodoModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        '_id': id,
        'title': title,
        'isCompleted': isCompleted,
      };

  SubTodoModel copyWith({String? id, String? title, bool? isCompleted}) {
    return SubTodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class TodoModel {
  final String id;
  final String title;
  final bool isCompleted;
  final List<SubTodoModel> subTodos;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final SyncStatus syncStatus;

  const TodoModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.subTodos = const [],
    required this.createdAt,
    this.updatedAt,
    this.syncStatus = SyncStatus.synced,
  });

  int get completedSubtaskCount => subTodos.where((s) => s.isCompleted).length;
  int get totalSubtaskCount => subTodos.length;

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    SyncStatus status = SyncStatus.synced;
    if (json['syncStatus'] != null) {
      status = SyncStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['syncStatus'],
        orElse: () => SyncStatus.synced,
      );
    }

    final subRaw = json['subTodos'] as List? ?? [];
    final subs = subRaw
        .map((e) => SubTodoModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return TodoModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      subTodos: subs,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      syncStatus: status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        '_id': id,
        'title': title,
        'isCompleted': isCompleted,
        'subTodos': subTodos.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'syncStatus': syncStatus.toString().split('.').last,
      };

  TodoModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    List<SubTodoModel>? subTodos,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      subTodos: subTodos ?? this.subTodos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
