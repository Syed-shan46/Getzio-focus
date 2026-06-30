import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/sticky_note.dart';
import '../datasources/sticky_note_remote_datasource.dart';

class StickyNoteRepository {
  final StickyNoteRemoteDataSource remoteDataSource;
  
  StickyNoteRepository({required this.remoteDataSource});

  // Determines which box to use based on authentication
  Future<Box<StickyNote>> _getBox(String? userId) async {
    if (userId == null || userId.isEmpty) {
      if (!Hive.isBoxOpen('guest_sticky_notes')) {
        await Hive.openBox<StickyNote>('guest_sticky_notes');
      }
      return Hive.box<StickyNote>('guest_sticky_notes');
    } else {
      final boxName = 'sticky_notes_$userId';
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<StickyNote>(boxName);
      }
      return Hive.box<StickyNote>(boxName);
    }
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
    
    // If authenticated, try to fetch from remote
    if (userId != null && userId.isNotEmpty) {
      try {
        final remoteNotes = await remoteDataSource.getStickyNotes(userId);
        // Sync local cache
        await box.clear();
        for (var note in remoteNotes) {
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
    await box.put(note.id, note);

    if (userId != null && userId.isNotEmpty) {
      try {
        // Attempt immediate sync
        final savedNote = await remoteDataSource.createStickyNote(note);
        await box.put(savedNote.id, savedNote);
      } catch (e) {
        // Queue for offline sync
        note.pendingSync = true;
        await box.put(note.id, note);
        await _queueSyncAction('CREATE', note);
      }
    }
  }

  Future<void> updateStickyNote(StickyNote note, String? userId) async {
    final box = await _getBox(userId);
    await box.put(note.id, note);

    if (userId != null && userId.isNotEmpty) {
      try {
        final updatedNote = await remoteDataSource.updateStickyNote(note);
        await box.put(updatedNote.id, updatedNote);
      } catch (e) {
        note.pendingSync = true;
        await box.put(note.id, note);
        await _queueSyncAction('UPDATE', note);
      }
    }
  }

  Future<void> deleteStickyNote(String id, String? userId) async {
    final box = await _getBox(userId);
    final note = box.get(id);
    if (note != null) {
      note.deleted = true;
      await box.put(id, note);
    }

    if (userId != null && userId.isNotEmpty) {
      try {
        await remoteDataSource.deleteStickyNote(id);
      } catch (e) {
        if (note != null) {
          await _queueSyncAction('DELETE', note);
        }
      }
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
