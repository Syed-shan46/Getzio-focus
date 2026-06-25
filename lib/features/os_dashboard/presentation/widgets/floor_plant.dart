import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class FloorPlant extends StatefulWidget {
  final String plantType; // 'Monstera', 'Snake Plant', 'Fiddle Leaf'
  final double scale;
  const FloorPlant({super.key, this.plantType = 'Monstera', this.scale = 1.0});

  @override
  State<FloorPlant> createState() => _FloorPlantState();
}

class _FloorPlantState extends State<FloorPlant> with SingleTickerProviderStateMixin {
  late AnimationController _swayController;

  @override
  void initState() {
    super.initState();
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _swayController,
      builder: (context, child) {
        final double swayAngle = math.sin(_swayController.value * 2 * math.pi) * 0.02;
        return CustomPaint(
          size: Size(160 * widget.scale, 240 * widget.scale),
          painter: _FloorPlantPainter(
            sway: swayAngle,
            plantType: widget.plantType,
            scale: widget.scale,
          ),
        );
      },
    );
  }
}

class _FloorPlantPainter extends CustomPainter {
  final double sway;
  final String plantType;
  final double scale;

  _FloorPlantPainter({required this.sway, required this.plantType, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(scale);

    final double w = 160.0;
    final double h = 240.0;

    // Pot Geometry
    final double potW = 56.0;
    final double potH = 46.0;
    final Offset potCenter = Offset(w / 2, h - potH / 2 - 8);

    // 1. Soft Floor Shadow (Occlusion + Projection)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    // Large ambient shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(potCenter.dx + 4, h - 8),
        width: potW * 1.5,
        height: 12,
      ),
      shadowPaint,
    );

    // Dark contact shadow directly under the pot
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(potCenter.dx, h - 8),
        width: potW * 1.1,
        height: 6,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // 2. Draw Stems & Leaves (with sway rotation around the pot base)
    final baseOrigin = Offset(w / 2, h - potH - 8);
    canvas.save();
    canvas.translate(baseOrigin.dx, baseOrigin.dy);
    canvas.rotate(sway);
    canvas.translate(-baseOrigin.dx, -baseOrigin.dy);

    if (plantType == 'Coconut Tree') {
      _drawCoconutTree(canvas, w, h, baseOrigin);
    } else {
      _drawStemsAndLeaves(canvas, w, h, baseOrigin);
    }

    canvas.restore();

