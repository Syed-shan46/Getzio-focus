import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/vision_room_providers.dart';
import '../walls/vision_wall.dart';
import '../walls/habit_wall.dart';
import '../walls/motivation_wall.dart';
import '../walls/achievement_wall.dart';
import '../walls/finance_wall.dart';
import '../walls/timeline_wall.dart';
import '../widgets/room_nav_dots.dart';

class VisionRoomScreen extends ConsumerStatefulWidget {
  const VisionRoomScreen({super.key});

  @override
  ConsumerState<VisionRoomScreen> createState() => _VisionRoomScreenState();
}

class _VisionRoomScreenState extends ConsumerState<VisionRoomScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<String> _wallNames = [
    'Finance Wall',
    'Achievement Wall',
    'Habit Wall',
    'Vision Board',
    'Motivation Wall',
    'Future Timeline'
  ];

  final Set<int> _visitedBoards = {3};

  void _handleDotTapped(int index) {
    final isGuest = ref.read(authProvider).value == null;
    if (isGuest) {
      if (!_visitedBoards.contains(index)) {
        if (_visitedBoards.length >= 3) {
          _showPremiumAuthSheet(context);
          return;
        } else {
          setState(() {
            _visitedBoards.add(index);
          });
        }
      }
    }
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  void _showPremiumAuthSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.fromBorderSide(BorderSide(color: Colors.white10, width: 1.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Save Your Vision Forever',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Create your free account to unlock unlimited Vision Room boards, sync across devices, and securely back up your dreams.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                _buildSocialButton(
                  context,
                  icon: Icons.g_mobiledata_rounded,
                  label: 'Continue with Google',
                  color: Colors.redAccent,
                  provider: 'Google',
                ),
                const SizedBox(height: 12),
                _buildSocialButton(
                  context,
                  icon: Icons.apple_rounded,
                  label: 'Continue with Apple',
                  color: Colors.white,
                  provider: 'Apple',
                ),
                const SizedBox(height: 12),
                _buildSocialButton(
                  context,
                  icon: Icons.mail_outline_rounded,
                  label: 'Continue with Email',
                  color: AppColors.accentBlue,
                  provider: 'Email',
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Maybe Later',
                    style: TextStyle(color: Colors.white30, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required String provider,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          ref.read(authProvider.notifier).simulateSocialLogin(provider);
        },
        icon: Icon(icon, color: color == Colors.white ? Colors.black : Colors.white, size: 24),
        label: Text(
          label,
          style: TextStyle(
            color: color == Colors.white ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color == Colors.white ? Colors.white : Colors.white.withValues(alpha: 0.05),
          side: color == Colors.white ? null : const BorderSide(color: Colors.white10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Default to Vision Board (index 3)
    _pageController = PageController(initialPage: 3, viewportFraction: 1.0);
    
    // Cinematic Entry Animation
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focusMode = ref.watch(focusModeProvider);
    
    return Scaffold(
      backgroundColor: Colors.black, // Base layer for fade
      extendBodyBehindAppBar: true,
      body: AnimatedBuilder(
        animation: _entryController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Stack(
                children: [
                  // 1. Solid premium background color
                  Container(color: const Color(0xFF0B101E)),

                  // 2. Walls (PageView)
                  PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Temporarily blocked left/right scroll
                    onPageChanged: (index) {
                      ref.read(currentWallIndexProvider.notifier).state = index;
                    },
                    itemCount: _wallNames.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (_pageController.position.haveDimensions) {
                            value = _pageController.page! - index;
                            value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                          }

                          // Parallax + Depth Tilt
                          final tilt = _pageController.position.haveDimensions 
                              ? (_pageController.page! - index) * 0.1 
                              : 0.0;

                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001) // perspective
                              ..rotateY(-tilt),
                            alignment: Alignment.center,
                            child: Opacity(
                              opacity: value.clamp(0.5, 1.0),
                              child: _buildWallContent(index),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // 4. Focus Mode Overlay
                  if (focusMode)
                    Container(
                      color: Colors.black.withValues(alpha: 0.7),
                      // Interaction blocking handled elsewhere
                    ),

                  // 5. UI Overlay (Top Bar + Nav Dots)
                  SafeArea(
                    child: IgnorePointer(
                      ignoring: focusMode,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: focusMode ? 0.0 : 1.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildTopBar(),
                            RoomNavDots(
                              controller: _pageController,
                              names: _wallNames,
                              onDotTapped: _handleDotTapped,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWallContent(int index) {
    switch (index) {
      case 0: return const FinanceWall();
      case 1: return const AchievementWall();
      case 2: return const HabitWall();
      case 3: return const VisionWall();
      case 4: return const MotivationWall();
      case 5: return const TimelineWall();
      default: return const SizedBox();
    }
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.glass,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder, width: 0.5),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
            ),
          ),
          
          // Removed Wall Label and Tune icon per user request to keep the UI minimal.
        ],
      ),
    );
  }
}
