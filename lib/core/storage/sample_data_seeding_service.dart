import 'dart:developer' as dev;
import '../../core/storage/hive_database.dart';

class SampleDataSeedingService {
  static const String _logTag = '[SampleDataSeeding]';
  static const int currentVersion = 5;

  /// Seeds minimal setup preferences (identity, life areas, trackers, workspace settings, habits)
  /// and ensures sample tasks, goals, affirmations, and vision room items are left empty.
  static Future<void> seedAll(HiveDatabase hiveDb) async {
    dev.log('$_logTag Initializing minimal guest session database seeding...');

    // 1. Identity & Life Areas
    await hiveDb.saveSelectedIdentity('🚀 Entrepreneur');
    await hiveDb.saveSelectedLifeAreas(['health', 'reading', 'finance', 'productivity']);
    await hiveDb.saveSelectedGoal('Become Consistent');

    // 2. Trackers Preferences
    await hiveDb.saveReadingPreferences({
      'categories': ['Self-Improvement', 'Business', 'Philosophy'],
      'bookTarget': 12,
      'dailyReadingMinutes': 25,
    });

    await hiveDb.saveHealthPreferences({
      'waterTarget': 2500,
      'sleepTarget': 8,
      'exerciseTarget': 30,
    });

    await hiveDb.saveFinancePreferences({
      'monthlySavings': 15000,
    });

    // 3. User Statistics
    await hiveDb.saveUserStatistics({
      'disciplinePoints': 120,
      'level': 1,
      'currentStreak': 3,
      'bestStreak': 5,
      'totalHabitsCompleted': 14,
    });

    // 4. Workspace Settings
    await hiveDb.saveWorkspaceSettings({
      'woodTexture': 'Oak',
      'wallColor': 'Deep Indigo',
      'plantType': 'Bonsai',
      'ambientMode': 'Auto',
      'rainMode': false,
      'homeExperience': 'classic',
    });

    // 5. Habits (Keep sample habits active)
    await hiveDb.saveSelectedHabits([
      {
        'id': 'habit_sample_1',
        'localId': 'habit_sample_1',
        'title': '🏋 Workout Routine',
        'category': 'Health',
        'difficulty': 'Medium',
        'isEnabled': true,
        'syncStatus': 'pending',
      },
      {
        'id': 'habit_sample_2',
        'localId': 'habit_sample_2',
        'title': '📖 Read 25 Pages',
        'category': 'Productivity',
        'difficulty': 'Easy',
        'isEnabled': true,
        'syncStatus': 'pending',
      },
      {
        'id': 'habit_sample_3',
        'localId': 'habit_sample_3',
        'title': '💰 Track Expenses',
        'category': 'Finance',
        'difficulty': 'Easy',
        'isEnabled': true,
        'syncStatus': 'pending',
      },
    ]);

    // 6. Keep sample vision board items, goals, todos, affirmations, and tasks empty
    await hiveDb.saveVisionItems([]);
    await hiveDb.saveSelectedGoals([]);
    await hiveDb.saveTodos([]);
    await hiveDb.saveSelectedAffirmations([]);
    await hiveDb.saveTasks([]);

    await hiveDb.saveSetupCompleted(true);
    await hiveDb.saveSampleDataSeeded(true);
    await hiveDb.saveSampleDataVersion(currentVersion);
    dev.log('$_logTag Seeding completed successfully!');
  }
}
