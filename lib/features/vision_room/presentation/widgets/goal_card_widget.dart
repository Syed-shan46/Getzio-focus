import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/smart_object_models.dart';
import '../../domain/models/vision_item.dart';

class GoalCardWidget extends StatelessWidget {
  final VisionItem item;

  const GoalCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final metadata = item.metadata ?? {};
    final title = item.content.isNotEmpty ? item.content : (metadata['title'] as String? ?? 'My Goal');
    final description = metadata['description'] as String? ?? '';
    final progressRatio = item.smartProgress;
    final progressPercent = item.smartProgressPercent;
    final priority = metadata['priority'] as String? ?? 'Medium';
    final colorValue = metadata['color'] as int? ?? Colors.blueAccent.toARGB32();
    final themeColor = Color(colorValue);

    return FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: 300,
        height: 200,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B), // Dark slate
            borderRadius: BorderRadius.zero,
            border: Border.all(color: themeColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title and Priority
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleLarge(color: Colors.white).copyWith(fontSize: 20),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(priority).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getPriorityColor(priority).withValues(alpha: 0.5)),
                ),
                child: Text(
                  priority.toUpperCase(),
                  style: AppTypography.caption(color: _getPriorityColor(priority)).copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTypography.bodyMedium(color: Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          const Spacer(),

          // Footer: Beautiful Road Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progressPercent == 100 ? 'Goal Reached!' : 'Journey in Progress',
                style: AppTypography.bodyMedium(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '$progressPercent%',
                style: AppTypography.caption(color: themeColor).copyWith(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              const double roadHeight = 16.0;
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  // Road Background
                  Container(
                    width: width,
                    height: roadHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12, width: 1),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4)
                      ],
                    ),
                  ),
                  // Dashed Center Line
                  Positioned.fill(
                    child: Row(
                      children: List.generate(
                        20,
                        (index) => Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            color: index % 2 == 0 ? Colors.white24 : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Filled Progress (Road traveled)
                  Container(
                    width: width * progressRatio,
                    height: roadHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [themeColor.withValues(alpha: 0.3), themeColor.withValues(alpha: 0.8)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Flag at the end
                  Positioned(
                    right: -4,
                    top: -24,
                    child: const Icon(
                      Icons.flag_rounded,
                      color: Colors.orangeAccent,
                      size: 28,
                    ),
                  ),
                  // Progress Marker (Person/Car)
                  Positioned(
                    left: (width * progressRatio).clamp(0.0, width - 24.0),
                    top: -12,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: themeColor.withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 2)
                        ],
                      ),
                      child: Icon(
                        Icons.directions_run_rounded,
                        color: themeColor,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.amber;
      case 'low':
      default:
        return Colors.greenAccent;
    }
  }
}
