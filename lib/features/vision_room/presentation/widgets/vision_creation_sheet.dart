import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

/// Premium bottom sheet that opens when tapping the Hanging Pen.
/// Contains two sections: Create (add items) and Edit Mode (enter in-place editing).
class VisionCreationSheet extends StatelessWidget {
  final VoidCallback onAddImage;
  final VoidCallback onAddStickyNote;
  final VoidCallback onAddQuote;
  final VoidCallback onAddGoal;
  final VoidCallback onAddPlan;
  final VoidCallback onAddTask;
  final VoidCallback onAddCountdown;
  final VoidCallback onAddFinance;
  final VoidCallback onAddFrame;
  final VoidCallback onAddText;
  final VoidCallback onEnterEditMode;
  final VoidCallback onExitRoom;

  const VisionCreationSheet({
    super.key,
    required this.onAddImage,
    required this.onAddStickyNote,
    required this.onAddQuote,
    required this.onAddGoal,
    required this.onAddPlan,
    required this.onAddTask,
    required this.onAddCountdown,
    required this.onAddFinance,
    required this.onAddFrame,
    required this.onAddText,
    required this.onEnterEditMode,
    required this.onExitRoom,
  });

  static void show(
    BuildContext context, {
    required VoidCallback onAddImage,
    required VoidCallback onAddStickyNote,
    required VoidCallback onAddQuote,
    required VoidCallback onAddGoal,
    required VoidCallback onAddPlan,
    required VoidCallback onAddTask,
    required VoidCallback onAddCountdown,
    required VoidCallback onAddFinance,
    required VoidCallback onAddFrame,
    required VoidCallback onAddText,
    required VoidCallback onEnterEditMode,
    required VoidCallback onExitRoom,
  }) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 500),
      )..drive(CurveTween(curve: Curves.easeOutBack)),
      builder: (context) => VisionCreationSheet(
        onAddImage: onAddImage,
        onAddStickyNote: onAddStickyNote,
        onAddQuote: onAddQuote,
        onAddGoal: onAddGoal,
        onAddPlan: onAddPlan,
        onAddTask: onAddTask,
        onAddCountdown: onAddCountdown,
        onAddFinance: onAddFinance,
        onAddFrame: onAddFrame,
        onAddText: onAddText,
        onEnterEditMode: onEnterEditMode,
        onExitRoom: onExitRoom,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
      child: Container(
        height: screenHeight * 0.76,
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 16, bottom: 8),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Create',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white60,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add new items to your vision room',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Create Grid
                    _CreateGrid(
                      items: [
                        _CreateItem(
                          icon: Icons.image_rounded,
                          title: 'Image',
                          description: 'Add a photo',
                          color: const Color(0xFF3B82F6),
                          onTap: () => _dismissAndCall(context, onAddImage),
                        ),
                        _CreateItem(
                          icon: Icons.sticky_note_2_rounded,
                          title: 'Sticky Note',
                          description: 'Quick note',
                          color: const Color(0xFFF59E0B),
                          onTap: () =>
                              _dismissAndCall(context, onAddStickyNote),
                        ),
                        _CreateItem(
                          icon: Icons.format_quote_rounded,
                          title: 'Quote',
                          description: 'Inspirational words',
                          color: const Color(0xFF8B5CF6),
                          onTap: () => _dismissAndCall(context, onAddQuote),
                        ),
                        _CreateItem(
                          icon: Icons.flag_rounded,
                          title: 'Goal',
                          description: 'Set a target',
                          color: const Color(0xFFEF4444),
                          onTap: () => _dismissAndCall(context, onAddGoal),
                        ),
                        _CreateItem(
                          icon: Icons.account_tree_rounded,
                          title: 'Roadmap',
                          description: 'Plan milestones',
                          color: const Color(0xFF10B981),
                          onTap: () => _dismissAndCall(context, onAddPlan),
                        ),
                        _CreateItem(
                          icon: Icons.check_circle_outline_rounded,
                          title: 'Task',
                          description: 'To-do item',
                          color: const Color(0xFFF97316),
                          onTap: () => _dismissAndCall(context, onAddTask),
                        ),
                        _CreateItem(
                          icon: Icons.timer_rounded,
                          title: 'Countdown',
                          description: 'Track a date',
                          color: const Color(0xFF06B6D4),
                          onTap: () => _dismissAndCall(context, onAddCountdown),
                        ),
                        _CreateItem(
                          icon: Icons.savings_rounded,
                          title: 'Finance Goal',
                          description: 'Save money',
                          color: const Color(0xFF14B8A6),
                          onTap: () => _dismissAndCall(context, onAddFinance),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Edit Mode Card
                    _EditModeCard(onTap: () => _enterEditMode(context)),
                    const SizedBox(height: 12),
                    
                    // Exit Room Card
                    _ExitRoomCard(onTap: () => _exitRoom(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _dismissAndCall(BuildContext context, VoidCallback action) {
    Navigator.pop(context);
    action();
  }

  void _enterEditMode(BuildContext context) {
    Navigator.pop(context);
    onEnterEditMode();
  }

  void _exitRoom(BuildContext context) {
    Navigator.pop(context);
    onExitRoom();
  }
}

// ─── CREATE GRID ───────────────────────────────────────────────────────────

class _CreateGrid extends StatelessWidget {
  final List<_CreateItem> items;

  const _CreateGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }
}

class _CreateItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _CreateItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  State<_CreateItem> createState() => _CreateItemState();
}

class _CreateItemState extends State<_CreateItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: _isPressed ? 0.08 : 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.color.withValues(alpha: _isPressed ? 0.5 : 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, color: widget.color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      widget.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── EDIT MODE CARD ────────────────────────────────────────────────────────

class _EditModeCard extends StatefulWidget {
  final VoidCallback onTap;

  const _EditModeCard({required this.onTap});

  @override
  State<_EditModeCard> createState() => _EditModeCardState();
}

class _EditModeCardState extends State<_EditModeCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.accentBlue.withValues(
                  alpha: _isPressed ? 0.25 : 0.15,
                ),
                context.colors.accentBlue.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colors.accentBlue.withValues(
                alpha: _isPressed ? 0.6 : 0.3,
              ),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: context.colors.accentBlue.withValues(alpha: 0.1),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: context.colors.accentBlue.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: context.colors.accentBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Vision Room',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Move, resize and organize your workspace',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: context.colors.accentBlue.withValues(alpha: 0.6),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExitRoomCard extends StatefulWidget {
  final VoidCallback onTap;

  const _ExitRoomCard({required this.onTap});

  @override
  State<_ExitRoomCard> createState() => _ExitRoomCardState();
}

class _ExitRoomCardState extends State<_ExitRoomCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const exitColor = Color(0xFFEF4444);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                exitColor.withValues(
                  alpha: _isPressed ? 0.25 : 0.12,
                ),
                exitColor.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: exitColor.withValues(
                alpha: _isPressed ? 0.6 : 0.25,
              ),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: exitColor.withValues(alpha: 0.08),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: exitColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.door_back_door_outlined,
                  color: exitColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Exit Vision Room',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Return to your main dashboard',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: exitColor.withValues(alpha: 0.6),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
