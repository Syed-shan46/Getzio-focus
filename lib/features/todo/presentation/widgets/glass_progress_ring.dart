import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Circular glass progress ring showing completion stats.
class GlassProgressRing extends StatelessWidget {
  final int completed;
  final int total;

  const GlassProgressRing({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (completed / total) : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.round),
      child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.glass,
            border: Border.all(color: AppColors.glassBorder, width: 0.5),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percentage),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return CustomPaint(
                painter: _ProgressRingPainter(
                  progress: value,
                  color: AppColors.accentBlue,
                  trackColor: AppColors.glassBorder,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: completed),
                        duration: const Duration(milliseconds: 600),
                        builder: (context, val, _) {
                          return RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$val',
                                  style: AppTypography.progressNumber(),
                                ),
                                TextSpan(
                                  text: ' / $total',
                                  style: AppTypography.progressLabel(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Text(
                        '${(value * 100).round()}%',
                        style: AppTypography.captionSmall(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;
    const strokeWidth = 3.5;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [
            color.withValues(alpha: 0.4),
            color,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );

      // Glow dot at the end
      final angle = -math.pi / 2 + 2 * math.pi * progress;
      final dotX = center.dx + radius * math.cos(angle);
      final dotY = center.dy + radius * math.sin(angle);

      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(dotX, dotY), 4, glowPaint);

      final dotPaint = Paint()..color = color;
      canvas.drawCircle(Offset(dotX, dotY), 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) => old.progress != progress;
}
