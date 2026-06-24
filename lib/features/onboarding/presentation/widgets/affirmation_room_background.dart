import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AffirmationRoomBackground extends StatefulWidget {
  final Widget child;

  const AffirmationRoomBackground({super.key, required this.child});

  @override
  State<AffirmationRoomBackground> createState() =>
      _AffirmationRoomBackgroundState();
}

class _AffirmationRoomBackgroundState extends State<AffirmationRoomBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0A0E1A),
                  Color(0xFF0D0A1A),
                  Color(0xFF050508),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ),

        // Warm ambient glow (top-center)
        Positioned(
          top: -100,
          left: 0,
          right: 0,
          child: Container(
            height: 350,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.3),
                radius: 1.0,
                colors: [
                  const Color(0xFF2A1F4A).withValues(alpha: 0.35),
                  const Color(0xFF1A1440).withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Soft accent glow (bottom-center)
        Positioned(
          bottom: -80,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [
                  AppColors.accentBlue.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Floating particles
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) {
              return CustomPaint(
                painter: _RoomParticlePainter(
                  animationValue: _particleController.value,
                ),
              );
            },
          ),
        ),

        // Content
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _RoomParticlePainter extends CustomPainter {
  final double animationValue;

  _RoomParticlePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    const particleCount = 20;
    for (int i = 0; i < particleCount; i++) {
      final seed = i * 137.508;
      final baseX = (seed * 1.3) % size.width;
      final baseY = ((seed * 2.1) % size.height);

      final dx = math.sin(animationValue * 2 * math.pi + i * 0.6) * 10;
      final dy = math.cos(animationValue * 2 * math.pi + i * 1.1) * 7;

      final x = (baseX + dx) % size.width;
      final y = (baseY + dy) % size.height;

      final radius = 0.8 + (i % 4) * 0.6;
      final opacity = 0.02 + (i % 6) * 0.008;

      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RoomParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
