import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../painters/wooden_plank_painter.dart';
import '../../domain/models/affirmation_model.dart';

/// Premium pastel color palette for affirmation planks.
/// Calming Scandinavian-inspired colors that rotate automatically.
class PlankColors {
  static const List<({Color plank, Color text, String name})> palette = [
    (plank: Color(0xFF8F9E8B), text: Color(0xFF2D352B), name: 'Sage Green'),
    (plank: Color(0xFFE6C5B3), text: Color(0xFF4D3126), name: 'Warm Peach'),
    (plank: Color(0xFF9EAFBE), text: Color(0xFF26323D), name: 'Dusty Blue'),
    (plank: Color(0xFFF5F2EB), text: Color(0xFF3C3932), name: 'Cream White'),
    (plank: Color(0xFFE4DDD3), text: Color(0xFF3B362F), name: 'Soft Beige'),
    (plank: Color(0xFFD6C0C2), text: Color(0xFF442E30), name: 'Muted Pink'),
    (
      plank: Color(0xFFD4A396),
      text: Color(0xFF3D221D),
      name: 'Light Terracotta',
    ),
    (plank: Color(0xFFDDD2C4), text: Color(0xFF3C352E), name: 'Warm Sand'),
  ];

  static ({Color plank, Color text, String name}) getColorForIndex(int index) {
    return palette[index % palette.length];
  }
}

/// Meaningful emoji icons for affirmation categories.
/// 🌱 Growth, ❤️ Self Love, ⭐ Confidence, ☀ Positivity, 🕊 Peace, 🎯 Focus
const List<String> _plankEmojis = ['🌱', '❤️', '⭐', '☀️', '🕊️', '🎯'];

/// A single wooden affirmation plank that hangs from the rope system.
/// Tapping expands it to reveal action buttons (Repeat, Favorite, Pin, Share).
class AffirmationPlank extends StatefulWidget {
  final DailyAffirmation affirmation;
  final int colorIndex;
  final int index;
  final double windOffset;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onPin;
  final VoidCallback onRepeat;
  final int repeatCount;
  final double tiltAngle;

  const AffirmationPlank({
    super.key,
    required this.affirmation,
    required this.colorIndex,
    required this.index,
    required this.windOffset,
    required this.isExpanded,
    required this.onTap,
    required this.onFavorite,
    required this.onPin,
    required this.onRepeat,
    this.repeatCount = 0,
    this.tiltAngle = 0.0,
  });

  @override
  State<AffirmationPlank> createState() => _AffirmationPlankState();
}

