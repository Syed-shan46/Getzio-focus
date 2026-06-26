import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/storage/hive_database.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../onboarding/domain/models/onboarding_models.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/models/auth_user_model.dart';
import '../../../auth/domain/services/guest_migration_service.dart';

// State definition for the OS dashboard
class OSState {
  final double disciplineScore; // 0.0 to 100.0
  final int currentStreak;
  final int bestStreak;
  final int level;
  final int xp;
  final String activeIdentity;
  final String selectedGoal;
  final String wakeUpTime;
  final List<UserHabit> selectedHabits;
  final List<String> completedHabitIdsToday;
  final String weatherStub;
  final String dailyQuote;
  final String dailyQuoteAuthor;
  final bool showCelebrationBanner;
  final int totalHabitsCompletedAllTime;
  
  // Customization fields
  final String woodTexture;
  final String wallColor;
  final String plantType;
  final String ambientMode;
  final bool rainMode;
  final String homeExperience;
  final List<String> selectedLifeAreas;
  final List<String> recoveryTasks;

  OSState({
    this.disciplineScore = 0.0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.level = 1,
    this.xp = 0,
    this.activeIdentity = '🚀 Entrepreneur',
    this.selectedGoal = 'Become Consistent',
    this.wakeUpTime = '6:00 AM',
    this.selectedHabits = const [],
    this.completedHabitIdsToday = const [],
    this.weatherStub = '72° Sunny',
    this.dailyQuote = 'Today\'s actions build tomorrow\'s identity.',
    this.dailyQuoteAuthor = 'Focus Core',
    this.showCelebrationBanner = false,
    this.totalHabitsCompletedAllTime = 0,
    this.woodTexture = 'Oak',
    this.wallColor = 'Deep Indigo',
    this.plantType = 'Bonsai',
    this.ambientMode = 'Auto',
    this.rainMode = false,
    this.homeExperience = 'living',
    this.selectedLifeAreas = const [],
    this.recoveryTasks = const [],
  });

  OSState copyWith({
    double? disciplineScore,
    int? currentStreak,
    int? bestStreak,
    int? level,
    int? xp,
    String? activeIdentity,
    String? selectedGoal,
    String? wakeUpTime,
    List<UserHabit>? selectedHabits,
    List<String>? completedHabitIdsToday,
    String? weatherStub,
    String? dailyQuote,
    String? dailyQuoteAuthor,
    bool? showCelebrationBanner,
    int? totalHabitsCompletedAllTime,
    String? woodTexture,
    String? wallColor,
    String? plantType,
    String? ambientMode,
    bool? rainMode,
    String? homeExperience,
    List<String>? selectedLifeAreas,
    List<String>? recoveryTasks,
  }) {
    return OSState(
      disciplineScore: disciplineScore ?? this.disciplineScore,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      activeIdentity: activeIdentity ?? this.activeIdentity,
      selectedGoal: selectedGoal ?? this.selectedGoal,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      selectedHabits: selectedHabits ?? this.selectedHabits,
      completedHabitIdsToday: completedHabitIdsToday ?? this.completedHabitIdsToday,
      weatherStub: weatherStub ?? this.weatherStub,
      dailyQuote: dailyQuote ?? this.dailyQuote,
      dailyQuoteAuthor: dailyQuoteAuthor ?? this.dailyQuoteAuthor,
      showCelebrationBanner: showCelebrationBanner ?? this.showCelebrationBanner,
      totalHabitsCompletedAllTime: totalHabitsCompletedAllTime ?? this.totalHabitsCompletedAllTime,
      woodTexture: woodTexture ?? this.woodTexture,
      wallColor: wallColor ?? this.wallColor,
      plantType: plantType ?? this.plantType,
      ambientMode: ambientMode ?? this.ambientMode,
      rainMode: rainMode ?? this.rainMode,
      homeExperience: homeExperience ?? this.homeExperience,
      selectedLifeAreas: selectedLifeAreas ?? this.selectedLifeAreas,
      recoveryTasks: recoveryTasks ?? this.recoveryTasks,
    );
  }
}

// State Notifier
class OSStateNotifier extends StateNotifier<OSState> {
  final HiveDatabase _hiveDb;
  final Ref _ref;

