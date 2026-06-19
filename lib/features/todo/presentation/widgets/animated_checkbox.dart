import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

/// Custom animated circular checkbox with scale + fill animation.
class AnimatedCheckbox extends StatefulWidget {
  final bool checked;
  final ValueChanged<bool> onChanged;
  final double size;
  final Color activeColor;

  const AnimatedCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
    this.size = 26,
    this.activeColor = AppColors.accentEmerald,
  });

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fill;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.1), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fill = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.checked) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.checked != oldWidget.checked) {
      if (widget.checked) {
        _controller.forward(from: 0.0);
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onChanged(!widget.checked);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.checked
                      ? widget.activeColor
                      : AppColors.glassBorder,
                  width: 2,
                ),
                color: widget.checked
                    ? widget.activeColor.withValues(alpha: _fill.value * 0.2)
                    : Colors.transparent,
              ),
              child: widget.checked
                  ? Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: widget.size * 0.55,
                        color: widget.activeColor.withValues(alpha: _fill.value),
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
