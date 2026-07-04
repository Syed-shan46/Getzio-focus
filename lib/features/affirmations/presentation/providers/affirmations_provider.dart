import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/affirmation_model.dart';
import '../../data/repositories/affirmations_repository.dart';
import '../../../os_dashboard/presentation/providers/os_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/storage/sync_manager.dart';
import '../../../../shared/providers/app_providers.dart';

class AffirmationsState {
  final List<DailyAffirmation> affirmations;
  final String activeCategory;
  final String searchQuery;
  final bool isSyncing;
  final bool isOffline;
  final int completedTodayCount;
  final int totalPracticedDays;
  final Map<String, int> repeatCounts;
  final String? lastViewedAffirmationId;
  final DateTime? lastViewedAt;

  AffirmationsState({
    this.affirmations = const [],
    this.activeCategory = 'All',
    this.searchQuery = '',
    this.isSyncing = false,
    this.isOffline = false,
    this.completedTodayCount = 0,
    this.totalPracticedDays = 14,
    this.repeatCounts = const {},
    this.lastViewedAffirmationId,
    this.lastViewedAt,
  });

  AffirmationsState copyWith({
    List<DailyAffirmation>? affirmations,
    String? activeCategory,
    String? searchQuery,
    bool? isSyncing,
    bool? isOffline,
    int? completedTodayCount,
    int? totalPracticedDays,
    Map<String, int>? repeatCounts,
    String? lastViewedAffirmationId,
    DateTime? lastViewedAt,
  }) {
    return AffirmationsState(
      affirmations: affirmations ?? this.affirmations,
      activeCategory: activeCategory ?? this.activeCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isSyncing: isSyncing ?? this.isSyncing,
      isOffline: isOffline ?? this.isOffline,
      completedTodayCount: completedTodayCount ?? this.completedTodayCount,
      totalPracticedDays: totalPracticedDays ?? this.totalPracticedDays,
      repeatCounts: repeatCounts ?? this.repeatCounts,
      lastViewedAffirmationId:
          lastViewedAffirmationId ?? this.lastViewedAffirmationId,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
    );
  }
}

class AffirmationsNotifier extends StateNotifier<AffirmationsState> {
  final AffirmationsRepository _repo;
  final Ref _ref;

  AffirmationsNotifier(this._repo, this._ref) : super(AffirmationsState()) {
    _loadData();
  }

  void clearAll() {
    state = AffirmationsState(affirmations: []);
  }

  Future<void> _loadData() async {
    final local = _repo.getLocalAffirmations();
    final isGuest = _ref.read(authProvider).valueOrNull == null;

    if (local.isEmpty && isGuest) {
      final defaults = [
        DailyAffirmation(
          id: 'def_1',
          title: 'Growth Mindset',
          text:
              'Challenges are opportunities to grow and expand my capabilities.',
          category: 'Mindset',
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
          colorTheme: 'Midnight Black',
          syncStatus: SyncStatus.synced,
        ),
        DailyAffirmation(
          id: 'def_3',
          title: 'Grateful Heart',
          text:
              'I appreciate the little details today. Peace is within my control.',
          category: 'Gratitude',
          colorTheme: 'Sunrise Orange',
          syncStatus: SyncStatus.synced,
        ),
      ];
      await _repo.saveLocalAffirmations(defaults);
      state = state.copyWith(affirmations: defaults);
    } else {
      state = state.copyWith(affirmations: local);
    }

    final hasToken = _ref.read(hiveDatabaseProvider).getAuthToken() != null;
    if (!hasToken) return;

    _repo
        .fetchAffirmationsFromServer()
        .then((remoteList) async {
          if (remoteList != null) {
            final localJson = jsonEncode(
              state.affirmations.map((a) => a.toMap()).toList(),
            );
            final remoteJson = jsonEncode(
              remoteList.map((a) => a.toMap()).toList(),
            );

            if (localJson != remoteJson) {
              await _repo.saveLocalAffirmations(remoteList);
              state = state.copyWith(
                affirmations: remoteList,
                isOffline: false,
              );
            }
          }
          _ref.read(syncManagerProvider).processQueue();
        })
        .catchError((e) {
          print('Error fetching affirmations silently: $e');
        });
  }

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

  Future<void> addAffirmation(DailyAffirmation aff) async {
    final isGuest = _ref.read(authProvider).value == null;
    if (isGuest) {
      final createdCount = state.affirmations
          .where((a) => !a.id.startsWith('def_') && !a.id.startsWith('a_seed_'))
          .length;
      if (createdCount >= 2) {
        _ref.read(premiumAuthTriggerProvider.notifier).state = 'affirmation';
        return;
      }
    }

    final pendingAff = aff.copyWith(syncStatus: SyncStatus.pending);
    final list = [...state.affirmations, pendingAff];
    state = state.copyWith(affirmations: list);
    await _repo.saveLocalAffirmations(list);

    final hasToken = _ref.read(hiveDatabaseProvider).getAuthToken() != null;
    if (hasToken) {
      _repo
          .createAffirmationOnServer(pendingAff)
          .then((synced) async {
            if (synced != null) {
              final updatedList = state.affirmations
                  .map((a) => a.id == aff.id ? synced : a)
                  .toList();
              state = state.copyWith(affirmations: updatedList);
              await _repo.saveLocalAffirmations(updatedList);
            } else {
              await _repo.queueAffirmationUpsert(pendingAff);
            }
          })
          .catchError((e) async {
            await _repo.queueAffirmationUpsert(pendingAff);
          });
    }
  }

