import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/storage/hive_database.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../onboarding/domain/models/onboarding_models.dart';
import 'os_providers.dart';

class MindsetExercise {
  final String id;
  final String title;
  final bool isCompleted;
  final int xpReward;

  MindsetExercise({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.xpReward = 20,
  });

  MindsetExercise copyWith({bool? isCompleted}) {
    return MindsetExercise(
      id: id,
      title: title,
      isCompleted: isCompleted ?? this.isCompleted,
      xpReward: xpReward,
    );
  }
}

class GratitudeCard {
  final String id;
  final String dateStr;
  final List<String> entries;
  final String mood; // 'Grateful', 'Peaceful', 'Inspired', 'Calm'
  final String? imagePath;

  GratitudeCard({
    required this.id,
    required this.dateStr,
    required this.entries,
    required this.mood,
    this.imagePath,
  });
}

class WisdomCard {
  final String id;
  final String quote;
  final String author;
  final String category;
  final String shortBio;
  final String avatarUrl;

  WisdomCard({
    required this.id,
    required this.quote,
    required this.author,
    required this.category,
    required this.shortBio,
    required this.avatarUrl,
  });
}

class MotivationState {
  final List<DailyAffirmation> affirmations;
  final List<MindsetExercise> mindsetExercises;
  final List<GratitudeCard> gratitudeCards;
  final List<String> savedWisdomIds;
  final int todayQuoteIndex;
  final bool showCelebration;

  MotivationState({
    this.affirmations = const [],
    this.mindsetExercises = const [],
    this.gratitudeCards = const [],
    this.savedWisdomIds = const [],
    this.todayQuoteIndex = 0,
    this.showCelebration = false,
  });

  MotivationState copyWith({
    List<DailyAffirmation>? affirmations,
    List<MindsetExercise>? mindsetExercises,
    List<GratitudeCard>? gratitudeCards,
    List<String>? savedWisdomIds,
    int? todayQuoteIndex,
    bool? showCelebration,
  }) {
    return MotivationState(
      affirmations: affirmations ?? this.affirmations,
      mindsetExercises: mindsetExercises ?? this.mindsetExercises,
      gratitudeCards: gratitudeCards ?? this.gratitudeCards,
      savedWisdomIds: savedWisdomIds ?? this.savedWisdomIds,
      todayQuoteIndex: todayQuoteIndex ?? this.todayQuoteIndex,
      showCelebration: showCelebration ?? this.showCelebration,
    );
  }
}

class MotivationNotifier extends StateNotifier<MotivationState> {
  final HiveDatabase _hiveDb;
  final Ref _ref;

  MotivationNotifier(this._hiveDb, this._ref) : super(MotivationState()) {
    _loadInitialData();
  }

  void _loadInitialData() {
    // 1. Load Affirmations from Hive
    final loadedAffs = _hiveDb.getSelectedAffirmations();
    List<DailyAffirmation> affirmationsList = loadedAffs.map((e) => DailyAffirmation.fromMap(e)).toList();

    // Populate default affirmations if empty
    if (affirmationsList.isEmpty) {
      affirmationsList = [
        DailyAffirmation(
          id: 'aff_1',
          title: 'Growth Mindset',
          text: 'Challenges are opportunities to grow and expand my capabilities.',
          category: 'Mindset',
          colorTheme: 'Emerald Green',
          backgroundStyle: 'Warm Wood',
          fontStyle: 'Serif',
          schedule: ['Morning'],
        ),
        DailyAffirmation(
          id: 'aff_2',
          title: 'Daily Discipline',
          text: 'I choose consistency over temporary motivation. I finish what I start.',
          category: 'Discipline',
          colorTheme: 'Minimal Black',
          backgroundStyle: 'Minimal Black',
          fontStyle: 'Sans-Serif',
          schedule: ['Morning', 'Afternoon'],
        ),
        DailyAffirmation(
          id: 'aff_3',
          title: 'Financial Abundance',
          text: 'I create value daily, and my work builds long-term security.',
          category: 'Finance',
          colorTheme: 'Luxury Gold',
          backgroundStyle: 'Luxury Gold',
          fontStyle: 'Serif',
          schedule: ['Morning', 'Evening'],
        ),
      ];
      _saveAffirmationsToHive(affirmationsList);
    }

    // 2. Load Mindset Exercises
    final initialMindset = [
      MindsetExercise(id: 'ex_1', title: 'Recite morning affirmation aloud with confidence'),
      MindsetExercise(id: 'ex_2', title: 'Visualize completing today\'s primary task successfully'),
      MindsetExercise(id: 'ex_3', title: 'Write down 3 specific things you are grateful for today'),
    ];

    // 3. Load Mock Gratitude Cards
    final initialGratitude = [
      GratitudeCard(
        id: 'g_1',
        dateStr: 'Yesterday',
        entries: [
          'The clean quiet morning workspace',
          'A warm mug of tea while reading Atomic Habits',
          'Solving a complex coding blocker successfully'
        ],
        mood: 'Peaceful',
      ),
    ];

    state = MotivationState(
      affirmations: affirmationsList,
      mindsetExercises: initialMindset,
      gratitudeCards: initialGratitude,
      savedWisdomIds: [],
      todayQuoteIndex: 0,
      showCelebration: false,
    );
  }

