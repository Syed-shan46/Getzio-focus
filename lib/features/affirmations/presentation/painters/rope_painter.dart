import 'dart:math';
import 'package:flutter/material.dart';

/// Paints the complete rope system for the hanging affirmation board.
///
/// The rope starts behind the wooden hook, forms an inverted V down to the
/// first board, passes through drilled holes in each board, and ends with
/// decorative knots and wooden beads below the last board.
///
/// Everything is drawn procedurally — thick twisted cotton rope with fibers,
/// soft highlights, dark inner grooves, natural thickness, and small
/// imperfections.
class RopeSystemPainter extends CustomPainter {
  /// Center X of the hook (where rope originates).
  final double hookCenterX;

  /// Y position of the hook bottom (where rope starts).
  final double hookBottomY;

  /// List of board rects (in the painter's coordinate space).
  /// Each rect represents a board's position and size.
  final List<Rect> boardRects;

  /// Horizontal offset of the left hole from the board's left edge.
  final double holeInset;

  /// Radius of the drilled holes.
  final double holeRadius;

  /// Rope thickness.
  final double thickness;

  /// Seed for deterministic randomness.
  final int seed;

  const RopeSystemPainter({
    required this.hookCenterX,
    required this.hookBottomY,
    required this.boardRects,
    this.holeInset = 28.0,
    this.holeRadius = 5.0,
    this.thickness = 5.0,
    this.seed = 42,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (boardRects.isEmpty) return;

    final rng = Random(seed);

    // ── Compute hole positions for each board ──────────────────────────────
    final leftHoles = <Offset>[];
    final rightHoles = <Offset>[];
    for (final rect in boardRects) {
      final cy = rect.center.dy;
      leftHoles.add(Offset(rect.left + holeInset, cy));
      rightHoles.add(Offset(rect.right - holeInset, cy));
    }

    // ── 1. Inverted V: hook → first board holes ───────────────────────────
    final hookOrigin = Offset(hookCenterX, hookBottomY);
    _drawRopeSegment(
      canvas,
      hookOrigin,
      leftHoles.first,
      thickness,
      rng,
      sagAmount: 4,
    );
    _drawRopeSegment(
      canvas,
      hookOrigin,
      rightHoles.first,
      thickness,
      rng,
      sagAmount: 4,
    );

    // ── 2. Rope between boards (left and right strands) ───────────────────
    for (int i = 0; i < boardRects.length - 1; i++) {
      // Left strand
      _drawRopeSegment(
        canvas,
        leftHoles[i],
        leftHoles[i + 1],
        thickness,
        rng,
        sagAmount: 3,
      );
      // Right strand
      _drawRopeSegment(
        canvas,
        rightHoles[i],
        rightHoles[i + 1],
        thickness,
        rng,
        sagAmount: 3,
      );
    }
  }

  /// Draws a single rope segment between two points with natural sag,
  /// twisted jute texture, highlights, and grooves.
  void _drawRopeSegment(
    Canvas canvas,
    Offset start,
    Offset end,
    double thickness,
    Random rng, {
    double sagAmount = 0.0,
  }) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = sqrt(dx * dx + dy * dy);
    if (length < 1) return;

    final double ropeAngle = atan2(dy, dx);

    // ── 1. Draw a soft, blurred drop shadow of the straight rope ──
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness + 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start + const Offset(2.0, 4.0), end + const Offset(2.0, 4.0), shadowPaint);

    // ── 2. Draw overlapping 3D ovals along the straight line ──
    final stepDistance = thickness * 0.45; // step size controls twist tightness
    final steps = (length / stepDistance).ceil();

    final strandPaint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final p = start + Offset(dx * t, dy * t);

      // Add a slight thickness variation wave along the rope
      final localThickness = thickness * (1.0 + 0.06 * sin(i * 0.2 + seed));

