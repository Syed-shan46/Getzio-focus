import 'dart:math' as math;
import 'package:flutter/material.dart';

class LeftFloatingShelf extends StatefulWidget {
  final bool alignLeft;
  final String woodTexture;
  final String plantType;
  final bool showDecorations;

  const LeftFloatingShelf({
    super.key,
    this.alignLeft = true,
    this.woodTexture = 'Mahogany',
    this.plantType = 'Bonsai',
    this.showDecorations = true,
  });

  @override
  State<LeftFloatingShelf> createState() => _LeftFloatingShelfState();
}

class _LeftFloatingShelfState extends State<LeftFloatingShelf>
    with SingleTickerProviderStateMixin {
  late AnimationController _swayController;

  @override
  void initState() {
    super.initState();
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _swayController,
        builder: (context, child) {
          return CustomPaint(
            painter: _LeftShelfPainter(
              progress: _swayController.value,
              alignLeft: widget.alignLeft,
              woodTexture: widget.woodTexture,
              plantType: widget.plantType,
              showDecorations: widget.showDecorations,
            ),
          );
        },
      ),
    );
  }
}

class _LeftShelfPainter extends CustomPainter {
  final double progress;
  final bool alignLeft;
  final String woodTexture;
  final String plantType;
  final bool showDecorations;

