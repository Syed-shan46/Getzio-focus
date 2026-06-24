import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/premium_chip.dart';
import '../widgets/section_header.dart';

/// Screen 5 — "What financial goal inspires you?"
/// Financial Goals, Savings Target, Monthly Challenge sections.
class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financePrefs = ref.watch(onboardingProvider).financePrefs;

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
              'What financial goal\ninspires you?',
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
              'Set your financial direction.',
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
                  // ─── Financial Goals (multi-select) ───────────────────
                  const SectionHeader(title: 'FINANCIAL GOALS'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _goalChip('Save Money', '💵', financePrefs, ref),
                        _goalChip('Emergency Fund', '🏦', financePrefs, ref),
                        _goalChip('Monthly Savings', '📊', financePrefs, ref),
                        _goalChip('Monthly Revenue', '💹', financePrefs, ref),
                        _goalChip('Business Growth', '📈', financePrefs, ref),
                        _goalChip('Investing', '📉', financePrefs, ref),
                        _goalChip('Debt Free', '🔓', financePrefs, ref),
                        _goalChip('Passive Income', '💸', financePrefs, ref),
                        _goalChip('Luxury Purchase', '💎', financePrefs, ref),
                        _goalChip('Home', '🏠', financePrefs, ref),
                        _goalChip('Vehicle', '🚗', financePrefs, ref),
                        _goalChip('Education', '🎓', financePrefs, ref),
                      ],
                    ),
                  ),

                  // ─── Savings Target (single select) ───────────────────
                  const SectionHeader(title: 'SAVINGS TARGET'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _targetPill('₹10K', financePrefs.savingsTarget, ref),
                        _targetPill('₹25K', financePrefs.savingsTarget, ref),
                        _targetPill('₹50K', financePrefs.savingsTarget, ref),
                        _targetPill('₹100K', financePrefs.savingsTarget, ref),
                        _targetPill('₹500K', financePrefs.savingsTarget, ref),
                        _targetPill('₹1M', financePrefs.savingsTarget, ref),
                      ],
                    ),
                  ),

                  // ─── Monthly Challenge (multi-select) ─────────────────
                  const SectionHeader(title: 'MONTHLY CHALLENGE'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _challengeChip('Save Daily', '🪙', financePrefs, ref),
                        _challengeChip('Track Expenses', '📝', financePrefs, ref),
                        _challengeChip('Avoid Impulse Buying', '🛑', financePrefs, ref),
                        _challengeChip('Invest Weekly', '📈', financePrefs, ref),
                        _challengeChip('Revenue Tracking', '📊', financePrefs, ref),
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

  Widget _goalChip(String label, String emoji, dynamic prefs, WidgetRef ref) {
    return PremiumChip(
      emoji: emoji,
      title: label,
      isSelected: prefs.financialGoals.contains(label),
      activeColor: const Color(0xFFE8A838),
      onTap: () {
        ref.read(onboardingProvider.notifier).toggleFinancialGoal(label);
      },
    );
  }

  Widget _targetPill(String label, String current, WidgetRef ref) {
    return PremiumPill(
      label: label,
      isSelected: current == label,
      activeColor: const Color(0xFFE8A838),
      onTap: () {
        ref.read(onboardingProvider.notifier).setSavingsTarget(label);
      },
    );
  }

  Widget _challengeChip(String label, String emoji, dynamic prefs, WidgetRef ref) {
    return PremiumChip(
      emoji: emoji,
      title: label,
      isSelected: prefs.monthlyChallenges.contains(label),
      activeColor: const Color(0xFFE8A838),
      onTap: () {
        ref.read(onboardingProvider.notifier).toggleMonthlyChallenge(label);
      },
    );
  }
}
