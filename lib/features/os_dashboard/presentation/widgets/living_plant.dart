import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/os_providers.dart';

class LivingPlant extends ConsumerStatefulWidget {
  const LivingPlant({super.key});

  @override
  ConsumerState<LivingPlant> createState() => _LivingPlantState();
}

class _LivingPlantState extends ConsumerState<LivingPlant> with SingleTickerProviderStateMixin {
  late AnimationController _swayController;

  @override
  void initState() {
    super.initState();
    // Soft, slow swaying animation for wind effect (leaves only)
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(osStateProvider);

    // Calculate growth stage based on streak
    int stage = 1;
    if (state.currentStreak >= 90) {
      stage = 4;
    } else if (state.currentStreak >= 30) {
      stage = 3;
    } else if (state.currentStreak >= 7) {
      stage = 2;
    }

    final double completionRatio = state.selectedHabits.isEmpty
        ? 0.5 // Default neutral color if no habits selected
        : (state.completedHabitIdsToday.length / state.selectedHabits.length);

    return AnimatedBuilder(
      animation: _swayController,
      builder: (context, child) {
        // Map easeInOut to sway angle (-0.025 to 0.025 rad)
        final double swayAngle = math.sin(_swayController.value * 2 * math.pi) * 0.025;
        return CustomPaint(
          size: const Size(110, 130),
          painter: PlantPainter(
            plantType: state.plantType,
            growthStage: stage,
            completionRatio: completionRatio,
            sway: swayAngle,
            woodTexture: state.woodTexture,
          ),
        );
      },
    );
  }
}

class PlantPainter extends CustomPainter {
  final String plantType;
  final int growthStage; // 1 = Seedling, 2 = Sprout, 3 = Mature, 4 = Grand
  final double completionRatio; // 0.0 to 1.0
  final double sway;
  final String woodTexture;

  PlantPainter({
    required this.plantType,
    required this.growthStage,
    required this.completionRatio,
    required this.sway,
    required this.woodTexture,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    
    // Pot geometry
    final double potWidth = 36.0;
    final double potHeight = 26.0;
    final Offset potCenter = Offset(w / 2, h - potHeight / 2 - 4);

    // 1. Draw Pot Shadow on floorboards
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(potCenter.dx + 2, h - 3),
        width: potWidth * 1.15,
        height: 5,
      ),
      shadowPaint,
    );

    // Determine Leaf Colors (Fades to grayish olive when completionRatio is low)
    final Color baseLeafColor;
    final Color accentLeafColor;

    if (completionRatio < 0.25) {
      baseLeafColor = Color.lerp(const Color(0xFF6F7464), const Color(0xFF818676), completionRatio * 4)!;
      accentLeafColor = const Color(0xFF505448);
    } else {
      baseLeafColor = Color.lerp(const Color(0xFF4CAF50), AppColors.accentEmerald, (completionRatio - 0.25) / 0.75)!;
      accentLeafColor = Color.lerp(const Color(0xFF2E7D32), const Color(0xFF1B5E20), (completionRatio - 0.25) / 0.75)!;
    }

    final trunkPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..strokeWidth = 3.2 + (growthStage * 0.6)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final baseOrigin = Offset(w / 2, h - potHeight - 4);

    // 2. Draw Plant (inside sway transform)
    canvas.save();
    // Soft sway rotation around the base of the plant (leaves only)
    canvas.translate(baseOrigin.dx, baseOrigin.dy);
    canvas.rotate(sway);
    canvas.translate(-baseOrigin.dx, -baseOrigin.dy);

    switch (plantType) {
      case 'Snake Plant':
        _drawSnakePlant(canvas, baseOrigin, baseLeafColor, accentLeafColor);
        break;
      case 'Monstera':
        _drawMonstera(canvas, baseOrigin, baseLeafColor, accentLeafColor, trunkPaint);
        break;
      case 'Peace Lily':
        _drawPeaceLily(canvas, baseOrigin, baseLeafColor, accentLeafColor, trunkPaint);
        break;
      case 'Bonsai':
      default:
        _drawBonsai(canvas, baseOrigin, baseLeafColor, accentLeafColor, trunkPaint);
        break;
    }

    canvas.restore();

