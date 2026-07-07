import 'package:flutter/material.dart';
import '../../domain/models/vision_customization.dart';

/// A premium animated window scene with moving clouds, tree silhouettes,
/// and warm sunlight. This becomes the emotional focus of the room.
class AnimatedWindowScene extends StatefulWidget {
  final VisionWindowScene scene;
  final double brightness;
  final double borderRadius;

  const AnimatedWindowScene({
    super.key,
    required this.scene,
    this.brightness = 0.7,
    this.borderRadius = 40,
  });

  @override
  State<AnimatedWindowScene> createState() => _AnimatedWindowSceneState();
}

class _AnimatedWindowSceneState extends State<AnimatedWindowScene>
    with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late AnimationController _treeController;
  late AnimationController _lightController;

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
    _treeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _lightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _treeController.dispose();
    _lightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius > 0
          ? BorderRadius.only(
              bottomLeft: Radius.circular(widget.borderRadius),
              bottomRight: Radius.circular(widget.borderRadius),
            )
          : BorderRadius.zero,
      child: Stack(
        children: [
          // Sky gradient
          Positioned.fill(child: _SkyGradient(scene: widget.scene)),

          // Animated clouds
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _cloudController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _CloudPainter(
                    progress: _cloudController.value,
                    scene: widget.scene,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),

          // Tree silhouettes (swaying)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: AnimatedBuilder(
              animation: _treeController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _TreePainter(
                    sway: _treeController.value,
                    scene: widget.scene,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),

          // Sun/moon glow
          Positioned(
            top: 30,
            right: 40,
            child: _CelestialBody(scene: widget.scene),
          ),

          // Glass reflection streaks
          Positioned.fill(
            child: CustomPaint(
              painter: _GlassReflectionPainter(),
              size: Size.infinite,
            ),
          ),

          // Warm sunlight overlay (slowly shifting)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _lightController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _SunlightPainter(
                    progress: _lightController.value,
                    brightness: widget.brightness,
                    scene: widget.scene,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SKY GRADIENT ──────────────────────────────────────────────────────────

class _SkyGradient extends StatelessWidget {
  final VisionWindowScene scene;

  const _SkyGradient({required this.scene});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: _sceneGradient(scene)),
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
      VisionWindowScene.desert => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF8C42), Color(0xFFE8B85A), Color(0xFFD4A050)],
      ),
      VisionWindowScene.aurora => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A0A2E), Color(0xFF1A3A4A), Color(0xFF0B2E1A)],
      ),
      VisionWindowScene.waterfall => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF6BB8E8), Color(0xFF3A9AD9), Color(0xFF1A6B3A)],
      ),
      VisionWindowScene.meadow => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF89CFF0), Color(0xFF7DD17D), Color(0xFF4A9A4A)],
      ),
      VisionWindowScene.canyon => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE07040), Color(0xFFC08050), Color(0xFF8B5A2B)],
      ),
      VisionWindowScene.village => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF87CEEB), Color(0xFF98D8C8), Color(0xFF6B8E6B)],
      ),
      VisionWindowScene.space => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF000011), Color(0xFF0B0B2E), Color(0xFF1A0B2E)],
      ),
      VisionWindowScene.tropical => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6), Color(0xFF0288D1)],
      ),
    };
  }
}

// ─── CLOUD PAINTER ─────────────────────────────────────────────────────────

class _CloudPainter extends CustomPainter {
  final double progress;
  final VisionWindowScene scene;

  _CloudPainter({required this.progress, required this.scene});

  @override
  void paint(Canvas canvas, Size size) {
    // Don't draw clouds for night, rain, space, aurora, desert, or canyon scenes
    if (scene == VisionWindowScene.nightSky ||
        scene == VisionWindowScene.rain ||
        scene == VisionWindowScene.space ||
        scene == VisionWindowScene.aurora ||
        scene == VisionWindowScene.desert ||
        scene == VisionWindowScene.canyon) {
      return;
    }

    final paint = Paint()..style = PaintingStyle.fill;

    // Cloud color based on scene
    paint.color = switch (scene) {
      VisionWindowScene.sunset => Colors.white.withValues(alpha: 0.15),
      VisionWindowScene.sunrise => Colors.white.withValues(alpha: 0.2),
      _ => Colors.white.withValues(alpha: 0.25),
    };

    // Draw 3 drifting clouds
    for (int i = 0; i < 3; i++) {
      final cloudY = size.height * (0.15 + i * 0.12);
      final cloudSpeed = 0.3 + i * 0.15;
      final offset = (progress * cloudSpeed + i * 0.3) % 1.4 - 0.2;
      final cloudX = offset * size.width;

      _drawCloud(canvas, Offset(cloudX, cloudY), 40 + i * 15, paint);
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawCircle(center, size * 0.5, paint);
    canvas.drawCircle(
      Offset(center.dx + size * 0.4, center.dy + size * 0.1),
      size * 0.4,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx - size * 0.4, center.dy + size * 0.1),
      size * 0.35,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx + size * 0.15, center.dy - size * 0.2),
      size * 0.3,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CloudPainter old) =>
      old.progress != progress || old.scene != scene;
}

