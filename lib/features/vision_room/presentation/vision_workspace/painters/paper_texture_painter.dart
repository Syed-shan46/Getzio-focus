import 'dart:math';
import 'package:flutter/material.dart';

/// Paints a realistic dusty board surface anchored to a deep warm brown base (#1F150C).
///
/// Layers:
///  - Gradient base in the warm #1F150C / #170F08 family
///  - Large aging tone patches (darker/lighter brown variants)
///  - Overhead top-center lamp light (warm spotlight beam)
///  - Fine multi-tonal dust grain
///  - Horizontal wear scratch lines
///  - Edge vignette
class PaperTexturePainter extends CustomPainter {
  final Color baseColor;
  final Color accentColor;

  const PaperTexturePainter({
    this.baseColor = const Color(0xFF1F150C),
    this.accentColor = const Color(0xFF100A05),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── 1. Gradient base (#1F150C family) ───────────────────────────────────
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1B120A), // slightly darker at top
          const Color(0xFF1F150C), // true base mid
          const Color(0xFF24190F), // warmer center
          const Color(0xFF1B1109), // back cooler bottom
          const Color(0xFF100A05), // dark bottom edge
        ],
        stops: const [0.0, 0.25, 0.55, 0.80, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), basePaint);

    // Subtle horizontal hue cross-band (adds cork/wood richness)
    final crossPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFF140D07).withValues(alpha: 0.35),
          Colors.transparent,
          const Color(0xFF281C10).withValues(alpha: 0.20),
          Colors.transparent,
          const Color(0xFF140D07).withValues(alpha: 0.35),
        ],
        stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), crossPaint);

    // ── 2. Aging tone patches ────────────────────────────────────────────────
    final patchPaint = Paint();
    final rPatch = Random(31);
    final patchColors = [
      const Color(0xFF2A1D12), // light brown highlight
      const Color(0xFF0F0A05), // dark spot
      const Color(0xFF1C120A), // mid-shadow
      const Color(0xFF2E2014), // warm tan
      const Color(0xFF140E08), // deeper shadow
    ];
    for (int i = 0; i < 16; i++) {
      final cx = rPatch.nextDouble() * w;
      final cy = rPatch.nextDouble() * h;
      final r = 60.0 + rPatch.nextDouble() * 220.0;
      final color = patchColors[rPatch.nextInt(patchColors.length)];
      final alpha = 0.08 + rPatch.nextDouble() * 0.16;
      patchPaint.shader = RadialGradient(
        colors: [color.withValues(alpha: alpha), Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
      canvas.drawCircle(Offset(cx, cy), r, patchPaint);
    }

    // ── 3. Overhead top-center light ────────────────────────────────────────
    // Warm lamp beam — from top center downward
    final topWarmPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -1.3),
        radius: 1.4,
        colors: [
          const Color(0xFFF0D8B0).withValues(alpha: 0.24), // warm golden beam
          const Color(0xFFDCA870).withValues(alpha: 0.12),
          const Color(0xFFB88C50).withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.28, 0.52, 0.82],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), topWarmPaint);

    // Bright central hotspot at the very top center
    final hotspotPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.90),
        radius: 0.45,
        colors: [
          Colors.white.withValues(alpha: 0.07),
          Colors.white.withValues(alpha: 0.02),
          Colors.transparent,
        ],
        stops: const [0.0, 0.40, 0.80],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), hotspotPaint);

    // ── 4. Multi-tonal dust grain ────────────────────────────────────────────
    final dustPaint = Paint()..style = PaintingStyle.fill;
    final rDust = Random(42);
    for (int i = 0; i < 2400; i++) {
      final x = rDust.nextDouble() * w;
      final y = rDust.nextDouble() * h;
      final r = 0.25 + rDust.nextDouble() * 1.0;
      final colorChoice = rDust.nextInt(5);
      Color dustColor;
      double alpha;
      switch (colorChoice) {
        case 0: // warm golden dust
          dustColor = const Color(0xFFE5B880);
          alpha = 0.03 + rDust.nextDouble() * 0.075;
          break;
        case 1: // white chalk dust
          dustColor = Colors.white;
          alpha = 0.025 + rDust.nextDouble() * 0.085;
          break;
        case 2: // light brown speck
          dustColor = const Color(0xFFCCA070);
          alpha = 0.020 + rDust.nextDouble() * 0.050;
          break;
        case 3: // dark mote (shadow speck)
          dustColor = Colors.black;
          alpha = 0.07 + rDust.nextDouble() * 0.11;
          break;
        default: // parchment warm dust
          dustColor = const Color(0xFFD4C0A0);
          alpha = 0.02 + rDust.nextDouble() * 0.06;
      }
      dustPaint.color = dustColor.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), r, dustPaint);
    }

    // ── 5. Horizontal wear scratches ─────────────────────────────────────────
    final scratchPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;
    final rScratch = Random(99);
    for (int i = 0; i < 70; i++) {
      final y = rScratch.nextDouble() * h;
      final x0 = rScratch.nextDouble() * w * 0.15;
      final len = 20.0 + rScratch.nextDouble() * w * 0.75;
      final alpha = 0.012 + rScratch.nextDouble() * 0.04;
      scratchPaint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawLine(Offset(x0, y), Offset(x0 + len, y), scratchPaint);
    }

    // ── 6. Edge vignette ─────────────────────────────────────────────────────
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.10,
        colors: [
          Colors.transparent,
          const Color(0xFF0F0A05).withValues(alpha: 0.50),
          const Color(0xFF080502).withValues(alpha: 0.80),
        ],
        stops: const [0.38, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), vignette);
  }

  @override
  bool shouldRepaint(covariant PaperTexturePainter old) =>
      old.baseColor != baseColor || old.accentColor != accentColor;
}
