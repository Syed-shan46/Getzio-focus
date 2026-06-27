import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/affirmation_model.dart';
import '../providers/affirmations_provider.dart';
import 'dedicated_editor_screen.dart';

class ReaderViewScreen extends ConsumerStatefulWidget {
  final DailyAffirmation affirmation;
  const ReaderViewScreen({super.key, required this.affirmation});

  @override
  ConsumerState<ReaderViewScreen> createState() => _ReaderViewScreenState();
}

class _ReaderViewScreenState extends ConsumerState<ReaderViewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;
  late DailyAffirmation _currentAff;

  @override
  void initState() {
    super.initState();
    _currentAff = widget.affirmation;

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // Slow, meditative breathing cycle (4s in, 4s out)
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseOpacity = Tween<double>(begin: 0.25, end: 0.45).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );

    // Register completion/XP gain on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(affirmationsProvider.notifier).completePractice();
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  Color _getThemeBgColor() {
    switch (_currentAff.colorTheme) {
      case 'Sunrise Orange': return const Color(0xFFFFF7ED);
      case 'Ocean Blue': return const Color(0xFFF0F9FF);
      case 'Minimal White': return const Color(0xFFFAFAFA);
      case 'Midnight Black': return const Color(0xFF030712);
      case 'Forest Green': return const Color(0xFFF0FDF4);
      case 'Lavender': return const Color(0xFFFAF5FF);
      case 'Coffee Brown': return const Color(0xFFFDF8F5);
      case 'Dark Glass': return const Color(0xFF111827);
      default: return const Color(0xFFFAFAFA);
    }
  }

  Color _getThemeTextColor() {
    switch (_currentAff.colorTheme) {
      case 'Midnight Black': return const Color(0xFFF9FAFB);
      case 'Dark Glass': return const Color(0xFFE5E7EB);
      case 'Sunrise Orange': return const Color(0xFF7C2D12);
      case 'Ocean Blue': return const Color(0xFF0C4A6E);
      case 'Forest Green': return const Color(0xFF14532D);
      case 'Lavender': return const Color(0xFF581C87);
      case 'Coffee Brown': return const Color(0xFF431407);
      default: return const Color(0xFF1F2937);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes in provider state so if we update in DedicatedEditorScreen it reflects immediately!
    final state = ref.watch(affirmationsProvider);
    final fresh = state.affirmations.firstWhere((a) => a.id == _currentAff.id, orElse: () => _currentAff);
    _currentAff = fresh;

    final themeBg = _getThemeBgColor();
    final textCol = _getThemeTextColor();
    final subTextCol = textCol.withOpacity(0.55);

    return Scaffold(
      backgroundColor: themeBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient breathing soft glow element in the center background
          Positioned(
            left: 20,
            right: 20,
            top: MediaQuery.of(context).size.height * 0.25,
            bottom: MediaQuery.of(context).size.height * 0.25,
            child: ScaleTransition(
              scale: _pulseScale,
              child: AnimatedBuilder(
                animation: _pulseOpacity,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _currentAff.colorTheme == 'Midnight Black' || _currentAff.colorTheme == 'Dark Glass'
                              ? const Color(0xFF6366F1).withOpacity(_pulseOpacity.value)
                              : const Color(0xFFF59E0B).withOpacity(_pulseOpacity.value),
                          blurRadius: 100,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Minimal header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: textCol.withOpacity(0.04),
                            shape: BoxShape.circle,
                            border: Border.all(color: textCol.withOpacity(0.08), width: 0.8),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded, color: textCol.withOpacity(0.7), size: 16),
                        ),
                      ),
                      Text(
                        'PRACTICE',
                        style: GoogleFonts.outfit(
                          color: subTextCol,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DedicatedEditorScreen(affirmation: _currentAff),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: textCol.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: textCol.withOpacity(0.08), width: 0.8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, color: textCol.withOpacity(0.7), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: GoogleFonts.outfit(
                                  color: textCol.withOpacity(0.8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Visual breathing cues instructions
                Center(
                  child: AnimatedBuilder(
                    animation: _breathingController,
                    builder: (context, child) {
                      final val = _breathingController.value;
                      final isInhaling = _breathingController.status == AnimationStatus.forward;
                      return Text(
                        isInhaling ? 'Breathe In' : 'Breathe Out',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: subTextCol.withOpacity(0.4 + (val * 0.4)),
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Main card quote reader
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_currentAff.emoji != null && _currentAff.emoji!.isNotEmpty) ...[
                        Text(
                          _currentAff.emoji!,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        '"${_currentAff.text}"',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          color: textCol,
                          fontWeight: FontWeight.bold,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentAff.author != null && _currentAff.author!.isNotEmpty
                            ? '— ${_currentAff.author}'
                            : '— Focus Room',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: subTextCol,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Breathing animation circle helper
                Center(
                  child: ScaleTransition(
                    scale: _pulseScale,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: textCol.withOpacity(0.03),
                        border: Border.all(color: textCol.withOpacity(0.12), width: 1.2),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.lens,
                          size: 10,
                          color: textCol.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Actions bar (Share, Favorite, Pin)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Favorite
                      _buildActionButton(
                        icon: _currentAff.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _currentAff.isFavorite ? Colors.redAccent : textCol,
                        label: 'Favorite',
                        textColor: subTextCol,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(affirmationsProvider.notifier).toggleFavorite(_currentAff.id);
                        },
                      ),
                      // Pin
                      _buildActionButton(
                        icon: _currentAff.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                        color: _currentAff.isPinned ? Colors.amber : textCol,
                        label: 'Pin Wall',
                        textColor: subTextCol,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(affirmationsProvider.notifier).togglePin(_currentAff.id);
                        },
                      ),
                      // Share
                      _buildActionButton(
                        icon: Icons.share_rounded,
                        color: textCol,
                        label: 'Share',
                        textColor: subTextCol,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Clipboard.setData(ClipboardData(text: '"${_currentAff.text}" — ${_currentAff.author ?? 'Focus'}'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: textCol,
                              content: Text(
                                'Affirmation copied to clipboard',
                                style: TextStyle(color: themeBg),
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.12), width: 0.8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 10, color: textColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
