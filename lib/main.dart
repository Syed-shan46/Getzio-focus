import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/hive_database.dart';
import 'core/theme/app_theme.dart';
import 'features/todo/presentation/screens/home_screen.dart';
import 'features/auth/presentation/screens/phone_login_screen.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'core/services/firebase_service.dart';
import 'shared/providers/app_providers.dart';

final onboardingCompletedProvider = StateProvider<bool>((ref) {
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
  } catch (e) {
    log('[Init] Hive error: $e');
  }

  final onboardingCompleted = hiveDb.isOnboardingCompleted();

  runApp(
    ProviderScope(
      overrides: [
        hiveDatabaseProvider.overrideWithValue(hiveDb),
        onboardingCompletedProvider.overrideWith((ref) => onboardingCompleted),
      ],
      child: const TodoApp(),
    ),
  );
}

class TodoApp extends ConsumerWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);

    return MaterialApp(
      title: 'Getzio Focus',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      home: !onboardingCompleted
          ? const OnboardingScreen()
          : authState.when(
              data: (user) => user != null ? const HomeScreen() : const PhoneLoginScreen(),
              loading: () => const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accentBlue,
                    strokeWidth: 2,
                  ),
                ),
              ),
              error: (err, _) => Scaffold(
                body: Center(
                  child: Text(
                    'Error loading auth state: $err',
                    style: AppTypography.bodyMedium(color: AppColors.error),
                  ),
                ),
              ),
            ),
    );
  }
}
