import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A premium hanging fountain pen that gently swings like a pendulum.
/// Tapping it opens the Vision Creation Sheet (no navigation).
class HangingPen extends StatefulWidget {
  final VoidCallback? onTap;

  const HangingPen({super.key, this.onTap});

  @override
  State<HangingPen> createState() => _HangingPenState();
}

class _HangingPenState extends State<HangingPen> with TickerProviderStateMixin {
  late AnimationController _pendulumController;
  late Animation<double> _pendulumAnimation;
  late AnimationController _idleController;
  late Animation<double> _idleSway;
  late AnimationController _tapController;
  late Animation<double> _tapScale;
  late Animation<double> _tapGlow;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    final rng = Random();
    final duration = 4.0 + rng.nextDouble() * 2.0;

    _pendulumController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (duration * 1000).round()),
    )..repeat(reverse: true);

    _pendulumAnimation = Tween<double>(begin: -0.035, end: 0.035).animate(
      CurvedAnimation(parent: _pendulumController, curve: Curves.easeInOut),
    );

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _idleSway = Tween<double>(begin: -0.002, end: 0.002).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _tapScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
    ]).animate(_tapController);

    _tapGlow = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 0.6,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.6,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_tapController);
  }

  @override
  void dispose() {
    _pendulumController.dispose();
    _idleController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _onPenTap() {
    if (_isAnimating) return;
    HapticFeedback.lightImpact();
    _isAnimating = true;
    _tapController.forward(from: 0.0).then((_) {
      _isAnimating = false;
    });

    // Open the creation sheet after a brief delay for the scale animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && widget.onTap != null) {
        widget.onTap!();
      }
    });
  }

  Widget _buildPenImage(double topPadding) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dynamic string length to clear safe area exactly without wasting space
        Container(
          width: 2,
          height: topPadding + 20, // Just clears the safe area
          decoration: BoxDecoration(
            color: Colors.brown.shade700,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 2,
                offset: const Offset(1, 0),
              ),
            ],
          ),
        ),
        // Small transparent container with border
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.transparent, // bg transparent
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.brown.shade800, // border needed
              width: 1.5,
            ),
          ),
          child: Text(
            'Focus',
            style: TextStyle(
              fontFamily: 'Kalam',
              fontWeight: FontWeight.bold,
              fontSize: 14, // Made text smaller
              color: Colors.brown.shade900,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -10, // Just enough off-screen to hide the top anchor
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _pendulumController,
                _idleController,
                _tapController,
              ]),
              builder: (context, _) {
                final angle = _pendulumAnimation.value + _idleSway.value;
                final scale = _tapScale.value;
                final glow = _tapGlow.value;

                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Soft glow behind pen (on tap)
                    if (glow > 0.01)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Transform.scale(
                            scale: 1.5,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(
                                      0xFFFBBF24,
                                    ).withValues(alpha: glow * 0.4),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Pen
                    Transform.rotate(
                      angle: angle,
                      alignment: Alignment.topCenter,
                      child: Transform.scale(
                        scale: scale,
                        child: GestureDetector(
                          onTap: _onPenTap,
                          behavior: HitTestBehavior.opaque,
                          child: _buildPenImage(
                            MediaQuery.paddingOf(context).top,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
