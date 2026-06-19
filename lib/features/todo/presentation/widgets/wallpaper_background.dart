import 'package:flutter/material.dart';

/// Full-screen wallpaper with overlay.
/// All UI content should be placed as a child of this widget.
class WallpaperBackground extends StatelessWidget {
  final Widget child;

  const WallpaperBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Wallpaper image
        Image.asset(
          'assets/images/wallpaper1.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),

        // Dark overlay (25%)

        // Content
        Positioned.fill(child: child),
      ],
    );
  }
}
