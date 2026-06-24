import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/vision_item.dart';

class GoalCardWidget extends StatelessWidget {
  final VisionItem item;

  const GoalCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final metadata = item.metadata ?? {};
    final title = metadata['title'] as String? ?? 'My Goal';
    final description = metadata['description'] as String? ?? '';
    final progress = (metadata['progress'] as num?)?.toDouble() ?? 0.0;
    final priority = metadata['priority'] as String? ?? 'Medium';
    final colorValue = metadata['color'] as int? ?? Colors.blueAccent.value;
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
            borderRadius: BorderRadius.circular(24),
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

          // Footer: Progress Ring and Percentage
          Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress / 100,
                      strokeWidth: 6,
                      backgroundColor: themeColor.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                    Center(
                      child: Text(
                        '${progress.toInt()}%',
                        style: AppTypography.caption(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progress == 100 ? 'Completed!' : 'In Progress',
                      style: AppTypography.bodyMedium(color: Colors.white),
                    ),
                    Text(
                      'Keep pushing forward',
                      style: AppTypography.caption(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ],
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
