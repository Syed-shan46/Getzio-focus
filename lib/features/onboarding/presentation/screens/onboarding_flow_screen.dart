import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/onboarding_background.dart';
import '../widgets/onboarding_bottom_bar.dart';
import 'welcome_screen.dart';
import 'life_areas_screen.dart';
import 'goals_screen.dart';
import 'habits_screen.dart';
import 'reading_screen.dart';
import 'health_screen.dart';
import 'finance_screen.dart';
import 'affirmations_screen.dart';
import 'review_screen.dart';

/// Premium 9-screen onboarding flow with persistent background,
/// bottom navigation bar, and smooth page transitions.
class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const int _totalSteps = 9; // Welcome(0), LifeAreas(1), Goals(2), Habits(3), Reading(4), Health(5), Finance(6), Affirmations(7), Review(8)

  void _nextPage() {
    if (_currentIndex < _totalSteps - 1) {
      _pageController.animateToPage(
        _currentIndex + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.animateToPage(
        _currentIndex - 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  bool _canContinue(OnboardingState state) {
    switch (_currentIndex) {
      case 0: // Welcome — always can continue
        return true;
      case 1: // Life Areas — at least 1 selected
        return state.selectedLifeAreas.isNotEmpty;
      case 2: // Goals — at least 1 selected
        return state.selectedGoals.isNotEmpty;
      case 3: // Habits — at least 1 selected
        return state.selectedHabits.isNotEmpty;
      case 4: // Reading — at least 1 category
        return state.readingPrefs.categories.isNotEmpty;
      case 5: // Health — at least 1 selection anywhere
        return state.healthPrefs.weightGoal.isNotEmpty ||
            state.healthPrefs.activities.isNotEmpty ||
            state.healthPrefs.nutritionGoals.isNotEmpty ||
            state.healthPrefs.sleepGoal.isNotEmpty;
      case 6: // Finance — at least 1 selection
        return state.financePrefs.financialGoals.isNotEmpty ||
            state.financePrefs.savingsTarget.isNotEmpty;
      case 7: // Affirmations — at least 1 selected
        return state.selectedAffirmations.isNotEmpty;
      case 8: // Review — handled by screen itself
        return true;
      default:
        return false;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: OnboardingBackground(
        child: Stack(
          children: [
            // Main Pages
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              children: [
                WelcomeScreen(onNext: _nextPage),
                const LifeAreasScreen(),
                const GoalsScreen(),
                const HabitsScreen(),
                const ReadingScreen(),
                const HealthScreen(),
                const FinanceScreen(),
                const AffirmationsScreen(),
                const ReviewScreen(),
              ],
            ),

            // Bottom Navigation Bar (hidden on Welcome and Review)
            if (_currentIndex > 0 && _currentIndex < _totalSteps - 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: OnboardingBottomBar(
                  currentStep: _currentIndex,
                  totalSteps: _totalSteps - 1, // Exclude welcome from progress
                  canContinue: _canContinue(onboardingState),
                  showBack: _currentIndex > 0,
                  onBack: _prevPage,
                  onContinue: _canContinue(onboardingState)
                      ? _nextPage
                      : () {},
                ),
              ),
          ],
        ),
      ),
    );
  }
}
