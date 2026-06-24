import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/app_providers.dart';
import '../providers/os_providers.dart';


class HeroSection extends ConsumerWidget {
  const HeroSection({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final osState = ref.watch(osStateProvider);
    final now = DateTime.now();
    final timeStr = DateFormat('h:mm a').format(now);
    final dateStr = DateFormat('EEEE, MMMM d').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weather, Date, and Time Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.wb_sunny_rounded, color: Colors.orangeAccent, size: 16),
                const SizedBox(width: 6),
                Text(osState.weatherStub, style: AppTypography.caption(color: Colors.white70)),
                const SizedBox(width: 12),
                Text('•  $dateStr', style: AppTypography.caption(color: Colors.white54)),
              ],
            ),
            Text(timeStr, style: AppTypography.caption(color: Colors.white)),
          ],
        ),
        const SizedBox(height: 24),
        
        // Greeting & Avatar Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getGreeting(), style: AppTypography.titleMedium(color: Colors.white54)),
                const SizedBox(height: 4),
                Text(
                  ref.watch(hiveDatabaseProvider).getUserName() ?? 'Syed',
                  style: AppTypography.displayLarge(color: Colors.white).copyWith(fontSize: 40),
                ),
              ],
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder, width: 2),
                color: Colors.white12,
              ),
              child: const Icon(Icons.person, color: Colors.white54, size: 32),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Motivational Anchor
        Text(
          '"Today\'s actions build tomorrow\'s identity."',
          style: AppTypography.bodyMedium(color: AppColors.accentBlue).copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 24),

        // Quick Stats Row (Streak, Level, Focus Points)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildStatChip(
                icon: Icons.local_fire_department_rounded,
                color: Colors.orangeAccent,
                value: '${osState.currentStreak} Day Streak',
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                icon: Icons.star_rounded,
                color: Colors.purpleAccent,
                value: 'Level ${osState.level}',
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                icon: Icons.bolt_rounded,
                color: Colors.yellowAccent,
                value: '${osState.xp} Focus Pts',
              ),
              if (osState.activeIdentity.isNotEmpty) ...[
                const SizedBox(width: 12),
                _buildStatChip(
                  icon: Icons.psychology_rounded,
                  color: Colors.tealAccent,
                  value: osState.activeIdentity,
                ),
              ],
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStatChip({required IconData icon, required Color color, required String value}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(value, style: AppTypography.captionSmall(color: Colors.white).copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
