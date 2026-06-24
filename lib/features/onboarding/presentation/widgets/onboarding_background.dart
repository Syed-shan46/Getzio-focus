import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Shared animated background for all onboarding screens.
/// Dark gradient with subtle warm lighting and floating particles.
class OnboardingBackground extends StatefulWidget {
  final Widget child;

  const OnboardingBackground({super.key, required this.child});

  @override
  State<OnboardingBackground> createState() => _OnboardingBackgroundState();
}

class _OnboardingBackgroundState extends State<OnboardingBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
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
        // Base gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0A0E1A),
                  Color(0xFF050816),
                  Color(0xFF000000),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Warm ambient light (top-center)
        Positioned(
          top: -80,
          left: 0,
          right: 0,
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [
                  const Color(0xFF1A1440).withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Subtle accent glow (bottom-right)
        Positioned(
          bottom: -100,
          right: -60,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentBlue.withValues(alpha: 0.04),
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
                painter: _ParticlePainter(
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

class _ParticlePainter extends CustomPainter {
  final double animationValue;

  _ParticlePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Generate deterministic particles
    const particleCount = 15;
    for (int i = 0; i < particleCount; i++) {
      final seed = i * 137.508; // golden angle
      final baseX = (seed % size.width);
      final baseY = ((seed * 1.7) % size.height);

      // Gentle floating motion
      final dx = math.sin(animationValue * 2 * math.pi + i * 0.8) * 8;
      final dy = math.cos(animationValue * 2 * math.pi + i * 1.2) * 6;

      final x = (baseX + dx) % size.width;
      final y = (baseY + dy) % size.height;

      final radius = 1.0 + (i % 3) * 0.5;
      final opacity = 0.03 + (i % 5) * 0.01;

      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
