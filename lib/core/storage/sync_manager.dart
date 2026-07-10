import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'hive_database.dart';
import '../../shared/providers/app_providers.dart';

final pendingSyncCountProvider = StateProvider<int>((ref) {
  // Try to initialize with current count if database is open
  try {
    final hiveDb = ref.watch(hiveDatabaseProvider);
    return hiveDb.getPendingSyncQueue().length;
  } catch (_) {
    return 0;
  }
});

class PendingSyncAction {
  final String id;
  final String operation; // 'create' | 'update' | 'delete' | 'create_milestone' | 'update_milestone' | 'delete_milestone' | 'create_subtask' | 'update_subtask' | 'delete_subtask'
  final String collection; // 'vision_room' | 'tasks' | 'affirmations' | 'sticky_notes' | 'settings' | 'goals'
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

class SyncQueueService {
  final HiveDatabase _hiveDb;
  final Ref _ref;
  bool _isProcessing = false;
  Timer? _retryTimer;

  SyncQueueService(this._hiveDb, this._ref) {
    _startRetryTimer();
  }

  void _startRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      final token = _hiveDb.getAuthToken();
      if (token != null && token.isNotEmpty) {
        final count = _hiveDb.getPendingSyncQueue().length;
        if (count > 0) {
          log('[SyncQueue] Periodic retry: processing $count pending actions...');
          await processQueue();
        }
      }
    });
  }

  void dispose() {
    _retryTimer?.cancel();
  }

  int getPendingSyncCount() {
    return _hiveDb.getPendingSyncQueue().length;
  }

  Future<void> queueAction({
    required String collection,
    required String operation,
    required String documentId,
    Map<String, dynamic>? payload,
  }) async {
    final hasToken = _hiveDb.getAuthToken() != null;
    
    // Always store locally first
    final action = PendingSyncAction(
      id: '${collection}_${documentId}_${DateTime.now().millisecondsSinceEpoch}',
      operation: operation,
      collection: collection,
      documentId: documentId,
      payload: payload,
      createdAt: DateTime.now(),
    );

    await _hiveDb.addToPendingSync(action.toMap());
    _updateCountState();

    if (hasToken) {
      // Trigger background process immediately if online
      triggerSync();
    }
  }

  void triggerSync() {
    Future.microtask(() => processQueue());
  }

  void _updateCountState() {
    try {
      final count = getPendingSyncCount();
      _ref.read(pendingSyncCountProvider.notifier).state = count;
    } catch (_) {}
  }

  Future<void> processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final queue = _hiveDb.getPendingSyncQueue();
      if (queue.isEmpty) {
        _isProcessing = false;
        _updateCountState();
        return;
      }

      final hasToken = _hiveDb.getAuthToken() != null;
      if (!hasToken) {
        _isProcessing = false;
        _updateCountState();
        return;
      }

      final dio = _ref.read(dioClientProvider);

      for (var actionMap in queue) {
        final action = PendingSyncAction.fromMap(actionMap);
        bool success = false;
        bool shouldDrop = false; // drop action if it's invalid (e.g. 404 or conflict resolution drop)

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
          } else if (action.collection == 'goals') {
            final goalId = action.payload?['goalId'] ?? action.documentId;
            final milestoneId = action.payload?['milestoneId'];
            if (action.operation == 'create') {
              final response = await dio.post('/focus/goals', data: action.payload);
              if (response.statusCode == 200 || response.statusCode == 201) success = true;
            } else if (action.operation == 'update') {
              final response = await dio.patch('/focus/goals/${action.documentId}', data: action.payload);
              if (response.statusCode == 200) success = true;
            } else if (action.operation == 'delete') {
              final response = await dio.delete('/focus/goals/${action.documentId}');
              if (response.statusCode == 200) success = true;
            } else if (action.operation == 'create_milestone') {
              final response = await dio.post('/focus/goals/$goalId/milestones', data: action.payload);
              if (response.statusCode == 200 || response.statusCode == 201) success = true;
            } else if (action.operation == 'update_milestone') {
              final response = await dio.patch('/focus/goals/$goalId/milestones/$milestoneId', data: action.payload);
              if (response.statusCode == 200) success = true;
            } else if (action.operation == 'delete_milestone') {
              final response = await dio.delete('/focus/goals/$goalId/milestones/$milestoneId');
              if (response.statusCode == 200) success = true;
            } else if (action.operation == 'create_subtask') {
              final response = await dio.post('/focus/goals/$goalId/milestones/$milestoneId/subtasks', data: action.payload);
              if (response.statusCode == 200 || response.statusCode == 201) success = true;
            } else if (action.operation == 'update_subtask') {
              final subtaskId = action.documentId;
              final response = await dio.patch('/focus/goals/$goalId/milestones/$milestoneId/subtasks/$subtaskId', data: action.payload);
              if (response.statusCode == 200) success = true;
            } else if (action.operation == 'delete_subtask') {
              final subtaskId = action.documentId;
              final response = await dio.delete('/focus/goals/$goalId/milestones/$milestoneId/subtasks/$subtaskId');
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
          } else if (action.collection == 'sticky_notes') {
            if (action.operation == 'create') {
              final response = await dio.post('/sticky-notes', data: action.payload);
              if (response.statusCode == 200 || response.statusCode == 201) success = true;
            } else if (action.operation == 'update') {
              final response = await dio.patch('/sticky-notes/${action.documentId}', data: action.payload);
              if (response.statusCode == 200) success = true;
            } else if (action.operation == 'delete') {
              final response = await dio.delete('/sticky-notes/${action.documentId}');
              if (response.statusCode == 200 || response.statusCode == 204) success = true;
            }
          } else if (action.collection == 'settings') {
            final response = await dio.post('/focus/onboarding', data: action.payload);
            if (response.statusCode == 200 || response.statusCode == 201) success = true;
          }
        } catch (e) {
          log('[SyncQueue] Failed to sync action ${action.id}: $e');
          // If server reports 404 or invalid payload (400), don't retry infinitely
          if (e.toString().contains('404') || e.toString().contains('400')) {
            shouldDrop = true;
          }
        }

        if (success || shouldDrop) {
          await _hiveDb.removeFromPendingSync(action.id);
          log('[SyncQueue] Action ${action.id} processed (success: $success, dropped: $shouldDrop) and removed from queue');
        } else {
          // If we failed due to connection issues, stop loop processing to preserve order and retry later
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
          break; // break processing loop to retry in next timer tick
        }
      }
    } catch (e) {
      log('[SyncQueue] Error processing queue: $e');
    } finally {
      _isProcessing = false;
      _updateCountState();
    }
  }
}

// Retain alias for backward compatibility
typedef SyncManager = SyncQueueService;

final syncQueueServiceProvider = Provider<SyncQueueService>((ref) {
  final hiveDb = ref.watch(hiveDatabaseProvider);
  return SyncQueueService(hiveDb, ref);
});

final syncManagerProvider = Provider<SyncManager>((ref) {
  return ref.watch(syncQueueServiceProvider);
});
