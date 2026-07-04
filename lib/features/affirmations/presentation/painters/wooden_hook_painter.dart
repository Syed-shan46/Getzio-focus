import 'dart:math';
import 'package:flutter/material.dart';

/// Paints a realistic circular wooden hook (oak material) with subtle wood
/// grain, soft lighting, drop shadow, a screw detail, and a small engraved
/// star — as if screwed into the wall.
/// Paints a beautiful brass rounded peg/pin.
class WoodenHookPainter extends CustomPainter {
  final double radius;
  final int seed;

  const WoodenHookPainter({this.radius = 26.0, this.seed = 15});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    const pinRadius = 10.0;

    // ── 1. Drop shadow on wall ──
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(
      Offset(center.dx + 1.0, center.dy + 2.0),
      pinRadius,
      shadowPaint,
    );

    // ── 2. Rounded brass metal peg body ──
    final metalPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.85,
        colors: [
          const Color(0xFFFFF59D), // Bright highlight gold
          const Color(0xFFFBC02D), // Solid mid gold
          const Color(0xFFF57F17), // Deep shadow gold/bronze
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: pinRadius));
    canvas.drawCircle(center, pinRadius, metalPaint);

    // ── 3. High-end polished outer highlight rim ──
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(center, pinRadius - 0.4, rimPaint);

    // ── 4. Tiny reflection highlight dot ──
    canvas.drawCircle(
      Offset(center.dx - 3.2, center.dy - 3.2),
      1.5,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant WoodenHookPainter old) =>
      old.radius != radius || old.seed != seed;
}
