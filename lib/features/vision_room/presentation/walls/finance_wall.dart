import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vision_room_providers.dart';
import '../widgets/wall_header.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../widgets/glass_card.dart';

class FinanceWall extends ConsumerWidget {
  const FinanceWall({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(visionFinanceGoalsProvider);
    final totalTarget = goals.fold<double>(0, (sum, item) => sum + item.targetAmount);
    final totalCurrent = goals.fold<double>(0, (sum, item) => sum + item.currentAmount);
    final overallProgress = totalTarget > 0 ? (totalCurrent / totalTarget).clamp(0.0, 1.0) : 0.0;

    return SafeArea(
      child: Column(
        children: [
          WallHeader(
            title: 'Wealth & Finance',
            subtitle: 'Your financial empire',
            onAddPressed: () {
              // TODO: Open add goal sheet
            },
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Main Vault / Net Worth
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.03),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentEmerald.withValues(alpha: 0.1),
                  blurRadius: 40,
                  spreadRadius: 10,
                )
              ],
            ),
            child: CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 8.0,
              percent: overallProgress,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏦', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(
                    '\$${(totalCurrent/1000).toStringAsFixed(1)}k',
                    style: AppTypography.displayLarge(color: Colors.white),
                  ),
                  Text(
                    'Net Worth',
                    style: AppTypography.caption(color: Colors.white54),
                  ),
                ],
              ),
              progressColor: AppColors.accentEmerald,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 1500,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Goals Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.85,
              ),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.icon, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        goal.title,
                        style: AppTypography.bodyLarge(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${(goal.currentAmount/1000).toStringAsFixed(1)}k / \$${(goal.targetAmount/1000).toStringAsFixed(1)}k',
                        style: AppTypography.captionSmall(color: Colors.white54),
                      ),
                      const Spacer(),
                      LinearProgressIndicator(
                        value: goal.progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(goal.colorValue)),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 6,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