      canvas.save();
      canvas.translate(p.dx, p.dy);
      // Rotate to match the rope direction + the helical strand tilt (32 degrees)
      canvas.rotate(ropeAngle + 0.55);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: localThickness * 1.05,
        height: localThickness * 0.55,
      );

      // Create a 3D cylindrical gradient for the strand
      final strandShader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFEADBCE), // Highlight
          const Color(0xFFC2A684), // Jute golden tan
          const Color(0xFF7A6045), // Jute shadow
          const Color(0xFF423120), // Crease
        ],
        stops: const [0.0, 0.35, 0.8, 1.0],
      ).createShader(rect);

      strandPaint.shader = strandShader;
      
      // Draw the strand oval
      canvas.drawOval(rect, strandPaint);
      canvas.restore();
    }

    // ── 3. Draw a dark central crease line to bind the twists visually ──
    final creasePaint = Paint()
      ..color = const Color(0xFF382618).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness * 0.12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, creasePaint);

    // ── 4. Add realistic hair fibers sticking out ──
    final hairPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;

    for (int i = 0; i < length; i += 4) {
      if (rng.nextDouble() < 0.25) {
        final t = i / length;
        final p = start + Offset(dx * t, dy * t);
        
        // Hair length and angles
        final hairLen = 2.0 + rng.nextDouble() * 5.0;
        final side = rng.nextBool() ? 1.0 : -1.0;
        final perpAngle = ropeAngle + (pi / 2) * side + (rng.nextDouble() - 0.5) * 1.2;
        
        hairPaint.color = const Color(0xFFD4C2AB).withValues(
          alpha: 0.15 + rng.nextDouble() * 0.25,
        );

        canvas.drawLine(
          p,
          p + Offset(cos(perpAngle) * hairLen, sin(perpAngle) * hairLen),
          hairPaint,
        );
      }
    }
  }

  /// Builds a smooth filled path around centerline points with dynamic jute thickness.
  Path _buildRopePath(List<Offset> points, double baseThickness) {
    if (points.isEmpty) return Path();
    final path = Path();

    // Right side (top to bottom)
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final localThickness = baseThickness * (1.0 + 0.08 * sin(i * 0.15 + seed));
      final halfT = localThickness / 2;
      Offset perp;
      if (i < points.length - 1) {
        final dir = points[i + 1] - p;
        final len = dir.distance;
        perp = len < 0.01
            ? Offset.zero
            : Offset(-dir.dy / len, dir.dx / len) * halfT;
      } else {
        final dir = p - points[i - 1];
        final len = dir.distance;
        perp = len < 0.01
            ? Offset.zero
            : Offset(-dir.dy / len, dir.dx / len) * halfT;
      }
      final side = p + perp;
      if (i == 0) {
        path.moveTo(side.dx, side.dy);
      } else {
        final prev = points[i - 1];
        final prevDir = p - prev;
        final prevLen = prevDir.distance;
        final prevLocalThickness = baseThickness * (1.0 + 0.08 * sin((i - 1) * 0.15 + seed));
        final prevHalfT = prevLocalThickness / 2;
        final prevPerp = prevLen < 0.01
            ? Offset.zero
            : Offset(-prevDir.dy / prevLen, prevDir.dx / prevLen) * prevHalfT;
        path.quadraticBezierTo(
          (prev + prevPerp).dx,
          (prev + prevPerp).dy,
          side.dx,
          side.dy,
        );
      }
    }

    // Left side (bottom to top)
    for (int i = points.length - 1; i >= 0; i--) {
      final p = points[i];
      final localThickness = baseThickness * (1.0 + 0.08 * sin(i * 0.15 + seed));
      final halfT = localThickness / 2;
      Offset perp;
      if (i > 0) {
        final dir = p - points[i - 1];
        final len = dir.distance;
        perp = len < 0.01
            ? Offset.zero
            : Offset(-dir.dy / len, dir.dx / len) * halfT;
      } else {
        perp = Offset.zero;
      }
      path.lineTo((p - perp).dx, (p - perp).dy);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant RopeSystemPainter old) =>
      old.hookCenterX != hookCenterX ||
      old.hookBottomY != hookBottomY ||
      old.boardRects.length != boardRects.length ||
      old.thickness != thickness ||
      old.seed != seed;
}

/// Paints a single drilled hole on a board surface.
/// The hole appears as a dark circle with inner shadow, giving the impression
/// that the rope passes through it.
class RopeHolePainter extends CustomPainter {
  final double radius;
  final int seed;

  const RopeHolePainter({this.radius = 5.0, this.seed = 10});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Outer ring (board material around hole)
    canvas.drawCircle(
      center,
      radius + 1.5,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
    );

    // Hole body (dark)
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF1A1008));

    // Inner shadow (top-left light, bottom-right dark)
    final innerShadow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        radius: 0.9,
        colors: [
          const Color(0xFF3D2A18).withValues(alpha: 0.6),
          const Color(0xFF0A0604),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, innerShadow);

    // Rim highlight (top edge catches light)
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withValues(alpha: 0.12);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 0.5),
      -pi * 0.8,
      pi * 0.6,
      false,
      rimPaint,
    );
  }

  @override
  bool shouldRepaint(covariant RopeHolePainter old) =>
      old.radius != radius || old.seed != seed;
}