  // Save changes back to Hive
  Future<void> _saveAffirmationsToHive(List<DailyAffirmation> list) async {
    final mapped = list.map((a) => a.toMap()).toList();
    await _hiveDb.saveSelectedAffirmations(mapped);
  }

  // --- Affirmation Actions ---
  Future<void> addAffirmation(DailyAffirmation affirmation) async {
    final list = [...state.affirmations, affirmation];
    state = state.copyWith(affirmations: list);
    await _saveAffirmationsToHive(list);
  }

  Future<void> updateAffirmation(DailyAffirmation updated) async {
    final list = state.affirmations.map((a) => a.id == updated.id ? updated : a).toList();
    state = state.copyWith(affirmations: list);
    await _saveAffirmationsToHive(list);
  }

  Future<void> deleteAffirmation(String id) async {
    final list = state.affirmations.where((a) => a.id != id).toList();
    state = state.copyWith(affirmations: list);
    await _saveAffirmationsToHive(list);
  }

  Future<void> toggleFavorite(String id) async {
    final list = state.affirmations.map((a) {
      if (a.id == id) return a.copyWith(isFavorite: !a.isFavorite);
      return a;
    }).toList();
    state = state.copyWith(affirmations: list);
    await _saveAffirmationsToHive(list);
  }

  Future<void> togglePin(String id) async {
    final list = state.affirmations.map((a) {
      if (a.id == id) return a.copyWith(isPinned: !a.isPinned);
      // Unpin others when pinning a new one
      if (a.isPinned) return a.copyWith(isPinned: false);
      return a;
    }).toList();
    state = state.copyWith(affirmations: list);
    await _saveAffirmationsToHive(list);
  }

  Future<void> duplicateAffirmation(String id) async {
    final original = state.affirmations.firstWhere((a) => a.id == id);
    final duplicate = DailyAffirmation(
      id: const Uuid().v4(),
      title: '${original.title} (Copy)',
      text: original.text,
      author: original.author,
      category: original.category,
      colorTheme: original.colorTheme,
      fontStyle: original.fontStyle,
      backgroundStyle: original.backgroundStyle,
      schedule: List<String>.from(original.schedule),
      woodFinish: original.woodFinish,
      frameStyle: original.frameStyle,
      frameColor: original.frameColor,
      glassReflection: original.glassReflection,
      fontWeight: original.fontWeight,
      quoteAlignment: original.quoteAlignment,
      quoteSize: original.quoteSize,
      accentColor: original.accentColor,
      bgBlur: original.bgBlur,
      borderDecoration: original.borderDecoration,
    );
    final list = [...state.affirmations, duplicate];
    state = state.copyWith(affirmations: list);
    await _saveAffirmationsToHive(list);
  }

  void reorderAffirmations(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final list = [...state.affirmations];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = state.copyWith(affirmations: list);
    _saveAffirmationsToHive(list);
  }

  // --- Mindset Actions ---
  void toggleMindsetExercise(String id) {
    final updated = state.mindsetExercises.map((e) {
      if (e.id == id) {
        final newCompleted = !e.isCompleted;
        if (newCompleted) {
          // Grant XP points through osStateNotifier!
          _ref.read(osStateProvider.notifier).toggleHabitCompletion('mindset_xp_dummy_${const Uuid().v4()}');
          // Trigger local celebration
          state = state.copyWith(showCelebration: true);
          Future.delayed(const Duration(seconds: 4), () {
            state = state.copyWith(showCelebration: false);
          });
        }
        return e.copyWith(isCompleted: newCompleted);
      }
      return e;
    }).toList();
    state = state.copyWith(mindsetExercises: updated);
  }

  // --- Gratitude Actions ---
  void addGratitudeCard(List<String> entries, String mood) {
    final newCard = GratitudeCard(
      id: const Uuid().v4(),
      dateStr: 'Today',
      entries: entries,
      mood: mood,
    );
    state = state.copyWith(
      gratitudeCards: [newCard, ...state.gratitudeCards],
    );
  }

  // --- Wisdom Actions ---
  void toggleSaveWisdom(String id) {
    final current = [...state.savedWisdomIds];
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    state = state.copyWith(savedWisdomIds: current);
  }

  // --- Quote Swiping ---
  void setTodayQuoteIndex(int index) {
    state = state.copyWith(todayQuoteIndex: index);
  }
}

// Provider
final dailyMotivationProvider = StateNotifierProvider<MotivationNotifier, MotivationState>((ref) {
  final hiveDb = ref.watch(hiveDatabaseProvider);
  return MotivationNotifier(hiveDb, ref);
});
