import 'dart:ui';
import 'package:flutter/material.dart';

/// Three compact glassmorphism stat cards that sit on the room floor.
/// Uses perspective Transform + oval floor shadow to create a convincing 3D
/// "resting on surface" look without any animated floor grid.
class FloorGlassPanel extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final int streakDays;
  // Kept for backwards compat — no-op.
  final bool showPerspectiveFloor;

  const FloorGlassPanel({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    required this.streakDays,
    this.showPerspectiveFloor = false,
  });

  @override
  Widget build(BuildContext context) {
    final double pct =
        totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _GroundedCard(
          icon: Icons.check_circle_outline_rounded,
          value: '$completedTasks/$totalTasks',
          label: 'Done',
          accentColor: const Color(0xFF4DA3FF),
          progress: pct,
        ),
        _GroundedCard(
          icon: Icons.bolt_rounded,
          value: '${(pct * 100).toInt()}%',
          label: 'Progress',
          accentColor: const Color(0xFF2CE38C),
          progress: pct,
          extraHeight: 8,
        ),
        _GroundedCard(
          icon: Icons.local_fire_department_rounded,
          value: '$streakDays',
          label: 'Cleared',
          accentColor: const Color(0xFFFF8C42),
        ),
      ],
    );
  }
}

// ─── Single grounded glassmorphism tile ──────────────────────────────────────
class _GroundedCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accentColor;
  final double? progress;
  final double extraHeight;

  const _GroundedCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accentColor,
    this.progress,
    this.extraHeight = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Content size (tightly calculated to avoid overflow):
    // Icon(22) + gap(4) + value-text(~18) + gap(2) + label(~12) + optional[gap(4)+progress(3)]
    // Without progress: 22+4+18+2+12 = 58px content
    // With progress:    58+4+3       = 65px content
    // Padding: h=8 top+bot=16px
    // Card height needed: 65+16 = 81px + extraHeight
    const double cardW = 94.0;
    final double cardH = 84.0 + extraHeight;

    return SizedBox(
      width: cardW,
      height: cardH + 10, // +10 for oval shadow below
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // ── Oval floor shadow — "resting on surface" depth ──────────────
          Positioned(
            bottom: 0,
            left: 6,
            right: 6,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.28),
                    blurRadius: 12,
                    spreadRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.30),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // ── Glass card with 3D perspective tilt ─────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: cardH,
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateX(-0.09),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    // tight padding so content fits in cardH
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.16),
                          Colors.white.withValues(alpha: 0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon badge
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Icon(icon, color: accentColor, size: 13),
                        ),
                        const SizedBox(height: 4),

                        // Value
                        Text(
                          value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 1),

                        // Label
                        Text(
                          label,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                        ),

                        // Progress bar (only on cards that have it)
                        if (progress != null) ...[
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.10),
                              valueColor:
                                  AlwaysStoppedAnimation(accentColor),
                              minHeight: 3.0,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Top specular highlight (3D catch-light on glass top edge) ───
          Positioned(
            top: 0,
            left: 10,
            right: 10,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.50),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
