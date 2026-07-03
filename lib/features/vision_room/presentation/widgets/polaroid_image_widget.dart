import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/vision_item.dart';
import '../../domain/models/vision_customization.dart';

class PolaroidImageWidget extends StatelessWidget {
  final VisionItem item;
  final CardCustomization cardCfg;

  const PolaroidImageWidget({
    super.key,
    required this.item,
    required this.cardCfg,
  });

  @override
  Widget build(BuildContext context) {
    final metadata = item.metadata ?? {};
    final caption = metadata['caption'] as String? ?? '';
    final emoji = metadata['emoji'] as String? ?? 'globe';

    return Opacity(
      opacity: cardCfg.opacity,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F6), // Polaroid classic off-white paper
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.08),
            width: 1.0,
          ),
          boxShadow: [
            // 1. Sharp near-contact shadow — warm brown board tone
            BoxShadow(
              color: const Color(0xFF0F0A05).withValues(alpha: 0.65),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(1, 2),
            ),
            // 2. Deep ambient diffusion — brown-shadow spreading on board
            BoxShadow(
              color: const Color(0xFF1C1108).withValues(alpha: 0.45),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(2, 8),
            ),
            // 3. Wide soft halo — atmospheric depth on dusty brown board
            BoxShadow(
              color: const Color(0xFF100A05).withValues(alpha: 0.60),
              blurRadius: 36,
              spreadRadius: 4,
              offset: const Offset(3, 14),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image print
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.1),
                    width: 0.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: item.content.startsWith('http')
                      ? Image.network(
                          item.content,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 40),
                            ),
                          ),
                        )
                      : Image.file(
                          File(item.content),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 40),
                            ),
                          ),
                        ),
                ),
              ),
            ),
            
            // Polaroid bottom write margin
            Container(
              height: 14,
              padding: const EdgeInsets.only(top: 1, left: 3, right: 3, bottom: 1),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.caveat(
                        color: const Color(0xFF2C2518), // Sketched felt-tip pen black ink
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                    ),
                  ),
                  if (caption.isNotEmpty) ...[
                    const SizedBox(width: 3),
                    CustomPaint(
                      size: const Size(9, 9),
                      painter: _PolaroidHandDrawnEmojiPainter(
                        emoji,
                        color: const Color(0xFF2C2518),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolaroidHandDrawnEmojiPainter extends CustomPainter {
  final String emojiType;
  final Color color;

  _PolaroidHandDrawnEmojiPainter(this.emojiType, {required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    switch (emojiType) {
      case 'globe':
        final path = Path();
        // Slightly imperfect circle (hand-drawn circle)
        path.moveTo(cx + w * 0.42, cy);
        path.quadraticBezierTo(cx + w * 0.4, cy - h * 0.38, cx, cy - h * 0.42);
        path.quadraticBezierTo(cx - w * 0.38, cy - h * 0.4, cx - w * 0.42, cy);
        path.quadraticBezierTo(cx - w * 0.4, cy + h * 0.38, cx, cy + h * 0.42);
        path.quadraticBezierTo(cx + w * 0.38, cy + h * 0.4, cx + w * 0.42, cy);

        // Vertical lines (meridians)
        path.moveTo(cx, cy - h * 0.42);
        path.quadraticBezierTo(cx - w * 0.20, cy + h * 0.02, cx, cy + h * 0.42);
        path.moveTo(cx, cy - h * 0.42);
        path.quadraticBezierTo(cx + w * 0.20, cy - h * 0.02, cx, cy + h * 0.42);
        // Center vertical line (axis/meridian)
        path.moveTo(cx, cy - h * 0.42);
        path.lineTo(cx, cy + h * 0.42);

        // Horizontal lines (equator & parallels)
        path.moveTo(cx - w * 0.42, cy);
        path.quadraticBezierTo(cx + w * 0.02, cy + h * 0.05, cx + w * 0.42, cy); // Equator
        
        path.moveTo(cx - w * 0.35, cy - h * 0.2);
        path.quadraticBezierTo(cx, cy - h * 0.15, cx + w * 0.35, cy - h * 0.2);
        
        path.moveTo(cx - w * 0.35, cy + h * 0.2);
        path.quadraticBezierTo(cx, cy + h * 0.25, cx + w * 0.35, cy + h * 0.2);

        canvas.drawPath(path, paint);
        break;

      case 'heart':
        final path = Path();
        path.moveTo(cx, cy + h * 0.32);
        // Left curve
        path.cubicTo(
          cx - w * 0.48, cy - h * 0.1,
          cx - w * 0.32, cy - h * 0.45,
          cx, cy - h * 0.25,
        );
        // Right curve
        path.cubicTo(
          cx + w * 0.32, cy - h * 0.45,
          cx + w * 0.48, cy - h * 0.1,
          cx, cy + h * 0.32,
        );
        canvas.drawPath(path, paint);
        break;

      case 'star':
        final path = Path();
        const double rOuter = 10.5;
        const double rInner = 4.5;
        for (int i = 0; i < 10; i++) {
          final double angle = (i * pi / 5) - pi / 2;
          final double r = i.isEven ? rOuter : rInner;
          final double x = cx + r * cos(angle);
          final double y = cy + r * sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
        break;

      case 'flame':
        final path = Path();
        path.moveTo(cx, cy + h * 0.38);
        path.cubicTo(cx - w * 0.35, cy + h * 0.38, cx - w * 0.4, cy, cx - w * 0.15, cy - h * 0.15);
        path.cubicTo(cx - w * 0.25, cy - h * 0.32, cx, cy - h * 0.45, cx, cy - h * 0.45);
        path.cubicTo(cx + w * 0.12, cy - h * 0.3, cx + w * 0.12, cy - h * 0.1, cx + w * 0.22, cy - h * 0.15);
        path.cubicTo(cx + w * 0.4, cy, cx + w * 0.35, cy + h * 0.38, cx, cy + h * 0.38);
        path.close();
        canvas.drawPath(path, paint);
        break;

      case 'airplane':
        final path = Path();
        // Fuselage
        path.moveTo(cx, cy - h * 0.45);
        path.lineTo(cx - w * 0.08, cy + h * 0.3);
        path.lineTo(cx + w * 0.08, cy + h * 0.3);
        path.close();
        // Wings
        path.moveTo(cx - w * 0.08, cy - h * 0.05);
        path.lineTo(cx - w * 0.45, cy + h * 0.08);
        path.lineTo(cx - w * 0.08, cy + h * 0.12);
        path.moveTo(cx + w * 0.08, cy - h * 0.05);
        path.lineTo(cx + w * 0.45, cy + h * 0.08);
        path.lineTo(cx + w * 0.08, cy + h * 0.12);
        // Tail wings
        path.moveTo(cx, cy + h * 0.22);
        path.lineTo(cx - w * 0.2, cy + h * 0.3);
        path.lineTo(cx, cy + h * 0.3);
        path.lineTo(cx + w * 0.2, cy + h * 0.3);
        canvas.drawPath(path, paint);
        break;

      case 'camera':
        final path = Path();
        // Body
        path.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - w * 0.38, cy - h * 0.22, w * 0.76, h * 0.52),
          const Radius.circular(3),
        ));
        // Lens
        canvas.drawCircle(Offset(cx, cy + h * 0.04), w * 0.18, paint);
        // Flash top bit
        path.moveTo(cx - w * 0.16, cy - h * 0.22);
        path.lineTo(cx - w * 0.12, cy - h * 0.34);
        path.lineTo(cx + w * 0.12, cy - h * 0.34);
        path.lineTo(cx + w * 0.16, cy - h * 0.22);
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _PolaroidHandDrawnEmojiPainter oldDelegate) {
    return oldDelegate.emojiType != emojiType || oldDelegate.color != color;
  }
}
