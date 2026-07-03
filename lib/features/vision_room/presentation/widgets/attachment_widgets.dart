import 'package:flutter/material.dart';

class PushPinWidget extends StatelessWidget {
  final String style; // 'red', 'blue', 'black', 'gold', 'silver', 'wooden', 'transparent'
  
  const PushPinWidget({super.key, this.style = 'red'});

  @override
  Widget build(BuildContext context) {
    Color primaryColor;
    Color highlightColor;
    
    final normalized = style.replaceAll('Pin', '').toLowerCase();
    
    switch (normalized) {
      case 'blue':
        primaryColor = const Color(0xFF1D4ED8);
        highlightColor = const Color(0xFF93C5FD);
        break;
      case 'black':
        primaryColor = const Color(0xFF1E293B);
        highlightColor = const Color(0xFF94A3B8);
        break;
      case 'gold':
      case 'brass':
      case 'luxurybrass':
      case 'green':
      case 'emerald':
        primaryColor = const Color(0xFF047857); // Premium Emerald Green
        highlightColor = const Color(0xFF6EE7B7); // Glassy light green
        break;
      case 'silver':
        primaryColor = Colors.grey.shade600;
        highlightColor = Colors.grey.shade200;
        break;
      case 'wood':
      case 'wooden':
        primaryColor = const Color(0xFF8D6E63);
        highlightColor = const Color(0xFFD7CCC8);
        break;
      case 'transparent':
        primaryColor = Colors.white.withValues(alpha: 0.25);
        highlightColor = Colors.white.withValues(alpha: 0.7);
        break;
      case 'red':
      default:
        primaryColor = const Color(0xFFB91C1C);
        highlightColor = const Color(0xFFFCA5A5);
        break;
    }

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.003) // Perspective distortion
        ..rotateX(-0.25) // Tilt forward
        ..rotateY(0.08), // Slight angle
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: 24,
        height: 36,
        child: CustomPaint(
          painter: _PushPinPainter(primaryColor, highlightColor),
        ),
      ),
    );
  }
}

class _PushPinPainter extends CustomPainter {
  final Color color;
  final Color highlight;

  _PushPinPainter(this.color, this.highlight);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    
    // Position of the sphere center (resting flush on the paper)
    final Offset sphereCenter = Offset(w / 2, h - 14);
    final double sphereRadius = w / 2.2;

    // 1. Draw Drop Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    
    canvas.drawCircle(Offset(sphereCenter.dx + 2.0, sphereCenter.dy + 3.5), sphereRadius, shadowPaint);

    // 2. Draw 3D Spherical Head (Radial gradient for depth)
    final Rect sphereRect = Rect.fromCircle(center: sphereCenter, radius: sphereRadius);
    final spherePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFECFDF5), // Bright glassy glint center
          highlight,              // Mid highlight
          color,                  // Body color
          color.withValues(alpha: 0.8), // Darker edge shade
        ],
        stops: const [0.0, 0.25, 0.75, 1.0],
        center: const Alignment(-0.35, -0.35),
        radius: 0.9,
      ).createShader(sphereRect);
    
    canvas.drawCircle(sphereCenter, sphereRadius, spherePaint);

    // 3. Specular reflection dot (glint) for high-gloss glass look
    final glintPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(sphereCenter.dx - 2.5, sphereCenter.dy - 2.5),
        width: 3.0,
        height: 2.0,
      ),
      glintPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TapeWidget extends StatelessWidget {
  final String style; // 'washi', 'transparent', 'beige'
  
  const TapeWidget({super.key, this.style = 'beige'});

  @override
  Widget build(BuildContext context) {
    Color tapeColor;
    double tapeOpacity;

    switch (style) {
      case 'transparent':
        tapeColor = Colors.white;
        tapeOpacity = 0.3;
        break;
      case 'washi':
        tapeColor = Colors.pink.shade200; // Mock Washi
        tapeOpacity = 0.85;
        break;
      case 'beige':
      default:
        tapeColor = const Color(0xFFE3D5C8);
        tapeOpacity = 0.9;
        break;
    }

    return Transform.rotate(
      angle: -0.15,
      child: Container(
        width: 48,
        height: 14,
        decoration: BoxDecoration(
          color: tapeColor.withValues(alpha: tapeOpacity),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: CustomPaint(
          painter: _TapeTornEdgesPainter(tapeColor.withValues(alpha: tapeOpacity)),
        ),
      ),
    );
  }
}

class _TapeTornEdgesPainter extends CustomPainter {
  final Color color;
  _TapeTornEdgesPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // Torn edge effect placeholder
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
