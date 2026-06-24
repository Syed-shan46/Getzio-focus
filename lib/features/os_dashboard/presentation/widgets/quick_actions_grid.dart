import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../vision_room/presentation/screens/vision_room_screen.dart';

class QuickActionsGrid extends ConsumerWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTypography.titleLarge(color: Colors.white)),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildActionCard(
                context,
                icon: Icons.bolt_rounded,
                label: 'Start Focus',
                color: Colors.yellowAccent,
                onTap: () {}, // Stub
              ),
              _buildActionCard(
                context,
                icon: Icons.auto_awesome_rounded,
                label: 'Vision Room',
                color: AppColors.accentBlue,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const VisionRoomScreen()));
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.flag_rounded,
                label: 'Add Goal',
                color: Colors.redAccent,
                onTap: () {},
              ),
              _buildActionCard(
                context,
                icon: Icons.check_circle_outline_rounded,
                label: 'Add Habit',
                color: AppColors.accentEmerald,
                onTap: () {},
              ),
              _buildActionCard(
                context,
                icon: Icons.book_rounded,
                label: 'Journal',
                color: Colors.purpleAccent,
                onTap: () {},
              ),
              _buildActionCard(
                context,
                icon: Icons.bar_chart_rounded,
                label: 'Weekly Review',
                color: Colors.orangeAccent,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: AppTypography.captionSmall(color: Colors.white70).copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
