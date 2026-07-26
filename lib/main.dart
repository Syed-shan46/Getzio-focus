import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/hive_database.dart';
import 'core/storage/sample_data_seeding_service.dart';
import 'core/theme/app_theme.dart';
import 'core/services/firebase_service.dart';
import 'shared/providers/app_providers.dart';
import 'features/onboarding/presentation/screens/premium_mvp_onboarding_screen.dart';
import 'features/onboarding/presentation/screens/video_splash_screen.dart';
import 'features/daily_motivation/presentation/screens/daily_motivation_screen.dart';
import 'features/os_dashboard/presentation/screens/os_dashboard_screen.dart';
import 'shared/providers/theme_provider.dart';
import 'core/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
    
    // Retrieve and print FCM token
    final fcmToken = await FirebaseMessaging.instance.getToken();
    log('[FCM] Token: $fcmToken');
    print("FCM Token: $fcmToken");
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

  // Initialize Notifications & send test
  try {
    await NotificationService().init();
    await NotificationService().showTestNotification();
    log('[Init] Notifications initialized and test sent');
  } catch (e) {
    log('[Init] Notifications error: $e');
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
  if (hiveDb.getAuthToken() != null) return;
  final needsSeed = !hiveDb.isSampleDataSeeded() ||
      hiveDb.getSampleDataVersion() < SampleDataSeedingService.currentVersion;
  if (needsSeed) {
    log('[Seed] Seeding default guest session data using SampleDataSeedingService...');
    await SampleDataSeedingService.seedAll(hiveDb);
  }
}

class TodoApp extends ConsumerWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Getzio Focus',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: VideoSplashScreen(
        nextScreen: onboardingCompleted
            ? const OSDashboardScreen()
            : const PremiumMVPOnboardingScreen(),
      ),
    );
  }
}

