import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/os_providers.dart';

class DailyQuoteCard extends ConsumerStatefulWidget {
  const DailyQuoteCard({super.key});

  @override
  ConsumerState<DailyQuoteCard> createState() => _DailyQuoteCardState();
}

class _DailyQuoteCardState extends ConsumerState<DailyQuoteCard> {
  final PageController _pageController = PageController();

  final List<Map<String, String>> _quotes = [
    {
      'quote': 'Today\'s actions build tomorrow\'s identity.',
      'author': 'Focus Core',
    },
    {
      'quote': 'The secret of your future is hidden in your daily routine.',
      'author': 'Mike Murdock',
    },
    {
      'quote': 'We are what we repeatedly do. Excellence, then, is not an act, but a habit.',
      'author': 'Aristotle',
    },
    {
      'quote': 'It is not that we have a short time to live, but that we waste a lot of it.',
      'author': 'Seneca',
    },
    {
      'quote': 'Do not pray for an easy life, pray for the strength to endure a difficult one.',
      'author': 'Bruce Lee',
    },
  ];

  final Set<int> _favoritedIndexes = {};

  void _toggleFavorite(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_favoritedIndexes.contains(index)) {
        _favoritedIndexes.remove(index);
      } else {
        _favoritedIndexes.add(index);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspaceState = ref.watch(osStateProvider);
    final frameColors = _getFrameColors(workspaceState.woodTexture);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'Motivational Wall',
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        
        // Framed Gallery Art Piece
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Hanging string/nail (Subtle wall accessory visual)
              Positioned(
                top: -14,
                child: Container(
                  width: 32,
                  height: 14,
                  child: CustomPaint(
                    painter: FrameHangerPainter(),
                  ),
                ),
              ),
              
              // Frame Base Container
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(12), // Thickness of the frame
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [frameColors.lightColor, frameColors.darkColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    // Wall Drop Shadow
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.7),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                    // Inner Frame Shadow
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 0.8,
                  ),
                ),
                child: Container(
                  height: 190,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1424), // Canvas mat background
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Soft wall art backing texture
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0D1222), Color(0xFF060912)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        // Matte paper overlay texture
                        Opacity(
                          opacity: 0.04,
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/wallpaper.png'), // fallback texturing
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        // PageView Content
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {},
                          itemCount: _quotes.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final quoteItem = _quotes[index];
                            final isFavorited = _favoritedIndexes.contains(index);

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Top Row: Quote Icon + Like
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(Icons.format_quote_rounded, color: Colors.amberAccent, size: 24),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: Icon(
                                          isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                          color: isFavorited ? Colors.redAccent : Colors.white24,
                                          size: 20,
                                        ),
                                        onPressed: () => _toggleFavorite(index),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),

                                  // Core Quote
                                  Text(
                                    quoteItem['quote']!,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.35,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),

                                  // Author
                                  Text(
                                    '— ${quoteItem['author']!}',
                                    style: AppTypography.captionSmall(color: Colors.white30).copyWith(
                                      fontStyle: FontStyle.italic,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Spacer(),

                                  // Swipe Indicator Dot Page Index
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(_quotes.length, (dotIdx) {
                                      final isCur = dotIdx == index;
                                      return AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        margin: const EdgeInsets.symmetric(horizontal: 3),
                                        width: isCur ? 12 : 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(3),
                                          color: isCur ? Colors.amberAccent : Colors.white10,
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _FrameColors _getFrameColors(String wood) {
    switch (wood) {
      case 'Oak':
        // Light natural wood frame
        return _FrameColors(
          lightColor: const Color(0xFFD7CCC8),
          darkColor: const Color(0xFF8D6E63),
        );
      case 'Mahogany':
        // Deep reddish mahogany frame
        return _FrameColors(
          lightColor: const Color(0xFF8D6E63),
          darkColor: const Color(0xFF3E2723),
        );
      case 'Walnut':
      default:
        // Classic dark walnut frame
        return _FrameColors(
          lightColor: const Color(0xFF5D4037),
          darkColor: const Color(0xFF2D1510),
        );
    }
  }
}

class _FrameColors {
  final Color lightColor;
  final Color darkColor;

  _FrameColors({required this.lightColor, required this.darkColor});
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HANGER PAINTER
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class FrameHangerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final nailPaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.fill;

    final wirePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw nail in the wall
    canvas.drawCircle(Offset(size.width / 2, 2), 2.5, nailPaint);

    // Draw diagonal hanging wires
    canvas.drawLine(Offset(size.width / 2, 2), Offset(2, size.height), wirePaint);
    canvas.drawLine(Offset(size.width / 2, 2), Offset(size.width - 2, size.height), wirePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
