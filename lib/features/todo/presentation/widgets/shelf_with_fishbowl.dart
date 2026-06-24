import 'package:flutter/material.dart';
import 'fish_bowl_widget.dart';

class ShelfWithFishbowl extends StatelessWidget {
  const ShelfWithFishbowl({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            top: 0,
            child: const FishBowlWidget(size: 200),
          ),
          CustomPaint(
            size: const Size(double.infinity, 16),
            painter: _ShelfPainter(),
          ),
        ],
      ),
    );
  }
}

class _ShelfPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shelfPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF5D4037),
          const Color(0xFF3E2723),
          const Color(0xFF2C1A12),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final shelfPath = Path()
      ..moveTo(0, 4)
      ..lineTo(size.width, 4)
      ..lineTo(size.width, 10)
      ..lineTo(0, 10)
      ..close();
    canvas.drawPath(shelfPath, shelfPaint);

    final topEdgePaint = Paint()
      ..color = const Color(0xFF795548).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, 4), Offset(size.width, 4), topEdgePaint);

    final bottomEdgePaint = Paint()
      ..color = const Color(0xFF1A0E0A).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, 10), Offset(size.width, 10), bottomEdgePaint);

    final bracketPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.fill;

    void drawBracket(double x) {
      final bracketPath = Path()
        ..moveTo(x - 8, 6)
        ..lineTo(x - 8, 16)
        ..lineTo(x - 6, 16)
        ..lineTo(x - 6, 8)
        ..lineTo(x + 6, 8)
        ..lineTo(x + 6, 16)
        ..lineTo(x + 8, 16)
        ..lineTo(x + 8, 6)
        ..close();
      canvas.drawPath(bracketPath, bracketPaint);
    }

    drawBracket(size.width * 0.2);
    drawBracket(size.width * 0.5);
    drawBracket(size.width * 0.8);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRect(
      Rect.fromLTWH(0, 11, size.width, 5),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
