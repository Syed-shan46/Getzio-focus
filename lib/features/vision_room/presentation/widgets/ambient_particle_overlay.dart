import 'dart:math';
import 'package:flutter/material.dart';

class AmbientParticleOverlay extends StatefulWidget {
  const AmbientParticleOverlay({super.key});

  @override
  State<AmbientParticleOverlay> createState() => _AmbientParticleOverlayState();
}

class _AmbientParticleOverlayState extends State<AmbientParticleOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..addListener(() => setState(() {}))
      ..repeat();
    
    _particles = List.generate(30, (index) => _Particle(_random));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ParticlePainter(_particles, _controller.value),
        size: Size.infinite,
      ),
    );
  }
}

class _Particle {
  double x, y;
  double speed;
  double radius;
  double alpha;
  double pulseOffset;

  _Particle(Random random) 
    : x = random.nextDouble(),
      y = random.nextDouble(),
      speed = 0.05 + random.nextDouble() * 0.1,
      radius = 1.0 + random.nextDouble() * 2.0,
      alpha = 0.1 + random.nextDouble() * 0.4,
      pulseOffset = random.nextDouble() * 2 * pi;
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress; // 0.0 to 1.0

  _ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var p in particles) {
      // Drift upwards
      double currentY = (p.y - progress * p.speed) % 1.0;
      if (currentY < 0) currentY += 1.0;

      // Small sine wave horizontal drift
      double currentX = p.x + sin(progress * 2 * pi + p.pulseOffset) * 0.02;

      // Opacity pulse
      double currentAlpha = p.alpha + sin(progress * 4 * pi + p.pulseOffset) * 0.2;
      currentAlpha = currentAlpha.clamp(0.0, 1.0);

      paint.color = Colors.white.withValues(alpha: currentAlpha);
      
      canvas.drawCircle(
        Offset(currentX * size.width, currentY * size.height), 
        p.radius, 
        paint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