// ─── TREE PAINTER ──────────────────────────────────────────────────────────

class _TreePainter extends CustomPainter {
  final double sway;
  final VisionWindowScene scene;

  _TreePainter({required this.sway, required this.scene});

  @override
  void paint(Canvas canvas, Size size) {
    if (scene == VisionWindowScene.city ||
        scene == VisionWindowScene.nightSky) {
      _drawBuildings(canvas, size);
      return;
    }

    if (scene == VisionWindowScene.space) {
      _drawSpaceView(canvas, size);
      return;
    }

    if (scene == VisionWindowScene.desert) {
      _drawDesert(canvas, size);
      return;
    }

    if (scene == VisionWindowScene.aurora) {
      _drawAuroraLandscape(canvas, size);
      return;
    }

    if (scene == VisionWindowScene.canyon) {
      _drawCanyon(canvas, size);
      return;
    }

    if (scene == VisionWindowScene.village) {
      _drawVillage(canvas, size);
      return;
    }

    final treeColor = switch (scene) {
      VisionWindowScene.forest => const Color(0xFF1B4332),
      VisionWindowScene.garden => const Color(0xFF2D6A4F),
      VisionWindowScene.mountains => const Color(0xFF2D5016),
      VisionWindowScene.ocean => const Color(0xFF1A5276),
      VisionWindowScene.lake => const Color(0xFF1A5276),
      VisionWindowScene.waterfall => const Color(0xFF1A4A2E),
      VisionWindowScene.meadow => const Color(0xFF2D5A1E),
      VisionWindowScene.tropical => const Color(0xFF0D3B1E),
      _ => const Color(0xFF2D6A4F),
    };

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = treeColor.withValues(alpha: 0.6);

    // Draw tree silhouettes at bottom
    final swayAmount = (sway - 0.5) * 6;

    // Left tree
    _drawTree(
      canvas,
      Offset(size.width * 0.1, size.height),
      80,
      swayAmount,
      paint,
    );
    // Right tree
    _drawTree(
      canvas,
      Offset(size.width * 0.85, size.height),
      100,
      -swayAmount,
      paint,
    );
    // Center small bush
    paint.color = treeColor.withValues(alpha: 0.4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height - 10),
        width: 120,
        height: 40,
      ),
      paint,
    );
  }

  void _drawDesert(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFC08040).withValues(alpha: 0.5);

    // Sand dune silhouette
    final dune = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.85)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.75, size.width * 0.35, size.height * 0.88)
      ..quadraticBezierTo(size.width * 0.55, size.height * 0.78, size.width * 0.7, size.height * 0.85)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.80, size.width, size.height * 0.88)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(dune, paint);

    // Cacti
    paint.color = const Color(0xFF2D5A1E).withValues(alpha: 0.5);
    _drawCactus(canvas, size.width * 0.25, size.height * 0.84, 20, paint);
    _drawCactus(canvas, size.width * 0.7, size.height * 0.82, 16, paint);
  }

  void _drawCactus(Canvas canvas, double x, double y, double h, Paint paint) {
    canvas.drawRect(Rect.fromLTWH(x - 2, y - h, 4, h), paint);
    canvas.drawRect(Rect.fromLTWH(x - 6, y - h * 0.6, 4, h * 0.3), paint);
    canvas.drawRect(Rect.fromLTWH(x + 2, y - h * 0.7, 4, h * 0.25), paint);
  }

  void _drawAuroraLandscape(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF0A2E1A).withValues(alpha: 0.7);
    final mountains = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.8)
      ..lineTo(size.width * 0.1, size.height * 0.72)
      ..lineTo(size.width * 0.2, size.height * 0.78)
      ..lineTo(size.width * 0.3, size.height * 0.65)
      ..lineTo(size.width * 0.4, size.height * 0.70)
      ..lineTo(size.width * 0.5, size.height * 0.62)
      ..lineTo(size.width * 0.6, size.height * 0.68)
      ..lineTo(size.width * 0.7, size.height * 0.64)
      ..lineTo(size.width * 0.8, size.height * 0.72)
      ..lineTo(size.width * 0.9, size.height * 0.66)
      ..lineTo(size.width, size.height * 0.74)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(mountains, paint);
  }

  void _drawCanyon(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF8B5A2B).withValues(alpha: 0.6);
    final canyon = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.7)
      ..lineTo(size.width * 0.12, size.height * 0.65)
      ..lineTo(size.width * 0.2, size.height * 0.75)
      ..lineTo(size.width * 0.3, size.height * 0.58)
      ..lineTo(size.width * 0.38, size.height * 0.80)
      ..lineTo(size.width * 0.45, size.height * 0.55)
      ..lineTo(size.width * 0.52, size.height * 0.82)
      ..lineTo(size.width * 0.6, size.height * 0.60)
      ..lineTo(size.width * 0.7, size.height * 0.72)
      ..lineTo(size.width * 0.8, size.height * 0.62)
      ..lineTo(size.width * 0.9, size.height * 0.78)
      ..lineTo(size.width, size.height * 0.68)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(canyon, paint);
  }

  void _drawVillage(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF3A5A3A).withValues(alpha: 0.6);
    // Rolling hills
    final hills = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.82)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.78, size.width * 0.3, size.height * 0.85)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.80, size.width * 0.6, size.height * 0.86)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.82, size.width, size.height * 0.84)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(hills, paint);

    // Houses
    paint.color = const Color(0xFF4A3A2A).withValues(alpha: 0.6);
    _drawHouse(canvas, size.width * 0.15, size.height * 0.80, 14, paint);
    _drawHouse(canvas, size.width * 0.35, size.height * 0.82, 12, paint);
    _drawHouse(canvas, size.width * 0.65, size.height * 0.83, 13, paint);
    _drawHouse(canvas, size.width * 0.82, size.height * 0.81, 11, paint);

    // Warm lit windows
    paint.color = const Color(0xFFFFD700).withValues(alpha: 0.3);
    canvas.drawCircle(Offset(size.width * 0.16, size.height * 0.78), 1.5, paint);
    canvas.drawCircle(Offset(size.width * 0.36, size.height * 0.80), 1.5, paint);
    canvas.drawCircle(Offset(size.width * 0.66, size.height * 0.81), 1.5, paint);
  }

  void _drawHouse(Canvas canvas, double x, double y, double size_, Paint paint) {
    // House body
    canvas.drawRect(Rect.fromLTWH(x - size_ / 2, y - size_, size_, size_), paint);
    // Roof (triangle)
    final roof = Path()
      ..moveTo(x - size_ / 2 - 2, y - size_)
      ..lineTo(x, y - size_ * 1.4)
      ..lineTo(x + size_ / 2 + 2, y - size_)
      ..close();
    canvas.drawPath(roof, paint);
  }

  void _drawSpaceView(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF1A1A3A).withValues(alpha: 0.6);
    // Earth curve at bottom
    final earth = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.6, size.width, size.height * 0.7)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(earth, paint);

    paint.color = const Color(0xFF2A5A3A).withValues(alpha: 0.4);
    final continent = Path()
      ..moveTo(size.width * 0.2, size.height * 0.72)
      ..lineTo(size.width * 0.25, size.height * 0.68)
      ..lineTo(size.width * 0.35, size.height * 0.70)
      ..lineTo(size.width * 0.3, size.height * 0.74)
      ..close();
    canvas.drawPath(continent, paint);

    // Stars
    paint.color = Colors.white.withValues(alpha: 0.6);
    for (int i = 0; i < 8; i++) {
      canvas.drawCircle(
        Offset(
          size.width * (0.05 + i * 0.12 + (i * 0.03)),
          size.height * (0.1 + (i % 3) * 0.12),
        ),
        0.8 + (i % 3) * 0.3,
        paint,
      );
    }
  }

  void _drawTree(
    Canvas canvas,
    Offset base,
    double height,
    double sway,
    Paint paint,
  ) {
    final path = Path();
    path.moveTo(base.dx, base.dy);
    path.lineTo(base.dx + sway, base.dy - height * 0.4);
    path.lineTo(base.dx + sway * 1.5, base.dy - height);
    // Tree crown
    canvas.drawPath(path, paint..color = paint.color.withValues(alpha: 0.5));
    canvas.drawCircle(
      Offset(base.dx + sway * 1.5, base.dy - height),
      height * 0.35,
      paint..color = paint.color.withValues(alpha: 0.7),
    );
    canvas.drawCircle(
      Offset(base.dx + sway * 1.5 - 15, base.dy - height + 10),
      height * 0.25,
      paint,
    );
    canvas.drawCircle(
      Offset(base.dx + sway * 1.5 + 15, base.dy - height + 5),
      height * 0.28,
      paint,
    );
  }

  void _drawBuildings(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF1A252F).withValues(alpha: 0.8);

    // Building silhouettes
    final buildings = [
      (size.width * 0.0, size.height * 0.4, 60.0),
      (size.width * 0.15, size.height * 0.3, 80.0),
      (size.width * 0.35, size.height * 0.5, 50.0),
      (size.width * 0.55, size.height * 0.25, 90.0),
      (size.width * 0.75, size.height * 0.4, 65.0),
    ];

    for (final (x, y, h) in buildings) {
      canvas.drawRect(Rect.fromLTWH(x, y, 40, h), paint);

      // Windows (lit)
      paint.color = const Color(0xFFFBBF24).withValues(alpha: 0.15);
      for (int wy = 0; wy < h ~/ 15; wy++) {
        for (int wx = 0; wx < 3; wx++) {
          if ((wx + wy) % 3 == 0) {
            canvas.drawRect(
              Rect.fromLTWH(x + 5 + wx * 12, y + 5 + wy * 15, 6, 8),
              paint,
            );
          }
        }
      }
      paint.color = const Color(0xFF1A252F).withValues(alpha: 0.8);
    }
  }

  @override
  bool shouldRepaint(covariant _TreePainter old) =>
      old.sway != sway || old.scene != scene;
}

