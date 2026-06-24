import 'dart:math';
import 'package:flutter/material.dart';

class FishBowlWidget extends StatefulWidget {
  final double size;

  const FishBowlWidget({super.key, this.size = 200});

  @override
  State<FishBowlWidget> createState() => _FishBowlWidgetState();
}

class _FishBowlWidgetState extends State<FishBowlWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Bubble> _bubbles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _bubbles = List.generate(8, (_) => _Bubble(_random));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size * 1.2,
          child: CustomPaint(
            painter: _FishBowlPainter(
              time: _controller.value,
              bubbles: _bubbles,
            ),
          ),
        );
      },
    );
  }
}

class _Bubble {
  final double x;
  final double startY;
  final double speed;
  final double size;
  final double phase;

  _Bubble(Random random)
      : x = 0.15 + random.nextDouble() * 0.7,
        startY = 0.6 + random.nextDouble() * 0.35,
        speed = 0.3 + random.nextDouble() * 0.7,
        size = 0.015 + random.nextDouble() * 0.025,
        phase = random.nextDouble() * 2 * pi;
}

class _FishBowlPainter extends CustomPainter {
  final double time;
  final List<_Bubble> bubbles;

  _FishBowlPainter({required this.time, required this.bubbles});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = size.width / 200;

    _drawWater(canvas, size, scale);
    _drawBowlGlass(canvas, cx, cy, scale, size);
    _drawGravel(canvas, size, scale);
    _drawPlant(canvas, size, scale);
    _drawBubbles(canvas, size);

