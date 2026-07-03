import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_database.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../domain/models/task_model.dart';
import '../../../affirmations/domain/models/affirmation_model.dart';

class TasksRepository {
  final HiveDatabase _hiveDb;
  final Ref _ref;

  TasksRepository(this._hiveDb, this._ref);

  List<TaskModel> getLocalTasks() {
    final maps = _hiveDb.getTasks();
    return maps.map((m) => TaskModel.fromMap(Map<String, dynamic>.from(m))).toList();
  }

  Future<void> saveLocalTasks(List<TaskModel> tasks) async {
    final maps = tasks.map((t) => t.toMap()).toList();
    await _hiveDb.saveTasks(maps);
  }

  Future<List<TaskModel>?> fetchTasksFromServer() async {
    final hasToken = _hiveDb.getAuthToken() != null;
    if (!hasToken) return null;

    try {
      final dio = _ref.read(dioClientProvider);
      final response = await dio.get('/tasks');
      if (response.statusCode == 200 && response.data != null && response.data['status'] == 'success') {
        final data = response.data['data']['tasks'] as List;
        return data.map((json) {
          final map = Map<String, dynamic>.from(json);
          map['syncStatus'] = SyncStatus.synced.name;
          map['lastSyncedAt'] = DateTime.now().toIso8601String();
          return TaskModel.fromMap(map);
        }).toList();
      }
    } catch (e) {
      dev.log('Error fetching tasks: $e');
    }
    return null;
  }

  Future<void> queueTaskUpsert(TaskModel task) async {
    final action = {
      'id': 'task_${task.id}_${DateTime.now().millisecondsSinceEpoch}',
      'operation': 'update',
      'collection': 'tasks',
      'documentId': task.id,
      'payload': task.toMap(),
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _hiveDb.addToPendingSync(action);
  }

  Future<void> queueTaskDeletion(String taskId) async {
    final action = {
      'id': 'task_delete_${taskId}_${DateTime.now().millisecondsSinceEpoch}',
      'operation': 'delete',
      'collection': 'tasks',
      'documentId': taskId,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _hiveDb.addToPendingSync(action);
  }
}
