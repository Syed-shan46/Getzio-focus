import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/vision_item.dart';
import '../providers/canvas_providers.dart';
import 'premium_goal_shelf_card.dart';
import 'vision_creation_sheet.dart';

class PremiumGoalShelf extends ConsumerStatefulWidget {
  const PremiumGoalShelf({super.key});

  @override
  ConsumerState<PremiumGoalShelf> createState() => _PremiumGoalShelfState();
}

class _PremiumGoalShelfState extends ConsumerState<PremiumGoalShelf> {
  late PageController _pageController;
  double _currentPageValue = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPageValue = _pageController.page ?? 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openCreationSheet() {
    HapticFeedback.mediumImpact();
    VisionCreationSheet.show(
      context,
      onAddGoal: () {
        // Example: Add a new dummy goal instantly for the MVP flow
        // The real MVP flow adds this dynamically or via sheet.
        final randomColor = Colors.primaries[math.Random().nextInt(Colors.primaries.length)];
        final newGoal = VisionItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: VisionItemType.goal.name,
          content: 'New Goal',
          colorValue: randomColor.toARGB32(),
        );
        ref.read(canvasStateProvider.notifier).addItem(newGoal);
      },
      // Not relevant for goal shelf, pass no-ops
      onAddPlan: () {},
      onAddTask: () {},
      onAddStickyNote: () {},
      onAddCountdown: () {},
      onAddFinance: () {},
      onAddQuote: () {},
      onAddImage: () {},
      onAddFrame: () {},
      onAddText: () {},
      onEnterEditMode: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasStateProvider);
    final goals = canvasState.items.where((item) => item.type == VisionItemType.goal.name).toList();

    return SizedBox(
      height: 480, // Premium height for beautiful display
      child: goals.isEmpty
          ? Center(
              child: _buildEmptyState(),
            )
          : Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: math.min(goals.length + 1, 7), // Up to 6 goals + 1 "Add" card
                  itemBuilder: (context, index) {
                    if (index == goals.length || index == 6) {
                      return _buildAddMoreCard(index);
                    }
                    return _buildCarouselCard(goals[index], index);
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildCarouselCard(VisionItem goal, int index) {
    // 3D Perspective calculation
    final difference = index - _currentPageValue;
    final isSelected = difference.abs() < 0.5;

    // Scale and Rotation
    final scale = 1.0 - (difference.abs() * 0.1).clamp(0.0, 0.2);
    final rotationY = difference * -0.2; // slight inward rotation
    final opacity = (1.0 - (difference.abs() * 0.4)).clamp(0.3, 1.0);

    return Opacity(
      opacity: opacity,
      child: Transform(
        alignment: FractionalOffset.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspective
          ..rotateY(rotationY)
          ..scale(scale),
        child: PremiumGoalShelfCard(
          item: goal,
          isSelected: isSelected,
          scale: scale,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: _openCreationSheet,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 380,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star_rounded, color: Colors.orangeAccent, size: 48),
                ),
                const SizedBox(height: 24),
                Text(
                  'Create Your First Goal',
                  style: AppTypography.displayMedium(color: Colors.white).copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Turn your biggest dream into daily progress.',
                    style: AppTypography.bodyLarge(color: Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _openCreationSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: Text('Create Goal', style: AppTypography.titleMedium(color: Colors.black)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddMoreCard(int index) {
    final difference = index - _currentPageValue;
    final scale = 1.0 - (difference.abs() * 0.1).clamp(0.0, 0.2);
    final rotationY = difference * -0.2;
    final opacity = (1.0 - (difference.abs() * 0.4)).clamp(0.3, 1.0);

    return Opacity(
      opacity: opacity,
      child: Transform(
        alignment: FractionalOffset.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(rotationY)
          ..scaleByDouble(scale, scale, 1.0, 1.0),
        child: GestureDetector(
          onTap: _openCreationSheet,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1, style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white38, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Add Another Goal',
                  style: AppTypography.titleMedium(color: Colors.white38),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
