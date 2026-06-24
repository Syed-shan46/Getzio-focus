import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

/// Premium animated chip used across all onboarding screens.
/// Supports emoji icon, title, optional subtitle, and satisfying selection animations.
class PremiumChip extends StatefulWidget {
  final String emoji;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? activeColor;

  const PremiumChip({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.activeColor,
  });

  @override
  State<PremiumChip> createState() => _PremiumChipState();
}

class _PremiumChipState extends State<PremiumChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? AppColors.accentBlue;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: widget.subtitle != null ? 12 : 10,
            vertical: widget.subtitle != null ? 8 : 6,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? activeColor.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected
                  ? activeColor.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.08),
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.15),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 6),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: AppTypography.bodyMedium(
                        color: widget.isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.7),
                      ).copyWith(
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 12.5,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        widget.subtitle!,
                        style: AppTypography.captionSmall(
                          color: Colors.white.withValues(alpha: 0.4),
                        ).copyWith(fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.isSelected) ...[
                const SizedBox(width: 5),
                Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: activeColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A text-only variant of the premium chip (no emoji) for options like
/// savings targets, book counts, reading times, etc.
class PremiumPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? activeColor;

  const PremiumPill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.accentBlue;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodyMedium(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
          ).copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
