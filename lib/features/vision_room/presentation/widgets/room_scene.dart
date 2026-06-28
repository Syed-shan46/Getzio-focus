import 'dart:math';
import 'dart:ui';
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

    return Stack(
      children: [
        // Layer 1: Background Wall
        RepaintBoundary(child: parallaxLayer(_WallLayer(customization: customization), 0.03)),

        // Layer 2: Window
        RepaintBoundary(child: parallaxLayer(_WindowLayer(customization: customization), 0.02)),

        // Layer 3: Outside World View (through window)
        RepaintBoundary(child: parallaxLayer(_OutsideViewLayer(customization: customization), 0.01)),

        // Layer 4: Wall Decor
        RepaintBoundary(child: parallaxLayer(_WallDecorLayer(customization: customization), 0.04)),

        // Layer 5: Shelf
        RepaintBoundary(child: parallaxLayer(_ShelfLayer(customization: customization), 0.06)),

        // Layer 6: Floor
        RepaintBoundary(child: parallaxLayer(_FloorLayer(customization: customization), 0.05)),

        // Layer 6.5: Item floor shadows (items near floor cast shadows)
        if (items.isNotEmpty)
          RepaintBoundary(child: parallaxLayer(_ItemShadowLayer(items: items), 0.08)),

        // Layer 7: The actual wall content (VisionBoard, etc.)
        Positioned.fill(child: child),

        // Layer 8: Foreground objects
        RepaintBoundary(child: parallaxLayer(_ForegroundLayer(customization: customization), 0.14)),

        // Layer 8.5: Hanging ceiling bulb (premium pendant light)
        RepaintBoundary(child: parallaxLayer(CeilingBulbLayer(customization: customization), 0.02)),

        // Layer 9: Lighting
        RepaintBoundary(child: parallaxLayer(LightingLayer(customization: customization), 0.02)),

        // Layer 10: Ambient particles
        RepaintBoundary(child: parallaxLayer(_ParticleLayer(customization: customization), 0.12)),
      ],
    );
  }
}

// ─── LAYER 1: WALL ─────────────────────────────────────────────────────────

class _WallLayer extends StatelessWidget {
  final VisionCustomization customization;
  const _WallLayer({required this.customization});

  @override
  Widget build(BuildContext context) {
    final bg = customization.background;
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: _wallGradient(bg),
        ),
        child: CustomPaint(
          painter: _WallTexturePainter(bg),
          size: Size.infinite,
        ),
      ),
    );
  }

  LinearGradient _wallGradient(VisionBackground bg) {
    return switch (bg) {
      VisionBackground.scandinavianWall => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F0E8), Color(0xFFE8E0D0), Color(0xFFD4C9B8)],
        ),
      VisionBackground.oceanView => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F4C75), Color(0xFF1A7BA0), Color(0xFF0B2E4A)],
        ),
      VisionBackground.forestCabin => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF0D2818)],
        ),
      VisionBackground.sunsetStudio => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B6B), Color(0xFFFFA751), Color(0xFFFFD93D)],
        ),
      VisionBackground.rainWindow => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF374151), Color(0xFF4A5568), Color(0xFF2D3748)],
        ),
      VisionBackground.modernLoft => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A202C), Color(0xFF2D3748), Color(0xFF1A202C)],
        ),
      VisionBackground.softClouds => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD6E4F0), Color(0xFFE8F0F8), Color(0xFFC8D8E8)],
        ),
      VisionBackground.walnutWood => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5C4033), Color(0xFF6B4A3A), Color(0xFF4A3328)],
        ),
      VisionBackground.matteBlack => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F0F0F), Color(0xFF1A1A1A), Color(0xFF000000)],
        ),
      VisionBackground.minimalWhite => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
        ),
      VisionBackground.concreteWall => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9CA3AF), Color(0xFF8B929A), Color(0xFF6B7280)],
        ),
      VisionBackground.stoneWall => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF78716C), Color(0xFF8B8280), Color(0xFF6B6560)],
        ),
      VisionBackground.softGradient => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF8E54E9)],
        ),
      VisionBackground.customImage => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF374151), Color(0xFF4B5563), Color(0xFF1F2937)],
        ),
    };
  }
}

class _WallTexturePainter extends CustomPainter {
  final VisionBackground bg;
  _WallTexturePainter(this.bg);

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle noise texture for wall
    final paint = Paint();
    final random = Random(42);
    final isLight = switch (bg) {
      VisionBackground.scandinavianWall => true,
      VisionBackground.softClouds => true,
      VisionBackground.minimalWhite => true,
      _ => false,
    };

