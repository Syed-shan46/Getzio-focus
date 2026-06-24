import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/vision_room_providers.dart';
import '../widgets/wall_header.dart';
import '../widgets/glass_card.dart';

class TimelineWall extends ConsumerWidget {
  const TimelineWall({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final milestones = ref.watch(visionTimelineProvider);

    // Group by year
    final Map<int, List<dynamic>> grouped = {};
    for (var m in milestones) {
      if (!grouped.containsKey(m.year)) grouped[m.year] = [];
      grouped[m.year]!.add(m);
    }
    
    final sortedYears = grouped.keys.toList()..sort();

    return SafeArea(
      child: Column(
        children: [
          WallHeader(
            title: 'Future Timeline',
            subtitle: 'Map out your destiny',
            onAddPressed: () {},
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.lg, bottom: 100),
              physics: const BouncingScrollPhysics(),
              itemCount: sortedYears.length,
              itemBuilder: (context, index) {
                final year = sortedYears[index];
                final yearMilestones = grouped[year]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Year Marker
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Row(
                        children: [
                          Text(
                            year.toString(),
                            style: AppTypography.displayLarge(color: AppColors.accentBlue),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.glassBorder,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Milestones for this year
                    ...yearMilestones.map((m) {
                      return Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.xl, bottom: AppSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timeline dot & line
                            Column(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: m.isCompleted ? Color(m.colorValue) : Colors.transparent,
                                    border: Border.all(
                                      color: Color(m.colorValue),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 2,
                                  height: 80, // Approximate height to next item
                                  color: AppColors.glassBorder,
                                ),
                              ],
                            ),
                            const SizedBox(width: AppSpacing.md),
                            
                            // Milestone Card
                            Expanded(
                              child: GlassCard(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getMonthName(m.month),
                                      style: AppTypography.captionSmall(color: Color(m.colorValue))
                                          .copyWith(letterSpacing: 1),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      m.title,
                                      style: AppTypography.titleMedium(
                                        color: m.isCompleted ? Colors.white70 : Colors.white,
                                      ).copyWith(
                                        decoration: m.isCompleted ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}
