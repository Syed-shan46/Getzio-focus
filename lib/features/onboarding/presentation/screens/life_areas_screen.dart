import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/onboarding_models.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/premium_chip.dart';

/// Screen 1 — "What would you like to improve?"
/// Multi-select flowing chip layout for life areas.
class LifeAreasScreen extends ConsumerWidget {
  const LifeAreasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAreas = ref.watch(onboardingProvider).selectedLifeAreas;

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
              'What would you\nlike to improve?',
              style: AppTypography.displayLarge(color: Colors.white).copyWith(
                fontSize: 34,
                height: 1.12,
                letterSpacing: -0.8,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              'Choose the areas that matter most today.\nYou can always change them later.',
              style: AppTypography.bodyMedium(
                color: Colors.white.withValues(alpha: 0.4),
              ).copyWith(height: 1.5),
            ),
          ),

          const SizedBox(height: 32),

          // Flowing chip layout
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: LifeArea.defaults.map((area) {
                  final isSelected = selectedAreas.contains(area.id);
                  return PremiumChip(
                    emoji: area.emoji,
                    title: area.title,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(onboardingProvider.notifier).toggleLifeArea(area.id);
                    },
                  );
                }).toList(),
              ),
            ),
          ),

          // Bottom spacing for navigation bar
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
