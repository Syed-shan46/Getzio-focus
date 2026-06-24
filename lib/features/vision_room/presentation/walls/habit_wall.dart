import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/vision_room_providers.dart';
import '../widgets/wall_header.dart';
import '../widgets/glass_card.dart';

class HabitWall extends ConsumerStatefulWidget {
  const HabitWall({super.key});

  @override
  ConsumerState<HabitWall> createState() => _HabitWallState();
}

class _HabitWallState extends ConsumerState<HabitWall> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(visionHabitsProvider);

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              WallHeader(
                title: 'Habit Shelf',
                subtitle: 'Your daily pillars',
                onAddPressed: () {
                  // TODO: Add habit
                },
              ),
              
              const SizedBox(height: AppSpacing.lg),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  physics: const BouncingScrollPhysics(),
                  itemCount: habits.length,
                  separatorBuilder: (c, i) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final h = habits[index];
                    return GlassCard(
                      onTap: () {
                        if (!h.completedToday) {
                          _confettiController.play();
                        }
                        ref.read(visionHabitsProvider.notifier).toggleHabit(h.id);
                      },
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: Color(h.colorValue).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(h.emoji, style: const TextStyle(fontSize: 24)),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  h.name,
                                  style: AppTypography.titleMedium(color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.local_fire_department_rounded, 
                                      size: 14, 
                                      color: h.streak > 0 ? Colors.orange : Colors.white38
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${h.streak} day streak',
                                      style: AppTypography.captionSmall(
                                        color: h.streak > 0 ? Colors.orange : Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Checkbox
                          Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: h.completedToday 
                                  ? AppColors.success 
                                  : Colors.white.withValues(alpha: 0.1),
                              border: Border.all(
                                color: h.completedToday 
                                    ? AppColors.success 
                                    : Colors.white.withValues(alpha: 0.3),
                                width: 2,
                              ),
                              boxShadow: h.completedToday ? [
                                BoxShadow(
                                  color: AppColors.success.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                )
                              ] : null,
                            ),
                            child: h.completedToday
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                                : null,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2, // downwards
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
