import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/smart_object_models.dart';
import '../../domain/models/vision_item.dart';

class GoalCardWidget extends StatelessWidget {
  final VisionItem item;

  const GoalCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final metadata = item.metadata ?? {};
    final title = item.content.isNotEmpty
        ? item.content
        : (metadata['title'] as String? ?? 'My Goal');
    final description =
        metadata['description'] as String? ??
        'Create meaningful goals with milestones and priorities.';
    final progressRatio = item.smartProgress;
    final progressPercent = item.smartProgressPercent;
    final priority = metadata['priority'] as String? ?? 'High';
    final category =
        metadata['category'] as String? ?? item.secondaryContent ?? 'General';
    final colorValue =
        metadata['color'] as int? ?? Colors.blueAccent.toARGB32();
    final themeColor = Color(colorValue);

    // Due date parsing
    final dueDate = item.countdownDate;
    final String dueDateStr = dueDate != null
        ? '${dueDate.day}/${dueDate.month}/${dueDate.year}'
        : 'No limit';

    final double width = item.width;
    final double height = item.height;

    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: 320,
          height: 240,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ─── CARD BASE CONTAINER ───
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0E15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white60, width: 5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // ─── RIGHT SIDE IMAGE WITH SHADERMASK BLEND ───
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          width: 140, // Perfect percentage of 320 width
                          child: ShaderMask(
                            shaderCallback: (rect) {
                              return const LinearGradient(
                                colors: [Colors.transparent, Colors.white],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                stops: [0.0, 0.6],
                              ).createShader(rect);
                            },
                            blendMode: BlendMode.dstIn,
                            child: Image.network(
                              'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=600&auto=format&fit=crop&q=80',
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: themeColor.withValues(alpha: 0.12),
                                );
                              },
                            ),
                          ),
                        ),

                        // ─── LEFT GRADIENT SHADE OVERLAY ───
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF0D0E15),
                                  const Color(
                                    0xFF0D0E15,
                                  ).withValues(alpha: 0.85),
                                  Colors.transparent,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                stops: const [0.0, 0.45, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // ─── CARD CONTENT ───
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(
                                height: 10,
                              ), // Leave room for top badge
                              // Chips Row (Category and Priority)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Category chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF2C2216,
                                      ).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFD4AF37,
                                        ).withValues(alpha: 0.5),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          color: Color(0xFFD4AF37),
                                          size: 10,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          category.toUpperCase(),
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFFD4AF37),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 8,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Priority chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF2C1616,
                                      ).withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFEF4444,
                                        ).withValues(alpha: 0.4),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          priority.toUpperCase(),
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFFEF4444),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 8,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        const Icon(
                                          Icons.local_fire_department_rounded,
                                          color: Color(0xFFEF4444),
                                          size: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Title & Description (Left Side)
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildTitleText(title, 15),
                                          const SizedBox(height: 3),
                                          Text(
                                            description,
                                            style: GoogleFonts.outfit(
                                              color: Colors.white.withValues(
                                                alpha: 0.6,
                                              ),
                                              fontSize: 10,
                                              height: 1.2,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4),

                                    // Floating Date Pill
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF7C3AED,
                                            ).withValues(alpha: 0.18),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: const Color(
                                                0xFF7C3AED,
                                              ).withValues(alpha: 0.35),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.calendar_today_rounded,
                                                color: Color(0xFFC084FC),
                                                size: 10,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                dueDateStr,
                                                style: GoogleFonts.outfit(
                                                  color: const Color(
                                                    0xFFC084FC,
                                                  ),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 8,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Journey Progress Box (Bottom Panel)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF151824,
                                  ).withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    width: 0.8,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        // Progress Circular Arrow Icon
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(
                                                0xFF34D399,
                                              ).withValues(alpha: 0.35),
                                              width: 1.0,
                                            ),
                                            color: const Color(
                                              0xFF34D399,
                                            ).withValues(alpha: 0.08),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.trending_up_rounded,
                                              color: Color(0xFF34D399),
                                              size: 11,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),

                                        // Text
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                progressRatio >= 1.0
                                                    ? 'Goal Conquered 🏆'
                                                    : 'Journey Progress',
                                                style: GoogleFonts.outfit(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 10.5,
                                                ),
                                              ),
                                              const SizedBox(height: 1),
                                              Text(
                                                progressRatio >= 1.0
                                                    ? 'Fantastic job!'
                                                    : 'Keep going, you\'re doing great!',
                                                style: GoogleFonts.outfit(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.4),
                                                  fontSize: 8,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Percentage
                                        Text(
                                          '$progressPercent%',
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFF34D399),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Slider/Progress CustomPaint
                                    SizedBox(
                                      height: 12,
                                      child: CustomPaint(
                                        painter: _PremiumProgressPainter(
                                          progress: progressRatio.clamp(
                                            0.0,
                                            1.0,
                                          ),
                                          themeColor: themeColor,
                                        ),
                                        child: const SizedBox.expand(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── TOP CENTER FLOATING GOLD BADGE ───
              Positioned(
                top: -8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF151824),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.track_changes_rounded,
                        color: Color(0xFFD4AF37),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleText(String title, double fontSize) {
    final words = title.split(' ');
    if (words.length <= 1) {
      return Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
          height: 1.15,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lastWord = words.last;
    final prefix = title.substring(0, title.length - lastWord.length);

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
          height: 1.15,
        ),
        children: [
          TextSpan(
            text: prefix,
            style: const TextStyle(color: Colors.white),
          ),
          TextSpan(
            text: lastWord,
            style: const TextStyle(color: Color(0xFFE6C594)),
          ),
        ],
      ),
    );
  }
}

class _PremiumProgressPainter extends CustomPainter {
  final double progress;
  final Color themeColor;

  _PremiumProgressPainter({required this.progress, required this.themeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double y = size.height / 2;
    final double startX = 0;
    final double endX = size.width - 12; // Save room for flag
    final double currentX = startX + (endX - startX) * progress;

    // 1. Draw inactive line
    final inactivePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(startX, y), Offset(endX, y), inactivePaint);

    // 2. Draw milestone dots
    final dotPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    for (int i = 1; i <= 3; i++) {
      final double dotX = startX + (endX - startX) * (i / 4);
      canvas.drawCircle(Offset(dotX, y), 1.2, dotPaint);
    }

    // 3. Draw active progress line
    if (progress > 0) {
      final activePaint = Paint()
        ..color = const Color(0xFF34D399)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      // Glow effect under progress line
      final glowPaint = Paint()
        ..color = const Color(0xFF34D399).withValues(alpha: 0.3)
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawLine(Offset(startX, y), Offset(currentX, y), glowPaint);
      canvas.drawLine(Offset(startX, y), Offset(currentX, y), activePaint);
    }

    // 4. Draw destination flagpole & flag
    final flagPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;

    // Pole
    final polePaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.6)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(endX, y + 5), Offset(endX, y - 10), polePaint);

    // Flag triangle
    final path = Path()
      ..moveTo(endX, y - 10)
      ..lineTo(endX + 8, y - 7)
      ..lineTo(endX, y - 4)
      ..close();
    canvas.drawPath(path, flagPaint);

    // Finial tip
    canvas.drawCircle(Offset(endX, y - 11), 1.0, flagPaint);

    // 5. Draw active thumb tracker
    if (progress > 0) {
      final thumbGlow = Paint()
        ..color = const Color(0xFF34D399).withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(currentX, y), 6, thumbGlow);

      final thumbWhite = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(currentX, y), 4.2, thumbWhite);

      final thumbCore = Paint()
        ..color = const Color(0xFF34D399)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(currentX, y), 2.2, thumbCore);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
