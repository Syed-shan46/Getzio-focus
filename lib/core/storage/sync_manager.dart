import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'hive_database.dart';
import '../../shared/providers/app_providers.dart';

class PendingSyncAction {
  final String id;
  final String operation; // 'create' | 'update' | 'delete'
  final String collection; // 'vision_room' | 'tasks' | 'affirmations'
  final String documentId;
  final Map<String, dynamic>? payload;
  final int retryCount;
  final DateTime createdAt;
  final DateTime? lastAttempt;

  PendingSyncAction({
    required this.id,
    required this.operation,
    required this.collection,
    required this.documentId,
    this.payload,
    this.retryCount = 0,
    required this.createdAt,
    this.lastAttempt,
  });

  factory PendingSyncAction.fromMap(Map<String, dynamic> map) {
    return PendingSyncAction(
      id: map['id'] ?? '',
      operation: map['operation'] ?? '',
      collection: map['collection'] ?? '',
      documentId: map['documentId'] ?? '',
      payload: map['payload'] != null ? Map<String, dynamic>.from(map['payload']) : null,
      retryCount: map['retryCount'] ?? 0,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      lastAttempt: map['lastAttempt'] != null ? DateTime.tryParse(map['lastAttempt'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'operation': operation,
    'collection': collection,
    'documentId': documentId,
    'payload': payload,
    'retryCount': retryCount,
    'createdAt': createdAt.toIso8601String(),
    'lastAttempt': lastAttempt?.toIso8601String(),
  };
}

class SyncManager {
  final HiveDatabase _hiveDb;
  final Ref _ref;
  bool _isProcessing = false;

  SyncManager(this._hiveDb, this._ref);

  Future<void> processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final queue = _hiveDb.getPendingSyncQueue();
      if (queue.isEmpty) {
        _isProcessing = false;
        return;
      }

      final hasToken = _hiveDb.getAuthToken() != null;
      if (!hasToken) {
        _isProcessing = false;
        return;
      }

      final dio = _ref.read(dioClientProvider);

      for (var actionMap in queue) {
        final action = PendingSyncAction.fromMap(actionMap);
        bool success = false;
        
        try {
          if (action.collection == 'tasks') {
            if (action.operation == 'create' || action.operation == 'update') {
              final response = await dio.post('/tasks/sync', data: {
                'modifications': [action.payload],
                'deletedIds': [],
              });
              if (response.statusCode == 200) success = true;
            } else if (action.operation == 'delete') {
              final response = await dio.post('/tasks/sync', data: {
                'modifications': [],
                'deletedIds': [action.documentId],
              });
              if (response.statusCode == 200) success = true;
            }
          } else if (action.collection == 'affirmations') {
            if (action.operation == 'create' || action.operation == 'update') {
              final response = await dio.post('/focus/affirmations', data: action.payload);
              if (response.statusCode == 200 || response.statusCode == 201) success = true;
            } else if (action.operation == 'delete') {
              final list = _hiveDb.getSelectedAffirmations();
              final response = await dio.post('/focus/sync', data: {'affirmations': list});
              if (response.statusCode == 200) success = true;
            }
          } else if (action.collection == 'vision_room') {
            if (action.operation == 'create') {
              final response = await dio.post('/focus/vision-room/item', data: action.payload);
              if (response.statusCode == 200 || response.statusCode == 201) success = true;
            } else if (action.operation == 'update') {
              final response = await dio.patch('/focus/vision-room/item/${action.documentId}', data: action.payload);
              if (response.statusCode == 200) success = true;
            } else if (action.operation == 'delete') {
              final response = await dio.delete('/focus/vision-room/item/${action.documentId}');
              if (response.statusCode == 200) success = true;
            }
          }
        } catch (e) {
          log('[SyncManager] Failed to sync action ${action.id}: $e');
        }

        if (success) {
          await _hiveDb.removeFromPendingSync(action.id);
          log('[SyncManager] Action ${action.id} synced successfully and removed from queue');
        } else {
          final updated = PendingSyncAction(
            id: action.id,
            operation: action.operation,
            collection: action.collection,
            documentId: action.documentId,
            payload: action.payload,
            retryCount: action.retryCount + 1,
            createdAt: action.createdAt,
            lastAttempt: DateTime.now(),
          );
          await _hiveDb.addToPendingSync(updated.toMap());
        }
      }
    } catch (e) {
      log('[SyncManager] Error processing queue: $e');
    } finally {
      _isProcessing = false;
    }
  }
}

final syncManagerProvider = Provider<SyncManager>((ref) {
  final hiveDb = ref.watch(hiveDatabaseProvider);
  return SyncManager(hiveDb, ref);
});
