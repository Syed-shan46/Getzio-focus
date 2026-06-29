import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

import '../../domain/models/vision_item.dart';
import '../providers/canvas_providers.dart';

class RoadmapBottomSheet extends ConsumerStatefulWidget {
  final VisionItem item;

  const RoadmapBottomSheet({super.key, required this.item});

  static void show(BuildContext context, {required VisionItem item}) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RoadmapBottomSheet(item: item),
    );
  }

  @override
  ConsumerState<RoadmapBottomSheet> createState() =>
      _RoadmapBottomSheetState();
}

class _RoadmapBottomSheetState extends ConsumerState<RoadmapBottomSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final metadata = item.metadata ?? {};
    final screenHeight = MediaQuery.of(context).size.height;

    final title = item.content.isNotEmpty ? item.content : 'Dream';
    final progress = _extractProgress(metadata);
    final targetDate = _extractTargetDate(metadata);
    final daysRemaining = targetDate?.difference(DateTime.now()).inDays;
    final currentMilestone = metadata['currentMilestone'] as String? ?? 'Getting Started';
    final nextAction = metadata['nextAction'] as String? ?? 'Define your first milestone';
    final milestones = _extractMilestones(metadata);
    final checklist = _extractChecklist(metadata);
    final timeline = _extractTimeline(metadata);
    final xpEarned = metadata['xpEarned'] as int? ?? 0;
    final quote = metadata['motivationalQuote'] as String?;
    final quoteAuthor = metadata['quoteAuthor'] as String?;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        height: screenHeight * 0.9,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.95),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 16, bottom: 8),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Close button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                AppColors.accentBlue.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'ROADMAP',
                          style: TextStyle(
                            color: AppColors.accentBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white60,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Goal Title
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Progress Ring + Stats
                    Row(
                      children: [
                        // Progress Ring (custom implementation)
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CustomPaint(
                            painter: _RoadmapRingPainter(
                              progress: progress,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.05),
                              gradientColors: const [
                                Color(0xFF2CE38C),
                                Color(0xFF4DA3FF),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${(progress * 100).round()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Progress',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 24),

                        // Stats Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatRow(
                                Icons.calendar_today_rounded,
                                'Target Date',
                                targetDate != null
                                    ? '${targetDate.day}/${targetDate.month}/${targetDate.year}'
                                    : 'Not set',
                              ),
                              const SizedBox(height: 12),
                              _buildStatRow(
                                Icons.timer_outlined,
                                'Days Remaining',
                                daysRemaining != null
                                    ? '$daysRemaining days'
                                    : 'No deadline',
                              ),
                              const SizedBox(height: 12),
                              _buildStatRow(
                                Icons.stars_rounded,
                                'XP Earned',
                                '$xpEarned XP',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Current Milestone
                    _buildSectionHeader(
                      Icons.flag_rounded,
                      'Current Milestone',
                      const Color(0xFF2CE38C),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2CE38C).withValues(alpha: 0.15),
                            const Color(0xFF2CE38C).withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF2CE38C).withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF2CE38C).withValues(alpha: 0.1),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2CE38C)
                                  .withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_upward_rounded,
                              color: Color(0xFF2CE38C),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentMilestone,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Next: $nextAction',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Milestone List
                    _buildSectionHeader(
                      Icons.flag_outlined,
                      'Milestones',
                      AppColors.accentBlue,
                    ),
                    const SizedBox(height: 12),
                    ...milestones.asMap().entries.map((entry) {
                      final i = entry.key;
                      final m = entry.value;
                      final isCompleted = m['completed'] == true;
                      final isCurrent = m['current'] == true;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? const Color(0xFF2CE38C).withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrent
                                ? const Color(0xFF2CE38C)
                                    .withValues(alpha: 0.3)
                                : isCompleted
                                    ? const Color(0xFF2CE38C)
                                        .withValues(alpha: 0.2)
                                    : Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? const Color(0xFF2CE38C)
                                        .withValues(alpha: 0.2)
                                    : isCurrent
                                        ? const Color(0xFF2CE38C)
                                            .withValues(alpha: 0.3)
                                        : Colors.white.withValues(alpha: 0.06),
                                border: Border.all(
                                  color: isCompleted || isCurrent
                                      ? const Color(0xFF2CE38C)
                                      : Colors.white.withValues(alpha: 0.15),
                                  width: 2,
                                ),
                              ),
                              child: isCompleted
                                  ? const Icon(Icons.check_rounded,
                                      size: 16, color: Color(0xFF2CE38C))
                                  : isCurrent
                                      ? Container(
                                          margin: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF2CE38C),
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            '${i + 1}',
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.4),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m['title'] ?? 'Milestone ${i + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: isCurrent
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                  if (m['description'] != null)
                                    Text(
                                      m['description'],
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.4),
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 28),

                    // Checklist
                    if (checklist.isNotEmpty) ...[
                      _buildSectionHeader(
                        Icons.checklist_rounded,
                        'Checklist',
                        const Color(0xFFF59E0B),
                      ),
                      const SizedBox(height: 12),
                      ...checklist.map((c) {
                        final isDone = c['completed'] == true;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () {
                              _toggleChecklistItem(c['id'] ?? '');
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDone
                                        ? const Color(0xFF2CE38C)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isDone
                                          ? const Color(0xFF2CE38C)
                                          : Colors.white
                                              .withValues(alpha: 0.2),
                                      width: 2,
                                    ),
                                  ),
                                  child: isDone
                                      ? const Icon(Icons.check_rounded,
                                          size: 14, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  c['text'] ?? '',
                                  style: TextStyle(
                                    color: isDone
                                        ? Colors.white.withValues(alpha: 0.4)
                                        : Colors.white,
                                    fontSize: 14,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 28),
                    ],

                    // Timeline
                    if (timeline.isNotEmpty) ...[
                      _buildSectionHeader(
                        Icons.timeline_rounded,
                        'Timeline',
                        const Color(0xFF8B5CF6),
                      ),
                      const SizedBox(height: 16),
                      _buildTimeline(timeline),
                      const SizedBox(height: 28),
                    ],

                    // Motivational Quote
                    if (quote != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                              const Color(0xFF4DA3FF).withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF8B5CF6)
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.format_quote_rounded,
                              color: const Color(0xFF8B5CF6)
                                  .withValues(alpha: 0.5),
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '"$quote"',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.5,
                              ),
                            ),
                            if (quoteAuthor != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                '— $quoteAuthor',
                                style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.5),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _extractProgress(Map<dynamic, dynamic> metadata) {
    final progress = metadata['progress'];
    if (progress is double) return progress.clamp(0.0, 1.0);
    if (progress is int) return (progress / 100).clamp(0.0, 1.0);
    if (progress is num) return progress.toDouble().clamp(0.0, 1.0);
    return 0.38;
  }

  DateTime? _extractTargetDate(Map<dynamic, dynamic> metadata) {
    final date = metadata['targetDate'];
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    return DateTime.now().add(const Duration(days: 90));
  }

  List<Map<String, dynamic>> _extractMilestones(
      Map<dynamic, dynamic> metadata) {
    final raw = metadata['milestones'];
    if (raw is List) {
      return raw.map((m) {
        if (m is Map) {
          return Map<String, dynamic>.from(m);
        }
        return <String, dynamic>{};
      }).toList();
    }
    return [
      {'title': 'Design', 'completed': true, 'description': 'UI/UX finalized'},
      {'title': 'Development', 'completed': false, 'current': true, 'description': 'In progress'},
      {'title': 'Testing', 'completed': false, 'description': 'QA phase'},
      {'title': 'Launch', 'completed': false, 'description': 'Go live'},
      {'title': 'Growth', 'completed': false, 'description': 'Scale'},
    ];
  }

  List<Map<String, dynamic>> _extractChecklist(
      Map<dynamic, dynamic> metadata) {
    final raw = metadata['checklist'];
    if (raw is List) {
      return raw.map((c) {
        if (c is Map) {
          return Map<String, dynamic>.from(c);
        }
        return <String, dynamic>{};
      }).toList();
    }
    return [];
  }

  List<Map<String, dynamic>> _extractTimeline(
      Map<dynamic, dynamic> metadata) {
    final raw = metadata['timeline'];
    if (raw is List) {
      return raw.map((t) {
        if (t is Map) {
          return Map<String, dynamic>.from(t);
        }
        return <String, dynamic>{};
      }).toList();
    }
    return [
      {'label': 'Today', 'icon': 'start'},
      {'label': 'Design', 'icon': 'arrow'},
      {'label': 'Development', 'icon': 'arrow'},
      {'label': 'Testing', 'icon': 'arrow'},
      {'label': 'Launch', 'icon': 'arrow'},
      {'label': 'Growth', 'icon': 'target'},
    ];
  }

  void _toggleChecklistItem(String id) {
    final metadata = Map<dynamic, dynamic>.from(widget.item.metadata ?? {});
    final checklist = _extractChecklist(metadata);
    final updated = checklist.map((c) {
      if (c['id'] == id) {
        c['completed'] = !(c['completed'] == true);
      }
      return c;
    }).toList();
    metadata['checklist'] = updated;
    ref.read(canvasStateProvider.notifier).updateContent(
      widget.item.id,
      widget.item.content,
    );
    setState(() {});
  }

  Widget _buildSectionHeader(
      IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon,
            size: 16, color: Colors.white.withValues(alpha: 0.5)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline(List<Map<String, dynamic>> timeline) {
    return Column(
      children: timeline.asMap().entries.map((entry) {
        final i = entry.key;
        final t = entry.value;
        final isLast = i == timeline.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline indicator
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: t['icon'] == 'target'
                            ? const Color(0xFF2CE38C)
                            : t['icon'] == 'start'
                                ? AppColors.accentBlue
                                : Colors.white.withValues(alpha: 0.2),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 2,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                  ],
                ),
              ),

              // Timeline content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    t['label'] ?? '',
                    style: TextStyle(
                      color: t['icon'] == 'target'
                          ? const Color(0xFF2CE38C)
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: t['icon'] == 'target'
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _RoadmapRingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final List<Color> gradientColors;

  _RoadmapRingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    final strokeWidth = 10.0;

    // Background ring
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = backgroundColor;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: gradientColors,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RoadmapRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