    paint.color = (isLight ? Colors.black : Colors.white).withValues(alpha: 0.02);
    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 3 + 1, paint);
    }

    // Ambient glow from top (like a soft window light)
    final glow = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 2.0,
        colors: [
          Colors.white.withValues(alpha: isLight ? 0.06 : 0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glow);

    // Bottom vignette
    final vignette = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.transparent,
          Colors.black.withValues(alpha: 0.15),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignette);
  }

  @override
  bool shouldRepaint(_WallTexturePainter old) => old.bg != bg;
}

// ─── LAYER 2: WINDOW ──────────────────────────────────────────────────────

class _WindowLayer extends StatelessWidget {
  final VisionCustomization customization;
  const _WindowLayer({required this.customization});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height * 0.45,
      child: ClipRect(
        child: Stack(
          children: [
            // Glass pane with blur
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.06),
                          Colors.white.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Window frame top/bottom bars
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            // Vertical frame dividers
            Positioned(
              left: MediaQuery.of(context).size.width * 0.33,
              top: 0,
              bottom: 8,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.66,
              top: 0,
              bottom: 8,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            // Diagonal reflection streaks
            Positioned.fill(
              child: CustomPaint(
                painter: _WindowReflectionPainter(),
                size: Size.infinite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowReflectionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Diagonal highlight streak
    paint.color = Colors.white.withValues(alpha: 0.04);
    final path = Path()
      ..moveTo(size.width * 0.1, 0)
      ..lineTo(size.width * 0.35, 0)
      ..lineTo(size.width * 0.15, size.height)
      ..lineTo(size.width * -0.1, size.height)
      ..close();
    canvas.drawPath(path, paint);

    // Second streak
    paint.color = Colors.white.withValues(alpha: 0.025);
    final path2 = Path()
      ..moveTo(size.width * 0.6, 0)
      ..lineTo(size.width * 0.75, 0)
      ..lineTo(size.width * 0.55, size.height)
      ..lineTo(size.width * 0.4, size.height)
      ..close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── LAYER 3: OUTSIDE VIEW ────────────────────────────────────────────────

class _OutsideViewLayer extends StatelessWidget {
  final VisionCustomization customization;
  const _OutsideViewLayer({required this.customization});

  @override
  Widget build(BuildContext context) {
    final scene = customization.windowScene;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height * 0.45,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: _sceneGradient(scene),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  LinearGradient _sceneGradient(VisionWindowScene scene) {
    return switch (scene) {
      VisionWindowScene.ocean => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF87CEEB), Color(0xFF1E90FF), Color(0xFF006994)],
        ),
      VisionWindowScene.forest => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF87CEEB), Color(0xFF228B22), Color(0xFF006400)],
        ),
      VisionWindowScene.mountains => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A90D9), Color(0xFF6B8E23), Color(0xFF556B2F)],
        ),
      VisionWindowScene.rain => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4A5568), Color(0xFF6B7280), Color(0xFF374151)],
        ),
      VisionWindowScene.snow => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F0F8), Color(0xFFD6E4F0), Color(0xFFB0C4DE)],
        ),
      VisionWindowScene.city => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2C3E50), Color(0xFF34495E), Color(0xFF1A252F)],
        ),
      VisionWindowScene.garden => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF87CEEB), Color(0xFF98FB98), Color(0xFF3CB371)],
        ),
      VisionWindowScene.lake => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF89CFF0), Color(0xFF2E86C1), Color(0xFF1B4F72)],
        ),
      VisionWindowScene.sunrise => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF8C42), Color(0xFFFFB347), Color(0xFFFFD699)],
        ),
      VisionWindowScene.sunset => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF4500), Color(0xFFFF6B6B), Color(0xFF8B0000)],
        ),
      VisionWindowScene.nightSky => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F0F2E), Color(0xFF1A1A4E), Color(0xFF0B0B1A)],
        ),
    };
  }
}

// ─── LAYER 4: WALL DECOR ───────────────────────────────────────────────────

