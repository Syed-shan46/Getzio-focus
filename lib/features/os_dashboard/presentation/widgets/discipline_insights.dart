import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/os_providers.dart';

class DisciplineInsights extends ConsumerWidget {
  const DisciplineInsights({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(osStateProvider);

    // Dynamic next achievement text
    String nextAchievement = 'Unstoppable (15 Day Streak)';
    if (state.currentStreak >= 15) {
      nextAchievement = 'Centurion (50 Habits Completed)';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'Discipline Insights',
            style: AppTypography.titleMedium(color: Colors.white).copyWith(fontSize: 20),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: GlassDecoration.card(),
          child: Column(
            children: [
              // Main Grid
              Row(
                children: [
                  Expanded(
                    child: _buildInsightItem(
                      label: 'Discipline Score',
                      value: '${state.disciplineScore.toInt()}%',
                      color: AppColors.accentEmerald,
                      subtext: 'Today\'s Completion',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInsightItem(
                      label: 'Weekly Growth',
                      value: '+15.4%',
                      color: AppColors.accentBlue,
                      subtext: 'vs Last Week',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInsightItem(
                      label: 'Current Streak',
                      value: '${state.currentStreak} Days',
                      color: Colors.orangeAccent,
                      subtext: 'Keep it going!',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInsightItem(
                      label: 'Best Streak',
                      value: '${state.bestStreak} Days',
                      color: Colors.purpleAccent,
                      subtext: 'All-time Record',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 20),
              
              // Next Achievement Bar
              Row(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Achievement',
                          style: AppTypography.caption(color: Colors.white54),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nextAchievement,
                          style: AppTypography.bodyMedium(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem({
    required String label,
    required String value,
    required Color color,
    required String subtext,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.captionSmall(color: Colors.white54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.displayMedium(color: color).copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtext,
          style: AppTypography.captionSmall(color: Colors.white30),
        ),
      ],
    );
  }
}
