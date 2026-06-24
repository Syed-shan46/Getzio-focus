import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/vision_room_providers.dart';
import '../widgets/wall_header.dart';
import '../widgets/glass_card.dart';

class MotivationWall extends ConsumerWidget {
  const MotivationWall({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          WallHeader(
            title: 'Motivation',
            subtitle: 'Fuel for your fire',
            onAddPressed: () {},
          ),
          
          const SizedBox(height: AppSpacing.lg),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              physics: const BouncingScrollPhysics(),
              children: [
                // Daily Affirmation
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAILY AFFIRMATION',
                        style: AppTypography.captionSmall(color: AppColors.accentBlue)
                            .copyWith(letterSpacing: 2),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '"I am capable of achieving everything I set my mind to. Today is a stepping stone to my future."',
                        style: AppTypography.titleLarge(color: Colors.white).copyWith(
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Current Focus Streak
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 32),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '12 Days',
                            style: AppTypography.displayMedium(color: Colors.white),
                          ),
                          Text(
                            'Current Focus Streak',
                            style: AppTypography.bodyMedium(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Featured Quote
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FROM STEVE JOBS',
                        style: AppTypography.captionSmall(color: Colors.white54)
                            .copyWith(letterSpacing: 2),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '"The people who are crazy enough to think they can change the world are the ones who do."',
                        style: AppTypography.titleMedium(color: Colors.white).copyWith(
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