class _WallDecorLayer extends StatelessWidget {
  final VisionCustomization customization;
  const _WallDecorLayer({required this.customization});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _WallDecorPainter(
          decorations: customization.decorations,
          boardStyle: customization.boardStyle,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _WallDecorPainter extends CustomPainter {
  final List<BoardDecoration> decorations;
  final VisionBoardStyle boardStyle;

  _WallDecorPainter({required this.decorations, required this.boardStyle});

  @override
  void paint(Canvas canvas, Size size) {
    for (final decor in decorations) {
      switch (decor) {
        case BoardDecoration.stringLights:
          _drawStringLights(canvas, size);
        case BoardDecoration.miniPlants:
          _drawMiniPlants(canvas, size);
        case BoardDecoration.pushPins:
          _drawPushPins(canvas, size);
        case BoardDecoration.washiTape:
          _drawWashiTape(canvas, size);
        case BoardDecoration.ribbons:
          _drawRibbons(canvas, size);
        case BoardDecoration.pressedFlowers:
          _drawPressedFlowers(canvas, size);
        case BoardDecoration.bookmarks:
          _drawBookmarks(canvas, size);
        case BoardDecoration.minimalShelves:
          _drawMinimalShelves(canvas, size);
        default:
          break;
      }
    }
  }

  void _drawStringLights(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.brown.withValues(alpha: 0.2);
    // Only draw at the top portion of the wall
    final wallHeight = size.height * 0.6;
    final path = Path();
    path.moveTo(50, wallHeight * 0.08);
    for (double x = 50; x <= size.width - 50; x += 20) {
      path.lineTo(x, wallHeight * 0.08 + sin(x * 0.02) * 6);
    }
    canvas.drawPath(path, paint);

    final bulbPaint = Paint()..style = PaintingStyle.fill;
    for (double x = 50; x <= size.width - 50; x += 50) {
      final y = wallHeight * 0.08 + sin(x * 0.02) * 6;
      bulbPaint.color = const Color(0xFFFFD700).withValues(alpha: 0.15);
      canvas.drawCircle(Offset(x, y + 4), 3, bulbPaint);
    }
  }

  void _drawMiniPlants(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final wallHeight = size.height * 0.6;
    final positions = [
      Offset(size.width * 0.06, wallHeight * 0.45),
      Offset(size.width * 0.94, wallHeight * 0.40),
    ];
    for (final pos in positions) {
      paint.color = const Color(0xFF2D6A4F).withValues(alpha: 0.12);
      canvas.drawCircle(Offset(pos.dx, pos.dy), 6, paint);
      paint.color = const Color(0xFF8B6914).withValues(alpha: 0.1);
      final pot = Path()
        ..moveTo(pos.dx - 5, pos.dy + 2)
        ..lineTo(pos.dx - 3, pos.dy + 10)
        ..lineTo(pos.dx + 3, pos.dy + 10)
        ..lineTo(pos.dx + 5, pos.dy + 2)
        ..close();
      canvas.drawPath(pot, paint);
    }
  }

  void _drawPushPins(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final wallHeight = size.height * 0.6;
    for (final pos in [
      Offset(size.width * 0.12, wallHeight * 0.1),
      Offset(size.width * 0.88, wallHeight * 0.08),
    ]) {
      canvas.drawCircle(pos, 3, paint);
    }
  }

  void _drawWashiTape(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.pink.withValues(alpha: 0.06);
    final wallHeight = size.height * 0.6;
    for (final pos in [
      Offset(size.width * 0.08, wallHeight * 0.06),
      Offset(size.width * 0.85, wallHeight * 0.10),
    ]) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(-0.12);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 40, height: 12),
          const Radius.circular(1),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  void _drawRibbons(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFF6B6B).withValues(alpha: 0.05);
    final wallHeight = size.height * 0.6;
    final path = Path()
      ..moveTo(size.width - 15, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 15)
      ..close();
    canvas.drawPath(path, paint);
    paint.color = const Color(0xFF4DA3FF).withValues(alpha: 0.05);
    final path2 = Path()
      ..moveTo(0, wallHeight - 15)
      ..lineTo(0, wallHeight)
      ..lineTo(15, wallHeight)
      ..close();
    canvas.drawPath(path2, paint);
  }

  void _drawPressedFlowers(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final wallHeight = size.height * 0.6;
    for (final pos in [
      Offset(size.width * 0.2, wallHeight * 0.12),
      Offset(size.width * 0.75, wallHeight * 0.15),
    ]) {
      paint.color = const Color(0xFFFFB7C5).withValues(alpha: 0.08);
      for (int i = 0; i < 5; i++) {
        canvas.drawCircle(
          Offset(pos.dx + cos(i * 1.256) * 3, pos.dy + sin(i * 1.256) * 3),
          2,
          paint,
        );
      }
      paint.color = const Color(0xFFFFD700).withValues(alpha: 0.06);
      canvas.drawCircle(pos, 1.5, paint);
    }
  }

  void _drawBookmarks(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final wallHeight = size.height * 0.6;
    final data = [
      (Offset(size.width * 0.9, wallHeight * 0.2), const Color(0xFFE74C3C)),
      (Offset(size.width * 0.1, wallHeight * 0.7), const Color(0xFF3498DB)),
    ];
    for (final (pos, color) in data) {
      paint.color = color.withValues(alpha: 0.08);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: pos, width: 6, height: 24),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  void _drawMinimalShelves(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B7355).withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final wallHeight = size.height * 0.6;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.04, wallHeight * 0.65, size.width * 0.25, 2.5),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.71, wallHeight * 0.7, size.width * 0.25, 2.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(_WallDecorPainter old) =>
      old.decorations != decorations || old.boardStyle != boardStyle;
}

// ─── LAYER 5: SHELF ───────────────────────────────────────────────────────

class _ShelfLayer extends StatelessWidget {
  final VisionCustomization customization;
  const _ShelfLayer({required this.customization});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.32,
      left: 0,
      right: 0,
      height: 8,
      child: Stack(
        children: [
          // Shelf front edge
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF8B7355).withValues(alpha: 0.2),
                  const Color(0xFF5C4033).withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
          // Shelf shadow
          Positioned(
            bottom: -16,
            left: 0,
            right: 0,
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── LAYER 6: FLOOR ────────────────────────────────────────────────────────

class _FloorLayer extends StatelessWidget {
  final VisionCustomization customization;
  const _FloorLayer({required this.customization});

  @override
  Widget build(BuildContext context) {
    final floorHeight = MediaQuery.of(context).size.height * 0.28;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: floorHeight,
      child: Stack(
        children: [
          // Floor surface with perspective
          Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0005)
              ..rotateX(0.15),
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF5C4033).withValues(alpha: 0.3),
                    const Color(0xFF3E1F0D).withValues(alpha: 0.5),
                    const Color(0xFF2A1508).withValues(alpha: 0.6),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: CustomPaint(
                painter: _FloorPlankPainter(),
                size: Size.infinite,
              ),
            ),
          ),
          // Bottom vignette
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
          // Floor reflection (subtle shine)
          Positioned.fill(
            child: Opacity(
              opacity: 0.04,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.3],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloorPlankPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;

    final plankCount = 8;
    final plankWidth = size.width / plankCount;

    for (int i = 0; i < plankCount; i++) {
      final x = i * plankWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      // Horizontal grain
      for (double y = 0; y < size.height; y += 12) {
        final grainX = x + 4 + sin(y * 0.1 + i) * (plankWidth * 0.3);
        canvas.drawLine(
          Offset(grainX, y),
          Offset(grainX + 6 + sin(y * 0.15) * 4, y + 2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── LAYER 6.5: ITEM FLOOR SHADOWS ─────────────────────────────────────────

class _ItemShadowLayer extends StatelessWidget {
  final List<VisionItem> items;

  const _ItemShadowLayer({required this.items});

  @override
  Widget build(BuildContext context) {
    final floorTop = MediaQuery.of(context).size.height * 0.72;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _ItemShadowPainter(
            items: items,
            floorTop: floorTop,
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _ItemShadowPainter extends CustomPainter {
  final List<VisionItem> items;
  final double floorTop;
  final double screenWidth;
  final double screenHeight;

  _ItemShadowPainter({
    required this.items,
    required this.floorTop,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (final item in items) {
      final itemBottom = item.y + item.height;
      final overlap = itemBottom - floorTop;
      if (overlap <= 0) continue;

      final shadowIntensity = (overlap / (screenHeight * 0.15)).clamp(0.1, 0.6);
      final shadowHeight = item.height * 0.15 * shadowIntensity;
      final shadowWidth = item.width * 0.9;

      final cx = item.x + item.width / 2;
      final shadowX = cx - shadowWidth / 2;
      final shadowY = floorTop;

      paint.color = Colors.black.withValues(alpha: 0.12 * shadowIntensity);
      canvas.drawOval(
        Rect.fromLTWH(shadowX, shadowY, shadowWidth, shadowHeight),
        paint,
      );

      // Second softer shadow layer
      paint.color = Colors.black.withValues(alpha: 0.06 * shadowIntensity);
      canvas.drawOval(
        Rect.fromLTWH(
          shadowX - shadowWidth * 0.1,
          shadowY - 2,
          shadowWidth * 1.2,
          shadowHeight * 1.3,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ItemShadowPainter old) => old.items != items;
}

// ─── LAYER 8: FOREGROUND ──────────────────────────────────────────────────

class _ForegroundLayer extends StatelessWidget {
  final VisionCustomization customization;
  const _ForegroundLayer({required this.customization});

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(child: SizedBox());
  }
}

// ─── LAYER 8.5: CEILING BULB (Premium Hanging Pendant Light) ──────────────────

class CeilingBulbLayer extends StatelessWidget {
  final VisionCustomization customization;
  const CeilingBulbLayer({super.key, required this.customization});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final brightness = customization.ambientBrightness;

    // Position: centered horizontally, ~12% down from top
    final bulbTop = screenHeight * 0.12;
    final bulbSize = screenWidth * 0.22; // ~22% of screen width

    return Positioned(
      top: 0, // Wire starts from the absolute top of the screen (ceiling)
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Ceiling mount (matte black cylinder)
            Positioned(
              top: 0,
              width: bulbSize * 0.38,
              height: 14,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),

            // Thin black hanging wire extending from the top to the bulb position
            Positioned(
              top: 14,
              width: 1.8,
              height: bulbTop - 14,
              child: Container(
                color: const Color(0xFF161616),
              ),
            ),

            // Soft radial glow bloom around the bulb (ambient warm glow)
            Positioned(
              top: bulbTop - bulbSize * 0.3,
              left: screenWidth / 2 - bulbSize * 0.8,
              width: bulbSize * 1.6,
              height: bulbSize * 1.6,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFF59E0B).withValues(alpha: 0.35 * brightness),
                      const Color(0xFFD97706).withValues(alpha: 0.15 * brightness),
                      const Color(0xFFB45309).withValues(alpha: 0.05 * brightness),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),
            ),

            // Bulb image (using the asset image bulb.png)
            Positioned(
              top: bulbTop - bulbSize * 0.1,
              left: screenWidth / 2 - bulbSize / 2,
              width: bulbSize,
              height: bulbSize,
              child: Image.asset(
                'assets/images/bulb.png',
                width: bulbSize,
                height: bulbSize,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),

            // Highlight core bloom (filament glare)
            Positioned(
              top: bulbTop + bulbSize * 0.15,
              left: screenWidth / 2 - 15,
              width: 30,
              height: 30,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFFBEB),
                      blurRadius: 20,
                      spreadRadius: 2 * brightness,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.8),
                      blurRadius: 40,
                      spreadRadius: 10 * brightness,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── LAYER 9: LIGHTING ────────────────────────────────────────────────────

class LightingLayer extends StatelessWidget {
  final VisionCustomization customization;
  const LightingLayer({super.key, required this.customization});

  @override
  Widget build(BuildContext context) {
    // Disabled screen-wide ambient overlays as requested to focus lighting locally around the bulb
    return const SizedBox.shrink();
  }
}

// ─── LAYER 10: PARTICLES ──────────────────────────────────────────────────

class _ParticleLayer extends StatefulWidget {
  final VisionCustomization customization;
  const _ParticleLayer({required this.customization});

  @override
  State<_ParticleLayer> createState() => _ParticleLayerState();
}

class _ParticleLayerState extends State<_ParticleLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_DustParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _particles = List.generate(15, (_) => _DustParticle(Random()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _DustPainter(_particles, _controller.value),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

class _DustParticle {
  double x, y;
  double speed;
  double size;
  double driftOffset;
  double alpha;

  _DustParticle(Random rnd)
      : x = rnd.nextDouble(),
        y = rnd.nextDouble(),
        speed = 0.005 + rnd.nextDouble() * 0.015,
        size = 0.5 + rnd.nextDouble() * 1.5,
        driftOffset = rnd.nextDouble() * 2 * pi,
        alpha = 0.05 + rnd.nextDouble() * 0.15;
}

class _DustPainter extends CustomPainter {
  final List<_DustParticle> particles;
  final double progress;

  _DustPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final y = (p.y - progress * p.speed) % 1.0;
      final x = p.x + sin(progress * 2 * pi + p.driftOffset) * 0.015;
      final alpha = p.alpha + sin(progress * 4 * pi + p.driftOffset) * 0.05;

      paint.color = Colors.white.withValues(alpha: alpha.clamp(0.0, 0.2));
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DustPainter old) => true;
}
