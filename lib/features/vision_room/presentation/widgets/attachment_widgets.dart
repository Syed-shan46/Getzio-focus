import 'package:flutter/material.dart';

class PushPinWidget extends StatelessWidget {
  final String style; // 'red', 'blue', 'black', 'gold', 'silver', 'wooden', 'transparent'
  
  const PushPinWidget({super.key, this.style = 'red'});

  @override
  Widget build(BuildContext context) {
    Color primaryColor;
    Color highlightColor;
    
    switch (style) {
      case 'blue':
        primaryColor = Colors.blue.shade700;
        highlightColor = Colors.blue.shade400;
        break;
      case 'black':
        primaryColor = Colors.black87;
        highlightColor = Colors.grey.shade700;
        break;
      case 'gold':
        primaryColor = const Color(0xFFD4AF37);
        highlightColor = const Color(0xFFF3E5AB);
        break;
      case 'silver':
        primaryColor = Colors.grey.shade400;
        highlightColor = Colors.grey.shade200;
        break;
      case 'red':
      default:
        primaryColor = Colors.red.shade700;
        highlightColor = Colors.red.shade400;
        break;
    }

    return SizedBox(
      width: 24,
      height: 36,
      child: CustomPaint(
        painter: _PushPinPainter(primaryColor, highlightColor),
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
    // 1. Draw Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    // Needle shadow
    canvas.drawLine(
      Offset(size.width / 2 + 1, size.height / 2 + 10),
      Offset(size.width / 2 + 3, size.height),
      shadowPaint..strokeWidth = 1,
    );
    
    // Head shadow
    canvas.drawCircle(Offset(size.width / 2 + 2, size.height / 3 + 2), size.width / 2.5, shadowPaint);

    // 2. Draw Needle
    final needlePaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2),
      Offset(size.width / 2, size.height),
      needlePaint,
    );

    // 3. Draw Pin Head (Plastic/Metal bulb)
    final headPaint = Paint()
      ..shader = RadialGradient(
        colors: [highlight, color, Colors.black87],
        stops: const [0.0, 0.6, 1.0],
        center: const Alignment(-0.3, -0.3),
        radius: 0.8,
      ).createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height / 3), radius: size.width / 2.5));

    canvas.drawCircle(Offset(size.width / 2, size.height / 3), size.width / 2.5, headPaint);
    
    // Specular highlight dot
    final highlightPaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width / 2 - 3, size.height / 3 - 3), width: 4, height: 2),
      highlightPaint,
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
        width: 80,
        height: 24,
        decoration: BoxDecoration(
          color: tapeColor.withValues(alpha: tapeOpacity),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, 2),
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
