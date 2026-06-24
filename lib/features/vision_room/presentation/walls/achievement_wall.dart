import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vision_room_providers.dart';
import '../widgets/wall_header.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';

class AchievementWall extends ConsumerWidget {
  const AchievementWall({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(visionAchievementsProvider);

    return SafeArea(
      child: Column(
        children: [
          WallHeader(
            title: 'Trophy Room',
            subtitle: 'Your milestones and victories',
            onAddPressed: () {}, // Generally auto-unlocked
          ),
          
          const SizedBox(height: AppSpacing.lg),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.8,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final a = achievements[index];
                
                return GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Badge icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: a.isUnlocked 
                              ? Colors.amber.withValues(alpha: 0.1) 
                              : Colors.white.withValues(alpha: 0.02),
                          border: Border.all(
                            color: a.isUnlocked 
                                ? Colors.amber.withValues(alpha: 0.5) 
                                : Colors.white.withValues(alpha: 0.05),
                            width: 2,
                          ),
                          boxShadow: a.isUnlocked ? [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.2),
                              blurRadius: 20,
                            )
                          ] : null,
                        ),
                        child: Text(
                          a.isUnlocked ? a.icon : '🔒', 
                          style: const TextStyle(fontSize: 32)
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        a.isUnlocked ? a.title : 'Locked',
                        style: AppTypography.bodyLarge(
                          color: a.isUnlocked ? Colors.white : Colors.white54,
                        ).copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        a.isUnlocked ? a.description : 'Keep going to unlock',
                        style: AppTypography.captionSmall(
                          color: a.isUnlocked ? Colors.white70 : Colors.white38,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
