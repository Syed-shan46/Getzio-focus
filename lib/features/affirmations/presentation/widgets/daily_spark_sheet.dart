import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'hanging_affirmation_board.dart';
import '../providers/affirmations_provider.dart';
import '../../domain/models/affirmation_model.dart';
import 'affirmation_bottom_sheet.dart';
import 'package:getzio_todo_app/core/theme/app_theme.dart';

/// A premium full-screen bottom sheet that reveals the hanging affirmation
/// board with backdrop blur, fade-in, and spring animation.
class DailySparkSheet extends ConsumerStatefulWidget {
  const DailySparkSheet({super.key});

  /// Shows the premium daily spark sheet.
  static Future<void> show(BuildContext context) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      isDismissible: true,
      enableDrag: false,
      useSafeArea: false,
      builder: (context) => const DailySparkSheet(),
    );
  }

  @override
  ConsumerState<DailySparkSheet> createState() => _DailySparkSheetState();
}

class _DailySparkSheetState extends ConsumerState<DailySparkSheet>
    with TickerProviderStateMixin {
  late AnimationController _sheetController;
  late AnimationController _fadeController;
  late Animation<double> _sheetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _sheetAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sheetController, curve: Curves.easeOutBack),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();
    _sheetController.forward();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _close() {
    HapticFeedback.lightImpact();
    _fadeController.reverse();
    _sheetController.reverse().then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _showActionsMenu() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ActionsBottomSheet(
        onAdd: () {
          Navigator.pop(context);
          AffirmationBottomSheet.show(this.context);
        },
        onShuffle: () {
          Navigator.pop(context);
          _shuffleColors();
        },
        onRandomQuote: () {
          Navigator.pop(context);
          _showRandomQuote();
        },
      ),
    );
  }

  void _shuffleColors() {
    HapticFeedback.mediumImpact();
    // Trigger a rebuild with shuffled color indices
    setState(() {});
  }

  void _showRandomQuote() {
    HapticFeedback.lightImpact();
    final quotes = [
      'Believe you can and you\'re halfway there.',
      'The only way to do great work is to love what you do.',
      'Success is not final, failure is not fatal: it is the courage to continue that counts.',
      'Your limitation—it\'s only your imagination.',
      'Push yourself, because no one else is going to do it for you.',
    ];
    final randomQuote = quotes[DateTime.now().millisecond % quotes.length];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5EDD8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Random Inspiration',
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFF3D2A18),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '"$randomQuote"',
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFF5C4E35),
            fontSize: 16,
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.outfit(color: const Color(0xFF8B7355)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final affState = ref.watch(affirmationsProvider);
    final affirmations = ref
        .read(affirmationsProvider.notifier)
        .getFilteredAffirmations();

    final pinned = affirmations.where((a) => a.isPinned).toList();
    final normal = affirmations.where((a) => !a.isPinned).toList();
    final sortedAffirmations = [...pinned, ...normal];

    final repeatCounts = <String, int>{};
    for (var aff in sortedAffirmations) {
      repeatCounts[aff.id] = affState.repeatCounts[aff.id] ?? 0;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_sheetController, _fadeController]),
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            if (_fadeAnimation.value > 0.01)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _close,
                  child: Container(
                    color: Colors.black.withValues(
                      alpha: 0.35 * _fadeAnimation.value,
                    ),
                  ),
                ),
              ),

            // Sheet content
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    (1 - _sheetAnimation.value) *
                        MediaQuery.of(context).size.height,
                  ),
                  child: Opacity(
                    opacity: _sheetAnimation.value.clamp(0.0, 1.0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(0),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          HangingAffirmationBoard(
                            affirmations: sortedAffirmations,
                            repeatCounts: repeatCounts,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          ],
        );
      },
    );
  }

}

/// Bottom sheet with actions: Add, Edit, Delete, Shuffle, Preview, Random Quote.
class _ActionsBottomSheet extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onShuffle;
  final VoidCallback onRandomQuote;

  const _ActionsBottomSheet({
    required this.onAdd,
    required this.onShuffle,
    required this.onRandomQuote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1510),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: context.colors.glassBorder),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: context.colors.textPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Board Actions',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _ActionTile(
                icon: Icons.add_circle_outline,
                label: 'Add Affirmation',
                onTap: onAdd,
              ),
              _ActionTile(
                icon: Icons.shuffle,
                label: 'Shuffle Colors',
                onTap: onShuffle,
              ),
              _ActionTile(
                icon: Icons.auto_awesome,
                label: 'Random Quote',
                onTap: onRandomQuote,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.textPrimary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.glassBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFB5C4B1), size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
