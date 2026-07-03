import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_database.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../domain/models/task_model.dart';
import '../../data/repositories/tasks_repository.dart';
import '../../../affirmations/domain/models/affirmation_model.dart';
import '../../../../core/storage/sync_manager.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  final hive = ref.watch(hiveDatabaseProvider);
  return TasksRepository(hive, ref);
});

enum TaskFilter { today, upcoming, completed, overdue, highPriority, mediumPriority, lowPriority, pinned, all }

class TasksState {
  final List<TaskModel> allTasks;
  final bool isLoading;
  final TaskFilter activeFilter;

  TasksState({
    this.allTasks = const [],
    this.isLoading = false,
    this.activeFilter = TaskFilter.today,
  });

  TasksState copyWith({
    List<TaskModel>? allTasks,
    bool? isLoading,
    TaskFilter? activeFilter,
  }) {
    return TasksState(
      allTasks: allTasks ?? this.allTasks,
      isLoading: isLoading ?? this.isLoading,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  List<TaskModel> get filteredTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (activeFilter) {
      case TaskFilter.today:
        return allTasks.where((t) {
          if (t.dueDate == null) return t.status != TaskStatus.completed;
          final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
          return d == today && t.status != TaskStatus.completed;
        }).toList();
      case TaskFilter.upcoming:
        return allTasks.where((t) {
          if (t.dueDate == null) return false;
          final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
          return d.isAfter(today) && t.status != TaskStatus.completed;
        }).toList();
      case TaskFilter.completed:
        return allTasks.where((t) => t.status == TaskStatus.completed || t.completed).toList();
      case TaskFilter.overdue:
        return allTasks.where((t) => t.status == TaskStatus.overdue).toList();
      case TaskFilter.highPriority:
        return allTasks.where((t) => t.priority == TaskPriority.high && t.status != TaskStatus.completed).toList();
      case TaskFilter.mediumPriority:
        return allTasks.where((t) => t.priority == TaskPriority.medium && t.status != TaskStatus.completed).toList();
      case TaskFilter.lowPriority:
        return allTasks.where((t) => t.priority == TaskPriority.low && t.status != TaskStatus.completed).toList();
      case TaskFilter.pinned:
        return allTasks.where((t) => t.pinned && t.status != TaskStatus.completed).toList();
      case TaskFilter.all:
      default:
        return allTasks.where((t) => t.status != TaskStatus.completed).toList();
    }
  }
}

class TasksNotifier extends StateNotifier<TasksState> {
  final TasksRepository _repository;
  final Ref _ref;

  TasksNotifier(this._repository, this._ref) : super(TasksState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Load instantly from local cache
    try {
      final localTasks = _repository.getLocalTasks();
      print('[Tasks] _loadData: ${localTasks.length} tasks from local cache');
      if (localTasks.isNotEmpty) {
        state = state.copyWith(allTasks: localTasks, isLoading: false);
      } else {
        state = state.copyWith(isLoading: true);
      }
    } catch (e, st) {
      print('[Tasks] ERROR loading local tasks: $e');
      print('[Tasks] Stack: $st');
      state = state.copyWith(isLoading: true);
    }

    // 2. Silently fetch fresh data from server in background
    final hasToken = _ref.read(hiveDatabaseProvider).getAuthToken() != null;
    print('[Tasks] hasToken: $hasToken');
    if (!hasToken) {
      state = state.copyWith(isLoading: false);
      return;
    }

    _repository.fetchTasksFromServer().then((serverTasks) async {
      print('[Tasks] Server returned ${serverTasks?.length ?? 0} tasks');
      if (serverTasks != null) {
        // Compare to check if identical
        final localJson = jsonEncode(state.allTasks.map((t) => t.toMap()).toList());
        final serverJson = jsonEncode(serverTasks.map((t) => t.toMap()).toList());

        if (localJson != serverJson) {
          state = state.copyWith(allTasks: serverTasks, isLoading: false);
          await _repository.saveLocalTasks(serverTasks);
        }
      }
      // Process pending sync queue
      _ref.read(syncManagerProvider).processQueue();
    }).catchError((e) {
      print('Error fetching tasks silently: $e');
    }).whenComplete(() {
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    });
  }

