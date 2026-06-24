import 'dart:math' as math;
import 'package:flutter/material.dart';

class WorkspaceShelf extends StatelessWidget {
  final String title;
  final String woodTexture;
  final Widget child;

  const WorkspaceShelf({
    super.key,
    required this.title,
    required this.woodTexture,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final woodColors = _getWoodColors(woodTexture);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Content container sitting on top of the shelf
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ),
        const SizedBox(height: 6),
        // Wooden Plank with grain painter, bevels, and shadows
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          height: 18,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Backing Wall Drop Shadow
              Positioned(
                top: 14,
                left: 10,
                right: 10,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.65),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Beveled Wood Plank body
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [woodColors.lightColor, woodColors.darkColor],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                      bottom: Radius.circular(10),
                    ),
                    border: Border.all(
                      color: woodColors.lightColor.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                      bottom: Radius.circular(10),
                    ),
                    child: CustomPaint(
                      painter: WoodGrainPainter(woodColors: woodColors),
                    ),
                  ),
                ),
              ),

              // 3. Highlight line on top edge for realistic depth
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 1.5,
                child: Container(
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),

              // 4. Subtle metal/brass plaque mounting on the front center
              Positioned(
                top: 4,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getPlaqueColors(woodTexture),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36), // Spacing between shelves
      ],
    );
  }

  _WoodColors _getWoodColors(String texture) {
    switch (texture) {
      case 'Oak':
        return _WoodColors(
          lightColor: const Color(0xFFD7CCC8),
          mediumColor: const Color(0xFFBCAAA4),
          darkColor: const Color(0xFF8D6E63),
          grainColor: const Color(0xFF5D4037).withValues(alpha: 0.18),
        );
      case 'Mahogany':
        return _WoodColors(
          lightColor: const Color(0xFF8D6E63),
          mediumColor: const Color(0xFF5D4037),
          darkColor: const Color(0xFF3E2723),
          grainColor: const Color(0xFF270F0A).withValues(alpha: 0.3),
        );
      case 'Walnut':
      default:
        return _WoodColors(
          lightColor: const Color(0xFF5D4037),
          mediumColor: const Color(0xFF4E342E),
          darkColor: const Color(0xFF2D1510),
          grainColor: const Color(0xFF1B0703).withValues(alpha: 0.4),
        );
    }
  }

  List<Color> _getPlaqueColors(String texture) {
    if (texture == 'Oak') {
      // Silver/steel look for Oak
      return [
        const Color(0xFFCFD8DC),
        const Color(0xFFECEFF1),
        const Color(0xFF90A4AE),
      ];
    } else {
      // Brass/gold look for Walnut and Mahogany
      return [
        const Color(0xFFFFD54F),
        const Color(0xFFFFF9C4),
        const Color(0xFFFFB300),
      ];
    }
  }
}

class _WoodColors {
  final Color lightColor;
  final Color mediumColor;
  final Color darkColor;
  final Color grainColor;

  _WoodColors({
    required this.lightColor,
    required this.mediumColor,
    required this.darkColor,
    required this.grainColor,
  });
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CUSTOM WOOD GRAIN PAINTER
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class WoodGrainPainter extends CustomPainter {
  final _WoodColors woodColors;

  WoodGrainPainter({required this.woodColors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = woodColors.grainColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Draw horizontal organic grain curves
    final random = math.Random(12345); // Seeded for consistency
    final numLines = 6;

    for (int i = 0; i < numLines; i++) {
      final path = Path();
      double startY = (size.height / (numLines + 1)) * (i + 1);
      path.moveTo(0, startY);

      // Create a nice wavy Bezier line
      final controlPoint1X = size.width * 0.25;
      final controlPoint1Y = startY + (random.nextDouble() * 6 - 3);
      final controlPoint2X = size.width * 0.75;
      final controlPoint2Y = startY + (random.nextDouble() * 6 - 3);
      final endX = size.width;
      final endY = startY + (random.nextDouble() * 4 - 2);

      path.cubicTo(controlPoint1X, controlPoint1Y, controlPoint2X, controlPoint2Y, endX, endY);
      canvas.drawPath(path, paint);
    }

    // Add some knots or swirls
    final knotPaint = Paint()
      ..color = woodColors.grainColor.withValues(alpha: woodColors.grainColor.a * 0.7)
      ..style = PaintingStyle.fill;

    // A small horizontal knot on the right side
    final knotX = size.width * 0.8;
    final knotY = size.height * 0.45;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(knotX, knotY), width: 12, height: 4),
      knotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
