import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Glass floating action button with blue glow.
class GlassFab extends StatelessWidget {
  final VoidCallback onPressed;

  const GlassFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipOval(
        child: Container(
          width: 60,
          height: 60,
          decoration: GlassDecoration.fab(),
          child: const Center(
            child: Icon(
              Icons.add_rounded,
              color: AppColors.accentBlue,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
