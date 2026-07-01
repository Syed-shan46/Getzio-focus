import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_database.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../domain/models/task_model.dart';
import '../../data/repositories/tasks_repository.dart';

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
    this.activeFilter = TaskFilter.all,
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
          if (t.dueDate == null) return false;
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
        return allTasks.where((t) => t.status != TaskStatus.completed).toList(); // Usually show pending by default
    }
  }
}

class TasksNotifier extends StateNotifier<TasksState> {
  final TasksRepository _repository;

  TasksNotifier(this._repository) : super(TasksState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);

    // 1. Load instantly from cache
    final localTasks = _repository.getLocalTasks();
    if (localTasks.isNotEmpty) {
      state = state.copyWith(allTasks: localTasks, isLoading: false);
    }

    // 2. Background sync offline changes
    await _repository.syncOfflineTasks(localTasks);

    // 3. Background fetch fresh data from server
    final serverTasks = await _repository.fetchTasksFromServer();
    if (serverTasks != null) {
      // Refresh state
      state = state.copyWith(allTasks: serverTasks, isLoading: false);
      // Update cache
      await _repository.saveLocalTasks(serverTasks);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  void setFilter(TaskFilter filter) {
    state = state.copyWith(activeFilter: filter);
  }

  Future<void> addTask(TaskModel task) async {
    final newList = [task, ...state.allTasks];
    state = state.copyWith(allTasks: newList);
    await _repository.saveLocalTasks(newList);
    await _repository.queueTaskUpsert(task);
    
    // Attempt background sync without waiting
    _repository.syncOfflineTasks(newList);
  }

  Future<void> updateTask(TaskModel task) async {
    // Before saving, ensure status calculation based on completion
    TaskModel updatedTask = task;
    if (task.completed && task.status != TaskStatus.completed) {
       updatedTask = task.copyWith(
           status: TaskStatus.completed, 
           completedAt: DateTime.now(),
       );
    } else if (!task.completed && task.status == TaskStatus.completed) {
       updatedTask = task.copyWith(
           status: TaskStatus.pending,
           completedAt: null,
       );
       // We would need to calculate if it should be overdue but the UI handles it
    }

    final newList = state.allTasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList();
    state = state.copyWith(allTasks: newList);
    await _repository.saveLocalTasks(newList);
    await _repository.queueTaskUpsert(updatedTask);
    
    _repository.syncOfflineTasks(newList);
  }

  Future<void> deleteTask(String id) async {
    final newList = state.allTasks.where((t) => t.id != id).toList();
    state = state.copyWith(allTasks: newList);
    await _repository.saveLocalTasks(newList);
    await _repository.queueTaskDeletion(id);
    
    _repository.syncOfflineTasks(newList);
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  final repo = ref.watch(tasksRepositoryProvider);
  return TasksNotifier(repo);
});