// ─── CELESTIAL BODY (Sun/Moon) ─────────────────────────────────────────────

class _CelestialBody extends StatelessWidget {
  final VisionWindowScene scene;

  const _CelestialBody({required this.scene});

  @override
  Widget build(BuildContext context) {
    final isNight = scene == VisionWindowScene.nightSky;
    final color = isNight ? const Color(0xFFF0F0F0) : const Color(0xFFFFF8E1);
    final glowColor = isNight
        ? const Color(0xFFE0E0FF)
        : const Color(0xFFFFD700);

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: glowColor.withValues(alpha: 0.2),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

// ─── GLASS REFLECTION ──────────────────────────────────────────────────────

class _GlassReflectionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

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

// ─── SUNLIGHT OVERLAY ──────────────────────────────────────────────────────

class _SunlightPainter extends CustomPainter {
  final double progress;
  final double brightness;
  final VisionWindowScene scene;

  _SunlightPainter({
    required this.progress,
    required this.brightness,
    required this.scene,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Warm sunlight gradient that slowly shifts
    final shift = (progress - 0.5) * 0.2;

    final sunlightColor = switch (scene) {
      VisionWindowScene.sunrise => const Color(0xFFFFB347),
      VisionWindowScene.sunset => const Color(0xFFFF6B6B),
      VisionWindowScene.nightSky => const Color(0xFF4A5568),
      VisionWindowScene.rain => const Color(0xFF6B7280),
      VisionWindowScene.space => const Color(0xFF2A2A4A),
      VisionWindowScene.aurora => const Color(0xFF3A5A8A),
      VisionWindowScene.desert => const Color(0xFFFFD699),
      VisionWindowScene.canyon => const Color(0xFFFF8C42),
      _ => const Color(0xFFFFF8E1),
    };

    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(0.3 + shift, -0.3),
        radius: 1.5,
        colors: [
          sunlightColor.withValues(alpha: 0.15 * brightness),
          sunlightColor.withValues(alpha: 0.05 * brightness),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _SunlightPainter old) =>
      old.progress != progress ||
      old.brightness != brightness ||
      old.scene != scene;
}

// ─── VISION WINDOW SCENE ENUM (re-export for convenience) ──────────────────
// This enum is defined in vision_customization.dart