  Future<void> refresh() async {
    await _loadData();
  }

  void setFilter(TaskFilter filter) {
    state = state.copyWith(activeFilter: filter);
  }

  Future<void> addTask(TaskModel task) async {
    final pendingTask = task.copyWith(syncStatus: SyncStatus.pending);
    final newList = [pendingTask, ...state.allTasks];
    state = state.copyWith(allTasks: newList);
    await _repository.saveLocalTasks(newList);
    
    // Background sync
    final dio = _ref.read(dioClientProvider);
    dio.post('/tasks/sync', data: {
      'modifications': [pendingTask.toMap()],
      'deletedIds': [],
    }).then((response) async {
      if (response.statusCode == 200) {
        final syncedList = state.allTasks.map((t) => t.id == task.id ? t.copyWith(syncStatus: SyncStatus.synced, lastSyncedAt: DateTime.now()) : t).toList();
        state = state.copyWith(allTasks: syncedList);
        await _repository.saveLocalTasks(syncedList);
      } else {
        await _repository.queueTaskUpsert(pendingTask);
      }
    }).catchError((e) async {
      await _repository.queueTaskUpsert(pendingTask);
    });
  }

  Future<void> updateTask(TaskModel task) async {
    final existingTask = state.allTasks.firstWhere((t) => t.id == task.id, orElse: () => task);
    bool isCompleted = task.completed;
    List<SubtaskModel> updatedSubtasks = task.subtasks;
    
    if (task.subtasks.isNotEmpty && task.completed != existingTask.completed) {
      updatedSubtasks = task.subtasks.map((s) => s.copyWith(completed: task.completed)).toList();
      isCompleted = task.completed;
    } else if (task.subtasks.isNotEmpty) {
      isCompleted = updatedSubtasks.every((s) => s.completed);
    }
    
    TaskModel updatedTask = task.copyWith(
      completed: isCompleted,
      subtasks: updatedSubtasks,
      manualProgress: isCompleted ? 100 : 0,
      syncStatus: SyncStatus.pending,
    );

    if (isCompleted && updatedTask.status != TaskStatus.completed) {
        updatedTask = updatedTask.copyWith(
            status: TaskStatus.completed, 
            completedAt: DateTime.now(),
        );
    } else if (!isCompleted && updatedTask.status == TaskStatus.completed) {
        updatedTask = updatedTask.copyWith(
            status: TaskStatus.pending,
            completedAt: null,
        );
    }

    final newList = state.allTasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList();
    state = state.copyWith(allTasks: newList);
    await _repository.saveLocalTasks(newList);
    
    // Background sync
    final dio = _ref.read(dioClientProvider);
    dio.post('/tasks/sync', data: {
      'modifications': [updatedTask.toMap()],
      'deletedIds': [],
    }).then((response) async {
      if (response.statusCode == 200) {
        final syncedList = state.allTasks.map((t) => t.id == task.id ? t.copyWith(syncStatus: SyncStatus.synced, lastSyncedAt: DateTime.now()) : t).toList();
        state = state.copyWith(allTasks: syncedList);
        await _repository.saveLocalTasks(syncedList);
      } else {
        await _repository.queueTaskUpsert(updatedTask);
      }
    }).catchError((e) async {
      await _repository.queueTaskUpsert(updatedTask);
    });
  }

  Future<void> deleteTask(String id) async {
    final newList = state.allTasks.where((t) => t.id != id).toList();
    state = state.copyWith(allTasks: newList);
    await _repository.saveLocalTasks(newList);

    // Background sync
    final dio = _ref.read(dioClientProvider);
    dio.post('/tasks/sync', data: {
      'modifications': [],
      'deletedIds': [id],
    }).then((response) async {
      if (response.statusCode != 200) {
        await _repository.queueTaskDeletion(id);
      }
    }).catchError((e) async {
      await _repository.queueTaskDeletion(id);
    });
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  final repo = ref.watch(tasksRepositoryProvider);
  return TasksNotifier(repo, ref);
});
