import 'dart:math';
import 'package:flutter/material.dart';

/// Paints a realistic wooden plank with rounded edges (18px), visible
/// thickness (10px), bevels on all four edges, wood grain texture wrapping
/// around edges, painted matte pastel finish, soft imperfections, and
/// realistic shadows.
///
/// The plank uses calming Scandinavian pastel colors with a matte painted
/// surface. Two drilled holes are painted on the left and right sides for
/// the rope to pass through, with contact shadows where rope touches wood.
class WoodenPlankPainter extends CustomPainter {
  final Color plankColor;
  final Color textColor;
  final bool isPinned;
  final bool isFavorite;
  final int seed;
  final double bevelDepth;
  final double cornerRadius;
  final double holeInset;
  final double holeRadius;
  final double tiltAngle;

  const WoodenPlankPainter({
    required this.plankColor,
    required this.textColor,
    this.isPinned = false,
    this.isFavorite = false,
    this.seed = 100,
    this.bevelDepth = 10.0,
    this.cornerRadius = 18.0,
    this.holeInset = 28.0,
    this.holeRadius = 5.0,
    this.tiltAngle = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = Rect.fromLTWH(0, 0, w, h);
    final borderRadius = BorderRadius.circular(cornerRadius);
    final rrect = borderRadius.resolve(TextDirection.ltr).toRRect(r);
    final rGrain = Random(seed);

    // ── 1. Drop shadow (onto wall — soft, layered) ────────────────────────
    // Dynamic shadow shift based on tilt angle to reinforce 3D depth
    final shadowOffsetX = -tiltAngle * 18.0;
    final shadowOffsetY = 6.0 + tiltAngle.abs() * 15.0;
    final shadowBlur = 14.0 + tiltAngle.abs() * 10.0;

    // Outer soft shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        r.shift(Offset(shadowOffsetX, shadowOffsetY + 4.0)),
        borderRadius.topLeft,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur),
    );
    // Inner sharper shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        r.shift(Offset(shadowOffsetX * 0.5, shadowOffsetY)),
        borderRadius.topLeft,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur * 0.35),
    );

    // ── 1.5. Clip to rounded rect for finished corners ───────────────────
    canvas.save();
    canvas.clipRRect(rrect);

    // ── 2. Plank thickness — all four edges ───────────────────────────────
    final thicknessColor = _darkenColor(plankColor, 0.35);
    final thicknessPaint = Paint()
      ..color = thicknessColor
      ..style = PaintingStyle.fill;

    // Bottom edge thickness
    final bottomPath = Path();
    bottomPath.moveTo(cornerRadius * 0.5, h - bevelDepth);
    bottomPath.lineTo(0, h - bevelDepth * 0.6);
    bottomPath.lineTo(0, h);
    bottomPath.lineTo(w, h);
    bottomPath.lineTo(w, h - bevelDepth * 0.6);
    bottomPath.lineTo(w - cornerRadius * 0.5, h - bevelDepth);
    bottomPath.close();
    canvas.drawPath(bottomPath, thicknessPaint);

    // Left edge thickness
    final leftPath = Path();
    leftPath.moveTo(0, cornerRadius * 0.5);
    leftPath.lineTo(0, h - cornerRadius * 0.5);
    leftPath.lineTo(bevelDepth * 0.6, h);
    leftPath.lineTo(bevelDepth, h - cornerRadius * 0.3);
    leftPath.lineTo(bevelDepth, cornerRadius * 0.3);
    leftPath.lineTo(bevelDepth * 0.6, 0);
    leftPath.close();
    canvas.drawPath(leftPath, thicknessPaint);

    // Right edge thickness
    final rightPath = Path();
    rightPath.moveTo(w, cornerRadius * 0.5);
    rightPath.lineTo(w, h - cornerRadius * 0.5);
    rightPath.lineTo(w - bevelDepth * 0.6, h);
    rightPath.lineTo(w - bevelDepth, h - cornerRadius * 0.3);
    rightPath.lineTo(w - bevelDepth, cornerRadius * 0.3);
    rightPath.lineTo(w - bevelDepth * 0.6, 0);
    rightPath.close();
    canvas.drawPath(rightPath, thicknessPaint);

    // Top edge thickness (subtle — light hits this edge)
    final topPath = Path();
    topPath.moveTo(cornerRadius * 0.5, 0);
    topPath.lineTo(w - cornerRadius * 0.5, 0);
    topPath.lineTo(w - cornerRadius * 0.3, bevelDepth * 0.4);
    topPath.lineTo(cornerRadius * 0.3, bevelDepth * 0.4);
    topPath.close();
    canvas.drawPath(topPath, Paint()..color = _darkenColor(plankColor, 0.15));

    // ── 3. Main plank body (matte pastel painted surface) ─────────────────
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _lightenColor(plankColor, 0.06),
          plankColor,
          _darkenColor(plankColor, 0.04),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(r);
    canvas.drawRRect(rrect, bodyPaint);

    // ── 4. Wood grain texture (horizontal lines with slight wave) ─────────
    final grainPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;

    for (int i = 0; i < 30; i++) {
      final y = rGrain.nextDouble() * h;
      final x0 = rGrain.nextDouble() * w * 0.06;
      final len = w * 0.55 + rGrain.nextDouble() * w * 0.45;
      final alpha = 0.025 + rGrain.nextDouble() * 0.045;
      grainPaint.color = _darkenColor(plankColor, 0.2).withValues(alpha: alpha);
      final midY = y + (rGrain.nextDouble() - 0.5) * 2.0;
      canvas.drawLine(Offset(x0, y), Offset(x0 + len * 0.5, midY), grainPaint);
      canvas.drawLine(
        Offset(x0 + len * 0.5, midY),
        Offset(x0 + len, y + (rGrain.nextDouble() - 0.5) * 2.0),
        grainPaint,
      );
    }

    // ── 5. Paint texture (matte finish — subtle noise) ────────────────────
    final texturePaint = Paint()..style = PaintingStyle.fill;
    final rTex = Random(seed + 33);
    for (int i = 0; i < 350; i++) {
      final x = rTex.nextDouble() * w;
      final y = rTex.nextDouble() * h;
      final rad = 0.3 + rTex.nextDouble() * 0.6;
      final choice = rTex.nextInt(3);
      Color color;
      double alpha;
      if (choice == 0) {
        color = _lightenColor(plankColor, 0.15);
        alpha = 0.018 + rTex.nextDouble() * 0.03;
      } else if (choice == 1) {
        color = _darkenColor(plankColor, 0.15);
        alpha = 0.018 + rTex.nextDouble() * 0.03;
      } else {
        color = Colors.white;
        alpha = 0.01 + rTex.nextDouble() * 0.02;
      }
      texturePaint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), rad, texturePaint);
    }

    // ── 6. Small scratches (wear and tear) ────────────────────────────────
    final scratchPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;
    final rScratch = Random(seed + 55);
    for (int i = 0; i < 10; i++) {
      final x = rScratch.nextDouble() * w;
      final y = rScratch.nextDouble() * h;
      final len = 5 + rScratch.nextDouble() * 14;
      final angle = rScratch.nextDouble() * 2 * pi;
      scratchPaint.color = _darkenColor(
        plankColor,
        0.28,
      ).withValues(alpha: 0.05 + rScratch.nextDouble() * 0.07);
      canvas.drawLine(
        Offset(x, y),
        Offset(x + cos(angle) * len, y + sin(angle) * len),
        scratchPaint,
      );
    }

    // ── 7. Bevel highlights (light hitting all top/left edges) ────────────
    final bevelHighlight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = _lightenColor(plankColor, 0.25).withValues(alpha: 0.4);
    final highlightPath = Path();
    // Top edge
    highlightPath.moveTo(cornerRadius, 1.5);
    highlightPath.lineTo(w - cornerRadius, 1.5);
    // Left edge
    highlightPath.moveTo(1.5, cornerRadius);
    highlightPath.lineTo(1.5, h - cornerRadius);
    canvas.drawPath(highlightPath, bevelHighlight);

    // ── 8. Inner shadow (bottom-right for depth) ──────────────────────────
    final innerShadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = _darkenColor(plankColor, 0.28).withValues(alpha: 0.22);
    final shadowPath = Path();
    // Bottom edge
    shadowPath.moveTo(cornerRadius, h - 1.5);
    shadowPath.lineTo(w - cornerRadius, h - 1.5);
    // Right edge
    shadowPath.moveTo(w - 1.5, cornerRadius);
    shadowPath.lineTo(w - 1.5, h - cornerRadius);
    canvas.drawPath(shadowPath, innerShadow);

    // ── 9. Soft top light glow ────────────────────────────────────────────
    final lightGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [Colors.white.withValues(alpha: 0.08), Colors.transparent],
        stops: const [0.0, 0.3],
      ).createShader(r);
    canvas.drawRRect(rrect, lightGlow);

    canvas.restore();

    // ── 10. Drilled holes for rope (left and right) with contact shadows ──
    // Removed to keep card surface completely clean.

    // ── 11. Pinned indicator ──
    // Removed to ensure a clean home decor wood aesthetic with no rivets/nails.

    // ── 12. Favorite indicator (small heart at top-right) ─────────────────
    if (isFavorite) {
      final heartCenter = Offset(w - 16, 10);
      final heartPaint = Paint()
        ..color = const Color(0xFFE57373).withValues(alpha: 0.85);
      _drawHeart(canvas, heartCenter, 4, heartPaint);
    }
  }

  void _drawDrilledHole(Canvas canvas, Offset center, double radius) {
    // Contact shadow (where rope touches wood)
    canvas.drawCircle(
      center,
      radius + 2.5,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Outer ring (board material around hole)
    canvas.drawCircle(
      center,
      radius + 1.5,
      Paint()..color = _darkenColor(plankColor, 0.2).withValues(alpha: 0.3),
    );

    // Hole body (dark)
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF1A1008));

    // Inner shadow gradient
    final innerShadow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        radius: 0.9,
        colors: [
          const Color(0xFF3D2A18).withValues(alpha: 0.6),
          const Color(0xFF0A0604),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, innerShadow);

    // Rim highlight (top edge catches light)
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withValues(alpha: 0.12);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 0.5),
      -pi * 0.8,
      pi * 0.6,
      false,
      rimPaint,
    );
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.3);
    path.cubicTo(
      center.dx - size,
      center.dy - size * 0.5,
      center.dx - size * 0.5,
      center.dy - size,
      center.dx,
      center.dy - size * 0.3,
    );
    path.cubicTo(
      center.dx + size * 0.5,
      center.dy - size,
      center.dx + size,
      center.dy - size * 0.5,
      center.dx,
      center.dy + size * 0.3,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  Color _lightenColor(Color color, double amount) {
    return Color.lerp(color, Colors.white, amount)!;
  }

  Color _darkenColor(Color color, double amount) {
    return Color.lerp(color, Colors.black, amount)!;
  }

  @override
  bool shouldRepaint(covariant WoodenPlankPainter old) =>
      old.plankColor != plankColor ||
      old.textColor != textColor ||
      old.isPinned != isPinned ||
      old.isFavorite != isFavorite ||
      old.seed != seed ||
      old.tiltAngle != tiltAngle;
}
