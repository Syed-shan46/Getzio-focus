import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/sticky_note.dart';
import '../../data/datasources/sticky_note_remote_datasource.dart';
import '../../data/repositories/sticky_note_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../shared/providers/app_providers.dart';

final stickyNoteRepositoryProvider = Provider<StickyNoteRepository>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  final remoteDataSource = StickyNoteRemoteDataSource(dio: dio);
  return StickyNoteRepository(remoteDataSource: remoteDataSource);
});

// Provides the list of sticky notes based on the current user
class StickyNoteNotifier extends StateNotifier<List<StickyNote>> {
  final StickyNoteRepository repository;
  final String? userId;
  final Map<String, Timer> _debouncers = {};

  StickyNoteNotifier(this.repository, this.userId) : super([]) {
    loadNotes();
  }

  @override
  void dispose() {
    for (final timer in _debouncers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  Future<void> loadNotes() async {
    state = await repository.getStickyNotes(userId);
  }

  Future<void> addNote(StickyNote note) async {
    // Optimistic UI update
    state = [...state, note];
    // Background sync
    await repository.saveStickyNote(note, userId);
  }

  void updateNote(StickyNote updatedNote) {
    // Optimistic UI update immediately
    state = [
      for (final note in state)
        if (note.id == updatedNote.id) updatedNote else note
    ];
    
    // Debounce background sync to prevent API spam during drag/resize
    _debouncers[updatedNote.id]?.cancel();
    _debouncers[updatedNote.id] = Timer(const Duration(milliseconds: 500), () async {
      try {
        await repository.updateStickyNote(updatedNote, userId);
      } catch (e) {
        // Handle error if needed
      }
    });
  }

  Future<void> deleteNote(String id) async {
    // Optimistic UI update
    state = state.where((note) => note.id != id).toList();
    // Background sync
    await repository.deleteStickyNote(id, userId);
  }

  Future<void> handleLoginContinueAndSave(String newUserId) async {
    await repository.migrateGuestToAuthenticated(newUserId);
    // Reload state for new user
    state = await repository.getStickyNotes(newUserId);
  }

  Future<void> handleLoginStartFresh(String newUserId) async {
    await repository.clearGuestData();
    // Reload state for new user
    state = await repository.getStickyNotes(newUserId);
  }
}

final stickyNotesProvider = StateNotifierProvider<StickyNoteNotifier, List<StickyNote>>((ref) {
  final repository = ref.watch(stickyNoteRepositoryProvider);
  final authState = ref.watch(authProvider);
  final userId = authState.value?.id;
  
  return StickyNoteNotifier(repository, userId);
});
