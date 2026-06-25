import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/vision_room_providers.dart';
import '../walls/vision_wall.dart';
import '../walls/habit_wall.dart';
import '../walls/motivation_wall.dart';
import '../walls/achievement_wall.dart';
import '../walls/finance_wall.dart';
import '../walls/timeline_wall.dart';


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

                  // 5. UI Overlay (Top Bar)
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
