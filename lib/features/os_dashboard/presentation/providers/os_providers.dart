import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/storage/hive_database.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../onboarding/domain/models/onboarding_models.dart';

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
  final List<String> selectedLifeAreas;

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
    this.woodTexture = 'Walnut',
    this.wallColor = 'Deep Indigo',
    this.plantType = 'Bonsai',
    this.ambientMode = 'Auto',
    this.rainMode = false,
    this.selectedLifeAreas = const [],
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
    List<String>? selectedLifeAreas,
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
      selectedLifeAreas: selectedLifeAreas ?? this.selectedLifeAreas,
    );
  }
}

// State Notifier
class OSStateNotifier extends StateNotifier<OSState> {
  final HiveDatabase _hiveDb;

  OSStateNotifier(this._hiveDb) : super(OSState()) {
    _loadInitialData();
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
    final wood = settings['woodTexture'] as String? ?? 'Walnut';
    final wall = settings['wallColor'] as String? ?? 'Deep Indigo';
    final plant = settings['plantType'] as String? ?? 'Bonsai';
    final ambient = settings['ambientMode'] as String? ?? 'Auto';
    final rain = settings['rainMode'] as bool? ?? false;
    
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
  }

  Future<void> updateWorkspaceSettings({
    String? woodTexture,
    String? wallColor,
    String? plantType,
    String? ambientMode,
    bool? rainMode,
  }) async {
    final newWood = woodTexture ?? state.woodTexture;
    final newWall = wallColor ?? state.wallColor;
    final newPlant = plantType ?? state.plantType;
    final newAmbient = ambientMode ?? state.ambientMode;
    final newRain = rainMode ?? state.rainMode;

    state = state.copyWith(
      woodTexture: newWood,
      wallColor: newWall,
      plantType: newPlant,
      ambientMode: newAmbient,
      rainMode: newRain,
    );

    await _hiveDb.saveWorkspaceSettings({
      'woodTexture': newWood,
      'wallColor': newWall,
      'plantType': newPlant,
      'ambientMode': newAmbient,
      'rainMode': newRain,
    });
  }
}

// Providers
final osStateProvider = StateNotifierProvider<OSStateNotifier, OSState>((ref) {
  final hiveDb = ref.watch(hiveDatabaseProvider);
  return OSStateNotifier(hiveDb);
});
