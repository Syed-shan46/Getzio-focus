import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/smart_object_models.dart';
import '../../domain/models/vision_item.dart';

// -----------------------------------------------------------------------------
// PLAN CARD WIDGET
// -----------------------------------------------------------------------------
class PlanCardWidget extends StatelessWidget {
  final VisionItem item;
  const PlanCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final metadata = item.metadata ?? {};
    final title = item.content.isNotEmpty
        ? item.content
        : (metadata['title'] as String? ?? 'Project Roadmap');
    final milestones = item.smartMilestones;

    return FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: 320,
        height: 240,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.zero,
            border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_tree_rounded,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleLarge(color: Colors.black87),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.smartProgressPercent}%',
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1, color: Colors.black12),
              Expanded(
                child: milestones.isEmpty
                    ? const Center(
                        child: Text(
                          'Tap to add milestones & tasks',
                          style: TextStyle(color: Colors.black38, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: milestones.take(4).length,
                        itemBuilder: (context, index) {
                          final m = milestones[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  m.isCompleted
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: m.isCompleted
                                      ? Colors.green
                                      : Colors.black26,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    m.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        AppTypography.bodyMedium(
                                          color: m.isCompleted
                                              ? Colors.black45
                                              : Colors.black87,
                                        ).copyWith(
                                          decoration: m.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TASK CARD WIDGET
// -----------------------------------------------------------------------------
class TaskCardWidget extends StatelessWidget {
  final VisionItem item;
  const TaskCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final metadata = item.metadata ?? {};
    final title = item.content.isNotEmpty
        ? item.content
        : (metadata['title'] as String? ?? 'Daily Goals');
    final checklist = item.smartChecklist;
    final isDone = item.smartProgress >= 1.0;

    // Warm organic yellow paper background gradient
    const paperGradient = LinearGradient(
      colors: [Color(0xFFE5BC68), Color(0xFFDFB15B)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    // Dark brown/charcoal ink color
    const inkColor = Color(0xFF2C2518);

    return FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: 200,
        height: 260,
        child: Container(
          decoration: BoxDecoration(gradient: paperGradient),
          child: Stack(
            children: [
              // Notebook lines
              Positioned.fill(
                child: CustomPaint(painter: _NotebookLinesPainter()),
              ),

              // Custom Smiley face in bottom-right corner
              Positioned(
                bottom: 12,
                right: 12,
                width: 22,
                height: 22,
                child: CustomPaint(painter: _SmileyPainter()),
              ),

              // Content Padding
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title "Daily Goals" or Task Title
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: inkColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Notebook line under title
                          Container(
                            width: 130,
                            height: 1.2,
                            color: inkColor.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Checklist Items
                    Expanded(
                      child: checklist.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHandChecklistItem(
                                  title: 'Task To Do',
                                  isChecked: isDone,
                                  inkColor: inkColor,
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...checklist.take(5).map((chk) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildHandChecklistItem(
                                      title: chk.title,
                                      isChecked: chk.isCompleted,
                                      inkColor: inkColor,
                                    ),
                                  );
                                }),
                                if (checklist.length > 5)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 28),
                                    child: Text(
                                      '+ ${checklist.length - 5} more...',
                                      style: TextStyle(
                                        color: inkColor.withValues(alpha: 0.5),
                                        fontSize: 10,
                                        fontStyle: FontStyle.italic,
                                      ),
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
    );
  }

  Widget _buildHandChecklistItem({
    required String title,
    required bool isChecked,
    required Color inkColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Custom hand-drawn checkbox container
        Container(
          width: 17,
          height: 17,
          decoration: BoxDecoration(
            border: Border.all(
              color: inkColor.withValues(alpha: 0.8),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
          alignment: const Alignment(0.0, -0.4),
          child: isChecked
              ? Text(
                  '✓',
                  style: TextStyle(
                    color: inkColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isChecked ? inkColor.withValues(alpha: 0.6) : inkColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _NotebookLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF78350F)
          .withValues(alpha: 0.08) // soft warm brown line
      ..strokeWidth = 1.0;

    // Draw horizontal lines starting below header
    double y = 48.0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      y += 24.0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SmileyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2C2518).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw outer circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    // Draw eyes
    final eyePaint = Paint()
      ..color = const Color(0xFF2C2518).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2 - 4, size.height / 2 - 3),
      1.2,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(size.width / 2 + 4, size.height / 2 - 3),
      1.2,
      eyePaint,
    );

    // Draw mouth arc
    final mouthRect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 3,
    );
    canvas.drawArc(mouthRect, 0.2, 2.8, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// FINANCE CARD WIDGET
// -----------------------------------------------------------------------------
class FinanceCardWidget extends StatelessWidget {
  final VisionItem item;
  const FinanceCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final metadata = item.metadata ?? {};
    final title = item.content.isNotEmpty
        ? item.content
        : (metadata['title'] as String? ?? 'Finance Goal');
    final current = parseDoubleHelper(metadata['currentAmount'], 0.0);
    final target = parseDoubleHelper(metadata['targetAmount'], 1000.0);
    final progressRatio = item.smartProgress;
    final progressPercent = item.smartProgressPercent;
    final remaining = (target - current).clamp(0.0, double.infinity);
    final targetDateStr = metadata['targetDate'] as String?;

    // Formatting Target Date
    String formattedDate = 'No Date';
    if (targetDateStr != null) {
      try {
        final dt = DateTime.parse(targetDateStr);
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        formattedDate = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      } catch (_) {}
    }

    final goldColor = const Color(0xFFD4AF37);

    return FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: 380,
        height: 220,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A), // Deep dark background
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white60, width: 5),
          ),
          child: Stack(
            children: [
              // -------------------------------------------------------------
              // BACKGROUND & IMAGE
              // -------------------------------------------------------------
              Positioned(
                right: -40,
                top: -20,
                bottom: -20,
                child: Container(
                  width: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: goldColor.withValues(alpha: 0.15),
                      width: 2,
                    ),
                  ),
                ),
              ),
              // Faded Right Background Image using assets/images/freedom.jpeg
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 220,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Colors.transparent, Colors.black],
                        stops: [0.0, 0.4],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: const Image(
                      image: AssetImage('assets/images/freedom.jpeg'),
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                    ),
                  ),
                ),
              ),

              // -------------------------------------------------------------
              // CONTENT OVERLAY
              // -------------------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Box
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: goldColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: goldColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            Icons.show_chart_rounded,
                            color: goldColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FINANCE GOAL',
                                style: AppTypography.caption(color: goldColor)
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                      fontSize: 10,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    AppTypography.titleMedium(
                                      color: Colors.white,
                                    ).copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.more_horiz, color: Colors.white30),
                      ],
                    ),
                    const Spacer(),

                    // Amounts
                    Text(
                      '₹${current.toStringAsFixed(0)} / ₹${target.toStringAsFixed(0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.displayMedium(
                        color: Colors.white,
                      ).copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 8),

                    // Custom Progress Bar
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progressRatio,
                        child: Container(
                          decoration: BoxDecoration(
                            color: goldColor,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: goldColor.withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Progress Subtext
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$progressPercent% Reached',
                          style: AppTypography.caption(
                            color: goldColor,
                          ).copyWith(fontSize: 11),
                        ),
                        Text(
                          '₹${remaining.toStringAsFixed(0)} to go',
                          style: AppTypography.caption(
                            color: Colors.white54,
                          ).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Divider
                    Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    const SizedBox(height: 10),

                    // Footer Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildStatCol(
                            Icons.calendar_today_outlined,
                            'Target Date',
                            formattedDate,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCol(
                            Icons.savings_outlined,
                            'Saved',
                            '₹${current.toStringAsFixed(0)}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCol(
                            Icons.trending_up,
                            'Status',
                            'On Track',
                            iconColor: goldColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(
    IconData icon,
    String label,
    String value, {
    Color? iconColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor ?? Colors.white54, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption(
                  color: Colors.white30,
                ).copyWith(fontSize: 9),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption(
                  color: Colors.white,
                ).copyWith(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// COUNTDOWN CARD WIDGET
// -----------------------------------------------------------------------------
class CountdownCardWidget extends StatelessWidget {
  final VisionItem item;
  const CountdownCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final metadata = item.metadata ?? {};
    final title = item.content.isNotEmpty
        ? item.content
        : (metadata['title'] as String? ?? 'Target Countdown');
    final targetDate =
        item.countdownDate ?? DateTime.now().add(const Duration(days: 30));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final remainingDays = target.difference(today).inDays.clamp(0, 9999);

    return FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: 220,
        height: 220,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.zero,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_rounded, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                '$remainingDays',
                style: AppTypography.displayLarge(
                  color: Colors.white,
                ).copyWith(fontSize: 44, height: 1.1),
              ),
              Text(
                'DAYS REMAINING',
                style: AppTypography.caption(color: Colors.white).copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleMedium(
                  color: Colors.white,
                ).copyWith(fontSize: 14, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
