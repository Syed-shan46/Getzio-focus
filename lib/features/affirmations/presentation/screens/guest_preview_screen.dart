import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/presentation/screens/phone_login_screen.dart';
import '../../../os_dashboard/presentation/screens/daily_motivation_screen.dart'; // import to reuse components/painters if needed

class GuestPreviewScreen extends StatefulWidget {
  final VoidCallback onClose;
  const GuestPreviewScreen({super.key, required this.onClose});

  @override
  State<GuestPreviewScreen> createState() => _GuestPreviewScreenState();
}

class _GuestPreviewScreenState extends State<GuestPreviewScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ambientController;
  late PageController _carouselController;
  int _activeCardIndex = 0;

  final List<Map<String, String>> _previewCards = [
    {
      'title': 'Mindset',
      'text': 'I am the architect of my life. I build its foundation and choose its contents.',
      'theme': 'Sunrise Orange',
      'icon': '🌱',
    },
    {
      'title': 'Discipline',
      'text': 'Discipline is the bridge between goals and accomplishment.',
      'theme': 'Midnight Black',
      'icon': '⚡',
    },
    {
      'title': 'Gratitude',
      'text': 'Gratitude turns what we have into enough, and more.',
      'theme': 'Ocean Blue',
      'icon': '🙏',
    },
  ];

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _carouselController = PageController(viewportFraction: 0.82);
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient animated sky background
          AnimatedBuilder(
            animation: _ambientController,
            builder: (context, child) {
              final val = _ambientController.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(const Color(0xFF0F172A), const Color(0xFF1E1E38), val)!,
                      Color.lerp(const Color(0xFF1E1B4B), const Color(0xFF311A4D), val)!,
                      Color.lerp(const Color(0xFF2E1065), const Color(0xFF180A2B), val)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),

          // Glassmorphic overlay content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Close & Title)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white12, width: 0.8),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 16),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Daily Affirmations',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Benefits statement
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BUILD MENTAL PRIMACY',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF60A5FA),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Align your mind every morning.',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Elevate focus, eliminate self-doubt, and anchor your intentions on visual widgets in your 3D Living Workspace.',
                        style: GoogleFonts.outfit(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Preview Cards Carousel
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    controller: _carouselController,
                    onPageChanged: (idx) => setState(() => _activeCardIndex = idx),
                    itemCount: _previewCards.length,
                    itemBuilder: (context, idx) {
                      final card = _previewCards[idx];
                      final isSelected = idx == _activeCardIndex;
                      return AnimatedScale(
                        scale: isSelected ? 1.0 : 0.92,
                        duration: const Duration(milliseconds: 300),
                        child: AnimatedOpacity(
                          opacity: isSelected ? 1.0 : 0.6,
                          duration: const Duration(milliseconds: 300),
                          child: _buildPreviewCard(card),
                        ),
                      );
                    },
                  ),
                ),

                // Carousel indicator dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_previewCards.length, (idx) {
                    final isSelected = idx == _activeCardIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                      width: isSelected ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.white24,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),

                const Spacer(),

                // Action Callout / Sign In UI
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Your affirmations are personal. Sign in to save them securely and access them on every device.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                            height: 1.45,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 52,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.phone_android_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Continue with Phone',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(Map<String, String> card) {
    Color cardBg = Colors.white10;
    Color textCol = Colors.white;
    Color accentCol = Colors.amberAccent;

    if (card['theme'] == 'Sunrise Orange') {
      cardBg = const Color(0xFFFEE2E2);
      textCol = const Color(0xFF7F1D1D);
      accentCol = const Color(0xFFF59E0B);
    } else if (card['theme'] == 'Ocean Blue') {
      cardBg = const Color(0xFFE0F2FE);
      textCol = const Color(0xFF0C4A6E);
      accentCol = const Color(0xFF0284C7);
    } else if (card['theme'] == 'Midnight Black') {
      cardBg = const Color(0xFF0F172A);
      textCol = const Color(0xFFF8FAFC);
      accentCol = const Color(0xFF94A3B8);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                card['icon'] ?? '🌱',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Text(
                card['title']!.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textCol.withOpacity(0.6),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '"${card['text']}"',
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              color: textCol,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.lock_outline_rounded, color: textCol.withOpacity(0.4), size: 14),
              const SizedBox(width: 4),
              Text(
                'Sign In to Edit',
                style: GoogleFonts.outfit(fontSize: 10, color: textCol.withOpacity(0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
