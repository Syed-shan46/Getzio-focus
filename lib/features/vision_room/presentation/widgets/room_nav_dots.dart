import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class RoomNavDots extends StatelessWidget {
  final PageController controller;
  final List<String> names;
  final ValueChanged<int>? onDotTapped;

  const RoomNavDots({
    super.key,
    required this.controller,
    required this.names,
    this.onDotTapped,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final page = controller.position.haveDimensions ? controller.page ?? 3 : 3.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(names.length, (index) {
              final isSelected = (page.round() == index);
              final distance = (page - index).abs();
              final scale = (1 - (distance * 0.3)).clamp(0.5, 1.0);
              final opacity = (1 - (distance * 0.5)).clamp(0.2, 1.0);

              return GestureDetector(
                onTap: () {
                  if (onDotTapped != null) {
                    onDotTapped!(index);
                  } else {
                    controller.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: isSelected ? 24 : 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: opacity),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ] : null,
                  ),
                  transform: Matrix4.identity()..scale(scale),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