  OSStateNotifier(this._hiveDb, this._ref) : super(OSState()) {
    _loadInitialData();
    Future.microtask(() => fetchTodaySession());

    // Listen to authentication state changes to reload data and sync sessions
    _ref.listen<AsyncValue<AuthUserModel?>>(authProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        log('[OSStateNotifier] User logged in, reloading initial data and fetching session...');
        _loadInitialData();
        fetchTodaySession();
      } else if (next.hasValue && next.value == null) {
        log('[OSStateNotifier] User logged out, resetting initial data...');
        _loadInitialData();
      }
    });
  }

  void _loadInitialData() {
    final identity = _hiveDb.getSelectedIdentity() ?? '🚀 Entrepreneur';
    final goal = _hiveDb.getSelectedGoal() ?? 'Become Consistent';
    final wakeUp = _hiveDb.getWakeUpTime() ?? '6:00 AM';

    final habitsData = _hiveDb.getSelectedHabits();
    final habits = habitsData.map((e) => UserHabit.fromMap(e)).toList();

    final statsData = _hiveDb.getUserStatistics();
    final stats = statsData != null ? UserStatistics.fromMap(statsData) : UserStatistics();

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final logs = _hiveDb.getHabitLogs();
    final completedToday = List<String>.from(logs[todayStr] ?? []);

    // Calculate initial score
    final score = habits.isEmpty ? 0.0 : (completedToday.length / habits.length) * 100.0;

    // Load workspace settings
    final settings = _hiveDb.getWorkspaceSettings();
    final wood = settings['woodTexture'] as String? ?? 'Oak';
    final wall = settings['wallColor'] as String? ?? 'Deep Indigo';
    final plant = settings['plantType'] as String? ?? 'Bonsai';
    final ambient = settings['ambientMode'] as String? ?? 'Auto';
    final rain = settings['rainMode'] as bool? ?? false;
    final homeExp = settings['homeExperience'] as String? ?? 'living';
    
    // Load life areas from onboarding
    final lifeAreas = _hiveDb.getSelectedLifeAreas();

    // Load pinned affirmation
    final affirmationsData = _hiveDb.getSelectedAffirmations();
    final affirmations = affirmationsData.map((e) => DailyAffirmation.fromMap(e)).toList();
    final pinnedAff = affirmations.firstWhere(
      (a) => a.isPinned,
      orElse: () => affirmations.isNotEmpty 
          ? affirmations.first 
          : DailyAffirmation(id: 'default', text: 'Discipline creates freedom.', author: 'Focus Core'),
    );

    state = OSState(
      disciplineScore: score,
      currentStreak: stats.currentStreak,
      bestStreak: stats.bestStreak,
      level: stats.level,
      xp: stats.disciplinePoints,
      activeIdentity: identity,
      selectedGoal: goal,
      wakeUpTime: wakeUp,
      selectedHabits: habits,
      completedHabitIdsToday: completedToday,
      totalHabitsCompletedAllTime: stats.totalHabitsCompleted,
      weatherStub: '72° Sunny',
      dailyQuote: pinnedAff.text,
      dailyQuoteAuthor: pinnedAff.author ?? 'Self',
      woodTexture: wood,
      wallColor: wall,
      plantType: plant,
      ambientMode: ambient,
      rainMode: rain,
      homeExperience: homeExp,
      selectedLifeAreas: lifeAreas,
    );
  }

  Future<void> toggleHabitCompletion(String habitId) async {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final currentCompleted = List<String>.from(state.completedHabitIdsToday);

    final isAdd = !currentCompleted.contains(habitId);
    int xpChange = 0;
    int completedAllTimeChange = 0;

    if (isAdd) {
      currentCompleted.add(habitId);
      xpChange = 10;
      completedAllTimeChange = 1;
    } else {
      currentCompleted.remove(habitId);
      xpChange = -10;
      completedAllTimeChange = -1;
    }

    // Update Logs in Box
    final logs = _hiveDb.getHabitLogs();
    logs[todayStr] = currentCompleted;
    await _hiveDb.saveHabitLogs(logs);

    // Calculate score
    final newScore = state.selectedHabits.isEmpty
        ? 0.0
        : (currentCompleted.length / state.selectedHabits.length) * 100.0;

    // Check if user completed all habits today for the first time
    bool completedAllToday = state.selectedHabits.isNotEmpty && currentCompleted.length == state.selectedHabits.length;
    bool showCelebration = false;
    if (completedAllToday && isAdd) {
      showCelebration = true;
      xpChange += 150; // +150 XP bonus
    }

    final newXp = (state.xp + xpChange).clamp(0, 99999);
    final newLevel = (newXp / 500).floor() + 1; // 500 XP per level

    // Compute Streak
    int currentStreak = state.currentStreak;
    int bestStreak = state.bestStreak;

    if (isAdd && currentCompleted.length == 1) {
      currentStreak += 1;
      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }
    } else if (!isAdd && currentCompleted.isEmpty) {
      currentStreak = (currentStreak - 1).clamp(0, 99999);
    }

    final newTotalCompleted = (state.totalHabitsCompletedAllTime + completedAllTimeChange).clamp(0, 99999);

    final updatedStats = UserStatistics(
      disciplinePoints: newXp,
      level: newLevel,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      totalHabitsCompleted: newTotalCompleted,
    );
    await _hiveDb.saveUserStatistics(updatedStats.toMap());

    state = state.copyWith(
      disciplineScore: newScore,
      completedHabitIdsToday: currentCompleted,
      xp: newXp,
      level: newLevel,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      totalHabitsCompletedAllTime: newTotalCompleted,
      showCelebrationBanner: showCelebration,
    );

    final hasToken = _hiveDb.getAuthToken() != null;
    if (hasToken) {
      try {
        final dio = _ref.read(dioClientProvider);
        dio.post(
          '/focus/habits/check',
          data: {
            'habitId': habitId,
            'completed': isAdd,
          },
        ).then((_) {
          log('[OSStateNotifier] Checked habit $habitId (completed: $isAdd) on server');
        }).catchError((e) {
          log('[OSStateNotifier] Failed to check habit on server: $e');
        });
      } catch (e) {
        log('[OSStateNotifier] Failed to check habit on server: $e');
      }
    }

    // Auto reset celebration banner after 4 seconds
    if (showCelebration) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          state = state.copyWith(showCelebrationBanner: false);
        }
      });
    }
  }

  void hideCelebrationBanner() {
    state = state.copyWith(showCelebrationBanner: false);
  }

  void nextQuote(String quote, String author) {
    state = state.copyWith(dailyQuote: quote, dailyQuoteAuthor: author);
  }

  Future<void> updateSelectedHabits(List<UserHabit> newHabits) async {
    // Save to Hive
    await _hiveDb.saveSelectedHabits(newHabits.map((h) => h.toMap()).toList());

    // Filter today's completed habit IDs to only include those still in the selected set
    final currentCompleted = List<String>.from(state.completedHabitIdsToday);
    final newCompleted = currentCompleted.where((id) => newHabits.any((h) => h.id == id)).toList();

    // Recalculate score
    final newScore = newHabits.isEmpty
        ? 0.0
        : (newCompleted.length / newHabits.length) * 100.0;

    state = state.copyWith(
      selectedHabits: newHabits,
      completedHabitIdsToday: newCompleted,
      disciplineScore: newScore,
    );

    // Sync to backend if logged in
    final hasToken = _hiveDb.getAuthToken() != null;
    if (hasToken) {
      try {
        final dio = _ref.read(dioClientProvider);
        final lifeAreas = _hiveDb.getSelectedLifeAreas();
        final selectedAffirmations = _hiveDb.getSelectedAffirmations();
        final readingPrefs = _hiveDb.getReadingPreferences() ?? {};
        final healthPrefs = _hiveDb.getHealthPreferences() ?? {};
        final financePrefs = _hiveDb.getFinancePreferences() ?? {};
        
        final onboardingPayload = {
          'identity': _hiveDb.getSelectedIdentity() ?? '🚀 Entrepreneur',
          'lifeAreas': lifeAreas,
          'selectedHabits': newHabits.map((h) => {
            'id': h.id,
            'title': h.title,
            'category': h.category,
          }).toList(),
          'readingPreferences': {
            'categories': readingPrefs['categories'] ?? [],
            'targetBooks': readingPrefs['bookTarget'] ?? 10,
            'pagesPerDay': readingPrefs['dailyReadingMinutes'] ?? 20,
          },
          'financePreferences': {
            'targetAmount': financePrefs['monthlySavings'] ?? 0,
            'monthlySavingsTarget': financePrefs['monthlySavings'] ?? 0,
          },
          'healthPreferences': {
            'waterTarget': healthPrefs['waterTarget'] ?? 2000,
            'sleepTarget': healthPrefs['sleepTarget'] ?? 8,
            'exerciseTarget': healthPrefs['exerciseTarget'] ?? 30,
          },
          'affirmations': selectedAffirmations.map((a) => a['text'] as String).toList(),
          'workspaceTheme': jsonEncode(_hiveDb.getWorkspaceSettings()),
        };
        dio.post('/focus/onboarding', data: onboardingPayload).then((_) {
          log('[OSStateNotifier] Synced onboarding preferences with updated habits');
        }).catchError((e) {
          log('[OSStateNotifier] Failed to sync onboarding habits: $e');
        });
      } catch (e) {
        log('[OSStateNotifier] Error syncing habits list: $e');
      }
    }
  }

  Future<void> updateWorkspaceSettings({
    String? woodTexture,
    String? wallColor,
    String? plantType,
    String? ambientMode,
    bool? rainMode,
    String? homeExperience,
  }) async {
    final newWood = woodTexture ?? state.woodTexture;
    final newWall = wallColor ?? state.wallColor;
    final newPlant = plantType ?? state.plantType;
    final newAmbient = ambientMode ?? state.ambientMode;
    final newRain = rainMode ?? state.rainMode;
    final newHomeExp = homeExperience ?? state.homeExperience;

    state = state.copyWith(
      woodTexture: newWood,
      wallColor: newWall,
      plantType: newPlant,
      ambientMode: newAmbient,
      rainMode: newRain,
      homeExperience: newHomeExp,
    );

    final updatedSettings = {
      'woodTexture': newWood,
      'wallColor': newWall,
      'plantType': newPlant,
      'ambientMode': newAmbient,
      'rainMode': newRain,
      'homeExperience': newHomeExp,
    };

    await _hiveDb.saveWorkspaceSettings(updatedSettings);

    // Sync to backend if logged in
    final hasToken = _hiveDb.getAuthToken() != null;
    if (hasToken) {
      try {
        final dio = _ref.read(dioClientProvider);
        final lifeAreas = _hiveDb.getSelectedLifeAreas();
        final selectedHabits = state.selectedHabits.map((h) => {
          'id': h.id,
          'title': h.title,
          'category': h.category,
        }).toList();
        final selectedAffirmations = _hiveDb.getSelectedAffirmations();
        final readingPrefs = _hiveDb.getReadingPreferences() ?? {};
        final healthPrefs = _hiveDb.getHealthPreferences() ?? {};
        final financePrefs = _hiveDb.getFinancePreferences() ?? {};
        
        final onboardingPayload = {
          'identity': _hiveDb.getSelectedIdentity() ?? '🚀 Entrepreneur',
          'lifeAreas': lifeAreas,
          'selectedHabits': selectedHabits,
          'readingPreferences': {
            'categories': readingPrefs['categories'] ?? [],
            'targetBooks': readingPrefs['bookTarget'] ?? 10,
            'pagesPerDay': readingPrefs['dailyReadingMinutes'] ?? 20,
          },
          'financePreferences': {
            'targetAmount': financePrefs['monthlySavings'] ?? 0,
            'monthlySavingsTarget': financePrefs['monthlySavings'] ?? 0,
          },
          'healthPreferences': {
            'waterTarget': healthPrefs['waterTarget'] ?? 2000,
            'sleepTarget': healthPrefs['sleepTarget'] ?? 8,
            'exerciseTarget': healthPrefs['exerciseTarget'] ?? 30,
          },
          'affirmations': selectedAffirmations.map((a) => a['text'] as String).toList(),
          'workspaceTheme': jsonEncode(updatedSettings),
        };
        dio.post('/focus/onboarding', data: onboardingPayload).then((_) {
          log('[OSStateNotifier] Synced onboarding preferences with updated workspace settings');
        }).catchError((e) {
          log('[OSStateNotifier] Failed to sync onboarding workspace settings: $e');
        });
      } catch (e) {
        log('[OSStateNotifier] Error syncing workspace settings: $e');
      }
    }
  }

  Future<void> fetchTodaySession() async {
    final hasToken = _hiveDb.getAuthToken() != null;
    if (!hasToken) return;

    // Retry pending migration if exists
    if (_hiveDb.isMigrationPending()) {
      log('[OSStateNotifier] Pending migration detected. Retrying...');
      GuestDataMigrationService.migrate(_ref).then((success) {
        if (success) {
          log('[OSStateNotifier] Pending migration successfully completed!');
        }
      });
    }

    try {
      final dio = _ref.read(dioClientProvider);
      final response = await dio.get('/focus/habits/today');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data != null) {
          final session = data['session'] as Map<String, dynamic>?;
          if (session != null) {
            final int xp = session['dailyXP'] ?? state.xp;
            final habitsList = session['habits'] as List?;
            final List<String> completedToday = [];
            final List<String> recovery = [];
            if (habitsList != null) {
              for (var h in habitsList) {
                if (h['completed'] == true) {
                  completedToday.add(h['habitId'].toString());
                } else {
                  final recTask = h['recoveryTask'] as String?;
                  if (recTask != null && recTask.isNotEmpty) {
                    recovery.add(recTask);
                  }
                }
              }
            }

            final newScore = state.selectedHabits.isEmpty
                ? 0.0
                : (completedToday.length / state.selectedHabits.length) * 100.0;

            state = state.copyWith(
              xp: xp,
              completedHabitIdsToday: completedToday,
              disciplineScore: newScore,
              recoveryTasks: recovery,
            );
          }
        }
      }
    } catch (e) {
      log('[OSStateNotifier] Failed to fetch today session: $e');
    }
  }
}

// Providers
final osStateProvider = StateNotifierProvider<OSStateNotifier, OSState>((ref) {
  final hiveDb = ref.watch(hiveDatabaseProvider);
  return OSStateNotifier(hiveDb, ref);
});
