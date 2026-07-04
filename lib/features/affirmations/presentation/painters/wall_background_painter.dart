import 'dart:math';
import 'package:flutter/material.dart';

/// Paints a premium warm beige wall with soft gradient, tiny wall texture,
/// floating dust, golden sunlight, and a subtle vignette.
///
/// Everything is drawn procedurally — no image assets.
class WallBackgroundPainter extends CustomPainter {
  final double ambientProgress;
  final double sunlightProgress;
  final List<DustMote> dustMotes;
  final int? seed;

  const WallBackgroundPainter({
    required this.ambientProgress,
    required this.sunlightProgress,
    required this.dustMotes,
    this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── 1. Warm beige gradient base ──────────────────────────────────────
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFF5E6D3), // warm beige top
          const Color(0xFFEDE0CC), // soft cream mid
          const Color(0xFFE4D5BE), // dusty beige lower
          const Color(0xFFD9C7AC), // deeper warm bottom
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), basePaint);

    // ── 2. Golden sunlight from top-right ────────────────────────────────
    final sunCenter = Offset(w * 0.75, h * 0.15);
    final sunRadius = w * 0.6 + sunlightProgress * 30;
    final sunPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(0.5, -0.6),
        radius: 1.2,
        colors: [
          const Color(
            0xFFFFE4B5,
          ).withValues(alpha: 0.35 + sunlightProgress * 0.08),
          const Color(0xFFFFD89B).withValues(alpha: 0.18),
          const Color(0xFFF5C77E).withValues(alpha: 0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), sunPaint);

    // Bright hotspot
    final hotspotPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(0.5, -0.7),
        radius: 0.35,
        colors: [
          Colors.white.withValues(alpha: 0.12 + sunlightProgress * 0.04),
          Colors.white.withValues(alpha: 0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.8],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), hotspotPaint);

    // ── 3. Tiny wall texture (fine grain) ────────────────────────────────
    final texturePaint = Paint()..style = PaintingStyle.fill;
    final rTexture = Random(seed ?? 77);
    for (int i = 0; i < 1800; i++) {
      final x = rTexture.nextDouble() * w;
      final y = rTexture.nextDouble() * h;
      final r = 0.3 + rTexture.nextDouble() * 0.8;
      final choice = rTexture.nextInt(4);
      Color color;
      double alpha;
      switch (choice) {
        case 0:
          color = const Color(0xFFC4A87E);
          alpha = 0.02 + rTexture.nextDouble() * 0.04;
          break;
        case 1:
          color = const Color(0xFFB89868);
          alpha = 0.015 + rTexture.nextDouble() * 0.035;
          break;
        case 2:
          color = Colors.white;
          alpha = 0.02 + rTexture.nextDouble() * 0.05;
          break;
        default:
          color = const Color(0xFF8B7355);
          alpha = 0.015 + rTexture.nextDouble() * 0.03;
      }
      texturePaint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), r, texturePaint);
    }

    // ── 4. Subtle wall plaster patches ───────────────────────────────────
    final patchPaint = Paint();
    final rPatch = Random(seed != null ? seed! + 13 : 90);
    for (int i = 0; i < 10; i++) {
      final cx = rPatch.nextDouble() * w;
      final cy = rPatch.nextDouble() * h;
      final r = 80.0 + rPatch.nextDouble() * 200.0;
      final isLight = rPatch.nextBool();
      final color = isLight
          ? const Color(0xFFF8EAD6).withValues(alpha: 0.08)
          : const Color(0xFFC9B89A).withValues(alpha: 0.06);
      patchPaint.shader = RadialGradient(
        colors: [color, Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
      canvas.drawCircle(Offset(cx, cy), r, patchPaint);
    }

    // ── 5. Floating dust motes ───────────────────────────────────────────
    for (var d in dustMotes) {
      final dx = d.x * w + sin(ambientProgress * 2 * pi * d.swaySpeed) * 12;
      final dy = (d.y - ambientProgress * d.speed * 0.3) % 1.0 * h;
      final opacity =
          0.06 + sin(ambientProgress * 2 * pi * d.swaySpeed * 0.5) * 0.04;
      canvas.drawCircle(
        Offset(dx, dy),
        d.size,
        Paint()
          ..color = const Color(0xFFFFE4B5).withValues(alpha: opacity.abs())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }

    // ── 6. Subtle vignette ───────────────────────────────────────────────
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.15,
        colors: [
          Colors.transparent,
          const Color(0xFF8B7355).withValues(alpha: 0.12),
          const Color(0xFF6B5340).withValues(alpha: 0.22),
        ],
        stops: const [0.45, 0.80, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), vignette);
  }

  @override
  bool shouldRepaint(covariant WallBackgroundPainter old) =>
      old.ambientProgress != ambientProgress ||
      old.sunlightProgress != sunlightProgress ||
      old.seed != seed;
}

/// A floating dust mote for the wall background.
class DustMote {
  double x;
  double y;
  final double speed;
  final double size;
  final double swaySpeed;

  DustMote({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.swaySpeed,
  });
}
