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

  /// Helper to safely extract a TodoModel from API responses, falling back to local prepared todo
  TodoModel _parseTodoResponse(dynamic resData, TodoModel fallback) {
    try {
      final raw = resData is Map && resData.containsKey('data')
          ? resData['data']
          : resData;
      if (raw is Map<String, dynamic> &&
          (raw.containsKey('title') || raw.containsKey('id') || raw.containsKey('_id'))) {
        final parsed = TodoModel.fromJson(raw);
        // Preserve local subTodos if server response omitted them
        final mergedSubs = (parsed.subTodos.isEmpty && fallback.subTodos.isNotEmpty)
            ? fallback.subTodos
            : parsed.subTodos;
        return parsed.copyWith(
          subTodos: mergedSubs,
          syncStatus: SyncStatus.synced,
        );
      }
    } catch (e) {
      log('[Repo] Error parsing todo response: $e');
    }
    return fallback.copyWith(syncStatus: SyncStatus.synced);
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

  DateTime? _lastFetchTime;

  Future<void> _fetchBackground() async {
    final token = _hiveDb.getAuthToken();
    if (token == null || token.isEmpty) {
      log('[Repo] Skipping background fetch for guest user');
      return;
    }

    final now = DateTime.now();
    if (_lastFetchTime != null &&
        now.difference(_lastFetchTime!) < const Duration(seconds: 30)) {
      log('[Repo] Skipped background fetch to avoid unnecessary API call (cached recently)');
      return;
    }
    _lastFetchTime = now;

    try {
      final res = await _dio.get('/todos');
      if (res.statusCode == 200 && res.data != null) {
        final dynamic rawList =
            res.data is Map && res.data.containsKey('data')
                ? res.data['data']
                : res.data;
        if (rawList is List) {
          final serverTodos = rawList
              .whereType<Map>()
              .map((e) => TodoModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();

          final localTodos = getLocalTodos();
          final localMap = {for (var t in localTodos) t.id: t};

          // Intelligently merge server todos with local todos
          final Map<String, TodoModel> mergedMap = {};

          for (var st in serverTodos) {
            final local = localMap[st.id];
            if (local != null && local.syncStatus != SyncStatus.synced) {
              // Keep local pending todo
              mergedMap[local.id] = local;
            } else {
              mergedMap[st.id] = st.copyWith(syncStatus: SyncStatus.synced);
            }
          }

          // Preserve any local pending todo that wasn't in server list yet
          for (var local in localTodos) {
            if (local.syncStatus != SyncStatus.synced &&
                !mergedMap.containsKey(local.id)) {
              mergedMap[local.id] = local;
            }
          }

          final mergedList = mergedMap.values.toList();
          await _hiveDb.clearTodos();
          for (var item in mergedList) {
            await _hiveDb.saveTodo(item.toJson());
          }
          _emit();
        }
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
        'subTodos': prepared.subTodos.map((s) => s.toJson()).toList(),
      });
      if (res.statusCode == 201 || res.statusCode == 200) {
        final synced = _parseTodoResponse(res.data, prepared);
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
        final synced = _parseTodoResponse(res.data, prepared);
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
      dynamic res;
      try {
        res = await _dio.patch('/todos/$id/toggle');
      } catch (_) {
        res = await _dio.put('/todos/$id', data: prepared.toJson());
      }
      if (res.statusCode == 200) {
        final synced = _parseTodoResponse(res.data, prepared);
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
      syncStatus: SyncStatus.pendingUpdate,
    );

    await _hiveDb.saveTodo(prepared.toJson());
    _emit();

    try {
      dynamic res;
      try {
        res = await _dio.post('/todos/$todoId/subtodos', data: {'title': title});
      } catch (_) {
        res = await _dio.put('/todos/$todoId', data: prepared.toJson());
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        final synced = _parseTodoResponse(res.data, prepared);
        await _hiveDb.saveTodo(synced.toJson());
        _emit();
        return synced;
      }
    } catch (e) {
      log('[Repo] Add subtask failed: $e');
      await _hiveDb.addToSyncQueue({
        'id': prepared.id,
        'action': 'UPDATE_TODO',
        'payload': prepared.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
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

    final prepared = original.copyWith(
      subTodos: updated,
      syncStatus: SyncStatus.pendingUpdate,
    );
    await _hiveDb.saveTodo(prepared.toJson());
    _emit();

    try {
      dynamic res;
      try {
        res = await _dio.patch('/todos/$todoId/subtodos/$subId/toggle');
      } catch (_) {
        res = await _dio.put('/todos/$todoId', data: prepared.toJson());
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        final synced = _parseTodoResponse(res.data, prepared);
        await _hiveDb.saveTodo(synced.toJson());
        _emit();
        return synced;
      }
    } catch (e) {
      log('[Repo] Toggle subtask failed: $e');
      await _hiveDb.addToSyncQueue({
        'id': prepared.id,
        'action': 'UPDATE_TODO',
        'payload': prepared.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
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
    final prepared = original.copyWith(
      subTodos: updated,
      syncStatus: SyncStatus.pendingUpdate,
    );

    await _hiveDb.saveTodo(prepared.toJson());
    _emit();

    try {
      dynamic res;
      try {
        res = await _dio.delete('/todos/$todoId/subtodos/$subId');
      } catch (_) {
        res = await _dio.put('/todos/$todoId', data: prepared.toJson());
      }

      if (res.statusCode == 200) {
        final synced = _parseTodoResponse(res.data, prepared);
        await _hiveDb.saveTodo(synced.toJson());
        _emit();
        return synced;
      }
    } catch (e) {
      log('[Repo] Delete subtask failed: $e');
      await _hiveDb.addToSyncQueue({
        'id': prepared.id,
        'action': 'UPDATE_TODO',
        'payload': prepared.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
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
      final preparedFallback = TodoModel.fromJson(payload);

      try {
        if (action == 'CREATE_TODO') {
          final res = await _dio.post('/todos', data: payload);
          if (res.statusCode == 200 || res.statusCode == 201) {
            final synced = _parseTodoResponse(res.data, preparedFallback);
            await _hiveDb.deleteTodo(id);
            await _hiveDb.saveTodo(synced.toJson());
            await _hiveDb.removeFromSyncQueue(id);
          }
        } else if (action == 'UPDATE_TODO' || action == 'TOGGLE_TODO') {
          final res = await _dio.put('/todos/$id', data: payload);
          if (res.statusCode == 200) {
            final synced = _parseTodoResponse(res.data, preparedFallback);
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
