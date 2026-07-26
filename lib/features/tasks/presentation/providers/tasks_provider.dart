import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_database.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../domain/models/task_model.dart';
import '../../data/repositories/tasks_repository.dart';
import '../../../affirmations/domain/models/affirmation_model.dart';
import '../../../../core/storage/sync_manager.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  final hive = ref.watch(hiveDatabaseProvider);
  ref.watch(authProvider);
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
    final userId = _ref.read(hiveDatabaseProvider).getUserId();
    final hasToken = _ref.read(hiveDatabaseProvider).getAuthToken() != null;
    print('[Tasks Debug] _loadData: userId=$userId, hasToken=$hasToken');

    // 1. Load instantly from local cache
    try {
      final localTasks = _repository.getLocalTasks();
      final activeTasks = localTasks.where((t) => !t.deleted).toList();
      print('[Tasks Debug] Loaded ${localTasks.length} tasks from local cache box (active count: ${activeTasks.length})');
      for (final t in activeTasks) {
        print('[Tasks Debug] Task in cache: id=${t.id}, title="${t.title}", syncStatus=${t.syncStatus}');
      }
      if (localTasks.isNotEmpty) {
        state = state.copyWith(allTasks: activeTasks, isLoading: false);
      } else {
        if (!hasToken) {
          // Seed guest tasks
          final seeded = _getGuestSeededTasks();
          state = state.copyWith(allTasks: seeded, isLoading: false);
          await _repository.saveLocalTasks(seeded);
        } else {
          state = state.copyWith(isLoading: true);
        }
      }
    } catch (e, st) {
      print('[Tasks] ERROR loading local tasks: $e');
      state = state.copyWith(isLoading: true);
    }

    // 2. Silently fetch fresh data from server in background
    if (!hasToken) {
      state = state.copyWith(isLoading: false);
      return;
    }

    _repository.fetchTasksFromServer().then((serverTasks) async {
      print('[Tasks] Server returned ${serverTasks?.length ?? 0} tasks');
      if (serverTasks != null) {
        final localTasks = _repository.getLocalTasks();
        final pendingTasks = localTasks.where((t) => t.syncStatus == SyncStatus.pending || t.deleted).toList();
        
        final List<TaskModel> mergedTasks = [];
        mergedTasks.addAll(pendingTasks);
        
        for (final st in serverTasks) {
          final isPendingLocally = pendingTasks.any((pt) => pt.id == st.id);
          if (!isPendingLocally) {
            mergedTasks.add(st);
          }
        }
        
        state = state.copyWith(allTasks: mergedTasks.where((t) => !t.deleted).toList(), isLoading: false);
        await _repository.saveLocalTasks(mergedTasks);
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

    if (pendingTask.completed || pendingTask.status == TaskStatus.completed) {
      NotificationService().cancelReminders(pendingTask.id);
      for (final sub in pendingTask.subtasks) {
        NotificationService().cancelReminders(sub.id);
      }
    } else {
      NotificationService().scheduleItemReminder(
        id: pendingTask.id,
        title: pendingTask.title,
        dueDate: pendingTask.dueDate,
        dueTime: pendingTask.dueTime,
        style: pendingTask.reminderStyle,
      );
      for (final sub in pendingTask.subtasks) {
        if (sub.completed) {
          NotificationService().cancelReminders(sub.id);
        } else {
          NotificationService().scheduleItemReminder(
            id: sub.id,
            title: sub.title,
            taskTitle: pendingTask.title,
            dueDate: sub.dueDate,
            dueTime: sub.dueTime,
            style: sub.reminderStyle,
          );
        }
      }
    }
    
    // Notify SyncQueueService
    _ref.read(syncQueueServiceProvider).triggerSync();
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
    
    if (updatedTask.completed || updatedTask.status == TaskStatus.completed) {
      NotificationService().cancelReminders(updatedTask.id);
      for (final sub in updatedTask.subtasks) {
        NotificationService().cancelReminders(sub.id);
      }
    } else {
      NotificationService().scheduleItemReminder(
        id: updatedTask.id,
        title: updatedTask.title,
        dueDate: updatedTask.dueDate,
        dueTime: updatedTask.dueTime,
        style: updatedTask.reminderStyle,
      );
      for (final sub in updatedTask.subtasks) {
        if (sub.completed) {
          NotificationService().cancelReminders(sub.id);
        } else {
          NotificationService().scheduleItemReminder(
            id: sub.id,
            title: sub.title,
            taskTitle: updatedTask.title,
            dueDate: sub.dueDate,
            dueTime: sub.dueTime,
            style: sub.reminderStyle,
          );
        }
      }
    }

    // Notify SyncQueueService
    _ref.read(syncQueueServiceProvider).triggerSync();
  }

  Future<void> deleteTask(String id) async {
    final filteredList = state.allTasks.where((t) => t.id != id).toList();
    state = state.copyWith(allTasks: filteredList);

    final allTasksInHive = _repository.getLocalTasks();
    final updatedHiveTasks = allTasksInHive.map((t) {
      if (t.id == id) {
        return t.copyWith(deleted: true, syncStatus: SyncStatus.pending);
      }
      return t;
    }).toList();
    
    if (!allTasksInHive.any((t) => t.id == id)) {
      await _repository.saveLocalTasks(filteredList);
    } else {
      await _repository.saveLocalTasks(updatedHiveTasks);
    }

    NotificationService().cancelReminders(id);

    // Notify SyncQueueService
    _ref.read(syncQueueServiceProvider).triggerSync();
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  final repo = ref.watch(tasksRepositoryProvider);
  return TasksNotifier(repo, ref);
});

List<TaskModel> _getGuestSeededTasks() {
  return [];
}
