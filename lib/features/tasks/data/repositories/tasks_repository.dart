import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_database.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../domain/models/task_model.dart';

class TasksRepository {
  final HiveDatabase _hiveDb;
  final Ref _ref;

  TasksRepository(this._hiveDb, this._ref);

  List<TaskModel> getLocalTasks() {
    final maps = _hiveDb.getTasks();
    return maps.map((m) => TaskModel.fromMap(m)).toList();
  }

  Future<void> saveLocalTasks(List<TaskModel> tasks) async {
    final maps = tasks.map((t) => t.toMap()).toList();
    await _hiveDb.saveTasks(maps);
  }

  Future<List<TaskModel>?> fetchTasksFromServer() async {
    final hasToken = _hiveDb.getAuthToken() != null;
    dev.log('fetchTasksFromServer - hasToken: $hasToken');
    if (!hasToken) return null;

    try {
      final dio = _ref.read(dioClientProvider);
      dev.log('fetchTasksFromServer - making GET request');
      final response = await dio.get('/tasks');
      if (response.statusCode == 200 && response.data != null && response.data['status'] == 'success') {
        final data = response.data['data']['tasks'] as List;
        return data.map((json) => TaskModel.fromMap(json as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      dev.log('Error fetching tasks: $e');
    }
    return null;
  }

  Future<void> syncOfflineTasks(List<TaskModel> localTasks) async {
    final pending = _hiveDb.getPendingTaskActions();
    if (pending.isEmpty) return;

    final hasToken = _hiveDb.getAuthToken() != null;
    if (!hasToken) return;

    final deletedIds = pending
        .where((a) => a['action'] == 'delete')
        .map((a) => a['id'].toString())
        .toList();
        
    final modifications = pending
        .where((a) => a['action'] == 'upsert')
        .map((a) => Map<String, dynamic>.from(a['data'] as Map))
        .toList();

    try {
      final dio = _ref.read(dioClientProvider);
      final response = await dio.post('/tasks/sync', data: {
        'modifications': modifications,
        'deletedIds': deletedIds,
      });

      if (response.statusCode == 200) {
        await _hiveDb.savePendingTaskActions([]); // Clear queue on success
        
        // Use returned server data if available
        if (response.data['status'] == 'success' && response.data['data']['tasks'] != null) {
            final data = response.data['data']['tasks'] as List;
            final serverTasks = data.map((json) => TaskModel.fromMap(json as Map<String, dynamic>)).toList();
            await saveLocalTasks(serverTasks);
        }
      }
    } catch (e) {
      dev.log('Failed to sync offline tasks: $e');
    }
  }

  Future<void> queueTaskUpsert(TaskModel task) async {
    final pending = _hiveDb.getPendingTaskActions();
    // Remove older upsert for this id if exists
    pending.removeWhere((a) => a['id'] == task.id);
    
    pending.add({
      'action': 'upsert',
      'id': task.id,
      'data': task.toMap(),
    });
    await _hiveDb.savePendingTaskActions(pending);
  }

  Future<void> queueTaskDeletion(String taskId) async {
    final pending = _hiveDb.getPendingTaskActions();
    // Remove any older upserts for this id
    pending.removeWhere((a) => a['id'] == taskId);
    
    pending.add({
      'action': 'delete',
      'id': taskId,
    });
    await _hiveDb.savePendingTaskActions(pending);
  }
}
