import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/vision_customization.dart';
import '../../domain/models/vision_item.dart';
import '../providers/canvas_providers.dart';
import '../providers/sticky_note_provider.dart';
import '../providers/vision_room_providers.dart';
import 'quote_card_widget.dart';
import 'goal_card_widget.dart';
import 'premium_cards.dart';
import 'sticky_note_bottom_sheet.dart';
import 'smart_object_sheets.dart';

class RoomScene extends StatelessWidget {
  final VisionCustomization customization;
  final Widget child;
  final List<VisionItem> items;
  final double pageOffset;

  const RoomScene({
    super.key,
    required this.customization,
    required this.child,
    this.items = const [],
    this.pageOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseOffset = -pageOffset * screenWidth;

    Widget parallaxLayer(Widget child, double factor) {
      return Transform.translate(
        offset: Offset(baseOffset * factor, 0),
        child: child,
      );
    }

    final wallGradient = _getWallGradient(customization.background);

    return Stack(
      children: [
        // 1. Living room background: wall gradient, skirting board & perspective wooden floorboards
        Positioned.fill(
          child: RepaintBoundary(
            child: parallaxLayer(
              CustomPaint(
                painter: RoomBackgroundPainter(
                  wallGradient: wallGradient,
                  floorHeight: 0,
                ),
                size: Size.infinite,
              ),
              0.03,
            ),
          ),
        ),

        // 6. The actual wall content (VisionBoard, items, etc.)
        Positioned.fill(child: child),
      ],
    );
  }

  LinearGradient _getWallGradient(VisionBackground bg) {
    return switch (bg) {
      VisionBackground.scandinavianWall => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF24190F), Color(0xFF1F150C), Color(0xFF150E08)],
      ),
      VisionBackground.oceanView => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F4C75), Color(0xFF1A7BA0), Color(0xFF0B2E4A)],
      ),
      VisionBackground.forestCabin => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF0D2818)],
      ),
      VisionBackground.sunsetStudio => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3B151E), Color(0xFF2A0E14), Color(0xFF160609)],
      ),
      VisionBackground.rainWindow => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF374151), Color(0xFF4A5568), Color(0xFF2D3748)],
      ),
      VisionBackground.modernLoft => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF5F5F2), Color(0xFFEBEBE6), Color(0xFFDDDCD6)],
      ),
      VisionBackground.matteBlack => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF24190F), Color(0xFF1F150C), Color(0xFF150E08)],
      ),
      _ => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF24190F), Color(0xFF1F150C), Color(0xFF150E08)],
      ),
    };
  }
}

/// Realistic round candle in a small transparent glass jar with a dancing flickering flame and warm light aura
class _RealisticCandle extends StatefulWidget {
  const _RealisticCandle();

  @override
  State<_RealisticCandle> createState() => _RealisticCandleState();
}

class _RealisticCandleState extends State<_RealisticCandle>
    with SingleTickerProviderStateMixin {
  late AnimationController _flickerController;

  @override
  void initState() {
    super.initState();
    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flickerController,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(44, 44),
          painter: _CandlePainter(progress: _flickerController.value),
        );
      },
    );
  }
}

class _CandlePainter extends CustomPainter {
  final double progress;

  _CandlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final bottomY = h - 1.0;

    // Flicker calculations for natural flame dancing & soft lighting
    final flickerSeed = math.sin(progress * math.pi * 4);
    final flameScale = 0.85 + 0.15 * ((flickerSeed + 1) / 2);
    final flameSway = math.cos(progress * math.pi * 3) * 0.6;
    final auraAlpha = 0.12 + 0.05 * math.sin(progress * math.pi * 2);

