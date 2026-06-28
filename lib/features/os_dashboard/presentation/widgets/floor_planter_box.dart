import 'package:flutter/material.dart';

class FloorPlanterBox extends StatelessWidget {
  final double scale;
  const FloorPlanterBox({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(280 * scale, 95 * scale),
      painter: _FloorPlanterPainter(scale: scale),
    );
  }
}

class _FloorPlanterPainter extends CustomPainter {
  final double scale;
  _FloorPlanterPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(scale);

    final double w = 280.0;
    final double h = 95.0;

    // Planter box geometry (Double width concrete trough)
    final double boxW = 230.0;
    final double boxH = 24.0;
    final Offset boxCenter = Offset(w / 2, h - boxH / 2 - 4);

    // 1. Soft Floor Shadow under the planter box
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(boxCenter.dx, h - 4),
        width: boxW * 1.15,
        height: 8,
      ),
      shadowPaint,
    );

    // 2. Draw 5 Spaced-Out Plants inside the box
    final Offset baseOrigin = Offset(w / 2, h - boxH - 4);

    // Plant 1: Tall Snake Plant 1 (far left, offset -78)
    _drawSnakePlant(canvas, baseOrigin + const Offset(-78, 4), 48.0, 7.5, -3.5);

    // Plant 2: Variegated Calathea (mid-left, offset -38)
    _drawCalatheaPlant(canvas, baseOrigin + const Offset(-38, 4));

    // Plant 3: Lush Feathery Fern (middle, offset 2)
    _drawFernPlant(canvas, baseOrigin + const Offset(2, 4));

    // Plant 4: Snake Plant 2 (mid-right, offset 42)
    _drawSnakePlant(canvas, baseOrigin + const Offset(42, 4), 40.0, 6.5, 2.8);

    // Plant 5: Flowering Red Anthurium (far right, offset 80)
    _drawAnthurium(canvas, baseOrigin + const Offset(80, 4));

    // 3. Draw Planter Box Container (Concrete trough)
    final boxPaint = Paint()
      ..shader = LinearGradient(
        colors: const [
          Color(0xFFE0E0E0), // Concrete light grey
          Color(0xFFBDBDBD), // Concrete mid grey
          Color(0xFF9E9E9E), // Shadow side
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCenter(center: boxCenter, width: boxW, height: boxH));

    final RRect rbox = RRect.fromRectAndRadius(
      Rect.fromCenter(center: boxCenter, width: boxW, height: boxH),
      const Radius.circular(4),
    );
    canvas.drawRRect(rbox, boxPaint);

    // Soil layer inside the rim
    canvas.drawRect(
      Rect.fromLTRB(boxCenter.dx - boxW / 2 + 2, boxCenter.dy - boxH / 2, boxCenter.dx + boxW / 2 - 2, boxCenter.dy - boxH / 2 + 3),
      Paint()..color = const Color(0xFF2C1C16),
    );

    // Rim highlight line
    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rbox, rimPaint);

    canvas.restore();
  }

  void _drawSnakePlant(Canvas canvas, Offset origin, double baseHeight, double baseWidth, double baseCurve) {
    // Spiky leaves with yellow borders and green centers
    final borderPaint = Paint()..style = PaintingStyle.fill;
    final centerPaint = Paint()..style = PaintingStyle.fill;

    void drawSpike(Offset base, double height, double width, double curveX) {
      final Path path = Path()
        ..moveTo(base.dx - width / 2, base.dy)
        ..quadraticBezierTo(base.dx + curveX, base.dy - height * 0.5, base.dx + curveX, base.dy - height)
        ..quadraticBezierTo(base.dx + curveX + width * 0.2, base.dy - height * 0.4, base.dx + width / 2, base.dy)
        ..close();

      // Yellow border
      borderPaint.color = const Color(0xFFD4E157);
      canvas.drawPath(path, borderPaint);

      // Inner green center
      final Path innerPath = Path()
        ..moveTo(base.dx - width * 0.3, base.dy)
        ..quadraticBezierTo(base.dx + curveX, base.dy - height * 0.48, base.dx + curveX, base.dy - height * 0.92)
        ..quadraticBezierTo(base.dx + curveX + width * 0.1, base.dy - height * 0.38, base.dx + width * 0.3, base.dy)
        ..close();
      centerPaint.color = const Color(0xFF1B5E20);
      canvas.drawPath(innerPath, centerPaint);

      // Variegation stripes
      final stripePaint = Paint()
        ..color = const Color(0xFF81C784).withValues(alpha: 0.35)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      for (double yRatio = 0.15; yRatio < 0.85; yRatio += 0.15) {
        final double cy = base.dy - height * yRatio;
        final double cx = base.dx + curveX * yRatio;
        final double wAtY = width * 0.32 * (1.0 - yRatio * 0.4);
        canvas.drawLine(Offset(cx - wAtY, cy), Offset(cx + wAtY, cy), stripePaint);
      }
    }

    drawSpike(origin + const Offset(-5, 0), baseHeight * 0.85, baseWidth * 0.85, baseCurve - 1.0);
    drawSpike(origin, baseHeight, baseWidth, baseCurve);
    drawSpike(origin + const Offset(5, 0), baseHeight * 0.72, baseWidth * 0.78, baseCurve + 1.2);
  }

  void _drawCalatheaPlant(Canvas canvas, Offset origin) {
    // Beautiful variegated round leaves
    final leafPaint = Paint()..style = PaintingStyle.fill;

    void drawLeaf(Offset base, double angle, double width, double height, Color baseColor, Color highlightColor) {
      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(angle);

      // Stem
      canvas.drawLine(Offset.zero, Offset(0, -height * 0.4), Paint()..color = baseColor..strokeWidth = 1.2);

      // Leaf base shape
      final leafCenter = Offset(0, -height * 0.8);
      canvas.drawOval(
        Rect.fromCenter(center: leafCenter, width: width, height: height),
        leafPaint..color = baseColor,
      );

      // Leaf inner highlight variegation
      canvas.drawOval(
        Rect.fromCenter(center: leafCenter, width: width * 0.65, height: height * 0.72),
        leafPaint..color = highlightColor,
      );

      // Leaf center midrib (vein spine)
      final veinPaint = Paint()
        ..color = const Color(0xFFC8E6C9).withValues(alpha: 0.45)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(0, -height * 0.32),
        Offset(0, -height * 1.28),
        veinPaint,
      );

      // Lateral diagonal side veins
      for (double y = -height * 0.52; y >= -height * 1.08; y -= height * 0.18) {
        final double distToCenter = (y + height * 0.8).abs();
        final double sideOffset = (width * 0.3) * (1.0 - distToCenter / (height * 0.62));
        canvas.drawLine(Offset(0, y), Offset(sideOffset, y - 2.5), veinPaint);
        canvas.drawLine(Offset(0, y), Offset(-sideOffset, y - 2.5), veinPaint);
      }

      canvas.restore();
    }

    drawLeaf(origin + const Offset(-4, 0), -0.5, 11.0, 16.0, const Color(0xFF1B5E20), const Color(0xFF388E3C));
    drawLeaf(origin, 0.0, 13.0, 20.0, const Color(0xFF0F3A22), const Color(0xFF2E7D32));
    drawLeaf(origin + const Offset(4, 0), 0.5, 10.0, 15.0, const Color(0xFF1B5E20), const Color(0xFF4CAF50));
  }

  void _drawFernPlant(Canvas canvas, Offset origin) {
    // Fern leaves radiating out
    final leafPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;
    final stemPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    void drawFernFrond(Offset base, double angle, double length) {
      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(angle);

      // Stem
      canvas.drawLine(Offset.zero, Offset(0, -length), stemPaint);

      // Fern leaflets
      final int leaflets = 6;
      for (int i = 1; i <= leaflets; i++) {
        final double t = i / leaflets;
        final double y = -length * t;
        final double lWidth = (8.0 * (1.0 - t * 0.6)).clamp(3.0, 8.0);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(-lWidth / 2 - 1, y), width: lWidth, height: 3),
          leafPaint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(lWidth / 2 + 1, y), width: lWidth, height: 3),
          leafPaint,
        );
      }

      canvas.restore();
    }

    drawFernFrond(origin, -0.65, 28.0);
    drawFernFrond(origin, -0.22, 34.0);
    drawFernFrond(origin, 0.22, 32.0);
    drawFernFrond(origin, 0.65, 24.0);
  }

  void _drawAnthurium(Canvas canvas, Offset origin) {
    // 1. Dark green heart-shaped leaves
    final leafPaint = Paint()
      ..color = const Color(0xFF1F4D2B)
      ..style = PaintingStyle.fill;
    final stemPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 1.0;

    void drawHeartLeaf(Offset base, double angle, double scaleVal) {
      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(angle);
      canvas.scale(scaleVal);

      // stem
      canvas.drawLine(Offset.zero, const Offset(0, -12), stemPaint);

      // heart path
      final Path path = Path()
        ..moveTo(0, -12)
        ..cubicTo(-8, -18, -12, -8, 0, 0)
        ..cubicTo(12, -8, 8, -18, 0, -12);
      canvas.drawPath(path, leafPaint);
      canvas.restore();
    }

    drawHeartLeaf(origin + const Offset(-6, 0), -0.4, 1.1);
    drawHeartLeaf(origin + const Offset(6, 0), 0.4, 0.9);

    // 2. Bright red spathe (flower bract) and yellow spadix
    final flowerPaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..style = PaintingStyle.fill;
    final spadixPaint = Paint()
      ..color = const Color(0xFFFFEB3B)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    void drawFlower(Offset base, double angle) {
      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(angle);

      // stem
      canvas.drawLine(Offset.zero, const Offset(0, -18), stemPaint);

      // heart-shaped red spathe
      final Path spathe = Path()
        ..moveTo(0, -18)
        ..cubicTo(-7, -23, -10, -14, 0, -8)
        ..cubicTo(10, -14, 7, -23, 0, -18);
      canvas.drawPath(spathe, flowerPaint);

      // yellow spadix stick pointing up-right
      canvas.drawLine(const Offset(0, -16), const Offset(2, -24), spadixPaint);

      canvas.restore();
    }

    drawFlower(origin, -0.15);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
