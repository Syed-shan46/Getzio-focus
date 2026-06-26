import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/hive_database.dart';
import 'core/theme/app_theme.dart';
import 'features/os_dashboard/presentation/screens/os_dashboard_screen.dart';
import 'core/services/firebase_service.dart';
import 'shared/providers/app_providers.dart';
import 'features/onboarding/presentation/screens/premium_mvp_onboarding_screen.dart';

final onboardingCompletedProvider = StateProvider<bool>((ref) {
  throw UnimplementedError();
});

final setupCompletedProvider = StateProvider<bool>((ref) {
  throw UnimplementedError();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent status bar — premium look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize Firebase
  try {
    await FirebaseService.initialize();
    log('[Init] Firebase initialized');
  } catch (e) {
    log('[Init] Firebase error: $e');
  }

  // Initialize local storage
  final hiveDb = HiveDatabase();
  try {
    await hiveDb.init();
    await _seedGuestSessionIfNeeded(hiveDb);
  } catch (e) {
    log('[Init] Hive error: $e');
  }

  final onboardingCompleted = hiveDb.isOnboardingCompleted();
  final setupCompleted = hiveDb.isSetupCompleted();

  runApp(
    ProviderScope(
      overrides: [
        hiveDatabaseProvider.overrideWithValue(hiveDb),
        onboardingCompletedProvider.overrideWith((ref) => onboardingCompleted),
        setupCompletedProvider.overrideWith((ref) => setupCompleted),
      ],
      child: const TodoApp(),
    ),
  );
}

Future<void> _seedGuestSessionIfNeeded(HiveDatabase hiveDb) async {
  if (!hiveDb.isSetupCompleted() && hiveDb.getAuthToken() == null) {
    log('[Seed] Seeding default guest session data...');

    await hiveDb.saveSelectedIdentity('🚀 Entrepreneur');
    await hiveDb.saveSelectedLifeAreas(['health', 'reading', 'finance', 'productivity']);
    await hiveDb.saveSelectedGoal('Become Consistent');

    final now = DateTime.now();
    await hiveDb.saveSelectedGoals([
      {
        'id': 'g_seed_1',
        'localId': 'g_seed_1',
        'title': 'Launch My Project',
        'category': 'Productivity',
        'target': 100,
        'currentProgress': 30,
        'status': 'in-progress',
        'priority': 'high',
        'deadline': now.add(const Duration(days: 30)).toIso8601String(),
        'syncStatus': 'pending',
      }
    ]);

    await hiveDb.saveReadingPreferences({
      'categories': ['Self-Improvement', 'Business'],
      'bookTarget': 12,
      'dailyReadingMinutes': 20,
    });

    await hiveDb.saveHealthPreferences({
      'waterTarget': 2000,
      'sleepTarget': 8,
      'exerciseTarget': 30,
    });

    await hiveDb.saveFinancePreferences({
      'monthlySavings': 10000,
    });

    await hiveDb.saveSelectedHabits([
      {
        'id': 'h_seed_1',
        'localId': 'h_seed_1',
        'title': '🏋 Workout',
        'category': 'Health',
        'difficulty': 'Medium',
        'isEnabled': true,
        'syncStatus': 'pending',
      },
      {
        'id': 'h_seed_2',
        'localId': 'h_seed_2',
        'title': '📖 Read 20 Pages',
        'category': 'Productivity',
        'difficulty': 'Easy',
        'isEnabled': true,
        'syncStatus': 'pending',
      },
      {
        'id': 'h_seed_3',
        'localId': 'h_seed_3',
        'title': '💰 Track Expenses',
        'category': 'Finance',
        'difficulty': 'Easy',
        'isEnabled': true,
        'syncStatus': 'pending',
      },
    ]);

    await hiveDb.saveSelectedAffirmations([
      {
        'id': 'a_seed_1',
        'localId': 'a_seed_1',
        'text': 'Discipline creates freedom.',
        'author': 'Focus Core',
        'category': 'General',
        'isPinned': true,
        'syncStatus': 'pending',
      },
      {
        'id': 'a_seed_2',
        'localId': 'a_seed_2',
        'text': 'I am matching my potential daily.',
        'author': 'Focus Core',
        'category': 'General',
        'isPinned': false,
        'syncStatus': 'pending',
      }
    ]);

    await hiveDb.saveUserStatistics({
      'disciplinePoints': 0,
      'level': 1,
      'currentStreak': 0,
      'bestStreak': 0,
      'totalHabitsCompleted': 0,
    });

    await hiveDb.saveWorkspaceSettings({
      'woodTexture': 'Walnut',
      'wallColor': 'Deep Indigo',
      'plantType': 'Bonsai',
      'ambientMode': 'Auto',
      'rainMode': false,
      'homeExperience': 'living',
    });

    await hiveDb.saveSetupCompleted(true);
    log('[Seed] Seeding completed.');
  }
}

class TodoApp extends ConsumerWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);

    return MaterialApp(
      title: 'Getzio Focus',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      home: onboardingCompleted
          ? const OSDashboardScreen()
          : const PremiumMVPOnboardingScreen(),
    );
  }
}