    // 1. Soft Warm Ambient Light Aura on Wall (subtle, localized light)
    final auraRadius = 20.0 * flameScale;
    final auraCenter = Offset(cx + flameSway, bottomY - 26);
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFB74D).withValues(alpha: auraAlpha),
          const Color(0xFFFF9800).withValues(alpha: auraAlpha * 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: auraCenter, radius: auraRadius));
    canvas.drawCircle(auraCenter, auraRadius, auraPaint);

    // 2. Compact 3D Glass Jar Base & Dimensions
    final jarW = 18.0;
    final jarH = 22.0;
    final jarRect = Rect.fromLTWH(cx - jarW / 2, bottomY - jarH, jarW, jarH);

    // 3. Thick Glass Base (solid 3D heavy glass bottom, clear & clean without black dots)
    final baseH = 3.5;
    final baseRect = Rect.fromLTWH(
      jarRect.left,
      jarRect.bottom - baseH,
      jarW,
      baseH,
    );
    final glassBasePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.25),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(baseRect);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        baseRect,
        bottomLeft: const Radius.circular(5),
        bottomRight: const Radius.circular(5),
      ),
      glassBasePaint,
    );

    // 4. 3D Cylindrical Wax Column inside Jar
    final waxH = (jarH - baseH) * 0.65;
    final waxTopY = jarRect.bottom - baseH - waxH;
    final waxRect = Rect.fromLTWH(jarRect.left + 1.5, waxTopY, jarW - 3, waxH);

    // Cylindrical 3D Shading Gradient
    final wax3DPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFFFFFEE0),
          const Color(0xFFFFFDD0),
          const Color(0xFFE8D9B5),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(waxRect);

    final waxPath = Path()
      ..moveTo(waxRect.left, waxRect.top)
      ..lineTo(waxRect.right, waxRect.top)
      ..lineTo(waxRect.right, waxRect.bottom)
      ..arcToPoint(
        Offset(waxRect.left, waxRect.bottom),
        radius: Radius.circular(waxRect.width / 2),
        clockwise: false,
      )
      ..close();
    canvas.drawPath(waxPath, wax3DPaint);

    // 3D Elliptical Wax Top Surface Pool with molten glow
    final waxTopRect = Rect.fromCenter(
      center: Offset(cx, waxTopY),
      width: waxRect.width,
      height: 4.0,
    );
    canvas.drawOval(waxTopRect, Paint()..color = const Color(0xFFF7ECDA));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, waxTopY), width: 7, height: 2.2),
      Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.65),
    );

    // 5. Outer 3D Glass Jar Body & Cylindrical Highlights
    final jarRRect = RRect.fromRectAndRadius(jarRect, const Radius.circular(5));

    final glassSheenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.05),
          Colors.white.withValues(alpha: 0.20),
        ],
        stops: const [0.05, 0.5, 0.95],
      ).createShader(jarRect);
    canvas.drawRRect(jarRRect, glassSheenPaint);

    // Glass Jar Rim / Top Lip Opening
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, jarRect.top), width: jarW, height: 4),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Specular Sheen Streak on left edge
    final specularPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(jarRect.left + 2, jarRect.top + 2),
      Offset(jarRect.left + 2, jarRect.bottom - 3),
      specularPaint,
    );

    // 6. Candle Wick with ember glow
    final wickTop = waxTopY - 4.0;
    canvas.drawLine(
      Offset(cx, waxTopY),
      Offset(cx + flameSway * 0.3, wickTop),
      Paint()
        ..color = const Color(0xFF111111)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(cx + flameSway * 0.3, wickTop + 0.4),
      0.6,
      Paint()..color = const Color(0xFFFF5722),
    );

    // 7. Dynamic 3D Flickering Flame
    canvas.save();
    canvas.translate(cx + flameSway, wickTop - 0.5);
    canvas.scale(flameScale);

    final flamePath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-3.5, -4.5, 0, -10)
      ..quadraticBezierTo(3.5, -4.5, 0, 0);

    canvas.drawPath(
      flamePath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFFFF5722), Color(0xFFFFB74D), Color(0xFFFFD54F)],
        ).createShader(Rect.fromLTWH(-3.5, -10, 7, 10)),
    );

    final innerFlamePath = Path()
      ..moveTo(0, -0.4)
      ..quadraticBezierTo(-1.8, -3, 0, -6.5)
      ..quadraticBezierTo(1.8, -3, 0, -0.4);

    canvas.drawPath(
      innerFlamePath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFFFFF59D), Colors.white],
        ).createShader(Rect.fromLTWH(-1.8, -6.5, 3.6, 6.5)),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CandlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// The exact living workspace fish tank with swimming Orange Goldfish and Blue Tetra