    // 3. Draw Premium 3D Ceramic/Terracotta Pot
    // Soil
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(potCenter.dx, potCenter.dy - potH / 2),
        width: potW * 0.94,
        height: 10,
      ),
      Paint()..color = const Color(0xFF2D1E18),
    );

    // Pot Body (Gradient for cylindrical dark grey/black shading matching picture)
    final potPaint = Paint()
      ..shader = LinearGradient(
        colors: const [
          Color(0xFF424953), // Highlight side (grey)
          Color(0xFF2C3037), // Mid body (dark charcoal)
          Color(0xFF1B1E22), // Shadow side (matte black)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCenter(center: potCenter, width: potW, height: potH));

    final potPath = Path()
      ..moveTo(potCenter.dx - potW / 2, potCenter.dy - potH / 2)
      ..lineTo(potCenter.dx + potW / 2, potCenter.dy - potH / 2)
      ..lineTo(potCenter.dx + potW * 0.38, potCenter.dy + potH / 2)
      ..lineTo(potCenter.dx - potW * 0.38, potCenter.dy + potH / 2)
      ..close();
    canvas.drawPath(potPath, potPaint);

    // Lip/Rim of the Pot
    final rimRect = Rect.fromCenter(
      center: Offset(potCenter.dx, potCenter.dy - potH / 2),
      width: potW * 1.06,
      height: 6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rimRect, const Radius.circular(3)),
      Paint()
        ..shader = LinearGradient(
          colors: const [
            Color(0xFF555E6B),
            Color(0xFF2C3037),
            Color(0xFF141619),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rimRect),
    );

    // Subtle 3D Highlight reflection on the left rim
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(potCenter.dx - potW * 0.3, potCenter.dy - potH / 2 + 1),
        width: 10,
        height: 2,
      ),
      highlightPaint,
    );
    canvas.restore();
  }

  void _drawStemsAndLeaves(Canvas canvas, double w, double h, Offset origin) {
    final stemPaint = Paint()
      ..color = const Color(0xFF1E3A20)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final leafBasePaint = Paint()
      ..style = PaintingStyle.fill;

    // Define Stems (X, Y control points and final leaves)
    final List<Map<String, dynamic>> leaves = [
      // Format: {endOffset, controlOffset, leafAngle, leafScale, isDarkBackground}
      // Back/Bottom layer leaves
      {
        'end': Offset(origin.dx - 48, origin.dy - 65),
        'ctrl': Offset(origin.dx - 30, origin.dy - 30),
        'angle': -math.pi / 3,
        'scale': 1.1,
        'color': const Color(0xFF1B4322),
      },
      {
        'end': Offset(origin.dx + 48, origin.dy - 55),
        'ctrl': Offset(origin.dx + 25, origin.dy - 25),
        'angle': math.pi / 2.8,
        'scale': 1.05,
        'color': const Color(0xFF15381B),
      },
      // Mid layer leaves
      {
        'end': Offset(origin.dx - 30, origin.dy - 120),
        'ctrl': Offset(origin.dx - 20, origin.dy - 60),
        'angle': -math.pi / 6,
        'scale': 1.3,
        'color': const Color(0xFF2E6334),
      },
      {
        'end': Offset(origin.dx + 35, origin.dy - 110),
        'ctrl': Offset(origin.dx + 18, origin.dy - 55),
        'angle': math.pi / 5.5,
        'scale': 1.25,
        'color': const Color(0xFF2A5C30),
      },
      // Front foreground layer leaves (overlapping pot slightly)
      {
        'end': Offset(origin.dx - 12, origin.dy - 150),
        'ctrl': Offset(origin.dx - 4, origin.dy - 75),
        'angle': -math.pi / 14,
        'scale': 1.45,
        'color': const Color(0xFF3B7A43),
      },
      {
        'end': Offset(origin.dx + 12, origin.dy - 145),
        'ctrl': Offset(origin.dx + 4, origin.dy - 70),
        'angle': math.pi / 16,
        'scale': 1.4,
        'color': const Color(0xFF35703C),
      },
      {
        'end': Offset(origin.dx - 55, origin.dy - 20),
        'ctrl': Offset(origin.dx - 35, origin.dy - 10),
        'angle': -math.pi / 2.1,
        'scale': 0.95,
        'color': const Color(0xFF27542D),
      },
      {
        'end': Offset(origin.dx + 52, origin.dy - 15),
        'ctrl': Offset(origin.dx + 32, origin.dy - 8),
        'angle': math.pi / 2.1,
        'scale': 0.9,
        'color': const Color(0xFF234B28),
      },
    ];

    for (var leaf in leaves) {
      final Offset end = leaf['end'];
      final Offset ctrl = leaf['ctrl'];
      final double angle = leaf['angle'];
      final double scale = leaf['scale'];
      final Color color = leaf['color'];

      // Draw Stem
      final path = Path()
        ..moveTo(origin.dx, origin.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.ctrlY(ctrl.dy), end.dx, end.dy);
      canvas.drawPath(path, stemPaint);

      // Draw Monstera Leaf
      canvas.save();
      canvas.translate(end.dx, end.dy);
      canvas.rotate(angle);
      canvas.scale(scale);

      _drawMonsteraLeafShape(canvas, color);

      canvas.restore();
    }
  }

  void _drawMonsteraLeafShape(Canvas canvas, Color color) {
    const double leafW = 28.0;
    const double leafH = 42.0;

    final leafPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Heart/Shield base path
    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(-leafW * 0.85, -leafH * 0.3, -leafW * 0.95, -leafH * 0.8, 0, -leafH)
      ..cubicTo(leafW * 0.95, -leafH * 0.8, leafW * 0.85, -leafH * 0.3, 0, 0)
      ..close();
    canvas.drawPath(path, leafPaint);

    // Draw central leaf vein
    final veinPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, 0), const Offset(0, -leafH * 0.92), veinPaint);

    // Swiss Cheese/Monstera splits (negative spaces in the leaf)
    final bgPaint = Paint()..color = const Color(0xFF071220); // matching wall background
    final splitPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    // Left slits
    canvas.drawLine(Offset(-leafW * 0.55, -leafH * 0.5), Offset(-leafW * 0.15, -leafH * 0.42), splitPaint);
    canvas.drawLine(Offset(-leafW * 0.65, -leafH * 0.68), Offset(-leafW * 0.2, -leafH * 0.58), splitPaint);
    canvas.drawLine(Offset(-leafW * 0.45, -leafH * 0.82), Offset(-leafW * 0.15, -leafH * 0.72), splitPaint);

    // Right slits
    canvas.drawLine(Offset(leafW * 0.55, -leafH * 0.48), Offset(leafW * 0.15, -leafH * 0.4), splitPaint);
    canvas.drawLine(Offset(leafW * 0.65, -leafH * 0.65), Offset(leafW * 0.2, -leafH * 0.55), splitPaint);
    canvas.drawLine(Offset(leafW * 0.45, -leafH * 0.8), Offset(leafW * 0.15, -leafH * 0.7), splitPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void _drawCoconutTree(Canvas canvas, double w, double h, Offset origin) {
    // 1. Partially buried coconut seed in soil
    final seedPaint = Paint()..color = const Color(0xFF3E2723);
    canvas.drawOval(
      Rect.fromCenter(center: origin - const Offset(2, 6), width: 14, height: 10),
      seedPaint,
    );

    // 2. Main stem/trunk (amber-orange/golden-yellow from the picture)
    final stemPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFB300), Color(0xFFE65100)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(origin.dx - 4, origin.dy - 65, 8, 65))
      ..strokeWidth = 3.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final trunkPath = Path()
      ..moveTo(origin.dx, origin.dy - 4)
      ..quadraticBezierTo(origin.dx - 3, origin.dy - 35, origin.dx - 1, origin.dy - 65);
    canvas.drawPath(trunkPath, stemPaint);

    final Offset canopyCenter = Offset(origin.dx - 1, origin.dy - 65);

    // 3. Sprouting Golden-orange midribs curving outwards
    final List<Map<String, dynamic>> fronds = [
      // {angle, length, curveY, color}
      {'angle': -math.pi * 0.78, 'length': 105.0, 'cy': -18.0, 'color': const Color(0xFF1B5E20)}, // Left low
      {'angle': -math.pi * 0.64, 'length': 130.0, 'cy': -30.0, 'color': const Color(0xFF2E7D32)}, // Left high
      {'angle': -math.pi * 0.50, 'length': 145.0, 'cy': -38.0, 'color': const Color(0xFF4CAF50)}, // Center vertical
      {'angle': -math.pi * 0.36, 'length': 130.0, 'cy': -30.0, 'color': const Color(0xFF2E7D32)}, // Right high
      {'angle': -math.pi * 0.22, 'length': 105.0, 'cy': -18.0, 'color': const Color(0xFF1B5E20)}, // Right low
    ];

    final leafletPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (var frond in fronds) {
      final double angle = frond['angle'] as double;
      final double length = frond['length'] as double;
      final double cy = frond['cy'] as double;
      final Color leafColor = frond['color'] as Color;

      canvas.save();
      canvas.translate(canopyCenter.dx, canopyCenter.dy);
      canvas.rotate(angle);

      // Draw the golden-orange midrib path (comb spine)
      final Paint midribPaint = Paint()
        ..color = const Color(0xFFFFB300)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      
      final frondPath = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(length * 0.45, cy * 0.35, length, 0);
      canvas.drawPath(frondPath, midribPaint);

      // Draw fine combed leaflets pointing out to both sides
      leafletPaint.color = leafColor;
      for (int i = 12; i < length; i += 3) {
        final double t = i / length;
        final double lx = t * length;
        final double ly = 2 * (1 - t) * t * (cy * 0.35);

        // Comb length peaks in middle, tapers to leaf tip
        final double leafletLen = 26.0 * math.sin(t * math.pi) * (0.8 + 0.35 * t);

        // Side 1 (pointing outwards-downwards)
        final double leafletAngle1 = 0.52 + 0.28 * t;
        canvas.drawLine(
          Offset(lx, ly),
          Offset(lx + math.cos(leafletAngle1) * leafletLen * 0.9, ly + math.sin(leafletAngle1) * leafletLen),
          leafletPaint,
        );

        // Side 2 (pointing outwards-upwards)
        final double leafletAngle2 = -0.52 - 0.28 * t;
        canvas.drawLine(
          Offset(lx, ly),
          Offset(lx + math.cos(leafletAngle2) * leafletLen * 0.9, ly + math.sin(leafletAngle2) * leafletLen),
          leafletPaint,
        );
      }

      canvas.restore();
    }
  }
}

extension on Offset {
  double ctrlY(double dy) => dy;
}