  _LeftShelfPainter({
    required this.progress,
    required this.alignLeft,
    required this.woodTexture,
    required this.plantType,
    this.showDecorations = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final shelfY = 55.0;
    // Shelf width is 24% of screen width, minimum 95px, maximum 135px
    final shelfW = (w * 0.24).clamp(95.0, 135.0);

    // Resolve wood colors based on selected texture
    Color woodTopColor;
    Color woodBottomColor;
    if (woodTexture == 'Oak') {
      woodTopColor = const Color(0xFFD7CCC8);
      woodBottomColor = const Color(0xFFC7B3A3);
    } else if (woodTexture == 'Mahogany') {
      woodTopColor = const Color(0xFF8D6E63);
      woodBottomColor = const Color(0xFF4E342E);
    } else {
      woodTopColor = const Color(0xFF5D4037); // Walnut/Dark Wood
      woodBottomColor = const Color(0xFF2E1912);
    }

    final startX = alignLeft ? 0.0 : w - shelfW;



    // 1. Wood Shelf Base
    final shelfPaint = Paint()
      ..shader = LinearGradient(
        colors: [woodTopColor, woodBottomColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(startX, shelfY, shelfW, 8));

    canvas.drawRect(Rect.fromLTWH(startX, shelfY, shelfW, 7), shelfPaint);
    canvas.drawRect(
      Rect.fromLTWH(startX, shelfY + 7, shelfW, 2),
      Paint()..color = const Color(0xFF1E0E0A).withValues(alpha: 0.8),
    );

    // Subtle shelf top highlight line
    final topHighlightPaint = Paint()
      ..color = const Color(0xFFD7CCC8).withValues(alpha: 0.5)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(startX, shelfY), Offset(startX + shelfW, shelfY), topHighlightPaint);

    if (!showDecorations) return;

    // 2. Fish Tank (shifted left for spacing)
    final tankX = alignLeft ? 8.0 : w - shelfW + 8.0;
    final tankW = 30.0;
    final tankH = 28.0;
    final tankY = shelfY - tankH - 2;

    // Tank shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tankX + 1, tankY + 1, tankW, tankH),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );

    // Tank glass body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tankX, tankY, tankW, tankH),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.08),
    );

    // Tank border
    final tankBorder = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tankX, tankY, tankW, tankH),
        const Radius.circular(3),
      ),
      tankBorder,
    );

    // Water fill
    final waterTop = tankY + tankH * 0.25;
    canvas.drawRect(
      Rect.fromLTWH(tankX, waterTop, tankW, tankH * 0.75),
      Paint()..color = Colors.blue.withValues(alpha: 0.12),
    );

    // Water surface line
    canvas.drawLine(
      Offset(tankX + 2, waterTop),
      Offset(tankX + tankW - 2, waterTop),
      Paint()
        ..color = Colors.cyan.withValues(alpha: 0.25)
        ..strokeWidth = 0.5,
    );

    // Gravel at bottom
    final gravelPaint = Paint()..color = const Color(0xFFD4A574);
    for (int i = 0; i < 6; i++) {
      final gx = tankX + 3 + i * 4.5 + math.sin(i * 2.7) * 2;
      final gy = tankY + tankH - 3 - (i % 3) * 2.5;
      canvas.drawCircle(Offset(gx, gy), 1.2, gravelPaint);
    }

    // Bubbles
    for (int i = 0; i < 3; i++) {
      final bPhase = progress * 2 * math.pi + i * 2.1;
      final by = tankY + tankH * 0.7 - (bPhase % (math.pi * 2)) / (math.pi * 2) * tankH * 0.5;
      final bx = tankX + 6 + i * 8 + math.sin(bPhase * 0.7) * 2;
      final bSize = 0.8 + i * 0.3;
      canvas.drawCircle(
        Offset(bx, by),
        bSize,
        Paint()..color = Colors.white.withValues(alpha: 0.3),
      );
    }

    // ── Fish 1 (Orange Goldfish) — smooth ellipse, loops perfectly ──
    final f1Angle = progress * 2 * math.pi;
    final f1Cx = tankX + tankW / 2;
    final f1Cy = waterTop + tankH * 0.42;
    final f1Rx = tankW / 2 - 8;
    final f1Ry = tankH * 0.12;
    final f1X = f1Cx + math.sin(f1Angle) * f1Rx;
    final f1Y = f1Cy + math.cos(f1Angle) * f1Ry;
    final f1AngleX = f1Angle;
    final f1Dir = math.cos(f1AngleX) < 0;

    canvas.save();
    canvas.translate(f1X, f1Y);
    if (f1Dir) canvas.scale(-1, 1);
    canvas.rotate(math.sin(f1Angle * 4) * 0.18);

    // Tail (wags with same-angle sine/cos so it stays coherent)
    final tail1Path = Path()
      ..moveTo(-3.5, 0)
      ..lineTo(-6, -2.5 + math.sin(f1Angle * 3) * 0.8)
      ..lineTo(-6, 2.5 + math.cos(f1Angle * 3) * 0.8)
      ..close();
    canvas.drawPath(tail1Path, Paint()..color = const Color(0xFFFF6B00));

    // Dorsal fin
    final dorsal1Path = Path()
      ..moveTo(-0.5, -1.5)
      ..lineTo(0.5, -3)
      ..lineTo(1.5, -1.5)
      ..close();
    canvas.drawPath(dorsal1Path, Paint()..color = const Color(0xFFFF8C00).withValues(alpha: 0.7));

    // Body
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, 0), width: 5.5, height: 2.5),
      Paint()..color = const Color(0xFFFF8C00),
    );

    // Eye
    canvas.drawCircle(Offset(2.0, -0.5), 0.7, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(2.2, -0.5), 0.35, Paint()..color = Colors.black);
    canvas.restore();

    // ── Fish 2 (Blue Tetra) — 2× speed, loops perfectly ──
    final f2Angle = progress * 2 * math.pi * 2 + 1.6;
    final f2Cx = tankX + tankW / 2;
    final f2Cy = waterTop + tankH * 0.58;
    final f2Rx = tankW / 2 - 8;
    final f2Ry = tankH * 0.09;
    final f2X = f2Cx + math.sin(f2Angle) * f2Rx;
    final f2Y = f2Cy + math.cos(f2Angle) * f2Ry;
    final f2Dir = math.cos(f2Angle) < 0;

    canvas.save();
    canvas.translate(f2X, f2Y);
    if (f2Dir) canvas.scale(-1, 1);
    canvas.rotate(math.sin(f2Angle * 3) * 0.12);

    // Tail
    final tail2Path = Path()
      ..moveTo(-2.5, 0)
      ..lineTo(-5, -2 + math.cos(f2Angle * 3) * 0.6)
      ..lineTo(-5, 2 + math.sin(f2Angle * 3) * 0.6)
      ..close();
    canvas.drawPath(tail2Path, Paint()..color = const Color(0xFF00BCD4));

    // Dorsal fin
    final dorsal2Path = Path()
      ..moveTo(-0.3, -1)
      ..lineTo(0.3, -2.2)
      ..lineTo(1, -1)
      ..close();
    canvas.drawPath(dorsal2Path, Paint()..color = const Color(0xFF26C6DA).withValues(alpha: 0.7));

    // Body
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, 0), width: 4, height: 2),
      Paint()..color = const Color(0xFF26C6DA),
    );

    // Eye
    canvas.drawCircle(Offset(1.5, -0.4), 0.5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(1.7, -0.4), 0.3, Paint()..color = Colors.black);
    canvas.restore();

    // 3. Indoor Plant Pot 1 (Terracotta)
    final double pot1X = alignLeft ? 46.0 : w - shelfW + 46.0;
    _drawPlantPot(canvas, pot1X, shelfY, const Color(0xFFFFCC80), const Color(0xFFFFA726));

    // 4. Trailing Ivy Vines — Plant 1
    _drawVines(canvas, pot1X + 5.0, shelfY, progress, 0, 1.8, 1.5, 2.2);

    // 5. Active Plant Type (replaces second vine plant)
    final double pot2X = alignLeft ? 65.0 : w - shelfW + 65.0;
    _drawPlantPot(canvas, pot2X, shelfY, const Color(0xFF4DB6AC), const Color(0xFF00897B));
    _drawMiniPlant(canvas, pot2X + 5.5, shelfY, plantType, progress);
  }

  void _drawMiniPlant(Canvas canvas, double cx, double shelfY, String type, double p) {
    final stemColor = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    final leafColor = Paint()..color = const Color(0xFF4CAF50);
    final darkLeaf = Paint()..color = const Color(0xFF2E7D32);

    canvas.save();
    canvas.translate(cx, shelfY - 10);

    switch (type) {
      case 'Snake Plant':
        for (int i = 0; i < 3; i++) {
          final xOff = -2.0 + i * 2.0;
          final sway = math.sin(p * 2 * math.pi + i * 1.5) * 0.6;
          canvas.drawLine(
            Offset(xOff, 0),
            Offset(xOff + sway, -8 - i * 2),
            stemColor,
          );
          canvas.drawCircle(Offset(xOff + sway, -8 - i * 2), 1.5, leafColor);
          canvas.drawCircle(Offset(xOff + sway + 0.5, -8 - i * 2), 0.8, darkLeaf);
        }
      case 'Monstera':
        canvas.drawLine(Offset(0, 0), Offset(0, -6), stemColor);
        canvas.drawCircle(Offset(0, -7), 3.5, leafColor);
        canvas.drawCircle(Offset(1, -7), 1.0, darkLeaf);
      case 'Peace Lily':
        canvas.drawLine(Offset(0, 0), Offset(1, -7), stemColor);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(1, -9), width: 4, height: 5),
          Paint()..color = const Color(0xFFFFFDE7),
        );
        canvas.drawCircle(Offset(1, -8), 0.6, Paint()..color = const Color(0xFFFFE082));
      default: // Bonsai
        final trunkPath = Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(2, -4, -1, -7)
          ..quadraticBezierTo(-2, -9, 1, -11);
        canvas.drawPath(trunkPath, stemColor);
        canvas.drawCircle(Offset(0, -10), 3.5, leafColor);
        canvas.drawCircle(Offset(-1, -10), 2.0, darkLeaf);
        canvas.drawCircle(Offset(1, -9), 1.5, leafColor);
    }
    canvas.restore();
  }

  void _drawPlantPot(Canvas canvas, double x, double shelfY, Color potColor, Color rimColor) {
    final potPaint = Paint()..color = potColor;
    canvas.drawRect(Rect.fromLTWH(x, shelfY - 10, 11, 10), potPaint);
    canvas.drawRect(
      Rect.fromLTWH(x - 1, shelfY - 10, 13, 2),
      Paint()..color = rimColor,
    );
  }

  void _drawVines(Canvas canvas, double rootX, double shelfY, double p, double phaseOffset,
      double amp1, double amp2, double amp3) {
    final stemPaint = Paint()
      ..color = const Color(0xFF065F46)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final leafPaint = Paint()..color = const Color(0xFF10B981);

    final s1 = math.sin(p * 2 * math.pi + 1.0 + phaseOffset) * amp1;
    final s2 = math.cos(p * 2 * math.pi + 2.0 + phaseOffset) * amp2;
    final s3 = math.sin(p * 2 * math.pi + 3.0 + phaseOffset) * amp3;

    final vinePath = Path()
      ..moveTo(rootX, shelfY - 4)
      ..quadraticBezierTo(rootX + 3 + s1, shelfY + 12, rootX - 2 + s2, shelfY + 24)
      ..quadraticBezierTo(rootX - 5 + s3, shelfY + 34, rootX - 1 + s1, shelfY + 46);

    canvas.drawPath(vinePath, stemPaint);

    canvas.drawCircle(Offset(rootX + 3 + s1, shelfY + 8), 2.8, leafPaint);
    canvas.drawCircle(Offset(rootX - 3 + s2, shelfY + 18), 2.2, leafPaint);
    canvas.drawCircle(Offset(rootX - 1 + s3, shelfY + 30), 3.0, leafPaint);
    canvas.drawCircle(Offset(rootX - 4 + s1, shelfY + 42), 2.0, leafPaint);
  }

  @override
  bool shouldRepaint(covariant _LeftShelfPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.alignLeft != alignLeft ||
        oldDelegate.woodTexture != woodTexture ||
        oldDelegate.plantType != plantType ||
        oldDelegate.showDecorations != showDecorations;
  }
}
