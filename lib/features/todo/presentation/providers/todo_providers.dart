import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/models/todo_model.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../data/repositories/todo_repository_impl.dart';

// ─── Repository ───────────────────────────────────────────────────────────

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final hiveDb = ref.watch(hiveDatabaseProvider);
  final dio = ref.watch(dioClientProvider);
  ref.watch(authProvider); // Force rebuild when session state changes
  return TodoRepositoryImpl(hiveDb, dio);
});

// ─── Todos Notifier ───────────────────────────────────────────────────────

class TodosNotifier extends StateNotifier<AsyncValue<List<TodoModel>>> {
  final TodoRepository _repo;
  StreamSubscription? _sub;

  TodosNotifier(this._repo) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    state = AsyncValue.data(_repo.getLocalTodos());
    _sub = _repo.watchTodos().listen(
          (list) => state = AsyncValue.data(list),
          onError: (err, stack) => state = AsyncValue.error(err, stack),
        );
    refresh();
  }

  Future<void> refresh() async {
    try {
      await _repo.fetchTodos();
      _repo.syncOfflineData();
    } catch (e) {
      debugPrint('[Todos] Refresh error: $e');
    }
  }

  Future<void> addTodo({
    required String title,
    List<String> subtaskTitles = const [],
  }) async {
    final subTodos = subtaskTitles
        .where((t) => t.trim().isNotEmpty)
        .map((t) => SubTodoModel(id: '', title: t.trim()))
        .toList();

    final todo = TodoModel(
      id: '',
      title: title.trim(),
      subTodos: subTodos,
      createdAt: DateTime.now(),
    );
    await _repo.createTodo(todo);
  }

  Future<void> updateTodo(TodoModel todo) async => _repo.updateTodo(todo);
  Future<void> deleteTodo(String id) async => _repo.deleteTodo(id);
  Future<void> toggleTodo(String id) async => _repo.toggleTodo(id);
  Future<void> addSubTodo(String todoId, String title) async =>
      _repo.addSubTodo(todoId, title);
  Future<void> toggleSubTodo(String todoId, String subId) async =>
      _repo.toggleSubTodo(todoId, subId);
  Future<void> deleteSubTodo(String todoId, String subId) async =>
      _repo.deleteSubTodo(todoId, subId);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final todosProvider =
    StateNotifierProvider<TodosNotifier, AsyncValue<List<TodoModel>>>((ref) {
  final repo = ref.watch(todoRepositoryProvider);
  return TodosNotifier(repo);
});

// ─── Stats ────────────────────────────────────────────────────────────────

class TodoStats {
  final int completed;
  final int total;
  final double percentage;

  const TodoStats({
    required this.completed,
    required this.total,
    required this.percentage,
  });
}

final todoStatsProvider = Provider<TodoStats>((ref) {
  final todosAsync = ref.watch(todosProvider);
  final todos = todosAsync.value ?? [];

  final total = todos.length;
  final completed = todos.where((t) => t.isCompleted).length;
  final pct = total > 0 ? (completed / total) * 100 : 0.0;

  return TodoStats(completed: completed, total: total, percentage: pct);
});
