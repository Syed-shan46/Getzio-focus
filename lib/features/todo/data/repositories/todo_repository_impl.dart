import 'dart:async';
import 'dart:developer';
import 'package:uuid/uuid.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/hive_database.dart';
import '../../domain/models/todo_model.dart';
import '../../domain/repositories/todo_repository.dart';

class TodoRepositoryImpl implements TodoRepository {
  final HiveDatabase _hiveDb;
  final DioClient _dio;
  final _stream = StreamController<List<TodoModel>>.broadcast();

  TodoRepositoryImpl(this._hiveDb, this._dio) {
    _emit();
  }

  void _emit() {
    _stream.add(getLocalTodos());
  }

  // ─── Read ───────────────────────────────────────────────────────────────

  @override
  List<TodoModel> getLocalTodos() {
    final cached = _hiveDb.getCachedTodos();
    final list = cached.map((j) => TodoModel.fromJson(j)).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Stream<List<TodoModel>> watchTodos() => _stream.stream;

  @override
  Future<List<TodoModel>> fetchTodos() async {
    _fetchBackground();
    return getLocalTodos();
  }

  Future<void> _fetchBackground() async {
    try {
      final res = await _dio.get('/todos');
      if (res.statusCode == 200 && res.data != null) {
        final List<dynamic> data = res.data['data'] ?? res.data;
        final todos =
            data.map((e) => TodoModel.fromJson(e as Map<String, dynamic>)).toList();

        // Preserve pending local changes
        final pending =
            getLocalTodos().where((e) => e.syncStatus != SyncStatus.synced).toList();
        await _hiveDb.clearTodos();
        for (var p in pending) {
          await _hiveDb.saveTodo(p.toJson());
        }
        await _hiveDb.saveTodos(todos.map((e) => e.toJson()).toList());
        _emit();
      }
    } catch (e) {
      log('[Repo] Fetch failed: $e');
    }
  }

  // ─── Create ─────────────────────────────────────────────────────────────

  @override
  Future<TodoModel> createTodo(TodoModel todo) async {
    final id = todo.id.isEmpty ? const Uuid().v4() : todo.id;
    final prepared = todo.copyWith(id: id, syncStatus: SyncStatus.pendingCreate);

    await _hiveDb.saveTodo(prepared.toJson());
    _emit();

    try {
      final res = await _dio.post('/todos', data: {
        'title': prepared.title,
        'subTodos': prepared.subTodos.map((s) => {'title': s.title}).toList(),
      });
      if (res.statusCode == 201 || res.statusCode == 200) {
        final synced = TodoModel.fromJson(res.data['data'] ?? res.data)
            .copyWith(syncStatus: SyncStatus.synced);
        await _hiveDb.deleteTodo(prepared.id);
        await _hiveDb.saveTodo(synced.toJson());
        _emit();
        return synced;
      }
    } catch (e) {
      log('[Repo] Create failed: $e');
      await _hiveDb.addToSyncQueue({
        'id': prepared.id,
        'action': 'CREATE_TODO',
        'payload': prepared.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
    return prepared;
  }

  // ─── Update ─────────────────────────────────────────────────────────────

  @override
  Future<TodoModel> updateTodo(TodoModel todo) async {
    final prepared = todo.copyWith(syncStatus: SyncStatus.pendingUpdate);
    await _hiveDb.saveTodo(prepared.toJson());
    _emit();

    try {
      final res = await _dio.put('/todos/${todo.id}', data: todo.toJson());
      if (res.statusCode == 200) {
        final synced = TodoModel.fromJson(res.data['data'] ?? res.data)
            .copyWith(syncStatus: SyncStatus.synced);
        await _hiveDb.saveTodo(synced.toJson());
        _emit();
        return synced;
      }
    } catch (e) {
      log('[Repo] Update failed: $e');
      await _hiveDb.addToSyncQueue({
        'id': todo.id,
        'action': 'UPDATE_TODO',
        'payload': todo.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
    return prepared;
  }

  // ─── Delete ─────────────────────────────────────────────────────────────

  @override
  Future<void> deleteTodo(String id) async {
    await _hiveDb.deleteTodo(id);
    _emit();

    try {
      await _dio.delete('/todos/$id');
    } catch (e) {
      log('[Repo] Delete failed: $e');
      await _hiveDb.addToSyncQueue({
        'id': id,
        'action': 'DELETE_TODO',
        'payload': {'id': id},
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // ─── Toggle ─────────────────────────────────────────────────────────────

  @override
  Future<TodoModel> toggleTodo(String id) async {
    final todos = getLocalTodos();
    final idx = todos.indexWhere((e) => e.id == id);
    if (idx == -1) throw Exception('Todo not found');

    final original = todos[idx];
    final prepared = original.copyWith(
      isCompleted: !original.isCompleted,
      syncStatus: SyncStatus.pendingUpdate,
    );

    await _hiveDb.saveTodo(prepared.toJson());
    _emit();

    try {
      final res = await _dio.patch('/todos/$id/toggle');
      if (res.statusCode == 200) {
        final synced = TodoModel.fromJson(res.data['data'] ?? res.data)
            .copyWith(syncStatus: SyncStatus.synced);
        await _hiveDb.saveTodo(synced.toJson());
        _emit();
        return synced;
      }
    } catch (e) {
      log('[Repo] Toggle failed: $e');
      await _hiveDb.addToSyncQueue({
        'id': id,
        'action': 'TOGGLE_TODO',
        'payload': prepared.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
    return prepared;
  }

  // ─── Subtasks ───────────────────────────────────────────────────────────

  @override
  Future<TodoModel> addSubTodo(String todoId, String title) async {
    final todos = getLocalTodos();
    final idx = todos.indexWhere((e) => e.id == todoId);
    if (idx == -1) throw Exception('Todo not found');

    final original = todos[idx];
    final newSub = SubTodoModel(id: const Uuid().v4(), title: title);
    final prepared = original.copyWith(
      subTodos: [...original.subTodos, newSub],
    );

    await _hiveDb.saveTodo(prepared.toJson());
    _emit();

    try {
      final res = await _dio.post('/todos/$todoId/subtodos', data: {'title': title});
      if (res.statusCode == 200 || res.statusCode == 201) {
        final synced = TodoModel.fromJson(res.data['data'] ?? res.data);
        await _hiveDb.saveTodo(synced.toJson());
        _emit();
        return synced;
      }
    } catch (e) {
      log('[Repo] Add subtask failed: $e');
    }
    return prepared;
  }

  @override
  Future<TodoModel> toggleSubTodo(String todoId, String subId) async {
    final todos = getLocalTodos();
    final idx = todos.indexWhere((e) => e.id == todoId);
    if (idx == -1) throw Exception('Todo not found');

    final original = todos[idx];
    final updated = original.subTodos.map((s) {
      if (s.id == subId) return s.copyWith(isCompleted: !s.isCompleted);
      return s;
    }).toList();

    final prepared = original.copyWith(subTodos: updated);
    await _hiveDb.saveTodo(prepared.toJson());
    _emit();

    try {
      final res = await _dio.patch('/todos/$todoId/subtodos/$subId/toggle');
      if (res.statusCode == 200) {
        final synced = TodoModel.fromJson(res.data['data'] ?? res.data);
        await _hiveDb.saveTodo(synced.toJson());
        _emit();
        return synced;
      }
    } catch (e) {
      log('[Repo] Toggle subtask failed: $e');
    }
    return prepared;
  }

  @override
  Future<TodoModel> deleteSubTodo(String todoId, String subId) async {
    final todos = getLocalTodos();
    final idx = todos.indexWhere((e) => e.id == todoId);
    if (idx == -1) throw Exception('Todo not found');

    final original = todos[idx];
    final updated = original.subTodos.where((s) => s.id != subId).toList();
    final prepared = original.copyWith(subTodos: updated);

    await _hiveDb.saveTodo(prepared.toJson());
    _emit();

    try {
      final res = await _dio.delete('/todos/$todoId/subtodos/$subId');
      if (res.statusCode == 200) {
        final synced = TodoModel.fromJson(res.data['data'] ?? res.data);
        await _hiveDb.saveTodo(synced.toJson());
        _emit();
        return synced;
      }
    } catch (e) {
      log('[Repo] Delete subtask failed: $e');
    }
    return prepared;
  }

  // ─── Sync ───────────────────────────────────────────────────────────────

  @override
  Future<void> syncOfflineData() async {
    final queue = _hiveDb.getSyncQueue();
    if (queue.isEmpty) return;

    log('[Sync] Processing ${queue.length} operations...');
    queue.sort((a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int));

    for (var op in queue) {
      final id = op['id'] as String;
      final action = op['action'] as String;
      final payload = Map<String, dynamic>.from(op['payload'] as Map);

      try {
        if (action == 'CREATE_TODO') {
          final res = await _dio.post('/todos', data: payload);
          if (res.statusCode == 200 || res.statusCode == 201) {
            final synced = TodoModel.fromJson(res.data['data'] ?? res.data);
            await _hiveDb.deleteTodo(id);
            await _hiveDb.saveTodo(synced.toJson());
            await _hiveDb.removeFromSyncQueue(id);
          }
        } else if (action == 'UPDATE_TODO' || action == 'TOGGLE_TODO') {
          final res = await _dio.put('/todos/$id', data: payload);
          if (res.statusCode == 200) {
            final synced = TodoModel.fromJson(res.data['data'] ?? res.data);
            await _hiveDb.saveTodo(synced.toJson());
            await _hiveDb.removeFromSyncQueue(id);
          }
        } else if (action == 'DELETE_TODO') {
          final res = await _dio.delete('/todos/$id');
          if (res.statusCode == 200 || res.statusCode == 404) {
            await _hiveDb.removeFromSyncQueue(id);
          }
        }
      } catch (e) {
        log('[Sync] Op $id failed: $e');
        break;
      }
    }
    _emit();
  }
}
