import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/vision_item.dart';
import '../../domain/models/habit_item.dart';
import '../../domain/models/achievement.dart';
import '../../domain/models/finance_goal.dart';
import '../../domain/models/timeline_milestone.dart';
import 'canvas_providers.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ROOM STATE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final currentWallIndexProvider = StateProvider<int>(
  (ref) => 3,
); // Default to Vision Wall (index 3)

final focusModeProvider = StateProvider<bool>((ref) => false); // Dims room

/// Whether the Vision Room is in Edit Mode (in-place editing).
/// When true, items become interactive with selection, resize, and rotate handles.
/// A floating toolbar appears at the bottom.
final editModeProvider = StateProvider<bool>((ref) => false);

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISION WALL
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Vision Wall items are now directly derived from the new CanvasState
final visionItemsProvider = Provider<List<VisionItem>>((ref) {
  return ref.watch(canvasStateProvider).items;
});

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HABIT WALL
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class HabitsNotifier extends StateNotifier<List<HabitItem>> {
  HabitsNotifier() : super([]);

  void loadMockData() {
    state = [
      HabitItem(id: 'h1', name: 'Morning Run', emoji: '🏃', streak: 12),
      HabitItem(
        id: 'h2',
        name: 'Read 20 pages',
        emoji: '📚',
        streak: 5,
        colorValue: 0xFFF59E0B,
      ),
      HabitItem(
        id: 'h3',
        name: 'Coding',
        emoji: '💻',
        streak: 45,
        colorValue: 0xFF8B5CF6,
        completedToday: true,
      ),
    ];
  }

  void toggleHabit(String id) {
    state = state.map((h) {
      if (h.id == id) {
        return h.copyWith(
          completedToday: !h.completedToday,
          streak: h.completedToday ? h.streak - 1 : h.streak + 1,
        );
      }
      return h;
    }).toList();
  }
}

final visionHabitsProvider =
    StateNotifierProvider<HabitsNotifier, List<HabitItem>>((ref) {
      final notifier = HabitsNotifier();
      notifier.loadMockData();
      return notifier;
    });

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ACHIEVEMENT WALL
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final visionAchievementsProvider = StateProvider<List<Achievement>>(
  (ref) => [
    Achievement(
      id: 'a1',
      title: 'First Steps',
      description: 'Complete your first habit',
      icon: '🌱',
      isUnlocked: true,
      tierIndex: 0,
    ),
    Achievement(
      id: 'a2',
      title: 'Consistency',
      description: 'Reach a 7-day streak',
      icon: '🔥',
      isUnlocked: true,
      tierIndex: 1,
    ),
    Achievement(
      id: 'a3',
      title: 'Deep Focus',
      description: 'Complete 100 focus sessions',
      icon: '🧠',
      isUnlocked: false,
      tierIndex: 2,
    ),
    Achievement(
      id: 'a4',
      title: 'Visionary',
      description: 'Complete a long-term goal',
      icon: '👑',
      isUnlocked: false,
      tierIndex: 3,
    ),
  ],
);

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FINANCE WALL
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final visionFinanceGoalsProvider = StateProvider<List<FinanceGoal>>(
  (ref) => [
    FinanceGoal(
      id: 'f1',
      title: 'Emergency Fund',
      targetAmount: 100000,
      currentAmount: 45000,
    ),
    FinanceGoal(
      id: 'f2',
      title: 'Dream Setup',
      targetAmount: 250000,
      currentAmount: 50000,
      icon: '🖥️',
      colorValue: 0xFF8B5CF6,
    ),
  ],
);

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TIMELINE WALL
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final visionTimelineProvider = StateProvider<List<TimelineMilestone>>(
  (ref) => [
    TimelineMilestone(
      id: 't1',
      year: 2026,
      month: 6,
      title: 'Launch App',
      category: 'career',
      isCompleted: true,
    ),
    TimelineMilestone(
      id: 't2',
      year: 2026,
      month: 12,
      title: 'Reach 10k MRR',
      category: 'finance',
    ),
    TimelineMilestone(
      id: 't3',
      year: 2027,
      month: 3,
      title: 'Buy Dream Car',
      category: 'personal',
      colorValue: 0xFFF59E0B,
    ),
    TimelineMilestone(
      id: 't4',
      year: 2028,
      month: 1,
      title: 'Buy House',
      category: 'personal',
      colorValue: 0xFF2CE38C,
    ),
  ],
);
