import 'dart:math' as math;
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
    final title = item.content.isNotEmpty ? item.content : (metadata['title'] as String? ?? 'My Goal');
    final description = metadata['description'] as String? ?? '';
    final progressRatio = item.smartProgress;
    final progressPercent = item.smartProgressPercent;
    final priority = metadata['priority'] as String? ?? 'Medium';
    final category = metadata['category'] as String? ?? item.secondaryContent ?? 'General';
    final colorValue = metadata['color'] as int? ?? Colors.blueAccent.toARGB32();
    final themeColor = Color(colorValue);

    // Milestones and checklist
    final milestones = item.smartMilestones;
    final checklist = item.smartChecklist;
    final completedMilestones = milestones.where((m) => m.isCompleted).length;
    final completedTasks = checklist.where((t) => t.isCompleted).length;

    // Due date parsing
    final dueDate = item.countdownDate;
    final String dueDateStr = dueDate != null
        ? '${dueDate.day}/${dueDate.month}/${dueDate.year}'
        : 'No limit';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.92), // Premium matte background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Category Badge & Priority
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: themeColor.withValues(alpha: 0.3), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.category_rounded, color: themeColor, size: 10),
                    const SizedBox(width: 4),
                    Text(
                      category.toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getPriorityColor(priority).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getPriorityColor(priority).withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  priority.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: _getPriorityColor(priority),
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Title & Target Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.outfit(
                      color: Colors.white60,
                      fontSize: 12,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Row 3: Stats (Tasks & Milestones counts)
          Row(
            children: [
              if (milestones.isNotEmpty) ...[
                Icon(Icons.flag_rounded, color: themeColor.withValues(alpha: 0.7), size: 12),
                const SizedBox(width: 4),
                Text(
                  '$completedMilestones/${milestones.length} Steps',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
              ],
              if (checklist.isNotEmpty) ...[
                Icon(Icons.assignment_turned_in_rounded, color: themeColor.withValues(alpha: 0.7), size: 12),
                const SizedBox(width: 4),
                Text(
                  '$completedTasks/${checklist.length} Tasks',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
              ],
              const Spacer(),
              const Icon(Icons.calendar_month_rounded, color: Colors.white38, size: 12),
              const SizedBox(width: 4),
              Text(
                dueDateStr,
                style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 4: Text Labels for Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progressRatio >= 1.0 ? 'Goal Conquered 🏆' : 'Journey Progress',
                style: GoogleFonts.outfit(
                  color: progressRatio >= 1.0 ? const Color(0xFFFFD54F) : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                '$progressPercent%',
                style: GoogleFonts.outfit(
                  color: themeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 5: Realistic Road Progress via Custom Paint
          SizedBox(
            height: 38,
            child: CustomPaint(
              painter: RealisticRoadProgressPainter(
                progress: progressRatio.clamp(0.0, 1.0),
                themeColor: themeColor,
                milestones: milestones,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
      default:
        return const Color(0xFF10B981);
    }
  }
}

class RealisticRoadProgressPainter extends CustomPainter {
  final double progress;
  final Color themeColor;
  final List<SmartMilestone> milestones;

  RealisticRoadProgressPainter({
    required this.progress,
    required this.themeColor,
    required this.milestones,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw asphalt road background
    final roadRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height / 2 - 8, size.width, 16),
      const Radius.circular(8),
    );
    final asphaltPaint = Paint()
      ..color = const Color(0xFF1E293B) // Dark asphalt
      ..style = PaintingStyle.fill;
    canvas.drawRRect(roadRect, asphaltPaint);

    // Subtle road texture (borders)
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(roadRect, borderPaint);

    // Draw solid white shoulder lines at the top and bottom of the road
    final shoulderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(0, size.height / 2 - 8), Offset(size.width, size.height / 2 - 8), shoulderPaint);
    canvas.drawLine(Offset(0, size.height / 2 + 8), Offset(size.width, size.height / 2 + 8), shoulderPaint);

    // 2. Draw yellow dashed lane divider down the center
    final dashPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.6) // yellow dash
      ..strokeWidth = 1.5;
    const double dashWidth = 8;
    const double dashSpace = 6;
    double currentX = 4;
    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, size.height / 2),
        Offset(currentX + dashWidth, size.height / 2),
        dashPaint,
      );
      currentX += dashWidth + dashSpace;
    }

    // 3. Draw Traveled glowing path (Progress overlay)
    if (progress > 0) {
      final traveledWidth = size.width * progress;
      final traveledRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height / 2 - 8, traveledWidth, 16),
        const Radius.circular(8),
      );
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            themeColor.withValues(alpha: 0.4),
            themeColor,
          ],
        ).createShader(Rect.fromLTWH(0, size.height / 2 - 8, traveledWidth, 16));
      canvas.drawRRect(traveledRect, progressPaint);

      // Traveled center line highlight (bright yellow/neon)
      final traveledDashPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5;
      double tX = 4;
      while (tX < traveledWidth) {
        canvas.drawLine(
          Offset(tX, size.height / 2),
          Offset(math.min(tX + dashWidth, traveledWidth), size.height / 2),
          traveledDashPaint,
        );
        tX += dashWidth + dashSpace;
      }
    }

    // 4. Draw milestones along the road
    if (milestones.isNotEmpty) {
      final step = size.width / (milestones.length + 1);
      for (int i = 0; i < milestones.length; i++) {
        final mX = step * (i + 1);
        final milestone = milestones[i];
        final isCompleted = milestone.isCompleted;

        // Draw milestone marker circle
        final markerPaint = Paint()
          ..color = isCompleted ? const Color(0xFF10B981) : const Color(0xFF64748B)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(mX, size.height / 2), 4, markerPaint);

        // Subtle glow outer circle
        final glowPaint = Paint()
          ..color = (isCompleted ? const Color(0xFF10B981) : const Color(0xFF64748B)).withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(Offset(mX, size.height / 2), 7, glowPaint);
      }
    }

    // 5. Draw realistic flag at the end (destination)
    final flagBaseX = size.width - 12;
    final flagBaseY = size.height / 2;

    // Draw Flagpole
    final polePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(flagBaseX, flagBaseY + 8), Offset(flagBaseX, flagBaseY - 22), polePaint);

    // Draw Flag cloth (Waving triangular flag shape)
    final flagPath = Path()
      ..moveTo(flagBaseX, flagBaseY - 22)
      ..lineTo(flagBaseX - 14, flagBaseY - 16)
      ..lineTo(flagBaseX, flagBaseY - 10)
      ..close();

    final flagPaint = Paint()
      ..color = const Color(0xFFEF4444) // Bright red flag
      ..style = PaintingStyle.fill;
    canvas.drawPath(flagPath, flagPaint);

    // Draw flagpole brass finial tip
    final tipPaint = Paint()
      ..color = const Color(0xFFF59E0B) // Gold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(flagBaseX, flagBaseY - 23), 2.0, tipPaint);

    // 6. Draw realistic progress vehicle or runner at active point
    final activeX = size.width * progress;
    final activeY = size.height / 2;

    // Draw indicator glow
    final activeGlow = Paint()
      ..color = themeColor.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(activeX, activeY), 10, activeGlow);

    // Active marker dot
    final activeDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(activeX, activeY), 5.5, activeDotPaint);

    // Center core
    final activeCorePaint = Paint()
      ..color = themeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(activeX, activeY), 3.0, activeCorePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
