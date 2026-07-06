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
    
    // Seeding default sticky notes from account for guest users if they haven't been seeded yet
    if (userId == null || userId.isEmpty) {
      final hasNewDefaults = box.values.any((note) => note.id == '05037d33-2f58-4141-a781-ba5306d1afef');
      if (!hasNewDefaults) {
        await box.clear();
        final defaults = _getDefaultStickyNotes();
        for (var note in defaults) {
          await box.put(note.id, note);
        }
      }
    }
    
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

  List<StickyNote> _getDefaultStickyNotes() {
    return [
      StickyNote(
        id: "05037d33-2f58-4141-a781-ba5306d1afef",
        userId: "guest",
        title: "Build Your Future",
        description: "Every small step moves you closer to your dream.",
        progress: 19,
        x: 228.604,
        y: 388.750,
        rotation: -0.007588,
        scale: 0.4476,
        pinStyle: "default",
        color: "#93C5FD",
      ),
      StickyNote(
        id: "0d4aeed2-0d95-4ff2-b85d-23fc223e0f0a",
        userId: "guest",
        title: "Capture Every Thought",
        description: "Create beautiful sticky notes with priorities",
        progress: 32,
        dueDate: DateTime.tryParse("2026-07-31T00:00:00.000Z"),
        x: 230.666,
        y: 209.604,
        rotation: -0.02807,
        scale: 0.4605,
        pinStyle: "default",
        color: "#FFFFFF",
      ),
      StickyNote(
        id: "3ab6153a-107c-4556-97ee-107579279b05",
        userId: "guest",
        title: "One Step at a Time",
        description: "Every small step moves you closer to your dream.",
        progress: 12,
        x: -41.958,
        y: 579.416,
        rotation: -0.01817,
        scale: 0.3659,
        pinStyle: "default",
        color: "#86EFAC",
      ),
      StickyNote(
        id: "8c792fd1-c4bf-4929-a875-590351e54c73",
        userId: "guest",
        title: "Keep Moving",
        description: "Progress beats perfection every single day.",
        progress: 0,
        x: 245.083,
        y: 54.927,
        rotation: -0.005697,
        scale: 0.3169,
        pinStyle: "default",
        color: "#C084FC",
      ),
      StickyNote(
        id: "af1135f4-eace-4d2d-96b0-61fe4dedbada",
        userId: "guest",
        title: "More Than Just Sticky Notes",
        description: "Add titles, checklists, priorities, due dates, and progress to stay focused on what matters.",
        progress: 47,
        x: 239.020,
        y: -5.125,
        rotation: -0.01225,
        scale: 0.3328,
        pinStyle: "default",
        color: "#93C5FD",
      ),
      StickyNote(
        id: "bb174570-c4f4-400e-b029-d5e201f112df",
        userId: "guest",
        title: "Dream Bigger",
        description: "Your future grows from today's consistent effort.",
        progress: 0,
        x: 239.541,
        y: 558.322,
        rotation: -0.001296,
        scale: 0.3468,
        pinStyle: "default",
        color: "#FBCFE8",
      ),
      StickyNote(
        id: "c3b8f44d-443e-431e-8212-692a22567f12",
        userId: "guest",
        title: "Success Formula",
        description: "Stay focused, stay patient, and never stop growing.",
        progress: 0,
        x: -13.291,
        y: 482.895,
        rotation: -0.01586,
        scale: 0.6420,
        pinStyle: "default",
        color: "#FDBA74",
      ),
    ];
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
