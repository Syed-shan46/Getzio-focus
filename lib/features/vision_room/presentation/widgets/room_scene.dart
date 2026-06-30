import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/vision_customization.dart';
import '../../domain/models/vision_item.dart';

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
                  floorHeight: 90,
                ),
                size: Size.infinite,
              ),
              0.03,
            ),
          ),
        ),

        // 2. Full-Width Wooden Shelf sitting on lower wall above floorboards
        Positioned(
          left: 0,
          right: 0,
          bottom: 105,
          child: RepaintBoundary(
            child: parallaxLayer(const _FullWidthFloatingShelf(), 0.05),
          ),
        ),

        // 3. Realistic Cozy Candle sitting on the left side of the bottom shelf
        Positioned(
          left: 44,
          bottom: 136,
          child: RepaintBoundary(
            child: parallaxLayer(const _RealisticCandle(), 0.05),
          ),
        ),

        // 4. Living Workspace Fish Tank sitting cleanly on the right side of the bottom shelf
        Positioned(
          right: 36,
          bottom: 136,
          child: RepaintBoundary(
            child: parallaxLayer(const _WorkspaceFishTank(), 0.05),
          ),
        ),

        // 5. Border lighting — soft warm glow on left & right walls only
        Positioned(
          top: 0,
          bottom: 105,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _BorderLightPainter(),
                size: Size.infinite,
              ),
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
        colors: [Color(0xFFFBE8CE), Color(0xFFF5DEC0), Color(0xFFEDD4B2)],
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
        colors: [Color(0xFFFBE8CE), Color(0xFFF5DEC0), Color(0xFFEDD4B2)],
      ),
      _ => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFBE8CE), Color(0xFFF5DEC0), Color(0xFFEDD4B2)],
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
    final Rect floorRect = Rect.fromLTRB(0, wallH, w, h);

    // 1. Wall Background Gradient
    final Paint wallPaint = Paint()
      ..shader = wallGradient.createShader(wallRect);
    canvas.drawRect(wallRect, wallPaint);

    // Soft wall shadow / ambient gradient in corners
    final cornerShadow = RadialGradient(
      colors: [Colors.black.withValues(alpha: 0.12), Colors.transparent],
      radius: 1.3,
    ).createShader(Rect.fromLTRB(-100, -100, w + 100, wallH + 100));
    canvas.drawRect(
      wallRect,
      Paint()
        ..shader = cornerShadow
        ..blendMode = BlendMode.multiply,
    );

    // 2. Baseboard / Skirting Molding (floor depth)
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

    // 3. Wooden Floorboards in perspective
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

  @override
  bool shouldRepaint(covariant RoomBackgroundPainter oldDelegate) =>
      oldDelegate.floorHeight != floorHeight ||
      oldDelegate.wallGradient != wallGradient;
}

/// Paints a soft warm light glow along the left and right wall edges only.
/// Does not affect the floor or shelf area.
class _BorderLightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final edgeWidth = w * 0.12;

    // Left edge warm light glow
    final leftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFFFFD54F).withValues(alpha: 0.08),
          const Color(0xFFFFB74D).withValues(alpha: 0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, edgeWidth, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, edgeWidth, h), leftPaint);

    // Right edge warm light glow
    final rightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [
          const Color(0xFFFFD54F).withValues(alpha: 0.08),
          const Color(0xFFFFB74D).withValues(alpha: 0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(w - edgeWidth, 0, edgeWidth, h));
    canvas.drawRect(Rect.fromLTWH(w - edgeWidth, 0, edgeWidth, h), rightPaint);

    // Subtle vertical light streaks
    final streakPaint = Paint()
      ..color = const Color(0xFFFFF8E1).withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(edgeWidth * 0.3, 0),
      Offset(edgeWidth * 0.3, h),
      streakPaint,
    );
    canvas.drawLine(
      Offset(w - edgeWidth * 0.3, 0),
      Offset(w - edgeWidth * 0.3, h),
      streakPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