class _AffirmationPlankState extends State<AffirmationPlank>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late AnimationController _favoriteController;
  late Animation<double> _expandAnimation;
  late Animation<double> _favoriteScale;
  late Animation<double> _favoriteGlow;
  bool _favoriteAnimating = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutBack,
    );

    _favoriteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _favoriteScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_favoriteController);
    _favoriteGlow = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 0.8,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.8,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_favoriteController);
  }

  @override
  void didUpdateWidget(AffirmationPlank oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _favoriteController.dispose();
    super.dispose();
  }

  void _handleFavorite() {
    if (_favoriteAnimating) return;
    HapticFeedback.lightImpact();
    setState(() => _favoriteAnimating = true);
    _favoriteController.forward(from: 0.0).then((_) {
      if (mounted) setState(() => _favoriteAnimating = false);
    });
    widget.onFavorite();
  }

  void _handleShare() {
    HapticFeedback.selectionClick();
    final aff = widget.affirmation;
    final shareText =
        '''
✨ ${aff.title}

"${aff.text}"

${aff.author != null && aff.author!.isNotEmpty ? '— ${aff.author}' : ''}

🌿 Getzio Focus — Daily Affirmations
''';
    Share.share(shareText, subject: 'My Daily Affirmation');
  }

  /// Returns the emoji for this plank (from affirmation or auto-assigned).
  String _getEmoji() {
    if (widget.affirmation.emoji != null &&
        widget.affirmation.emoji!.isNotEmpty) {
      return widget.affirmation.emoji!;
    }
    return _plankEmojis[widget.index % _plankEmojis.length];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = PlankColors.getColorForIndex(widget.colorIndex);
    final seed = widget.affirmation.id.hashCode.abs();

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_expandController, _favoriteController]),
          builder: (context, _) {
            final expandProgress = _expandAnimation.value;
            final favScale = _favoriteScale.value;
            final favGlow = _favoriteGlow.value;

            return Transform.translate(
              offset: Offset(widget.windOffset, 0),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Plank body ──
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: widget.isExpanded ? 110 : 76,
                        maxHeight: widget.isExpanded ? 110 : 76,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Favorite glow
                          if (favGlow > 0.01)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Transform.scale(
                                  scale: 1.12,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      gradient: RadialGradient(
                                        colors: [
                                          const Color(
                                            0xFFE57373,
                                          ).withValues(alpha: favGlow * 0.35),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Wooden plank painted surface
                          Positioned.fill(
                            child: CustomPaint(
                              painter: WoodenPlankPainter(
                                plankColor: colorScheme.plank,
                                textColor: colorScheme.text,
                                isPinned: widget.affirmation.isPinned,
                                isFavorite: widget.affirmation.isFavorite,
                                seed: seed,
                                tiltAngle: widget.tiltAngle,
                              ),
                            ),
                          ),
                          // Text content (centered, avoiding holes)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 44,
                              vertical: 12,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Emoji + Affirmation text
                                Flexible(
                                  child: Center(
                                    child: Text(
                                      '${_getEmoji()} ${widget.affirmation.text}',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.patrickHand(
                                        color: colorScheme.text,
                                        fontSize: widget.isExpanded ? 20 : 17.5,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                                // Author (only when expanded)
                                if (widget.isExpanded &&
                                    widget.affirmation.author != null &&
                                    widget.affirmation.author!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    '— ${widget.affirmation.author}',
                                    style: GoogleFonts.outfit(
                                      color: colorScheme.text.withValues(
                                        alpha: 0.55,
                                      ),
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Favorite heart animation overlay
                          if (_favoriteAnimating)
                            Positioned(
                              top: 4,
                              right: 12,
                              child: IgnorePointer(
                                child: Transform.scale(
                                  scale: favScale,
                                  child: Icon(
                                    widget.affirmation.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: const Color(
                                      0xFFE57373,
                                    ).withValues(alpha: 0.9),
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // ── Expanded action buttons (clipped to 0 height when collapsed) ──
                    if (widget.isExpanded || expandProgress > 0.01)
                      AnimatedBuilder(
                        animation: _expandAnimation,
                        builder: (context, child) {
                          return ClipRect(
                            child: Align(
                              alignment: Alignment.topCenter,
                              heightFactor: expandProgress,
                              child: child,
                            ),
                          );
                        },
                        child: Opacity(
                          opacity: expandProgress.clamp(0.0, 1.0),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _ActionButton(
                                  icon: Icons.repeat_rounded,
                                  label: 'Repeat',
                                  count: widget.repeatCount,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    widget.onRepeat();
                                  },
                                ),
                                _ActionButton(
                                  icon: widget.affirmation.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  label: 'Favorite',
                                  iconColor: widget.affirmation.isFavorite
                                      ? const Color(0xFFE57373)
                                      : null,
                                  onTap: _handleFavorite,
                                ),
                                _ActionButton(
                                  icon: widget.affirmation.isPinned
                                      ? Icons.push_pin
                                      : Icons.push_pin_outlined,
                                  label: widget.affirmation.isPinned
                                      ? 'Pinned'
                                      : 'Pin',
                                  iconColor: widget.affirmation.isPinned
                                      ? const Color(0xFFF59E0B)
                                      : null,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    widget.onPin();
                                  },
                                ),
                                _ActionButton(
                                  icon: Icons.share_outlined,
                                  label: 'Share',
                                  onTap: _handleShare,
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
      ),
    );
  }
}

/// A circular action button with icon + label.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? count;
  final Color? iconColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.count,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Icon(
              icon,
              size: 16,
              color: iconColor ?? Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            count != null && count! > 0 ? '$label ($count)' : label,
            style: GoogleFonts.outfit(
              fontSize: 9,
              color: Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
