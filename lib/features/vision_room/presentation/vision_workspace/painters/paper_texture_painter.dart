import 'dart:math';
import 'package:flutter/material.dart';

class PaperTexturePainter extends CustomPainter {
  final Color baseColor;
  final Color accentColor;

  PaperTexturePainter({
    this.baseColor = const Color(0xFFF5F0E8),
    this.accentColor = const Color(0xFFE8E0D0),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = baseColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    paint.color = accentColor.withValues(alpha: 0.15);
    for (int i = 0; i < 300; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final r = 0.5 + random.nextDouble() * 1.5;
      canvas.drawCircle(Offset(x, y), r, paint);
    }

    final fiberPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3
      ..color = accentColor.withValues(alpha: 0.08);

    final fiberRandom = Random(123);
    for (int i = 0; i < 80; i++) {
      final x = fiberRandom.nextDouble() * size.width;
      final y = fiberRandom.nextDouble() * size.height;
      final angle = fiberRandom.nextDouble() * pi;
      final len = 10 + fiberRandom.nextDouble() * 30;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + cos(angle) * len, y + sin(angle) * len),
        fiberPaint,
      );
    }

    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          Colors.transparent,
          Colors.brown.withValues(alpha: 0.04),
          Colors.brown.withValues(alpha: 0.08),
        ],
        stops: const [0.4, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignette);
  }

  @override
  bool shouldRepaint(covariant PaperTexturePainter old) =>
      old.baseColor != baseColor || old.accentColor != accentColor;
}
