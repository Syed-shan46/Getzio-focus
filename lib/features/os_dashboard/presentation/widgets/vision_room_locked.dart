import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../vision_room/presentation/screens/vision_room_screen.dart';
import '../providers/os_providers.dart';

class VisionRoomLockedCard extends ConsumerStatefulWidget {
  const VisionRoomLockedCard({super.key});

  @override
  ConsumerState<VisionRoomLockedCard> createState() => _VisionRoomLockedCardState();
}

class _VisionRoomLockedCardState extends ConsumerState<VisionRoomLockedCard> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _doorOpenController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _doorOpenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _doorOpenController.dispose();
    super.dispose();
  }

  void _handleTap(bool isUnlocked) {
    HapticFeedback.mediumImpact();
    if (isUnlocked) {
      // Unlocked: Open doors and then navigate
      _doorOpenController.forward().then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VisionRoomScreen()),
        ).then((_) {
          // Reset doors on return
          _doorOpenController.reverse();
        });
      });
    } else {
      // Locked: Shake card animation
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(osStateProvider);
    
    final completedHabits = state.totalHabitsCompletedAllTime;
    final currentXp = state.xp;
    
    const targetHabits = 50;
    const targetXp = 500;
    
    final isUnlocked = completedCountMet(completedHabits, targetHabits) || xpMet(currentXp, targetXp);
    
    // Progress is the max of either condition
    final habitProgress = (completedHabits / targetHabits).clamp(0.0, 1.0);
    final xpProgress = (currentXp / targetXp).clamp(0.0, 1.0);
    final maxProgress = math.max(habitProgress, xpProgress);

    // Shake offset interpolation
    final shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );

    return AnimatedBuilder(
      animation: shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(shakeAnimation.value, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () => _handleTap(isUnlocked),
        onLongPress: () => _handleTap(true), // Secret debug bypass
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isUnlocked ? const Color(0xFFD4AF37).withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                            color: isUnlocked ? const Color(0xFFD4AF37) : Colors.white30,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Spatial Command Center',
                            style: AppTypography.titleMedium(color: Colors.white70),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isUnlocked ? const Color(0xFFD4AF37).withValues(alpha: 0.15) : Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isUnlocked ? 'READY' : 'LOCKED',
                          style: AppTypography.captionSmall(
                            color: isUnlocked ? const Color(0xFFD4AF37) : Colors.white54,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Door Illustration & Description
                  Row(
                    children: [
                      // Luxury Door 3D visualizer
                      SizedBox(
                        width: 90,
                        height: 120,
                        child: AnimatedBuilder(
                          animation: _doorOpenController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: DoorPainter(
                                openProgress: _doorOpenController.value,
                                isUnlocked: isUnlocked,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      
                      // Message
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUnlocked ? 'Enter Vision Room' : 'Your Vision Room',
                              style: AppTypography.titleLarge(color: Colors.white).copyWith(
                                fontSize: 20,
                                color: isUnlocked ? const Color(0xFFD4AF37) : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isUnlocked
                                  ? 'Your private focus sanctuary is unlocked. Tap to open the golden gates.'
                                  : 'Stay consistent to unlock your private space. Complete habits to earn keys.',
                              style: AppTypography.bodyMedium(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Unlock Requirement details
                  Text(
                    'UNLOCK REQUIREMENT',
                    style: AppTypography.captionSmall(color: Colors.white30).copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Criteria 1: 50 Habits
                  _buildRequirementItem(
                    label: 'Complete 50 Habits',
                    current: completedHabits,
                    target: targetHabits,
                    isCompleted: completedCountMet(completedHabits, targetHabits),
                  ),
                  const SizedBox(height: 8),

                  // Criteria 2: 500 XP
                  _buildRequirementItem(
                    label: 'Reach 500 XP',
                    current: currentXp,
                    target: targetXp,
                    isCompleted: xpMet(currentXp, targetXp),
                  ),
                  const SizedBox(height: 16),

                  // Overall progress slider
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: maxProgress,
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isUnlocked ? const Color(0xFFD4AF37) : AppColors.accentBlue,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool completedCountMet(int count, int target) => count >= target;
  bool xpMet(int xp, int target) => xp >= target;

  Widget _buildRequirementItem({
    required String label,
    required int current,
    required int target,
    required bool isCompleted,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
              color: isCompleted ? AppColors.accentEmerald : Colors.white24,
              size: 14,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.caption(color: isCompleted ? Colors.white70 : Colors.white30),
            ),
          ],
        ),
        Text(
          '$current / $target',
          style: AppTypography.captionSmall(color: isCompleted ? AppColors.accentEmerald : Colors.white30).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LUXURY 3D DOUBLE-DOOR CUSTOM PAINTER
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class DoorPainter extends CustomPainter {
  final double openProgress;
  final bool isUnlocked;

  DoorPainter({required this.openProgress, required this.isUnlocked});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Draw door frame
    final framePaint = Paint()
      ..color = isUnlocked ? const Color(0xFFD4AF37).withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final frameRect = Rect.fromLTRB(4, 4, width - 4, height - 4);
    canvas.drawRect(frameRect, framePaint);

    // Draw background portal glow (behind doors)
    if (isUnlocked) {
      final portalPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFD4AF37).withValues(alpha: 0.4),
            const Color(0xFFD4AF37).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, width, height));
      canvas.drawRect(Rect.fromLTRB(6, 6, width - 6, height - 6), portalPaint);
    }

    // Door Panel Painting (Left and Right doors)
    final doorPaint = Paint()
      ..color = isUnlocked ? const Color(0xFF161E35) : const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = isUnlocked ? const Color(0xFFD4AF37) : Colors.white24
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final halfWidth = (width - 10) / 2;

    // Left Door
    canvas.save();
    // 3D Hinge Rotation Perspective
    final leftXOffset = 6.0;
    canvas.translate(leftXOffset, height / 2);
    // Skewing matrix to represent 3D depth rotation
    var matrixLeft = Matrix4.identity()
      ..setEntry(3, 2, 0.002) // perspective
      ..rotateY(-openProgress * math.pi / 2.2);
    canvas.transform(matrixLeft.storage);
    canvas.translate(-leftXOffset, -height / 2);
    
    // Draw Left door surface
    final leftDoorRect = Rect.fromLTWH(leftXOffset, 6, halfWidth, height - 12);
    canvas.drawRect(leftDoorRect, doorPaint);
    canvas.drawRect(leftDoorRect, borderPaint);
    
    // Inner panel trim for luxury look
    canvas.drawRect(
      leftDoorRect.deflate(6),
      borderPaint..strokeWidth = 0.8,
    );
    // Door knob
    canvas.drawCircle(
      Offset(leftXOffset + halfWidth - 5, height / 2),
      2.5,
      Paint()..color = isUnlocked ? const Color(0xFFD4AF37) : Colors.white30,
    );
    canvas.restore();

    // Right Door
    canvas.save();
    // 3D Hinge Rotation Perspective (anchored on right edge)
    final rightXAnchor = width - 6.0;
    canvas.translate(rightXAnchor, height / 2);
    var matrixRight = Matrix4.identity()
      ..setEntry(3, 2, 0.002)
      ..rotateY(openProgress * math.pi / 2.2);
    canvas.transform(matrixRight.storage);
    canvas.translate(-rightXAnchor, -height / 2);
    
    // Draw Right door surface
    final rightDoorRect = Rect.fromLTWH(rightXAnchor - halfWidth, 6, halfWidth, height - 12);
    canvas.drawRect(rightDoorRect, doorPaint);
    canvas.drawRect(rightDoorRect, borderPaint..strokeWidth = 1.5);
    
    // Inner panel trim
    canvas.drawRect(
      rightDoorRect.deflate(6),
      borderPaint..strokeWidth = 0.8,
    );
    // Door knob
    canvas.drawCircle(
      Offset(rightXAnchor - halfWidth + 5, height / 2),
      2.5,
      Paint()..color = isUnlocked ? const Color(0xFFD4AF37) : Colors.white30,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DoorPainter oldDelegate) =>
      oldDelegate.openProgress != openProgress || oldDelegate.isUnlocked != isUnlocked;
}
