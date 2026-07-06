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
    final hasToken = _ref.read(hiveDatabaseProvider).getAuthToken() != null;
    print('[Tasks] _loadData hasToken: $hasToken');

    // 1. Load instantly from local cache
    try {
      final localTasks = _repository.getLocalTasks();
      print('[Tasks] _loadData: ${localTasks.length} tasks from local cache');
      if (localTasks.isNotEmpty) {
        state = state.copyWith(allTasks: localTasks, isLoading: false);
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
        state = state.copyWith(allTasks: serverTasks, isLoading: false);
        await _repository.saveLocalTasks(serverTasks);
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

    NotificationService().cancelReminders(id);

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

List<TaskModel> _getGuestSeededTasks() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final threeDaysAgo = today.subtract(const Duration(days: 3));

  return [
    // Today's Targets (3 cards)
    TaskModel(
      id: 'guest_today_1',
      title: 'Outline Weekly Goals',
      description: 'Prepare target overview list and organize boards.',
      category: 'Work',
      priority: TaskPriority.high,
      dueDate: today,
      dueTime: '10:00 AM',
      reminder: true,
      reminderStyle: ReminderStyle.balanced,
      createdAt: now,
      updatedAt: now,
      subtasks: [
        SubtaskModel(
          id: 'guest_today_1_sub1',
          title: 'Draft board outline',
          completed: false,
          dueDate: today,
          dueTime: '10:00 AM',
        ),
        SubtaskModel(
          id: 'guest_today_1_sub2',
          title: 'Review team backlog',
          completed: true,
          dueDate: today,
          dueTime: '11:00 AM',
        ),
      ],
    ),
    TaskModel(
      id: 'guest_today_2',
      title: 'Full Body HIIT Workout',
      description: 'Complete HIIT circuit and light stretching.',
      category: 'Fitness',
      priority: TaskPriority.medium,
      dueDate: today,
      dueTime: '6:30 PM',
      reminder: true,
      reminderStyle: ReminderStyle.balanced,
      createdAt: now,
      updatedAt: now,
      subtasks: [
        SubtaskModel(
          id: 'guest_today_2_sub1',
          title: 'Warmup stretches',
          completed: false,
          dueDate: today,
          dueTime: '6:30 PM',
        ),
      ],
    ),
    TaskModel(
      id: 'guest_today_3',
      title: 'Read 15 Pages of Book',
      description: 'Focus on productivity book chapter 4.',
      category: 'Personal',
      priority: TaskPriority.low,
      dueDate: today,
      createdAt: now,
      updatedAt: now,
      subtasks: [],
    ),

    // Completed Targets (3 cards)
    TaskModel(
      id: 'guest_comp_1',
      title: 'Design Dashboard Mockups',
      description: 'Complete UI layout variants for the Tasks feature.',
      category: 'Work',
      priority: TaskPriority.high,
      dueDate: yesterday,
      completed: true,
      completedAt: yesterday,
      createdAt: yesterday,
      updatedAt: yesterday,
      subtasks: [
        SubtaskModel(
          id: 'guest_comp_1_sub1',
          title: 'Layout structure setup',
          completed: true,
          dueDate: yesterday,
        ),
      ],
    ),
    TaskModel(
      id: 'guest_comp_2',
      title: 'Monthly Budget Review',
      description: 'Calculate subscription renewals and personal expenses.',
      category: 'Finance',
      priority: TaskPriority.medium,
      dueDate: yesterday,
      completed: true,
      completedAt: yesterday,
      createdAt: yesterday,
      updatedAt: yesterday,
      subtasks: [],
    ),
    TaskModel(
      id: 'guest_comp_3',
      title: 'Water Houseplants',
      description: 'Water indoor plants and add fertilizer.',
      category: 'Personal',
      priority: TaskPriority.low,
      dueDate: yesterday,
      completed: true,
      completedAt: yesterday,
      createdAt: yesterday,
      updatedAt: yesterday,
      subtasks: [],
    ),

    // Overdue Targets (3 cards)
    TaskModel(
      id: 'guest_over_1',
      title: 'Submit Project Milestone 1',
      description: 'Publish documentation and initial code branch.',
      category: 'Work',
      priority: TaskPriority.high,
      dueDate: yesterday,
      dueTime: '2:00 PM',
      createdAt: yesterday,
      updatedAt: yesterday,
      subtasks: [
        SubtaskModel(
          id: 'guest_over_1_sub1',
          title: 'Finalize branch tests',
          completed: false,
          dueDate: yesterday,
          dueTime: '2:00 PM',
        ),
      ],
    ),
    TaskModel(
      id: 'guest_over_2',
      title: 'Plan Travel Vacation Route',
      description: 'Outline flights, hotels, and tourist spots.',
      category: 'Travel',
      priority: TaskPriority.medium,
      dueDate: threeDaysAgo,
      createdAt: threeDaysAgo,
      updatedAt: threeDaysAgo,
      subtasks: [],
    ),
    TaskModel(
      id: 'guest_over_3',
      title: 'Schedule Annual Dentist Checkup',
      description: 'Call dentist office for appointment options.',
      category: 'Health',
      priority: TaskPriority.low,
      dueDate: yesterday,
      createdAt: yesterday,
      updatedAt: yesterday,
      subtasks: [],
    ),
  ];
}
