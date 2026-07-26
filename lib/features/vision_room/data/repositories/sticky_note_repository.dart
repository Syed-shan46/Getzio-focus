import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/sticky_note.dart';
import '../datasources/sticky_note_remote_datasource.dart';
import '../../../../core/storage/sync_manager.dart';

class StickyNoteRepository {
  final StickyNoteRemoteDataSource remoteDataSource;
  final Ref? _ref;
  
  StickyNoteRepository({required this.remoteDataSource, Ref? ref}) : _ref = ref;

  // Determines which box to use based on authentication
  Future<Box<StickyNote>> _getBox(String? userId) async {
    if (!Hive.isBoxOpen('sticky_notes')) {
      await Hive.openBox<StickyNote>('sticky_notes');
    }
    return Hive.box<StickyNote>('sticky_notes');
  }

  Future<void> _queueSyncAction(String action, StickyNote note) async {
    final box = await Hive.openBox<Map>('pending_sync_actions');
    await box.add({
      'action': action,
      'data': note.toJson(),
    });
  }

  Future<List<StickyNote>> getStickyNotes(String? userId) async {
    final box = await _getBox(userId);
    
    // Clear out any old sample sticky notes from the box so they disappear
    final sampleIds = {
      '05037d33-2f58-4141-a781-ba5306d1afef',
      '0d4aeed2-0d95-4ff2-b85d-23fc223e0f0a',
      '3ab6153a-107c-4556-97ee-107579279b05',
      '8c792fd1-c4bf-4929-a875-590351e54c73',
      'af1135f4-eace-4d2d-96b0-61fe4dedbada',
      'bb174570-c4f4-400e-b029-d5e201f112df',
      'c3b8f44d-443e-431e-8212-692a22567f12',
    };
    for (var id in sampleIds) {
      if (box.containsKey(id)) {
        await box.delete(id);
      }
    }
    
    // If authenticated, try to fetch from remote
    if (userId != null && userId.isNotEmpty) {
      try {
        final remoteNotes = await remoteDataSource.getStickyNotes(userId);
        // Sync local cache: preserve local pending or deleted changes
        final localPending = box.values.where((n) => n.pendingSync || n.deleted).toList();
        await box.clear();
        for (var note in remoteNotes) {
          final isPendingLocally = localPending.any((ln) => ln.id == note.id);
          if (!isPendingLocally) {
            await box.put(note.id, note);
          }
        }
        for (var note in localPending) {
          await box.put(note.id, note);
        }
      } catch (e) {
        // Silent fail on fetch, rely on cache
        print('Failed to fetch from remote: $e');
      }
    }
    
    return box.values.where((n) => !n.deleted).toList();
  }



  Future<void> saveStickyNote(StickyNote note, String? userId) async {
    final box = await _getBox(userId);
    note.pendingSync = true;
    await box.put(note.id, note);

    if (_ref != null) {
      _ref!.read(syncQueueServiceProvider).triggerSync();
    }
  }

  Future<void> updateStickyNote(StickyNote note, String? userId) async {
    final box = await _getBox(userId);
    note.pendingSync = true;
    await box.put(note.id, note);

    if (_ref != null) {
      _ref!.read(syncQueueServiceProvider).triggerSync();
    }
  }

  Future<void> deleteStickyNote(String id, String? userId) async {
    final box = await _getBox(userId);
    final note = box.get(id);
    if (note != null) {
      note.deleted = true;
      note.pendingSync = true;
      await box.put(id, note);
    }

    if (_ref != null) {
      _ref!.read(syncQueueServiceProvider).triggerSync();
    }
  }

  // Called when logging in with "Continue & Save"
  Future<void> migrateGuestToAuthenticated(String newUserId) async {
    final guestBox = await _getBox(null);
    final authBox = await _getBox(newUserId);

    final guestNotes = guestBox.values.toList();
    
    for (var note in guestNotes) {
      final updatedNote = note.copyWith(userId: newUserId);
      await authBox.put(updatedNote.id, updatedNote);
      
      // Upload to remote
      try {
        final remote = await remoteDataSource.createStickyNote(updatedNote);
        await authBox.put(remote.id, remote);
      } catch (e) {
        await _queueSyncAction('CREATE', updatedNote);
      }
    }
    
    // Clear guest cache
    await guestBox.clear();
  }

  // Called when logging in with "Start Fresh"
  Future<void> clearGuestData() async {
    final guestBox = await _getBox(null);
    await guestBox.clear();
  }
}
