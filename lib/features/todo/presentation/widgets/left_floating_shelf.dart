import 'dart:math' as math;
import 'package:flutter/material.dart';

class LeftFloatingShelf extends StatefulWidget {
  final bool alignLeft;
  final String woodTexture;
  final String plantType;
  final bool showDecorations;
  final List<Widget>? children;
  final double? shelfWidth;

  const LeftFloatingShelf({
    super.key,
    this.alignLeft = true,
    this.woodTexture = 'Mahogany',
    this.plantType = 'Bonsai',
    this.showDecorations = true,
    this.children,
    this.shelfWidth,
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
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double shelfW = widget.shelfWidth ?? (w * 0.24).clamp(95.0, 135.0);
        final double startX = widget.alignLeft ? 0.0 : w - shelfW;
        final double itemSize = ((shelfW - 18) / 3.0).clamp(24.0, 42.0);

        return SizedBox(
          height: 120,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
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
                        shelfWidth: widget.shelfWidth,
                      ),
                    );
                  },
                ),
              ),
              if (widget.children != null)
                Positioned(
                  top: 55 - itemSize,
                  left: widget.alignLeft ? startX + 6 : startX + 12,
                  width: shelfW - 18,
                  height: itemSize,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: widget.children!,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LeftShelfPainter extends CustomPainter {
  final double progress;
  final bool alignLeft;
  final String woodTexture;
  final String plantType;
  final bool showDecorations;
  final double? shelfWidth;

  _LeftShelfPainter({
    required this.progress,
    required this.alignLeft,
    required this.woodTexture,
    required this.plantType,
    this.showDecorations = true,
    this.shelfWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final shelfY = 55.0;
    // Shelf width is 24% of screen width, minimum 95px, maximum 135px
    final shelfW = shelfWidth ?? (w * 0.24).clamp(95.0, 135.0);

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

    // Ambient LED Backlight / Glow on the wall behind the shelf
    final Paint ledGlowPaint = Paint()
      ..color = const Color(0xFFFFE082).withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Downward soft light beam
    final Path glowPath = Path()
      ..moveTo(startX + 8, shelfY + 6)
      ..lineTo(startX + shelfW - 8, shelfY + 6)
      ..lineTo(startX + shelfW - 14, shelfY + 24)
      ..lineTo(startX + 14, shelfY + 24)
      ..close();
    canvas.drawPath(glowPath, ledGlowPaint);

    // Upward subtle glow
    final Paint ledGlowUpPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRect(Rect.fromLTWH(startX + 8, shelfY - 8, shelfW - 16, 8), ledGlowUpPaint);

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

    // Subtle neon LED strip light directly on the under-edge for a cool 3D hardware look
    final Paint ledStripPaint = Paint()
      ..color = const Color(0xFFFFFDE7).withValues(alpha: 0.95)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(startX + 4, shelfY + 7), Offset(startX + shelfW - 4, shelfY + 7), ledStripPaint);

    if (!showDecorations) return;

    // 2. Fish Tank (increased width and height for a spacious premium feel)
    final tankX = alignLeft ? 8.0 : w - shelfW + 8.0;
    final tankW = 52.0;
    final tankH = 32.0;
    final tankY = shelfY - tankH - 2;

    // Tank shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tankX + 1, tankY + 1, tankW, tankH),
        const Radius.circular(5),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );

    // Tank glass body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tankX, tankY, tankW, tankH),
        const Radius.circular(4),
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
        const Radius.circular(4),
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

    // Gravel at bottom (increased count to span the wider tank width)
    final gravelPaint = Paint()..color = const Color(0xFFD4A574);
    final int gravelCount = (tankW / 4.8).floor();
    for (int i = 0; i < gravelCount; i++) {
      final gx = tankX + 3 + i * 4.8 + math.sin(i * 2.7) * 1.5;
      final gy = tankY + tankH - 3 - (i % 3) * 2.5;
      canvas.drawCircle(Offset(gx, gy), 1.2, gravelPaint);
    }

    // Bubbles (increased count and dynamic spreading)
    for (int i = 0; i < 5; i++) {
      final bPhase = progress * 2 * math.pi + i * 1.8;
      final by = tankY + tankH * 0.75 - (bPhase % (math.pi * 2)) / (math.pi * 2) * tankH * 0.65;
      final bx = tankX + 6 + i * (tankW - 12) / 4 + math.sin(bPhase * 0.7) * 2;
      final bSize = 0.6 + (i % 3) * 0.3;
      canvas.drawCircle(
        Offset(bx, by),
        bSize,
        Paint()..color = Colors.white.withValues(alpha: 0.3),
      );
    }

    // ── Fish 1 (Orange Goldfish) — continuous rotation, no instant flip ──
    final f1Period = progress * 2 * math.pi;
    final f1Cos = math.cos(f1Period);
    final f1Sin = math.sin(f1Period);
    final f1X = tankX + tankW / 2 + f1Sin * (tankW / 2 - 8);

    // Smooth heading: 0 (facing right) → ±π/2 (vertical) → ±π (facing left)
    // Right wall (sin>0): curves up (-π/2), Left wall (sin<0): curves down (+π/2)
    final f1Side = f1Sin >= 0 ? -1.0 : 1.0;
    final f1T = ((f1Cos + 1) / 2).clamp(0.0, 1.0);
    final f1S = f1T * f1T * (3 - 2 * f1T);
    final f1Heading = f1Side * math.pi * (1 - f1S);

    // Gentle upward lunge when turning at walls
    final f1Lunge = f1Sin * f1Sin * (-1.5);
    final f1Y = waterTop + tankH * 0.42 + math.sin(f1Period * 0.7) * 1.2 + f1Lunge;

    canvas.save();
    canvas.translate(f1X, f1Y);
    canvas.rotate(f1Heading);
    // Gentle body wave while swimming
    canvas.rotate(math.sin(f1Period * 3) * 0.08);

    // Tail wags at steady pace
    final tail1Path = Path()
      ..moveTo(-3.5, 0)
      ..lineTo(-6, -2.5 + math.sin(f1Period * 3) * 0.8)
      ..lineTo(-6, 2.5 + math.cos(f1Period * 3) * 0.8)
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

    // ── Fish 2 (Blue Tetra) — 2× speed, continuous rotation ──
    final f2Period = progress * 2 * math.pi * 2 + 1.6;
    final f2Cos = math.cos(f2Period);
    final f2Sin = math.sin(f2Period);
    final f2X = tankX + tankW / 2 + f2Sin * (tankW / 2 - 8);

    final f2Side = f2Sin >= 0 ? -1.0 : 1.0;
    final f2T = ((f2Cos + 1) / 2).clamp(0.0, 1.0);
    final f2S = f2T * f2T * (3 - 2 * f2T);
    final f2Heading = f2Side * math.pi * (1 - f2S);

    final f2Lunge = f2Sin * f2Sin * (-1.0);
    final f2Y = waterTop + tankH * 0.58 + math.cos(f2Period * 0.6) * 1.0 + f2Lunge;

    canvas.save();
    canvas.translate(f2X, f2Y);
    canvas.rotate(f2Heading);
    canvas.rotate(math.sin(f2Period * 3) * 0.06);

    // Tail
    final tail2Path = Path()
      ..moveTo(-2.5, 0)
      ..lineTo(-5, -2 + math.cos(f2Period * 3) * 0.6)
      ..lineTo(-5, 2 + math.sin(f2Period * 3) * 0.6)
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

    // 3. Active Plant Type (replaces previous plants, positioned cleanly with breathing room)
    final double potX = alignLeft ? 74.0 : w - shelfW + 74.0;
    _drawPlantPot(canvas, potX, shelfY, const Color(0xFF4DB6AC), const Color(0xFF00897B));
    _drawMiniPlant(canvas, potX + 5.5, shelfY, plantType, progress);
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