class _WorkspaceFishTank extends StatefulWidget {
  const _WorkspaceFishTank();

  @override
  State<_WorkspaceFishTank> createState() => _WorkspaceFishTankState();
}

class _WorkspaceFishTankState extends State<_WorkspaceFishTank>
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
    return AnimatedBuilder(
      animation: _swayController,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(78, 48),
          painter: _WorkspaceFishTankPainter(progress: _swayController.value),
        );
      },
    );
  }
}

class _WorkspaceFishTankPainter extends CustomPainter {
  final double progress;

  _WorkspaceFishTankPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final tankX = 0.0;
    final tankY = 0.0;
    final tankW = w;
    final tankH = h;

    // Tank glass body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tankX, tankY, tankW, tankH),
        const Radius.circular(6),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );

    // Tank border
    final tankBorder = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tankX, tankY, tankW, tankH),
        const Radius.circular(6),
      ),
      tankBorder,
    );

    // Water fill
    final waterTop = tankY + tankH * 0.22;
    canvas.drawRect(
      Rect.fromLTWH(tankX, waterTop, tankW, tankH * 0.78),
      Paint()..color = Colors.blue.withValues(alpha: 0.15),
    );

    // Water surface line
    canvas.drawLine(
      Offset(tankX + 2, waterTop),
      Offset(tankX + tankW - 2, waterTop),
      Paint()
        ..color = Colors.cyan.withValues(alpha: 0.35)
        ..strokeWidth = 0.8,
    );

    // Gravel at bottom
    final gravelPaint = Paint()..color = const Color(0xFFD4A574);
    final int gravelCount = (tankW / 4.8).floor();
    for (int i = 0; i < gravelCount; i++) {
      final gx = tankX + 3 + i * 4.8 + math.sin(i * 2.7) * 1.5;
      final gy = tankY + tankH - 3 - (i % 3) * 2.5;
      canvas.drawCircle(Offset(gx, gy), 1.4, gravelPaint);
    }

    // Bubbles
    for (int i = 0; i < 5; i++) {
      final bPhase = progress * 2 * math.pi + i * 1.8;
      final by =
          tankY +
          tankH * 0.75 -
          (bPhase % (math.pi * 2)) / (math.pi * 2) * tankH * 0.65;
      final bx = tankX + 6 + i * (tankW - 12) / 4 + math.sin(bPhase * 0.7) * 2;
      final bSize = 0.7 + (i % 3) * 0.4;
      canvas.drawCircle(
        Offset(bx, by),
        bSize,
        Paint()..color = Colors.white.withValues(alpha: 0.35),
      );
    }

    // ── Fish 1 (Orange Goldfish) ──
    final f1Period = progress * 2 * math.pi;
    final f1Cos = math.cos(f1Period);
    final f1Sin = math.sin(f1Period);
    final f1X = tankX + tankW / 2 + f1Sin * (tankW / 2 - 10);

    final f1Side = f1Sin >= 0 ? -1.0 : 1.0;
    final f1T = ((f1Cos + 1) / 2).clamp(0.0, 1.0);
    final f1S = f1T * f1T * (3 - 2 * f1T);
    final f1Heading = f1Side * math.pi * (1 - f1S);

    final f1Lunge = f1Sin * f1Sin * (-1.5);
    final f1Y =
        waterTop + tankH * 0.40 + math.sin(f1Period * 0.7) * 1.5 + f1Lunge;

    canvas.save();
    canvas.translate(f1X, f1Y);
    canvas.rotate(f1Heading);
    canvas.rotate(math.sin(f1Period * 3) * 0.08);

    final tail1Path = Path()
      ..moveTo(-4.5, 0)
      ..lineTo(-8, -3.5 + math.sin(f1Period * 3) * 1.0)
      ..lineTo(-8, 3.5 + math.cos(f1Period * 3) * 1.0)
      ..close();
    canvas.drawPath(tail1Path, Paint()..color = const Color(0xFFFF6B00));

    final dorsal1Path = Path()
      ..moveTo(-1.0, -2.0)
      ..lineTo(0.8, -4.0)
      ..lineTo(2.0, -2.0)
      ..close();
    canvas.drawPath(
      dorsal1Path,
      Paint()..color = const Color(0xFFFF8C00).withValues(alpha: 0.7),
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 0), width: 7.5, height: 3.5),
      Paint()..color = const Color(0xFFFF8C00),
    );

    canvas.drawCircle(
      const Offset(2.8, -0.7),
      0.9,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      const Offset(3.0, -0.7),
      0.45,
      Paint()..color = Colors.black,
    );
    canvas.restore();

    // ── Fish 2 (Blue Tetra) ──
    final f2Period = progress * 2 * math.pi * 2 + 1.6;
    final f2Cos = math.cos(f2Period);
    final f2Sin = math.sin(f2Period);
    final f2X = tankX + tankW / 2 + f2Sin * (tankW / 2 - 10);

    final f2Side = f2Sin >= 0 ? -1.0 : 1.0;
    final f2T = ((f2Cos + 1) / 2).clamp(0.0, 1.0);
    final f2S = f2T * f2T * (3 - 2 * f2T);
    final f2Heading = f2Side * math.pi * (1 - f2S);

    final f2Lunge = f2Sin * f2Sin * (-1.0);
    final f2Y =
        waterTop + tankH * 0.60 + math.cos(f2Period * 0.6) * 1.2 + f2Lunge;

    canvas.save();
    canvas.translate(f2X, f2Y);
    canvas.rotate(f2Heading);
    canvas.rotate(math.sin(f2Period * 3) * 0.06);

    final tail2Path = Path()
      ..moveTo(-3.5, 0)
      ..lineTo(-6.5, -2.8 + math.cos(f2Period * 3) * 0.8)
      ..lineTo(-6.5, 2.8 + math.sin(f2Period * 3) * 0.8)
      ..close();
    canvas.drawPath(tail2Path, Paint()..color = const Color(0xFF00BCD4));

    final dorsal2Path = Path()
      ..moveTo(-0.5, -1.5)
      ..lineTo(0.5, -3.0)
      ..lineTo(1.5, -1.5)
      ..close();
    canvas.drawPath(
      dorsal2Path,
      Paint()..color = const Color(0xFF26C6DA).withValues(alpha: 0.7),
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 0), width: 6.0, height: 2.8),
      Paint()..color = const Color(0xFF00ACC1),
    );

    canvas.drawCircle(
      const Offset(2.2, -0.5),
      0.7,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      const Offset(2.4, -0.5),
      0.35,
      Paint()..color = Colors.black,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WorkspaceFishTankPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Full-width wooden shelf stretching across the wall above floorboards
class _FullWidthFloatingShelf extends StatelessWidget {
  const _FullWidthFloatingShelf();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Backing Drop Shadow on wall across full width
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            height: 20,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),

          // 2. Multiple Wall Brackets across the full width shelf
          ...[0.18, 0.50, 0.82].map(
            (factor) => Positioned(
              left: MediaQuery.of(context).size.width * factor - 3.5,
              top: 12,
              child: Container(
                width: 7,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Main Wooden Plank Body stretching full width
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 14,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6A4423),
                    Color(0xFF4A2F18),
                    Color(0xFF321F0F),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Top bevel highlight streak across full width
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 1.5,
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The exact room background painter used in the living room workspace:
/// renders wall stucco/shadow texturing, skirting board, and wooden floorboards in perspective.
class RoomBackgroundPainter extends CustomPainter {
  final LinearGradient wallGradient;
  final double floorHeight;

  RoomBackgroundPainter({
    required this.wallGradient,
    required this.floorHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double wallH = h - floorHeight;

    final Rect wallRect = Rect.fromLTRB(0, 0, w, wallH);

    // 1. Wall Background Gradient
    final Paint wallPaint = Paint()
      ..shader = wallGradient.createShader(wallRect);
    canvas.drawRect(wallRect, wallPaint);

    // 2. Large aging tone patches (board unevenness / worn surface)
    final patchPaint = Paint();
    final rPatch = math.Random(17);
    final patchColors = [
      const Color(0xFF4A2E2E), // rose highlight
      const Color(0xFF221010), // very dark
      const Color(0xFF3C2020), // mid shadow
      const Color(0xFF3E1818), // warm rust
      const Color(0xFF2A1414), // deeper shadow
    ];
    for (int i = 0; i < 10; i++) {
      final cx = rPatch.nextDouble() * w;
      final cy = rPatch.nextDouble() * wallH;
      final r = 70.0 + rPatch.nextDouble() * 180.0;
      final color = patchColors[rPatch.nextInt(patchColors.length)];
      final alpha = 0.06 + rPatch.nextDouble() * 0.14;
      patchPaint.shader = RadialGradient(
        colors: [color.withValues(alpha: alpha), Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
      canvas.drawCircle(Offset(cx, cy), r, patchPaint);
    }

    // 3. Overhead top-center lamp light (warm amber beam)
    final topLightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -1.25),
        radius: 1.40,
        colors: [
          const Color(0xFFE8C090).withValues(alpha: 0.22),
          const Color(0xFFD4A060).withValues(alpha: 0.10),
          const Color(0xFFB88040).withValues(alpha: 0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.28, 0.54, 0.82],
      ).createShader(Rect.fromLTWH(0, 0, w, wallH));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, wallH), topLightPaint);

    // Bright central hotspot — the lamp's nearest point
    final hotspotPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.92),
        radius: 0.42,
        colors: [
          Colors.white.withValues(alpha: 0.07),
          Colors.white.withValues(alpha: 0.02),
          Colors.transparent,
        ],
        stops: const [0.0, 0.38, 0.78],
      ).createShader(Rect.fromLTWH(0, 0, w, wallH));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, wallH), hotspotPaint);

    // 4. Multi-tonal dust grain
    final dustPaint = Paint()..style = PaintingStyle.fill;
    final rDust = math.Random(42);
    for (int i = 0; i < 1800; i++) {
      final x = rDust.nextDouble() * w;
      final y = rDust.nextDouble() * wallH;
      final r = 0.2 + rDust.nextDouble() * 0.95;
      final pick = rDust.nextInt(5);
      Color dc;
      double alpha;
      switch (pick) {
        case 0: // warm rust dust
          dc = const Color(0xFFD47060);
          alpha = 0.025 + rDust.nextDouble() * 0.065;
          break;
        case 1: // white chalk dust
          dc = Colors.white;
          alpha = 0.020 + rDust.nextDouble() * 0.075;
          break;
        case 2: // rose-pink dust
          dc = const Color(0xFFE08070);
          alpha = 0.012 + rDust.nextDouble() * 0.040;
          break;
        case 3: // dark mote
          dc = Colors.black;
          alpha = 0.05 + rDust.nextDouble() * 0.09;
          break;
        default: // parchment warm dust
          dc = const Color(0xFFD4A880);
          alpha = 0.015 + rDust.nextDouble() * 0.055;
      }
      dustPaint.color = dc.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), r, dustPaint);
    }

    // 5. Horizontal surface scratch lines (worn board)
    final scratchPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;
    final rScratch = math.Random(99);
    for (int i = 0; i < 60; i++) {
      final y = rScratch.nextDouble() * wallH;
      final x0 = rScratch.nextDouble() * w * 0.15;
      final len = 20.0 + rScratch.nextDouble() * w * 0.72;
      final alpha = 0.010 + rScratch.nextDouble() * 0.038;
      scratchPaint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawLine(Offset(x0, y), Offset(x0 + len, y), scratchPaint);
    }

    // 6. Edge vignette (corners and sides fade to near-black)
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.12,
        colors: [
          Colors.transparent,
          const Color(0xFF180808).withValues(alpha: 0.52),
          const Color(0xFF0D0303).withValues(alpha: 0.80),
        ],
        stops: const [0.38, 0.74, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, wallH));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, wallH), vignette);

    if (floorHeight > 0.0) {
      final Rect floorRect = Rect.fromLTRB(0, wallH, w, h);

      // 7. Baseboard / Skirting Molding (floor depth)
      final double baseboardH = 12.0;
      final Rect baseboardRect = Rect.fromLTRB(0, wallH - baseboardH, w, wallH);
      final baseboardPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(baseboardRect);
      canvas.drawRect(baseboardRect, baseboardPaint);
      canvas.drawLine(
        Offset(0, wallH - baseboardH),
        Offset(w, wallH - baseboardH),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.2)
          ..strokeWidth = 0.8,
      );
      canvas.drawLine(
        Offset(0, wallH),
        Offset(w, wallH),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.3)
          ..strokeWidth = 1.2,
      );

      // 8. Wooden Floorboards in perspective
      final floorGradient = const LinearGradient(
        colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
      canvas.drawRect(
        floorRect,
        Paint()..shader = floorGradient.createShader(floorRect),
      );

      // Horizontal floorboard spacing lines
      final plankPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..strokeWidth = 1.4;
      final int plankCount = 6;
      for (int j = 0; j <= plankCount; j++) {
        final double t = j / plankCount;
        final double y = wallH + floorHeight * math.pow(t, 1.38);
        canvas.drawLine(Offset(0, y), Offset(w, y), plankPaint);
        if (j > 0 && j < plankCount) {
          canvas.drawLine(
            Offset(0, y + 1),
            Offset(w, y + 1),
            Paint()
              ..color = Colors.white.withValues(alpha: 0.03)
              ..strokeWidth = 0.6,
          );
        }
      }

      // Converging vertical joint lines
      final jointPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..strokeWidth = 1.0;
      final Offset vanishingPoint = Offset(w / 2, -h * 0.15);
      for (int k = -3; k <= 7; k++) {
        final double startX = (w / 4.5) * k;
        final Offset startFloor = Offset(startX, wallH);
        final double dirX = startFloor.dx - vanishingPoint.dx;
        final double dirY = startFloor.dy - vanishingPoint.dy;
        final double scale = (h - wallH) / dirY;
        final Offset endFloor = Offset(startFloor.dx + dirX * scale, h);
        canvas.drawLine(startFloor, endFloor, jointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant RoomBackgroundPainter oldDelegate) =>
      oldDelegate.floorHeight != floorHeight ||
      oldDelegate.wallGradient != wallGradient;
}




class _ShelfItemsScrollWidget extends ConsumerWidget {
  const _ShelfItemsScrollWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasItems = ref
        .watch(canvasStateProvider)
        .items
        .where((item) => item.metadata?['isOnShelf'] == true)
        .toList();

    final notesAsItems = ref
        .watch(stickyNotesProvider)
        .where((note) => note.category.contains('#shelf'))
        .map((note) {
          final colorHex = note.color.replaceFirst('#', '0xFF');
          final colorVal = int.tryParse(colorHex) ?? 0xFFF59E0B;
          return VisionItem(
            id: note.id,
            type: VisionItemType.stickyNote.name,
            content: note.title,
            secondaryContent: note.description,
            colorValue: colorVal,
            countdownDate: note.dueDate,
            metadata: {'progress': note.progress.toDouble(), 'isOnShelf': true},
          );
        })
        .toList();

    final combinedItems = [...canvasItems, ...notesAsItems]
      ..sort((a, b) {
        // Primary sort: createdAt timestamp from metadata (ISO-8601 string)
        final aCreated = a.metadata?['createdAt'] as String?;
        final bCreated = b.metadata?['createdAt'] as String?;
        if (aCreated != null && bCreated != null) {
          return aCreated.compareTo(bCreated);
        }
        // Fallback: zIndex (increments on each addItem call, so works as creation order)
        return a.zIndex.compareTo(b.zIndex);
      });

    if (combinedItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: combinedItems.length,
        itemBuilder: (context, index) {
          final item = combinedItems[index];
          return Padding(
            padding: const EdgeInsets.only(right: 18),
            child: _buildShelfItem(context, ref, item),
          );
        },
      ),
    );
  }

  Widget _buildShelfItem(BuildContext context, WidgetRef ref, VisionItem item) {
    Widget cardChild;
    final isSticky = item.type == VisionItemType.stickyNote.name;

    if (isSticky) {
      final Color paperColor = Color(item.colorValue);
      cardChild = Container(
        width: 160,
        height: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: paperColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.kalam(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black.withValues(alpha: 0.85),
              ),
            ),
            if (item.secondaryContent != null &&
                item.secondaryContent!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  item.secondaryContent!,
                  maxLines: 3,
                  overflow: TextOverflow.fade,
                  style: GoogleFonts.kalam(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    } else if (item.type == VisionItemType.image.name) {
      cardChild = Container(
        width: 320,
        height: 240,
        padding: const EdgeInsets.all(12), // Elegant frame padding
        decoration: BoxDecoration(
          color: const Color(0xFF2B1B10), // Rich dark mahogany wood frame
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFFFD54F).withValues(alpha: 0.35), // Gold inner border trim
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: item.content.startsWith('http')
              ? Image.network(item.content, fit: BoxFit.cover)
              : Image.file(
                  File(item.content),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey),
                ),
        ),
      );
    } else if (item.type == VisionItemType.quote.name) {
      cardChild = QuoteCardWidget(item: item);
    } else if (item.type == VisionItemType.goal.name) {
      cardChild = GoalCardWidget(item: item);
    } else if (item.type == VisionItemType.plan.name) {
      cardChild = PlanCardWidget(item: item);
    } else if (item.type == VisionItemType.task.name) {
      cardChild = TaskCardWidget(item: item);
    } else if (item.type == VisionItemType.financeGoal.name) {
      cardChild = FinanceCardWidget(item: item);
    } else if (item.type == VisionItemType.countdown.name) {
      cardChild = CountdownCardWidget(item: item);
    } else {
      cardChild = Container(
        color: Color(item.colorValue),
        child: Center(child: Text(item.content)),
      );
    }

    final double cardW = isSticky ? 160 : 320;
    final double cardH = isSticky ? 160 : 240;
    final double shelfW = isSticky ? 64 : 85;
    final double shelfH = 64;

    final isEditMode = ref.watch(editModeProvider);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5), // Align items precisely on top of the wooden shelf plank
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (isEditMode) {
                    ref.read(canvasStateProvider.notifier).selectItem(item.id);
                    return;
                  }
                  final originalNotes = ref.read(stickyNotesProvider);
                  final matchIndex = originalNotes.indexWhere((n) => n.id == item.id);
                  if (matchIndex != -1) {
                    StickyNoteBottomSheet.show(
                      context,
                      existingNote: originalNotes[matchIndex],
                    );
                  } else {
                    SmartObjectSheetRouter.open(context, item);
                  }
                },
                child: Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0025)
                    ..rotateX(-0.16)
                    ..rotateY(0.04)
                    ..rotateZ(-0.01),
                  child: Container(
                    decoration: BoxDecoration(
                      border: ref.watch(canvasStateProvider).selectedIds.contains(item.id) 
                          ? Border.all(color: Colors.blueAccent, width: 2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.55),
                          blurRadius: 8,
                          spreadRadius: -2,
                          offset: const Offset(2, 8),
                        ),
                      ],
                    ),
                    child: IgnorePointer(
                      child: SizedBox(
                        width: shelfW,
                        height: shelfH,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: SizedBox(
                            width: cardW,
                            height: cardH,
                            child: cardChild,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Delete button when edit mode is active
          if (isEditMode)
            Positioned(
              top: 0,
              right: 12,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  // Check if it's a sticky note or a canvas item
                  final originalNotes = ref.read(stickyNotesProvider);
                  final isStickyNote = originalNotes.any((n) => n.id == item.id);
                  if (isStickyNote) {
                    ref.read(stickyNotesProvider.notifier).deleteNote(item.id);
                  } else {
                    ref.read(canvasStateProvider.notifier).removeItem(item.id);
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
  }
}
