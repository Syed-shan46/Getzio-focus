import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/hive_database.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../domain/models/onboarding_models.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATE — Holds all onboarding selections across 7 screens
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class OnboardingState {
  final List<String> selectedLifeAreas;
  final List<UserGoal> selectedGoals;
  final ReadingPreferences readingPrefs;
  final HealthPreferences healthPrefs;
  final FinancePreferences financePrefs;
  final String? wakeUpTime;

  // Legacy fields kept for backward-compat with dashboard
  final UserIdentity? selectedIdentity;
  final List<UserHabit> selectedHabits;
  final List<DailyAffirmation> selectedAffirmations;

  OnboardingState({
    this.selectedLifeAreas = const [],
    this.selectedGoals = const [],
    this.readingPrefs = const ReadingPreferences(),
    this.healthPrefs = const HealthPreferences(),
    this.financePrefs = const FinancePreferences(),
    this.wakeUpTime,
    this.selectedIdentity,
    this.selectedHabits = const [],
    this.selectedAffirmations = const [],
  });

  OnboardingState copyWith({
    List<String>? selectedLifeAreas,
    List<UserGoal>? selectedGoals,
    ReadingPreferences? readingPrefs,
    HealthPreferences? healthPrefs,
    FinancePreferences? financePrefs,
    String? wakeUpTime,
    UserIdentity? selectedIdentity,
    List<UserHabit>? selectedHabits,
    List<DailyAffirmation>? selectedAffirmations,
  }) {
    return OnboardingState(
      selectedLifeAreas: selectedLifeAreas ?? this.selectedLifeAreas,
      selectedGoals: selectedGoals ?? this.selectedGoals,
      readingPrefs: readingPrefs ?? this.readingPrefs,
      healthPrefs: healthPrefs ?? this.healthPrefs,
      financePrefs: financePrefs ?? this.financePrefs,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      selectedIdentity: selectedIdentity ?? this.selectedIdentity,
      selectedHabits: selectedHabits ?? this.selectedHabits,
      selectedAffirmations: selectedAffirmations ?? this.selectedAffirmations,
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NOTIFIER — Business logic for onboarding flow
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final HiveDatabase _hiveDb;

  OnboardingNotifier(this._hiveDb) : super(OnboardingState());

  // ─── Life Areas (multi-select) ──────────────────────────────────────────
  void toggleLifeArea(String areaId) {
    final current = List<String>.from(state.selectedLifeAreas);
    if (current.contains(areaId)) {
      current.remove(areaId);
    } else {
      current.add(areaId);
    }
    state = state.copyWith(selectedLifeAreas: current);
  }

  // ─── Goals (multi-select) ──────────────────────────────────────────────
  void toggleGoal(UserGoal goal) {
    final current = List<UserGoal>.from(state.selectedGoals);
    final exists = current.indexWhere((g) => g.id == goal.id);
    if (exists >= 0) {
      current.removeAt(exists);
    } else {
      current.add(goal);
    }
    state = state.copyWith(selectedGoals: current);
  }

  void addCustomGoal(UserGoal goal) {
    final current = List<UserGoal>.from(state.selectedGoals);
    current.add(goal);
    state = state.copyWith(selectedGoals: current);
  }

  // ─── Reading ────────────────────────────────────────────────────────────
  void updateReadingPrefs(ReadingPreferences prefs) {
    state = state.copyWith(readingPrefs: prefs);
  }

  void toggleReadingCategory(String category) {
    final current = List<String>.from(state.readingPrefs.categories);
    if (current.contains(category)) {
      current.remove(category);
    } else {
      current.add(category);
    }
    state = state.copyWith(
      readingPrefs: state.readingPrefs.copyWith(categories: current),
    );
  }

  void setBookTarget(int target) {
    state = state.copyWith(
      readingPrefs: state.readingPrefs.copyWith(bookTarget: target),
    );
  }

  void setReadingMinutes(int minutes) {
    state = state.copyWith(
      readingPrefs: state.readingPrefs.copyWith(dailyReadingMinutes: minutes),
    );
  }

  // ─── Health ─────────────────────────────────────────────────────────────
  void updateHealthPrefs(HealthPreferences prefs) {
    state = state.copyWith(healthPrefs: prefs);
  }

  void setWeightGoal(String goal) {
    state = state.copyWith(
      healthPrefs: state.healthPrefs.copyWith(weightGoal: goal),
    );
  }

  void toggleActivity(String activity) {
    final current = List<String>.from(state.healthPrefs.activities);
    if (current.contains(activity)) {
      current.remove(activity);
    } else {
      current.add(activity);
    }
    state = state.copyWith(
      healthPrefs: state.healthPrefs.copyWith(activities: current),
    );
  }

  void toggleNutritionGoal(String goal) {
    final current = List<String>.from(state.healthPrefs.nutritionGoals);
    if (current.contains(goal)) {
      current.remove(goal);
    } else {
      current.add(goal);
    }
    state = state.copyWith(
      healthPrefs: state.healthPrefs.copyWith(nutritionGoals: current),
    );
  }

  void setSleepGoal(String goal) {
    state = state.copyWith(
      healthPrefs: state.healthPrefs.copyWith(sleepGoal: goal),
    );
  }

  // ─── Finance ────────────────────────────────────────────────────────────
  void updateFinancePrefs(FinancePreferences prefs) {
    state = state.copyWith(financePrefs: prefs);
  }

  void toggleFinancialGoal(String goal) {
    final current = List<String>.from(state.financePrefs.financialGoals);
    if (current.contains(goal)) {
      current.remove(goal);
    } else {
      current.add(goal);
    }
    state = state.copyWith(
      financePrefs: state.financePrefs.copyWith(financialGoals: current),
    );
  }

  void setSavingsTarget(String target) {
    state = state.copyWith(
      financePrefs: state.financePrefs.copyWith(savingsTarget: target),
    );
  }

  void toggleMonthlyChallenge(String challenge) {
    final current = List<String>.from(state.financePrefs.monthlyChallenges);
    if (current.contains(challenge)) {
      current.remove(challenge);
    } else {
      current.add(challenge);
    }
    state = state.copyWith(
      financePrefs: state.financePrefs.copyWith(monthlyChallenges: current),
    );
  }

  // ─── Legacy methods ─────────────────────────────────────────────────────
  void setIdentity(UserIdentity identity) {
    state = state.copyWith(selectedIdentity: identity);
  }

  void setGoal(UserGoal goal) {
    // Legacy single-goal; now we use toggleGoal for multi-select
    toggleGoal(goal);
  }

  void setWakeUpTime(String time) {
    state = state.copyWith(wakeUpTime: time);
  }

  void toggleHabit(UserHabit habit) {
    final current = List<UserHabit>.from(state.selectedHabits);
    final exists = current.indexWhere((h) => h.id == habit.id);
    if (exists >= 0) {
      current.removeAt(exists);
    } else {
      current.add(habit);
    }
    state = state.copyWith(selectedHabits: current);
  }

  void toggleAffirmation(DailyAffirmation affirmation) {
    final current = List<DailyAffirmation>.from(state.selectedAffirmations);
    final exists = current.indexWhere((a) => a.id == affirmation.id);
    if (exists >= 0) {
      current.removeAt(exists);
    } else {
      current.add(affirmation);
    }
    state = state.copyWith(selectedAffirmations: current);
  }

  void setPinnedAffirmation(String id) {
    final updatedList = state.selectedAffirmations.map((a) {
      return a.copyWith(isPinned: a.id == id);
    }).toList();
    state = state.copyWith(selectedAffirmations: updatedList);
  }

  // ─── Persist everything ─────────────────────────────────────────────────
  Future<void> completeOnboarding() async {
    // Life Areas
    await _hiveDb.saveSelectedLifeAreas(state.selectedLifeAreas);

    // Goals
    await _hiveDb.saveSelectedGoals(
      state.selectedGoals.map((g) => g.toMap()).toList(),
    );

    // Identity (derive from first life area for dashboard compat)
    final identityStr = state.selectedLifeAreas.isNotEmpty
        ? state.selectedLifeAreas.first
        : '🌱 Self-Disciplined';
    await _hiveDb.saveSelectedIdentity(identityStr);

    // Goal (save first goal title for dashboard compat)
    final goalStr = state.selectedGoals.isNotEmpty
        ? state.selectedGoals.first.title
        : 'Become Consistent';
    await _hiveDb.saveSelectedGoal(goalStr);

    // Wake up time
    if (state.wakeUpTime != null) {
      await _hiveDb.saveWakeUpTime(state.wakeUpTime!);
    }

    // Reading
    await _hiveDb.saveReadingPreferences(state.readingPrefs.toMap());

    // Health
    await _hiveDb.saveHealthPreferences(state.healthPrefs.toMap());

    // Finance
    await _hiveDb.saveFinancePreferences(state.financePrefs.toMap());

    // Habits & Affirmations
    await _hiveDb.saveSelectedHabits(
      state.selectedHabits.map((h) => h.toMap()).toList(),
    );
    await _hiveDb.saveSelectedAffirmations(
      state.selectedAffirmations.map((a) => a.toMap()).toList(),
    );

    // Statistics
    final stats = UserStatistics(
      disciplinePoints: 0,
      level: 1,
      currentStreak: 0,
      bestStreak: 0,
      totalHabitsCompleted: 0,
    );
    await _hiveDb.saveUserStatistics(stats.toMap());
    await _hiveDb.saveSetupCompleted(true);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final hiveDb = ref.watch(hiveDatabaseProvider);
  return OnboardingNotifier(hiveDb);
});
