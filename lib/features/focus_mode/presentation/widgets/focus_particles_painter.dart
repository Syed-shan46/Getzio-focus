import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Particle {
  double x;
  double y;
  double size;
  double opacity;
  double speedY;
  double speedX;
  
  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speedY,
    required this.speedX,
  });
}

class FocusParticlesPainterWidget extends StatefulWidget {
  final Widget child;
  final bool isRunning;
  final bool isBreakMode;
  
  const FocusParticlesPainterWidget({
    super.key, 
    required this.child, 
    required this.isRunning,
    this.isBreakMode = false,
  });

  @override
  State<FocusParticlesPainterWidget> createState() => _FocusParticlesPainterWidgetState();
}

class _FocusParticlesPainterWidgetState extends State<FocusParticlesPainterWidget> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final List<Particle> _particles = [];
  final Random _rnd = Random();
  final int _maxParticles = 15;
  
  // Dimensions - we don't have exact constraints until paint, 
  // but we can generate positions relatively (0.0 to 1.0) and map them
  
  @override
  void initState() {
    super.initState();
    _initParticles();
    _ticker = createTicker((elapsed) {
      if (!widget.isRunning) return;
      setState(() {
        _updateParticles();
      });
    });
    _ticker.start();
  }
  
  @override
  void didUpdateWidget(FocusParticlesPainterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !_ticker.isTicking) {
      _ticker.start();
    } else if (!widget.isRunning && _ticker.isTicking) {
      _ticker.stop();
    }
  }

  void _initParticles() {
    for (int i = 0; i < _maxParticles; i++) {
      _particles.add(_createRandomParticle(initial: true));
    }
  }
  
  Particle _createRandomParticle({bool initial = false}) {
    return Particle(
      x: _rnd.nextDouble(), // 0.0 to 1.0 (will multiply by width)
      y: initial ? _rnd.nextDouble() : -0.1, // If initial, random across height. Else spawn above top.
      size: 2.0 + _rnd.nextDouble() * 3.0, // 2 to 5 px
      opacity: 0.15 + _rnd.nextDouble() * 0.25, // 15% to 40%
      speedY: 0.0005 + _rnd.nextDouble() * 0.001, // Very slow falling
      speedX: (_rnd.nextDouble() - 0.5) * 0.0005, // Slight horizontal drift
    );
  }

  void _updateParticles() {
    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      p.y += p.speedY;
      p.x += p.speedX;
      
      // If it falls below bottom, respawn
      if (p.y > 1.1) {
        _particles[i] = _createRandomParticle();
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlesPainter(
        particles: _particles,
        isBreakMode: widget.isBreakMode,
      ),
      child: widget.child,
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final bool isBreakMode;
  
  _ParticlesPainter({required this.particles, required this.isBreakMode});

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = isBreakMode ? const Color(0xFF66FFB2) : const Color(0xFFFFB266); // Amber or Green
    
    for (var p in particles) {
      // Fade out near the bottom (y > 0.8)
      double currentOpacity = p.opacity;
      if (p.y > 0.8) {
        final fade = (1.1 - p.y) / 0.3; // 1.0 at 0.8, 0.0 at 1.1
        currentOpacity = p.opacity * fade.clamp(0.0, 1.0);
      }
      
      final paint = Paint()
        ..color = baseColor.withValues(alpha: currentOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0); // Glowing effect
        
      canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true; // Ticker drives rebuilds
}
