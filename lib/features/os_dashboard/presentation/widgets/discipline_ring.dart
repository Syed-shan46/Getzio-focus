import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/os_providers.dart';

class DisciplineRing extends ConsumerStatefulWidget {
  const DisciplineRing({super.key});

  @override
  ConsumerState<DisciplineRing> createState() => _DisciplineRingState();
}

class _DisciplineRingState extends ConsumerState<DisciplineRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _animation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(osStateProvider);
    final selectedHabits = state.selectedHabits;
    final completedHabitsCount = state.completedHabitIdsToday.length;
    final totalHabitsCount = selectedHabits.length;
    final remainingHabitsCount = totalHabitsCount - completedHabitsCount;
    final xpEarned = completedHabitsCount * 10;
    
    final scoreRatio = totalHabitsCount == 0 ? 0.0 : completedHabitsCount / totalHabitsCount;

    // Animate to new score ratio
    _animation = Tween<double>(begin: _animation.value, end: scoreRatio)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward(from: 0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentEmerald.withValues(alpha: 0.02),
                blurRadius: 60,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Daily Discipline',
                style: AppTypography.titleMedium(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background Track
                      CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 14,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.05)),
                      ),
                      // Animated Fill
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return CircularProgressIndicator(
                            value: _animation.value,
                            strokeWidth: 14,
                            strokeCap: StrokeCap.round,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentEmerald),
                          );
                        },
                      ),
                      // Inner Content (Score, Completed stats, Remaining)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Text(
                                  '${(_animation.value * 100).toInt()}%',
                                  style: AppTypography.displayLarge(color: Colors.white).copyWith(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$completedHabitsCount / $totalHabitsCount Done',
                              style: AppTypography.bodyMedium(color: Colors.white70).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              remainingHabitsCount == 0 ? 'All Completed!' : '$remainingHabitsCount Remaining',
                              style: AppTypography.caption(
                                color: remainingHabitsCount == 0 ? AppColors.accentEmerald : Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Completion Metrics & XP Earned today
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetricStat(
                    icon: Icons.flash_on_rounded,
                    color: Colors.yellowAccent,
                    value: '+$xpEarned XP',
                    label: 'Earned Today',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white12,
                  ),
                  _buildMetricStat(
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.accentEmerald,
                    value: '$completedHabitsCount Tasks',
                    label: 'Completed',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricStat({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              value,
              style: AppTypography.titleMedium(color: Colors.white).copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.captionSmall(color: Colors.white38),
        ),
      ],
    );
  }
}
