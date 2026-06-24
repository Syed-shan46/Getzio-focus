import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/os_providers.dart';

class PersonalGrowthLockedCard extends ConsumerWidget {
  const PersonalGrowthLockedCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(osStateProvider);
    final completedCount = state.totalHabitsCompletedAllTime;
    const targetCount = 15;
    
    final isUnlocked = completedCount >= targetCount;
    final progress = (completedCount / targetCount).clamp(0.0, 1.0);
    
    // Calculate block characters ██████░░░░
    final fullBlocks = (progress * 10).round().clamp(0, 10);
    final emptyBlocks = 10 - fullBlocks;
    final blocksString = ('█' * fullBlocks) + ('░' * emptyBlocks);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isUnlocked ? AppColors.accentBlue.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                        color: isUnlocked ? AppColors.accentEmerald : Colors.white30,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Personal Growth OS',
                        style: AppTypography.titleMedium(color: Colors.white70),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUnlocked ? AppColors.accentEmerald.withValues(alpha: 0.15) : Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isUnlocked ? 'UNLOCKED' : 'LOCKED',
                      style: AppTypography.captionSmall(
                        color: isUnlocked ? AppColors.accentEmerald : Colors.white54,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Content & Illustration Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔒 Personal Growth',
                          style: AppTypography.titleLarge(color: Colors.white).copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Complete 15 daily habits to unlock advanced self-reflection, journaling, and metrics.',
                          style: AppTypography.bodyMedium(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Custom Growth Illustration
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: CustomPaint(
                      painter: GrowthTreePainter(progress: progress),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Progress Display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    blocksString,
                    style: TextStyle(
                      fontFamily: 'Courier', // Monospace for align
                      fontSize: 16,
                      color: AppColors.accentBlue.withValues(alpha: 0.7),
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    '$completedCount / $targetCount Completed',
                    style: AppTypography.captionSmall(color: Colors.white70).copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isUnlocked ? AppColors.accentEmerald : AppColors.accentBlue,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CUSTOM TREE GROWTH PAINTER
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class GrowthTreePainter extends CustomPainter {
  final double progress;

  GrowthTreePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentBlue.withValues(alpha: 0.4)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;

    // Draw base pot/soil
    final potPath = Path()
      ..moveTo(width * 0.3, height * 0.85)
      ..lineTo(width * 0.7, height * 0.85)
      ..lineTo(width * 0.6, height * 0.95)
      ..lineTo(width * 0.4, height * 0.95)
      ..close();
    
    canvas.drawPath(potPath, paint);

    if (progress > 0.1) {
      // Main trunk
      final trunkHeight = height * 0.85 - (height * 0.45 * progress);
      canvas.drawLine(
        Offset(width / 2, height * 0.85),
        Offset(width / 2, trunkHeight),
        paint..color = AppColors.accentBlue,
      );

      if (progress > 0.4) {
        // Left Branch
        canvas.drawCurve(
          canvas,
          Offset(width / 2, height * 0.6),
          Offset(width * 0.25, height * 0.45),
          paint..color = AppColors.accentBlue.withValues(alpha: 0.8),
        );
      }
      if (progress > 0.7) {
        // Right Branch
        canvas.drawCurve(
          canvas,
          Offset(width / 2, height * 0.55),
          Offset(width * 0.75, height * 0.4),
          paint..color = AppColors.accentBlue.withValues(alpha: 0.8),
        );
      }
      if (progress >= 1.0) {
        // Top bud/leaf
        final leafPaint = Paint()
          ..color = AppColors.accentEmerald
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(width / 2, trunkHeight - 4), 6, leafPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GrowthTreePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

extension on Canvas {
  void drawCurve(Canvas canvas, Offset start, Offset end, Paint paint) {
    final control = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2 - 10);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    canvas.drawPath(path, paint);
  }
}