  Future<void> updateAffirmation(DailyAffirmation updated) async {
    final pendingAff = updated.copyWith(syncStatus: SyncStatus.pending);
    final list = state.affirmations
        .map((a) => a.id == updated.id ? pendingAff : a)
        .toList();
    state = state.copyWith(affirmations: list);
    await _repo.saveLocalAffirmations(list);

    final hasToken = _ref.read(hiveDatabaseProvider).getAuthToken() != null;
    if (hasToken) {
      _repo
          .syncWithBackend(list)
          .then((success) async {
            if (success) {
              final updatedList = state.affirmations
                  .map(
                    (a) => a.id == updated.id
                        ? a.copyWith(syncStatus: SyncStatus.synced)
                        : a,
                  )
                  .toList();
              state = state.copyWith(affirmations: updatedList);
              await _repo.saveLocalAffirmations(updatedList);
            } else {
              await _repo.queueAffirmationUpsert(pendingAff);
            }
          })
          .catchError((e) async {
            await _repo.queueAffirmationUpsert(pendingAff);
          });
    }
  }

  Future<void> deleteAffirmation(String id) async {
    final list = state.affirmations.where((a) => a.id != id).toList();
    state = state.copyWith(affirmations: list);
    await _repo.saveLocalAffirmations(list);
    await _repo.trackPendingDeletion(id);

    final hasToken = _ref.read(hiveDatabaseProvider).getAuthToken() != null;
    if (hasToken) {
      _repo.syncWithBackend(list).catchError((e) async {
        await _repo.queueAffirmationDeletion(id);
        return false;
      });
    }
  }

  Future<void> togglePin(String id) async {
    final list = state.affirmations.map((a) {
      if (a.id == id) {
        return a.copyWith(
          isPinned: !a.isPinned,
          syncStatus: SyncStatus.pending,
        );
      }
      if (a.isPinned) {
        return a.copyWith(isPinned: false, syncStatus: SyncStatus.pending);
      }
      return a;
    }).toList();
    state = state.copyWith(affirmations: list);
    await _repo.saveLocalAffirmations(list);

    _repo.syncWithBackend(list).then((success) async {
      if (success) {
        final syncedList = state.affirmations
            .map(
              (a) => a.syncStatus == SyncStatus.pending
                  ? a.copyWith(syncStatus: SyncStatus.synced)
                  : a,
            )
            .toList();
        state = state.copyWith(affirmations: syncedList);
        await _repo.saveLocalAffirmations(syncedList);
      }
    });
  }

  Future<void> toggleFavorite(String id) async {
    final list = state.affirmations.map((a) {
      if (a.id == id) {
        return a.copyWith(
          isFavorite: !a.isFavorite,
          syncStatus: SyncStatus.pending,
        );
      }
      return a;
    }).toList();
    state = state.copyWith(affirmations: list);
    await _repo.saveLocalAffirmations(list);

    _repo.syncWithBackend(list).then((success) async {
      if (success) {
        final syncedList = state.affirmations
            .map(
              (a) => a.id == id ? a.copyWith(syncStatus: SyncStatus.synced) : a,
            )
            .toList();
        state = state.copyWith(affirmations: syncedList);
        await _repo.saveLocalAffirmations(syncedList);
      }
    });
  }

  Future<void> reorderAffirmations(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final list = [...state.affirmations];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item.copyWith(syncStatus: SyncStatus.pending));

    final pendingList = list
        .map((a) => a.copyWith(syncStatus: SyncStatus.pending))
        .toList();
    state = state.copyWith(affirmations: pendingList);
    await _repo.saveLocalAffirmations(pendingList);

    _repo.syncWithBackend(pendingList).then((success) async {
      if (success) {
        final syncedList = state.affirmations
            .map((a) => a.copyWith(syncStatus: SyncStatus.synced))
            .toList();
        state = state.copyWith(affirmations: syncedList);
        await _repo.saveLocalAffirmations(syncedList);
      }
    });
  }

  Future<void> duplicateAffirmation(String id) async {
    final isGuest = _ref.read(authProvider).value == null;
    if (isGuest) {
      final createdCount = state.affirmations
          .where((a) => !a.id.startsWith('def_') && !a.id.startsWith('a_seed_'))
          .length;
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

    _repo.syncWithBackend(list).then((success) async {
      if (success) {
        final syncedList = state.affirmations
            .map(
              (a) => a.id == copy.id
                  ? a.copyWith(syncStatus: SyncStatus.synced)
                  : a,
            )
            .toList();
        state = state.copyWith(affirmations: syncedList);
        await _repo.saveLocalAffirmations(syncedList);
      }
    });
  }

  void completePractice() {
    state = state.copyWith(completedTodayCount: state.completedTodayCount + 1);
    _ref
        .read(osStateProvider.notifier)
        .toggleHabitCompletion(
          'daily_affirmation_practice_${const Uuid().v4()}',
        );
  }

  /// Increments the repeat count for an affirmation and persists locally.
  void incrementRepeatCount(String affirmationId, int count) {
    final currentCount = state.repeatCounts[affirmationId] ?? 0;
    final newCounts = Map<String, int>.from(state.repeatCounts);
    newCounts[affirmationId] = currentCount + count;
    state = state.copyWith(repeatCounts: newCounts);

    // Persist to Hive for offline storage
    _repo.saveRepeatCounts(newCounts);
  }

  /// Tracks the last viewed affirmation (for "recently used" feature).
  void trackLastViewed(String affirmationId) {
    state = state.copyWith(
      lastViewedAffirmationId: affirmationId,
      lastViewedAt: DateTime.now(),
    );
  }

  /// Loads repeat counts from Hive into state.
  Future<void> loadRepeatCounts() async {
    final counts = _repo.getRepeatCounts();
    state = state.copyWith(repeatCounts: counts);
  }

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
      ref.watch(authProvider);
      final repo = ref.watch(affirmationsRepositoryProvider);
      return AffirmationsNotifier(repo, ref);
    });
