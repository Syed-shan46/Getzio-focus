import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/premium_chip.dart';
import '../widgets/section_header.dart';

/// Screen 4 — "Build a healthier lifestyle."
/// Sectioned layout: Weight Goal, Activity, Nutrition, Sleep.
class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthPrefs = ref.watch(onboardingProvider).healthPrefs;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Headline
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              'Build a healthier\nlifestyle.',
              style: AppTypography.displayLarge(color: Colors.white).copyWith(
                fontSize: 34,
                height: 1.12,
                letterSpacing: -0.8,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              'Choose what matters to your body and mind.',
              style: AppTypography.bodyMedium(
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Scrollable sections
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Weight Goal (single select) ──────────────────────
                  const SectionHeader(title: 'WEIGHT GOAL'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _weightPill('Lose Weight', '🔥', healthPrefs.weightGoal, ref),
                        _weightPill('Maintain Weight', '⚖️', healthPrefs.weightGoal, ref),
                        _weightPill('Gain Weight', '💪', healthPrefs.weightGoal, ref),
                      ],
                    ),
                  ),

                  // ─── Activity (multi-select) ──────────────────────────
                  const SectionHeader(title: 'ACTIVITY'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _activityChip('Walking', '🚶', healthPrefs, ref),
                        _activityChip('Running', '🏃', healthPrefs, ref),
                        _activityChip('Gym', '🏋️', healthPrefs, ref),
                        _activityChip('Cycling', '🚴', healthPrefs, ref),
                        _activityChip('Yoga', '🧘', healthPrefs, ref),
                        _activityChip('Stretching', '🤸', healthPrefs, ref),
                        _activityChip('Home Workout', '🏠', healthPrefs, ref),
                        _activityChip('Swimming', '🏊', healthPrefs, ref),
                      ],
                    ),
                  ),

                  // ─── Nutrition (multi-select) ─────────────────────────
                  const SectionHeader(title: 'NUTRITION'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _nutritionChip('Drink More Water', '💧', healthPrefs, ref),
                        _nutritionChip('Eat Fruits', '🍎', healthPrefs, ref),
                        _nutritionChip('Eat Vegetables', '🥦', healthPrefs, ref),
                        _nutritionChip('Reduce Sugar', '🍬', healthPrefs, ref),
                        _nutritionChip('No Soft Drinks', '🥤', healthPrefs, ref),
                        _nutritionChip('High Protein', '🥩', healthPrefs, ref),
                      ],
                    ),
                  ),

                  // ─── Sleep (single select) ────────────────────────────
                  const SectionHeader(title: 'SLEEP'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _sleepPill('Sleep Before 10 PM', '🌙', healthPrefs.sleepGoal, ref),
                        _sleepPill('Sleep Before 11 PM', '🌜', healthPrefs.sleepGoal, ref),
                        _sleepPill('8 Hours Sleep', '😴', healthPrefs.sleepGoal, ref),
                        _sleepPill('Improve Sleep Quality', '✨', healthPrefs.sleepGoal, ref),
                      ],
                    ),
                  ),

                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weightPill(String label, String emoji, String current, WidgetRef ref) {
    return PremiumChip(
      emoji: emoji,
      title: label,
      isSelected: current == label,
      activeColor: AppColors.accentEmerald,
      onTap: () {
        ref.read(onboardingProvider.notifier).setWeightGoal(label);
      },
    );
  }

  Widget _activityChip(String label, String emoji, dynamic prefs, WidgetRef ref) {
    return PremiumChip(
      emoji: emoji,
      title: label,
      isSelected: prefs.activities.contains(label),
      activeColor: AppColors.accentEmerald,
      onTap: () {
        ref.read(onboardingProvider.notifier).toggleActivity(label);
      },
    );
  }

  Widget _nutritionChip(String label, String emoji, dynamic prefs, WidgetRef ref) {
    return PremiumChip(
      emoji: emoji,
      title: label,
      isSelected: prefs.nutritionGoals.contains(label),
      activeColor: AppColors.accentEmerald,
      onTap: () {
        ref.read(onboardingProvider.notifier).toggleNutritionGoal(label);
      },
    );
  }

  Widget _sleepPill(String label, String emoji, String current, WidgetRef ref) {
    return PremiumChip(
      emoji: emoji,
      title: label,
      isSelected: current == label,
      activeColor: AppColors.accentEmerald,
      onTap: () {
        ref.read(onboardingProvider.notifier).setSleepGoal(label);
      },
    );
  }
}
