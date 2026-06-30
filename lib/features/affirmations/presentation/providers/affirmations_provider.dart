import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/affirmation_model.dart';
import '../../data/repositories/affirmations_repository.dart';
import '../../../os_dashboard/presentation/providers/os_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class AffirmationsState {
  final List<DailyAffirmation> affirmations;
  final String activeCategory;
  final String searchQuery;
  final bool isSyncing;
  final bool isOffline;
  final int completedTodayCount;
  final int totalPracticedDays;

  AffirmationsState({
    this.affirmations = const [],
    this.activeCategory = 'All',
    this.searchQuery = '',
    this.isSyncing = false,
    this.isOffline = false,
    this.completedTodayCount = 0,
    this.totalPracticedDays = 14,
  });

  AffirmationsState copyWith({
    List<DailyAffirmation>? affirmations,
    String? activeCategory,
    String? searchQuery,
    bool? isSyncing,
    bool? isOffline,
    int? completedTodayCount,
    int? totalPracticedDays,
  }) {
    return AffirmationsState(
      affirmations: affirmations ?? this.affirmations,
      activeCategory: activeCategory ?? this.activeCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isSyncing: isSyncing ?? this.isSyncing,
      isOffline: isOffline ?? this.isOffline,
      completedTodayCount: completedTodayCount ?? this.completedTodayCount,
      totalPracticedDays: totalPracticedDays ?? this.totalPracticedDays,
    );
  }
}

class AffirmationsNotifier extends StateNotifier<AffirmationsState> {
  final AffirmationsRepository _repo;
  final Ref _ref;
  Timer? _syncTimer;

