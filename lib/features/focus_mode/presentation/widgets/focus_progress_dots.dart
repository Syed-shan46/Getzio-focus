import 'package:flutter/material.dart';

class FocusProgressDots extends StatelessWidget {
  final int totalDurationSeconds;
  final int remainingSeconds;
  final bool isBreakMode;
  final bool isCompact;

  const FocusProgressDots({
    super.key,
    required this.totalDurationSeconds,
    required this.remainingSeconds,
    this.isBreakMode = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (totalDurationSeconds <= 0) return const SizedBox.shrink();

    final int totalDots = isCompact ? 8 : 15;
    final double progress = 1.0 - (remainingSeconds / totalDurationSeconds).clamp(0.0, 1.0);
    final int completedDots = (progress * totalDots).floor();

    final Color activeColor = isBreakMode ? const Color(0xFF66FFB2) : const Color(0xFFFFB266);
    final double marginH = isCompact ? 1.5 : 3.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalDots, (index) {
        final isCompleted = index < completedDots;
        final isJustCompleted = index == completedDots - 1; // The one that just lit up

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          margin: EdgeInsets.symmetric(horizontal: marginH),
          width: isCompleted ? (isJustCompleted ? 8.0 : 6.0) : 4.0,
          height: isCompleted ? (isJustCompleted ? 8.0 : 6.0) : 4.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted 
                ? activeColor 
                : Colors.white.withValues(alpha: 0.1),
            boxShadow: isCompleted 
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: isJustCompleted ? 0.8 : 0.4),
                      blurRadius: isJustCompleted ? 6.0 : 3.0,
                      spreadRadius: isJustCompleted ? 1.0 : 0.0,
                    )
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