    final fishX = cx + sin(time * 2 * pi) * 30 * scale;
    final fishY = cy + sin(time * 4 * pi) * 15 * scale;
    final bodyAngle = sin(time * 2 * pi) * 0.15;
    _drawFish(canvas, fishX, fishY, scale, time, bodyAngle);
  }

  void _drawWater(Canvas canvas, Size size, double scale) {
    final rect = Rect.fromLTWH(0, size.height * 0.08, size.width, size.height * 0.85);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blue.withValues(alpha: 0.08),
          Colors.blue.withValues(alpha: 0.15),
          Colors.blue.withValues(alpha: 0.12),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawBowlGlass(Canvas canvas, double cx, double cy, double scale, Size size) {
    final glassPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * scale
      ..color = Colors.white.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final bowlPath = Path()
      ..moveTo(cx - 75 * scale, cy - 5 * scale)
      ..quadraticBezierTo(
        cx - 85 * scale, cy - 65 * scale,
        cx - 50 * scale, cy - 85 * scale,
      )
      ..quadraticBezierTo(
        cx, cy - 95 * scale,
        cx + 50 * scale, cy - 85 * scale,
      )
      ..quadraticBezierTo(
        cx + 85 * scale, cy - 65 * scale,
        cx + 75 * scale, cy - 5 * scale,
      )
      ..lineTo(cx + 75 * scale, cy + 70 * scale)
      ..quadraticBezierTo(
        cx + 65 * scale, cy + 85 * scale,
        cx, cy + 90 * scale,
      )
      ..quadraticBezierTo(
        cx - 65 * scale, cy + 85 * scale,
        cx - 75 * scale, cy + 70 * scale,
      )
      ..close();

    canvas.drawPath(bowlPath, glassPaint);

    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale
      ..color = Colors.white.withValues(alpha: 0.15);
    final highlightPath = Path()
      ..moveTo(cx - 55 * scale, cy - 55 * scale)
      ..quadraticBezierTo(
        cx - 40 * scale, cy - 75 * scale,
        cx - 10 * scale, cy - 80 * scale,
      );
    canvas.drawPath(highlightPath, highlightPaint);
  }

  void _drawGravel(Canvas canvas, Size size, double scale) {
    final gravelPaint = Paint()..style = PaintingStyle.fill;
    final baseY = size.height * 0.77;

    for (int i = 0; i < 20; i++) {
      final gx = 15 * scale + i * 8 * scale + sin(i * 2.3) * 5 * scale;
      final gy = baseY + sin(i * 1.7) * 4 * scale;
      final gs = 3 * scale + sin(i * 3.1) * 1.5 * scale;
      final brightness = 0.25 + sin(i * 2.7) * 0.1;
      gravelPaint.color = Color.fromRGBO(
        (160 * brightness).toInt(),
        (120 * brightness).toInt(),
        (70 * brightness).toInt(),
        0.8,
      );
      canvas.drawCircle(Offset(gx, gy), gs, gravelPaint);
    }
  }

  void _drawPlant(Canvas canvas, Size size, double scale) {
    final plantPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale
      ..strokeCap = StrokeCap.round;

    final baseX = size.width * 0.8;
    final baseY = size.height * 0.75;

    for (int i = 0; i < 3; i++) {
      plantPaint.color = Color.fromRGBO(34, 120 + i * 20, 50, 0.7);
      final plantPath = Path();
      double px = baseX + i * 8 * scale;
      double py = baseY;
      plantPath.moveTo(px, py);
      for (int j = 0; j < 6; j++) {
        px += sin(j * 0.8 + time * 0.5 + i) * 6 * scale;
        py -= 12 * scale;
        plantPath.lineTo(px, py);
      }
      canvas.drawPath(plantPath, plantPaint);
    }
  }

  void _drawBubbles(Canvas canvas, Size size) {
    for (final bubble in bubbles) {
      final bx = bubble.x * size.width;
      final by = bubble.startY * size.height -
          (time * bubble.speed % 1.0) * size.height * 0.7;
      if (by < size.height * 0.1) continue;

      final wobble = sin(time * 4 * pi + bubble.phase) * 3;
      final bubblePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(bx + wobble, by),
        bubble.size * size.width,
        bubblePaint,
      );

      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(bx + wobble - bubble.size * size.width * 0.25,
            by - bubble.size * size.width * 0.25),
        bubble.size * size.width * 0.3,
        highlightPaint,
      );
    }
  }

  void _drawFish(Canvas canvas, double x, double y, double scale, double time, double bodyAngle) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(bodyAngle);

    final fishLength = 50 * scale;
    final fishHeight = 22 * scale;

    _drawTail(canvas, fishLength, fishHeight, time, scale);
    _drawDorsalFin(canvas, fishLength, fishHeight, time, scale);
    _drawPectoralFin(canvas, fishLength, fishHeight, time, scale);
    _drawBody(canvas, fishLength, fishHeight, scale);
    _drawEye(canvas, fishLength, fishHeight, scale);
    _drawGills(canvas, fishLength, fishHeight, scale);
    _drawScales(canvas, fishLength, fishHeight, scale);

    canvas.restore();
  }

  void _drawBody(Canvas canvas, double fishLength, double fishHeight, double scale) {
    final bodyPath = Path();
    final tipX = fishLength * 0.45;
    final snoutX = -fishLength * 0.5;

    bodyPath.moveTo(tipX, 0);
    bodyPath.cubicTo(
      tipX, -fishHeight * 0.4,
      fishLength * 0.2, -fishHeight * 0.5,
      0, -fishHeight * 0.5,
    );
    bodyPath.cubicTo(
      -fishLength * 0.2, -fishHeight * 0.5,
      -fishLength * 0.35, -fishHeight * 0.35,
      -fishLength * 0.4, -fishHeight * 0.15,
    );
    bodyPath.cubicTo(
      -fishLength * 0.45, -fishHeight * 0.08,
      snoutX, -fishHeight * 0.04,
      snoutX, 0,
    );
    bodyPath.cubicTo(
      snoutX, fishHeight * 0.04,
      -fishLength * 0.45, fishHeight * 0.08,
      -fishLength * 0.4, fishHeight * 0.15,
    );
    bodyPath.cubicTo(
      -fishLength * 0.35, fishHeight * 0.35,
      -fishLength * 0.2, fishHeight * 0.5,
      0, fishHeight * 0.5,
    );
    bodyPath.cubicTo(
      fishLength * 0.2, fishHeight * 0.5,
      tipX, fishHeight * 0.4,
      tipX, 0,
    );
    bodyPath.close();

    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.8,
        colors: [
          const Color(0xFFFF8A65),
          const Color(0xFFE64A19),
          const Color(0xFFBF360C),
          const Color(0xFF3E2723),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset.zero,
        width: fishLength * 1.2,
        height: fishHeight * 1.2,
      ));

    canvas.drawPath(bodyPath, bodyPaint);

    final bellyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFFFFCCBC).withValues(alpha: 0.3),
          const Color(0xFFFFAB91).withValues(alpha: 0.5),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(0, fishHeight * 0.3),
        width: fishLength * 0.6,
        height: fishHeight * 0.3,
      ));

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, fishHeight * 0.15),
        width: fishLength * 0.5,
        height: fishHeight * 0.4,
      ),
      bellyPaint,
    );
  }

  void _drawTail(Canvas canvas, double fishLength, double fishHeight, double time, double scale) {
    final tailWag = sin(time * 6 * pi) * 0.15;
    final tailX = fishLength * 0.45;

    final tailPath = Path()
      ..moveTo(tailX, 0)
      ..cubicTo(
        tailX + 12 * scale + tailWag * 8 * scale,
        -fishHeight * 0.3,
        tailX + 20 * scale + tailWag * 12 * scale,
        -fishHeight * 0.6,
        tailX + 10 * scale + tailWag * 10 * scale,
        -fishHeight * 0.7,
      )
      ..cubicTo(
        tailX + 5 * scale + tailWag * 5 * scale,
        -fishHeight * 0.5,
        tailX + 3 * scale,
        -fishHeight * 0.2,
        tailX,
        0,
      )
      ..cubicTo(
        tailX + 3 * scale,
        fishHeight * 0.2,
        tailX + 5 * scale + tailWag * 5 * scale,
        fishHeight * 0.5,
        tailX + 10 * scale + tailWag * 10 * scale,
        fishHeight * 0.7,
      )
      ..cubicTo(
        tailX + 20 * scale + tailWag * 12 * scale,
        fishHeight * 0.6,
        tailX + 12 * scale + tailWag * 8 * scale,
        fishHeight * 0.3,
        tailX,
        0,
      )
      ..close();

    final tailPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.3, 0),
        radius: 1,
        colors: [
          const Color(0xFFFF8A65),
          const Color(0xFFBF360C).withValues(alpha: 0.8),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(tailX + 8 * scale, 0),
        width: 30 * scale,
        height: fishHeight * 1.4,
      ));

    canvas.drawPath(tailPath, tailPaint);
  }

  void _drawDorsalFin(Canvas canvas, double fishLength, double fishHeight, double time, double scale) {
    final finWave = sin(time * 4 * pi) * 0.1;

    final dorsalPath = Path()
      ..moveTo(-fishLength * 0.15, -fishHeight * 0.45)
      ..cubicTo(
        -fishLength * 0.05 + finWave * 5 * scale,
        -fishHeight * 0.8,
        fishLength * 0.15 + finWave * 5 * scale,
        -fishHeight * 0.75,
        fishLength * 0.3,
        -fishHeight * 0.4,
      );

    final dorsalPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFF8A65).withValues(alpha: 0.6),
          const Color(0xFFBF360C).withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(0, -fishHeight * 0.6),
        width: fishLength * 0.5,
        height: fishHeight * 0.5,
      ));

    canvas.drawPath(
      dorsalPath..close(),
      dorsalPaint..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      dorsalPath,
      Paint()
        ..color = const Color(0xFFBF360C).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * scale,
    );
  }

  void _drawPectoralFin(Canvas canvas, double fishLength, double fishHeight, double time, double scale) {
    final finFlap = sin(time * 3 * pi) * 0.15;

    final pectPath = Path()
      ..moveTo(0, fishHeight * 0.2)
      ..cubicTo(
        -5 * scale,
        fishHeight * 0.4 + finFlap * 5 * scale,
        -15 * scale,
        fishHeight * 0.45 + finFlap * 5 * scale,
        -20 * scale,
        fishHeight * 0.35,
      )
      ..cubicTo(
        -15 * scale,
        fishHeight * 0.3,
        -5 * scale,
        fishHeight * 0.25,
        0,
        fishHeight * 0.2,
      )
      ..close();

    final pectPaint = Paint()
      ..color = const Color(0xFFFF8A65).withValues(alpha: 0.5);
    canvas.drawPath(pectPath, pectPaint);
  }

  void _drawEye(Canvas canvas, double fishLength, double fishHeight, double scale) {
    final eyeX = -fishLength * 0.33;
    final eyeY = -fishHeight * 0.08;

    canvas.drawCircle(
      Offset(eyeX, eyeY),
      4 * scale,
      Paint()..color = Colors.white,
    );

    canvas.drawCircle(
      Offset(eyeX + 1 * scale, eyeY),
      2.5 * scale,
      Paint()..color = const Color(0xFF1A1A2E),
    );

    canvas.drawCircle(
      Offset(eyeX + 1.5 * scale, eyeY - 0.5 * scale),
      1 * scale,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );

    final browPaint = Paint()
      ..color = const Color(0xFF3E2723).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(eyeX + 1 * scale, eyeY - 5 * scale),
        width: 8 * scale,
        height: 4 * scale,
      ),
      pi,
      pi,
      false,
      browPaint,
    );
  }

  void _drawGills(Canvas canvas, double fishLength, double fishHeight, double scale) {
    final gillPaint = Paint()
      ..color = const Color(0xFF3E2723).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * scale
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final gillPath = Path()
        ..moveTo(-fishLength * 0.2 + i * 3 * scale, -fishHeight * 0.1)
        ..quadraticBezierTo(
          -fishLength * 0.22 + i * 3 * scale,
          fishHeight * 0.02,
          -fishLength * 0.18 + i * 3 * scale,
          fishHeight * 0.15,
        );
      canvas.drawPath(gillPath, gillPaint);
    }
  }

  void _drawScales(Canvas canvas, double fishLength, double fishHeight, double scale) {
    final scalePaint = Paint()
      ..color = const Color(0xFFFFAB91).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 * scale;

    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 6; col++) {
        final sx = -fishLength * 0.3 + col * 9 * scale + (row % 2) * 4.5 * scale;
        final sy = -fishHeight * 0.35 + row * 7 * scale + fishHeight * 0.1;
        if (sx > fishLength * 0.3 || sy > fishHeight * 0.4 || sy < -fishHeight * 0.4) continue;
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(sx, sy),
            width: 6 * scale,
            height: 4 * scale,
          ),
          pi * 1.1,
          pi * 0.8,
          false,
          scalePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FishBowlPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