  AffirmationsNotifier(this._repo, this._ref) : super(AffirmationsState()) {
    _loadData();

    // Auto-retry sync in background every 30 seconds if offline or has pending items
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      final hasPending = state.affirmations.any((a) => a.syncStatus == SyncStatus.pending || a.syncStatus == SyncStatus.failed);
      if (hasPending || state.isOffline) {
        syncNow();
      }
    });
  }

  void clearAll() {
    _syncTimer?.cancel();
    state = AffirmationsState(affirmations: []);
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final local = _repo.getLocalAffirmations();
    final isGuest = _ref.read(authProvider).valueOrNull == null;

    // If empty and user is a guest, initialize default cards
    if (local.isEmpty && isGuest) {
      final defaults = [
        DailyAffirmation(
          id: 'def_1',
          title: 'Growth Mindset',
          text:
              'Challenges are opportunities to grow and expand my capabilities.',
          category: 'Mindset',
          backgroundStyle: 'Minimal White',
          colorTheme: 'Minimal White',
          isPinned: true,
          syncStatus: SyncStatus.synced,
        ),
        DailyAffirmation(
          id: 'def_2',
          title: 'Daily Discipline',
          text:
              'I choose consistency over temporary motivation. I finish what I start.',
          category: 'Discipline',
          backgroundStyle: 'Midnight Black',
          colorTheme: 'Midnight Black',
          syncStatus: SyncStatus.synced,
        ),
        DailyAffirmation(
          id: 'def_3',
          title: 'Grateful Heart',
          text:
              'I appreciate the little details today. Peace is within my control.',
          category: 'Gratitude',
          backgroundStyle: 'Sunrise Orange',
          colorTheme: 'Sunrise Orange',
          syncStatus: SyncStatus.synced,
        ),
      ];
      await _repo.saveLocalAffirmations(defaults);
      state = state.copyWith(affirmations: defaults);
    } else {
      state = state.copyWith(affirmations: local);
    }

    // Load fresh data from backend on startup if possible
    try {
      final remoteList = await _repo.fetchAffirmationsFromServer();
      if (remoteList != null) {
        final mergedList = <DailyAffirmation>[];
        mergedList.addAll(remoteList);

        // Keep local pending mutations
        final localPending = state.affirmations
            .where((a) => a.syncStatus == SyncStatus.pending || a.syncStatus == SyncStatus.failed)
            .toList();

        for (var localItem in localPending) {
          final idx = mergedList.indexWhere((r) => r.id == localItem.id);
          if (idx != -1) {
            mergedList[idx] = localItem;
          } else {
            mergedList.add(localItem);
          }
        }

        await _repo.saveLocalAffirmations(mergedList);
        state = state.copyWith(affirmations: mergedList, isOffline: false);
      }
    } catch (e) {
      // Offline fallback
    }

    // Try to sync initially
    syncNow();
  }

  // Filtered list getter helper
  List<DailyAffirmation> getFilteredAffirmations() {
    return state.affirmations.where((a) {
      final matchesCategory =
          state.activeCategory == 'All' ||
          a.category.toLowerCase() == state.activeCategory.toLowerCase();
      final matchesSearch =
          a.text.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          a.title.toLowerCase().contains(state.searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void setActiveCategory(String category) {
    state = state.copyWith(activeCategory: category);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // Add a new affirmation
  Future<void> addAffirmation(DailyAffirmation aff) async {
    final isGuest = _ref.read(authProvider).value == null;
    if (isGuest) {
      final createdCount = state.affirmations.where((a) => !a.id.startsWith('def_') && !a.id.startsWith('a_seed_')).length;
      if (createdCount >= 2) {
        _ref.read(premiumAuthTriggerProvider.notifier).state = 'affirmation';
        return;
      }
    }

    final pendingAff = aff.copyWith(syncStatus: SyncStatus.pending);
    final list = [...state.affirmations, pendingAff];
    state = state.copyWith(affirmations: list);
    await _repo.saveLocalAffirmations(list);
    // Silent background sync
    syncNow();
  }

  // Update existing affirmation
  Future<void> updateAffirmation(DailyAffirmation updated) async {
    final pendingAff = updated.copyWith(syncStatus: SyncStatus.pending);
    final list = state.affirmations
        .map((a) => a.id == updated.id ? pendingAff : a)
        .toList();
    state = state.copyWith(affirmations: list);
    await _repo.saveLocalAffirmations(list);
    // Silent background sync
    syncNow();
  }

  // Delete affirmation
  Future<void> deleteAffirmation(String id) async {
    final list = state.affirmations.where((a) => a.id != id).toList();
    state = state.copyWith(affirmations: list);
    await _repo.saveLocalAffirmations(list);
    await _repo.trackPendingDeletion(id);
    // Silent background sync
    syncNow();
  }

  // Toggle pinned card
  Future<void> togglePin(String id) async {
    final list = state.affirmations.map((a) {
      if (a.id == id) {
        return a.copyWith(isPinned: !a.isPinned, syncStatus: SyncStatus.pending);
      }
      if (a.isPinned) {
        return a.copyWith(isPinned: false, syncStatus: SyncStatus.pending);
      }
      return a;
    }).toList();
    state = state.copyWith(affirmations: list);
    await _repo.saveLocalAffirmations(list);
    syncNow();
  }

  // Toggle favorite
  Future<void> toggleFavorite(String id) async {
    final list = state.affirmations.map((a) {
      if (a.id == id) {
        return a.copyWith(isFavorite: !a.isFavorite, syncStatus: SyncStatus.pending);
      }
      return a;
    }).toList();
    state = state.copyWith(affirmations: list);
    await _repo.saveLocalAffirmations(list);
    syncNow();
  }

  // Reorder affirmations
  Future<void> reorderAffirmations(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final list = [...state.affirmations];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item.copyWith(syncStatus: SyncStatus.pending));

    final pendingList = list.map((a) => a.copyWith(syncStatus: SyncStatus.pending)).toList();
    state = state.copyWith(affirmations: pendingList);
    await _repo.saveLocalAffirmations(pendingList);
    syncNow();
  }

  // Duplicate card
  Future<void> duplicateAffirmation(String id) async {
    final isGuest = _ref.read(authProvider).value == null;
    if (isGuest) {
      final createdCount = state.affirmations.where((a) => !a.id.startsWith('def_') && !a.id.startsWith('a_seed_')).length;
      if (createdCount >= 2) {
        _ref.read(premiumAuthTriggerProvider.notifier).state = 'affirmation';
        return;
      }
    }

    final original = state.affirmations.firstWhere((a) => a.id == id);
    final copy = original.copyWith(
      id: const Uuid().v4(),
      title: '${original.title} (Copy)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );
    final list = [...state.affirmations, copy];
    state = state.copyWith(affirmations: list);
    await _repo.saveLocalAffirmations(list);
    syncNow();
  }

  // Complete practicing today's affirmations (Gains small XP)
  void completePractice() {
    state = state.copyWith(completedTodayCount: state.completedTodayCount + 1);
    // Award 15 XP through the OS dashboard system provider
    _ref
        .read(osStateProvider.notifier)
        .toggleHabitCompletion(
          'daily_affirmation_practice_${const Uuid().v4()}',
        );
  }

  // Force sync
  Future<void> syncNow() async {
    if (state.isSyncing) return;
    state = state.copyWith(isSyncing: true);

    final success = await _repo.syncWithBackend(state.affirmations);
    if (success) {
      final updatedList = state.affirmations.map((a) {
        if (a.syncStatus != SyncStatus.synced) {
          return a.copyWith(syncStatus: SyncStatus.synced);
        }
        return a;
      }).toList();
      await _repo.saveLocalAffirmations(updatedList);
      state = state.copyWith(
        affirmations: updatedList,
        isSyncing: false,
        isOffline: false,
      );
    } else {
      final updatedList = state.affirmations.map((a) {
        if (a.syncStatus == SyncStatus.pending) {
          return a.copyWith(syncStatus: SyncStatus.failed);
        }
        return a;
      }).toList();
      await _repo.saveLocalAffirmations(updatedList);
      state = state.copyWith(
        affirmations: updatedList,
        isSyncing: false,
        isOffline: true,
      );
    }
  }
}

final affirmationsProvider =
    StateNotifierProvider<AffirmationsNotifier, AffirmationsState>((ref) {
      ref.watch(authProvider); // Rebuild automatically on user login/logout/change
      final repo = ref.watch(affirmationsRepositoryProvider);
      return AffirmationsNotifier(repo, ref);
    });
