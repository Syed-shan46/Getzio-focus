import 'package:flutter/material.dart';

class RoomBackground extends StatelessWidget {
  const RoomBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.5, -0.6), // Top left glow
          radius: 1.5,
          colors: [
            Color(0xFF1E293B), // Soft slate
            Color(0xFF0F172A), // Dark slate
            Color(0xFF050816), // Deepest black
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      // Future: Add animated soft light spots here
    );
  }
}