    // 3. Draw Pot (Ceramic pot with glossy glaze)
    // Dark soil inside the pot
    final soilPaint = Paint()..color = const Color(0xFF3E2723);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(potCenter.dx, potCenter.dy - potHeight / 2),
        width: potWidth * 0.95,
        height: 6,
      ),
      soilPaint,
    );

    // Ceramic pot body
    final potPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFECEFF1), // modern white ceramic
          const Color(0xFFCFD8DC),
          const Color(0xFF90A4AE),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCenter(center: potCenter, width: potWidth, height: potHeight));

    final potPath = Path()
      ..moveTo(potCenter.dx - potWidth / 2, potCenter.dy - potHeight / 2)
      ..lineTo(potCenter.dx + potWidth / 2, potCenter.dy - potHeight / 2)
      ..lineTo(potCenter.dx + potWidth * 0.42, potCenter.dy + potHeight / 2)
      ..lineTo(potCenter.dx - potWidth * 0.42, potCenter.dy + potHeight / 2)
      ..close();
    canvas.drawPath(potPath, potPaint);

    // Rim of the pot
    final rimPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFECEFF1)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(potCenter.dx - potWidth * 0.55, potCenter.dy - potHeight / 2 - 2, potWidth * 1.1, 4));
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(potCenter.dx, potCenter.dy - potHeight / 2),
          width: potWidth * 1.08,
          height: 4,
        ),
        const Radius.circular(2),
      ),
      rimPaint,
    );
  }

  // ─── Bonsai Painter ────────────────────────────────────────────────────────
  void _drawBonsai(Canvas canvas, Offset origin, Color leafColor, Color accentColor, Paint trunkPaint) {
    double trunkHeight = 12.0 + (growthStage * 11.0);

    // Curved organic trunk path
    final path = Path()
      ..moveTo(origin.dx, origin.dy)
      ..quadraticBezierTo(
        origin.dx - 18,
        origin.dy - trunkHeight * 0.4,
        origin.dx - 10,
        origin.dy - trunkHeight,
      );
    canvas.drawPath(path, trunkPaint);

    // Branch 1 (Left)
    if (growthStage >= 2) {
      final leftBranch = Path()
        ..moveTo(origin.dx - 14, origin.dy - trunkHeight * 0.35)
        ..quadraticBezierTo(
          origin.dx - 32,
          origin.dy - trunkHeight * 0.42,
          origin.dx - 36,
          origin.dy - trunkHeight * 0.52,
        );
      canvas.drawPath(leftBranch, trunkPaint);
      _drawLeafCluster(canvas, Offset(origin.dx - 36, origin.dy - trunkHeight * 0.52), 15, leafColor, accentColor);
    }

    // Branch 2 (Right)
    if (growthStage >= 3) {
      final rightBranch = Path()
        ..moveTo(origin.dx - 12, origin.dy - trunkHeight * 0.65)
        ..quadraticBezierTo(
          origin.dx + 12,
          origin.dy - trunkHeight * 0.72,
          origin.dx + 22,
          origin.dy - trunkHeight * 0.82,
        );
      canvas.drawPath(rightBranch, trunkPaint);
      _drawLeafCluster(canvas, Offset(origin.dx + 22, origin.dy - trunkHeight * 0.82), 18, leafColor, accentColor);
    }

    // Main canopy at top
    double canopyRadius = 14.0 + (growthStage * 3.5);
    _drawLeafCluster(canvas, Offset(origin.dx - 10, origin.dy - trunkHeight), canopyRadius, leafColor, accentColor);
  }

  void _drawLeafCluster(Canvas canvas, Offset center, double radius, Color color, Color accentColor) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Layer 1: Dark base leaves
    paint.color = accentColor;
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(Offset(center.dx - radius * 0.35, center.dy - radius * 0.1), radius * 0.75, paint);
    canvas.drawCircle(Offset(center.dx + radius * 0.35, center.dy - radius * 0.1), radius * 0.75, paint);

    // Layer 2: Highlight leaves
    paint.color = color;
    canvas.drawCircle(Offset(center.dx, center.dy - radius * 0.2), radius * 0.7, paint);
    canvas.drawCircle(Offset(center.dx - radius * 0.3, center.dy - radius * 0.25), radius * 0.55, paint);
    canvas.drawCircle(Offset(center.dx + radius * 0.3, center.dy - radius * 0.25), radius * 0.55, paint);
  }

  // ─── Snake Plant Painter ───────────────────────────────────────────────────
  void _drawSnakePlant(Canvas canvas, Offset origin, Color leafColor, Color accentColor) {
    final numLeaves = 2 + growthStage;

    for (int i = 0; i < numLeaves; i++) {
      final double fraction = numLeaves <= 1 ? 0.5 : i / (numLeaves - 1);
      final double heightOffset = 22.0 + (growthStage * 16.0) + (math.sin(i * 1.5) * 6.0);
      final double widthFactor = 5.0 + growthStage * 0.8;

      final double angleOffset = (fraction - 0.5) * 40; // spread leaves
      final double angleRad = angleOffset * math.pi / 180;

      final double endX = origin.dx + math.sin(angleRad) * heightOffset;
      final double endY = origin.dy - math.cos(angleRad) * heightOffset;

      final leafPath = Path();
      leafPath.moveTo(origin.dx - 1.5, origin.dy);
      
      final double ctrlX1 = origin.dx + math.sin(angleRad) * (heightOffset * 0.5) - math.cos(angleRad) * widthFactor;
      final double ctrlY1 = origin.dy - math.cos(angleRad) * (heightOffset * 0.5) - math.sin(angleRad) * widthFactor;
      leafPath.quadraticBezierTo(ctrlX1, ctrlY1, endX, endY);

      final double ctrlX2 = origin.dx + math.sin(angleRad) * (heightOffset * 0.5) + math.cos(angleRad) * widthFactor;
      final double ctrlY2 = origin.dy - math.cos(angleRad) * (heightOffset * 0.5) + math.sin(angleRad) * widthFactor;
      leafPath.quadraticBezierTo(ctrlX2, ctrlY2, origin.dx + 1.5, origin.dy);
      leafPath.close();

      // Outer background leaf
      canvas.drawPath(leafPath, Paint()..color = accentColor..style = PaintingStyle.fill);

      // Transparent border trim (previously yellow)
      final borderPaint = Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawPath(leafPath, borderPaint);

      // Organic inner stripe patterns
      final innerPaint = Paint()
        ..color = leafColor.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;
      canvas.drawPath(leafPath, innerPaint);

      // Tiger stripes
      final stripePaint = Paint()
        ..color = accentColor.withValues(alpha: 0.35)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;
      for (double y = origin.dy - 6; y > endY + 4; y -= 6) {
        final double progress = (origin.dy - y) / heightOffset;
        final double currentW = widthFactor * (1.0 - progress);
        canvas.drawLine(Offset(origin.dx + (y - origin.dy) * math.tan(angleRad) - currentW * 0.5, y),
                         Offset(origin.dx + (y - origin.dy) * math.tan(angleRad) + currentW * 0.5, y), stripePaint);
      }
    }
  }

  // ─── Monstera Painter ──────────────────────────────────────────────────────
  void _drawMonstera(Canvas canvas, Offset origin, Color leafColor, Color accentColor, Paint trunkPaint) {
    final numLeaves = 1 + growthStage;

    final stemPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final leafPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < numLeaves; i++) {
      final double progress = i / numLeaves;
      final double angle = -120.0 + (progress * 110.0) + (math.sin(i) * 12.0);
      final double angleRad = angle * math.pi / 180;
      final double length = 18.0 + (growthStage * 14.0);

      final double endX = origin.dx + math.cos(angleRad) * length;
      final double endY = origin.dy + math.sin(angleRad) * length;

      // Draw thin leaf stem
      canvas.drawPath(
        Path()
          ..moveTo(origin.dx, origin.dy)
          ..quadraticBezierTo(
            origin.dx + math.cos(angleRad - 0.15) * length * 0.55,
            origin.dy + math.sin(angleRad - 0.15) * length * 0.55,
            endX,
            endY,
          ),
        stemPaint,
      );

      // Rotate canvas for leaf drawing
      canvas.save();
      canvas.translate(endX, endY);
      canvas.rotate(angleRad + math.pi / 2);

      final double leafW = 12.0 + (growthStage * 3.0);
      final double leafH = 18.0 + (growthStage * 4.0);

      // Heart shaped shield
      final path = Path()
        ..moveTo(0, 0)
        ..cubicTo(-leafW * 0.8, -leafH * 0.35, -leafW, -leafH * 0.85, 0, -leafH)
        ..cubicTo(leafW, -leafH * 0.85, leafW * 0.8, -leafH * 0.35, 0, 0)
        ..close();

      leafPaint.color = accentColor;
      canvas.drawPath(path, leafPaint);

      // Inner color shading
      final highlightPath = Path()
        ..moveTo(0, 0)
        ..cubicTo(-leafW * 0.55, -leafH * 0.35, -leafW * 0.65, -leafH * 0.75, 0, -leafH * 0.96)
        ..cubicTo(leafW * 0.65, -leafH * 0.75, leafW * 0.55, -leafH * 0.35, 0, 0)
        ..close();
      leafPaint.color = leafColor;
      canvas.drawPath(highlightPath, leafPaint);

      // Monstera splits (fenestrations)
      if (growthStage >= 3) {
        final splitPaint = Paint()
          ..color = const Color(0xFF0D1527) // blend shadow with wall gradient
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;
        // Draw 3 fine lines representing slits
        canvas.drawLine(Offset(-leafW * 0.6, -leafH * 0.6), Offset(-leafW * 0.15, -leafH * 0.5), splitPaint);
        canvas.drawLine(Offset(leafW * 0.6, -leafH * 0.58), Offset(leafW * 0.15, -leafH * 0.48), splitPaint);
        canvas.drawLine(Offset(-leafW * 0.5, -leafH * 0.75), Offset(-leafW * 0.1, -leafH * 0.65), splitPaint);
      }

      canvas.restore();
    }
  }

  // ─── Peace Lily Painter ────────────────────────────────────────────────────
  void _drawPeaceLily(Canvas canvas, Offset origin, Color leafColor, Color accentColor, Paint trunkPaint) {
    final numLeaves = 2 + growthStage;

    final stemPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.7)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < numLeaves; i++) {
      final double fraction = i / (numLeaves - 1);
      final double angle = -135.0 + (fraction * 90.0);
      final double angleRad = angle * math.pi / 180;
      final double length = 18.0 + (growthStage * 11.0);

      final double endX = origin.dx + math.cos(angleRad) * length;
      final double endY = origin.dy + math.sin(angleRad) * length;

      canvas.drawPath(
        Path()
          ..moveTo(origin.dx, origin.dy)
          ..quadraticBezierTo(origin.dx, origin.dy - length * 0.35, endX, endY),
        stemPaint,
      );

      canvas.save();
      canvas.translate(endX, endY);
      canvas.rotate(angleRad + math.pi / 2);

      final double leafW = 6.0 + growthStage * 0.8;
      final double leafH = 16.0 + (growthStage * 3.5);

      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-leafW, -leafH * 0.4, 0, -leafH)
        ..quadraticBezierTo(leafW, -leafH * 0.4, 0, 0)
        ..close();

      canvas.drawPath(path, Paint()..color = accentColor..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = leafColor.withValues(alpha: 0.75)..style = PaintingStyle.fill);

      // leaf center vein line
      canvas.drawLine(Offset(0, 0), Offset(0, -leafH * 0.95), Paint()..color = accentColor..strokeWidth = 0.6);

      canvas.restore();
    }

    // White Peace Lily Flower (stage >= 2)
    if (growthStage >= 2) {
      final flowerX = origin.dx + 6;
      final flowerY = origin.dy - 32.0 - (growthStage * 5);

      // Stiff flower stem
      canvas.drawPath(
        Path()
          ..moveTo(origin.dx, origin.dy)
          ..quadraticBezierTo(origin.dx + 3, origin.dy - 18, flowerX, flowerY),
        Paint()
          ..color = const Color(0xFF81C784)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke,
      );

      // Spathe (pointed oval white petal shell)
      canvas.save();
      canvas.translate(flowerX, flowerY);
      canvas.rotate(-0.08);

      final petalPath = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-7, -10, 0, -20)
        ..quadraticBezierTo(7, -10, 0, 0)
        ..close();

      canvas.drawPath(
        petalPath,
        Paint()
          ..color = Colors.white.withValues(alpha: completionRatio > 0.45 ? 0.95 : 0.35)
          ..style = PaintingStyle.fill,
      );

      // Spadix (textured yellow central core)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-1.2, -12, 2.4, 8),
          const Radius.circular(1.2),
        ),
        Paint()
          ..color = Colors.yellowAccent.withValues(alpha: completionRatio > 0.45 ? 0.9 : 0.3)
          ..style = PaintingStyle.fill,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
