import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../onboarding/domain/models/onboarding_models.dart';
import '../providers/daily_motivation_provider.dart';
import '../providers/os_providers.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// PREMIUM DAILY AFFIRMATIONS SCREEN — Living Workspace Study Room Edition
// ═══════════════════════════════════════════════════════════════════════════════

class DailyMotivationScreen extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const DailyMotivationScreen({super.key, required this.onClose});

  @override
  ConsumerState<DailyMotivationScreen> createState() => _DailyMotivationScreenState();
}

class _DailyMotivationScreenState extends ConsumerState<DailyMotivationScreen>
    with TickerProviderStateMixin {
  // Controllers
  late AnimationController _ambientController;
  late AnimationController _shimmerController;
  late PageController _carouselController;

  // Navigation state
  int _activeTabIndex = 0;
  int _activeCarouselIndex = 0;

  // TTS mock state
  bool _isPlayingSpeech = false;
  String _playingAffirmationId = '';

  // Ambient particles
  late List<_DustMote> _dustMotes;
  late List<_SteamWisp> _steamWisps;

  // Categories
  static const List<Map<String, dynamic>> _categories = [
    {'name': 'Personal Growth', 'icon': '🌱', 'color': 0xFF4CAF50},
    {'name': 'Self Confidence', 'icon': '💪', 'color': 0xFFFF9800},
    {'name': 'Discipline', 'icon': '⚡', 'color': 0xFF2196F3},
    {'name': 'Business', 'icon': '💼', 'color': 0xFF607D8B},
    {'name': 'Wealth', 'icon': '💰', 'color': 0xFFFFD700},
    {'name': 'Health', 'icon': '❤️', 'color': 0xFFE91E63},
    {'name': 'Fitness', 'icon': '🏋️', 'color': 0xFFFF5722},
    {'name': 'Spiritual', 'icon': '🕌', 'color': 0xFF9C27B0},
    {'name': 'Family', 'icon': '👨‍👩‍👧', 'color': 0xFF795548},
    {'name': 'Leadership', 'icon': '👑', 'color': 0xFFFFC107},
    {'name': 'Focus', 'icon': '🎯', 'color': 0xFF00BCD4},
    {'name': 'Gratitude', 'icon': '🙏', 'color': 0xFF8BC34A},
    {'name': 'Success', 'icon': '🏆', 'color': 0xFFFF6F00},
    {'name': 'Relationships', 'icon': '🤝', 'color': 0xFFAD1457},
    {'name': 'Custom', 'icon': '✨', 'color': 0xFF455A64},
  ];

  // Tab definitions
  static const List<Map<String, String>> _tabs = [
    {'title': 'Today', 'icon': '⭐'},
    {'title': 'My Affirmations', 'icon': '❤️'},
    {'title': 'Categories', 'icon': '🏷'},
    {'title': 'Favorites', 'icon': '📌'},
    {'title': 'Morning', 'icon': '🌅'},
    {'title': 'Night', 'icon': '🌙'},
    {'title': 'Vision', 'icon': '✨'},
  ];

  @override
  void initState() {
    super.initState();

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _ambientController.addListener(() {
      if (mounted) setState(() {});
    });

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _carouselController = PageController(viewportFraction: 0.82);

    // Initialize particles
    final random = math.Random();
    _dustMotes = List.generate(8, (_) => _DustMote(
      x: random.nextDouble(),
      y: random.nextDouble(),
      speed: 0.02 + random.nextDouble() * 0.04,
      size: 0.8 + random.nextDouble() * 1.2,
      swaySpeed: 0.08 + random.nextDouble() * 0.12,
    ));
    _steamWisps = List.generate(3, (_) => _SteamWisp(
      xOffset: random.nextDouble() * 6 - 3,
      progress: random.nextDouble(),
      speed: 0.15 + random.nextDouble() * 0.15,
      size: 1.0 + random.nextDouble() * 1.0,
    ));
  }

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _ambientController.dispose();
    _shimmerController.dispose();
    _carouselController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _playSoothingAudio(String text, String id) async {
    if (_isPlayingSpeech && _playingAffirmationId == id) {
      setState(() { _isPlayingSpeech = false; _playingAffirmationId = ''; });
      try {
        await _audioPlayer.stop();
      } catch (_) {}
      return;
    }
    setState(() { _isPlayingSpeech = true; _playingAffirmationId = id; });
    try {
      // Play a beautiful calming wind chimes audio
      await _audioPlayer.play(UrlSource('https://assets.mixkit.co/active_storage/sfx/2568/2568-84.wav'));
    } catch (e) {
      debugPrint('Audio play failed: $e');
    }
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted && _playingAffirmationId == id) {
        setState(() { _isPlayingSpeech = false; _playingAffirmationId = ''; });
      }
    });
  }

  List<DailyAffirmation> _getFilteredAffirmations(MotivationState mState) {
    switch (_activeTabIndex) {
      case 0: // Today — all
        return mState.affirmations;
      case 1: // My Affirmations — all
        return mState.affirmations;
      case 2: // Categories — handled separately
        return mState.affirmations;
      case 3: // Favorites
        return mState.affirmations.where((a) => a.isFavorite).toList();
      case 4: // Morning
        return mState.affirmations.where((a) => a.schedule.contains('Morning')).toList();
      case 5: // Night
        return mState.affirmations.where((a) =>
            a.schedule.contains('Night') || a.schedule.contains('Evening')).toList();
      case 6: // Vision — pinned
        return mState.affirmations.where((a) => a.isPinned).toList();
      default:
        return mState.affirmations;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final osState = ref.watch(osStateProvider);
    final mState = ref.watch(dailyMotivationProvider);
    final time = _ambientController.value;

    // Tick particles
    for (var d in _dustMotes) {
      d.y = (d.y - 0.004 * d.speed) % 1.0;
    }
    for (var s in _steamWisps) {
      s.progress += 0.008 * s.speed;
      if (s.progress >= 1.0) {
        s.progress = 0.0;
        s.xOffset = (math.Random().nextDouble() * 6 - 3);
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ─── 1. STUDY ROOM ENVIRONMENT ─────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _StudyRoomPainter(
                woodTexture: osState.woodTexture,
                ambientTime: time,
                dustMotes: _dustMotes,
                steamWisps: _steamWisps,
              ),
            ),
          ),

          // ─── 2. MAIN SCROLLABLE CONTENT ────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(osState),

                // Hero Affirmation Frame (Vision Card) - Small version
                _buildHeroFrame(osState, mState),

                const SizedBox(height: 8),

                // Wooden Navigation Shelf
                _buildWoodenNavShelf(osState),

                const SizedBox(height: 8),

                // Create New Affirmation Button (placed globally here!)
                _buildCreateButton(osState),

                const SizedBox(height: 6),

                // Tab Content
                Expanded(
                  child: _activeTabIndex == 0
                      ? _buildTodayTab(mState, osState)
                      : _activeTabIndex == 2
                          ? _buildCategoriesView(mState, osState)
                          : _buildCarouselView(mState, osState),
                ),

                // Motivation Footer
                _buildMotivationFooter(mState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(OSState osState) {
    final todayStr = DateFormat('EEEE, MMMM d').format(DateTime.now());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12, width: 0.8),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 15),
            ),
          ),
          const SizedBox(width: 14),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w400),
                ),
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
          // Date & Streak
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                todayStr,
                style: GoogleFonts.outfit(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.2), width: 0.7),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.amberAccent, size: 11),
                    const SizedBox(width: 2),
                    Text(
                      '${osState.currentStreak} Day',
                      style: GoogleFonts.outfit(fontSize: 9, color: Colors.amberAccent, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HERO AFFIRMATION FRAME
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeroFrame(OSState osState, MotivationState mState) {
    // Use pinned affirmation if available, else use daily quote
    final pinned = mState.affirmations.where((a) => a.isPinned).toList();
    final String heroQuote = pinned.isNotEmpty ? pinned.first.text : osState.dailyQuote;
    final String heroAuthor = pinned.isNotEmpty ? (pinned.first.author ?? 'You') : osState.dailyQuoteAuthor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, _) {
          final shimmerVal = math.sin(_shimmerController.value * 2 * math.pi).abs();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0D16).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Color.lerp(
                  const Color(0xFF3A2A1A),
                  const Color(0xFFD4A853),
                  shimmerVal * 0.08,
                )!,
                width: 1.5,
              ),
              boxShadow: [
                // Warm spotlight from above
                BoxShadow(
                  color: Colors.amberAccent.withValues(alpha: 0.04),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, -5),
                ),
                // Depth shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Spotlight indicator
                Container(
                  width: 30,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.amberAccent.withValues(alpha: 0.25),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 6),
                // Glass reflection line
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  height: 0.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Quote
                Text(
                  '"$heroQuote"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.95),
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '— $heroAuthor',
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    color: const Color(0xFFD4A853).withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WOODEN NAVIGATION SHELF
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildWoodenNavShelf(OSState osState) {
    Color woodColor;
    if (osState.woodTexture == 'Oak') {
      woodColor = const Color(0xFFC7B3A3);
    } else if (osState.woodTexture == 'Mahogany') {
      woodColor = const Color(0xFF4A2C22);
    } else {
      woodColor = const Color(0xFF2E1912);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 36,
      decoration: BoxDecoration(
        color: Color.lerp(woodColor, Colors.black, 0.50),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final tab = _tabs[index];
            final isSelected = _activeTabIndex == index;

            return GestureDetector(
              onTap: () {
                if (_activeTabIndex != index) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _activeTabIndex = index;
                    _activeCarouselIndex = 0;
                  });
                  // Reset carousel
                  if (_carouselController.hasClients) {
                    _carouselController.jumpToPage(0);
                  }
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 90,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected
                        ? [woodColor, Color.lerp(woodColor, Colors.black, 0.12)!]
                        : [Color.lerp(woodColor, Colors.black, 0.30)!, Color.lerp(woodColor, Colors.black, 0.45)!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Colors.amberAccent.withValues(alpha: 0.12), blurRadius: 6, offset: const Offset(0, 1))]
                      : [],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(tab['icon']!, style: const TextStyle(fontSize: 10)),
                    const SizedBox(width: 3),
                    Text(
                      tab['title']!,
                      style: GoogleFonts.outfit(
                        fontSize: 8,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                        color: isSelected ? const Color(0xFF1A0E06) : Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CAROUSEL VIEW (for most tabs)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCarouselView(MotivationState mState, OSState osState) {
    final filtered = _getFilteredAffirmations(mState);

    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Carousel
        Expanded(
          child: PageView.builder(
            controller: _carouselController,
            itemCount: filtered.length,
            onPageChanged: (idx) {
              HapticFeedback.selectionClick();
              setState(() => _activeCarouselIndex = idx);
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _carouselController,
                builder: (context, child) {
                  double scale = 1.0;
                  double opacity = 1.0;
                  if (_carouselController.position.haveDimensions) {
                     double currentPage = _carouselController.page ?? index.toDouble();
                     double diff = (currentPage - index).abs();
                     scale = (1.0 - (diff * 0.08)).clamp(0.88, 1.0);
                     opacity = (1.0 - (diff * 0.3)).clamp(0.5, 1.0);
                  }

                  final aff = filtered[index];
                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: Center(
                        child: SizedBox(
                          height: 230,
                          child: _buildAffirmationCard(aff, osState),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        // Page indicator
        if (filtered.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 4, top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                filtered.length.clamp(0, 10),
                (i) => Container(
                  width: i == _activeCarouselIndex ? 14 : 5,
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i == _activeCarouselIndex
                        ? Colors.amberAccent.withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('✨', style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          Text(
            'No affirmations here yet.',
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.white30),
          ),
          const SizedBox(height: 4),
          Text(
            'Create your first to get started.',
            style: GoogleFonts.outfit(fontSize: 10, color: Colors.white.withValues(alpha: 0.2)),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(OSState osState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          _showCreateAffirmationSheet(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amberAccent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.18), width: 0.8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: Colors.amberAccent, size: 14),
              const SizedBox(width: 6),
              Text(
                'Create New Affirmation',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AFFIRMATION CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAffirmationCard(DailyAffirmation aff, OSState osState, {bool showActions = true}) {
    // 1. Resolve Accent Color
    Color accentCol;
    switch (aff.accentColor) {
      case 'Gold':
        accentCol = const Color(0xFFD4A853);
        break;
      case 'Emerald':
        accentCol = const Color(0xFF10B981);
        break;
      case 'Sapphire':
        accentCol = const Color(0xFF3B82F6);
        break;
      case 'Ruby':
        accentCol = const Color(0xFFEF4444);
        break;
      case 'Rose':
        accentCol = const Color(0xFFEC4899);
        break;
      case 'Amber':
      default:
        accentCol = Colors.amberAccent;
    }

    // 2. Resolve Card background and text colors
    final colorMap = _resolveCardColors(aff.backgroundStyle);
    final textCol = colorMap['text']!;
    final subCol = colorMap['sub']!;

    // 3. Resolve outer wood finish/metal frame border decoration
    BoxDecoration outerFrameDecoration = const BoxDecoration();
    if (aff.frameStyle != 'None') {
      Color frameCol = const Color(0xFF3E2723); // default Walnut

      // Parse frameColor dropdown selection
      switch (aff.frameColor) {
        case 'Ebony Black':
          frameCol = const Color(0xFF151821);
          break;
        case 'Natural Oak':
          frameCol = const Color(0xFFC7B3A3);
          break;
        case 'Crimson Mahogany':
          frameCol = const Color(0xFF5D4037);
          break;
        case 'Forest Pine':
          frameCol = const Color(0xFF1A3A22);
          break;
        case 'Warm Walnut':
        default:
          frameCol = const Color(0xFF3E2723);
      }

      // Handle override based on woodFinish selection
      switch (aff.woodFinish) {
        case 'Oak':
          frameCol = const Color(0xFFB59D88);
          break;
        case 'Mahogany':
          frameCol = const Color(0xFF4E2319);
          break;
        case 'Rosewood':
          frameCol = const Color(0xFF632B2B);
          break;
        case 'Ebony':
          frameCol = const Color(0xFF0F1117);
          break;
        case 'Walnut':
        default:
          // Keep frameColor mapping
          break;
      }

      double bWidth = 3.0;
      if (aff.frameStyle == 'Thin Metal') {
        bWidth = 1.0;
        frameCol = const Color(0xFFD4A853); // Gold metallic look
      } else if (aff.frameStyle == 'Chunky Border') {
        bWidth = 5.0;
      } else if (aff.frameStyle == 'Minimal Bevel') {
        bWidth = 2.0;
      }

      outerFrameDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: frameCol, width: bWidth),
      );
    }

    // 4. Resolve Typography Weight, Size, and Alignment
    FontWeight fontW;
    switch (aff.fontWeight) {
      case 'Light':
        fontW = FontWeight.w300;
        break;
      case 'Semi-Bold':
        fontW = FontWeight.w600;
        break;
      case 'Bold':
        fontW = FontWeight.w700;
        break;
      case 'Normal':
      default:
        fontW = FontWeight.w400;
    }

    TextAlign align;
    switch (aff.quoteAlignment) {
      case 'Left':
        align = TextAlign.left;
        break;
      case 'Right':
        align = TextAlign.right;
        break;
      case 'Center':
      default:
        align = TextAlign.center;
    }

    TextStyle quoteStyle = _resolveQuoteStyle(aff.fontStyle).copyWith(
      fontWeight: fontW,
      fontSize: aff.quoteSize,
    );

    final isPlaying = _isPlayingSpeech && _playingAffirmationId == aff.id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: outerFrameDecoration.copyWith(
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          children: [
            // ─── BACKGROUND LAYOUT ───
            Positioned.fill(
              child: Container(
                decoration: _resolveCardDecoration(aff.backgroundStyle),
              ),
            ),

            // ─── GLASS BLUR / FILTER LAYOUT ───
            if (aff.bgBlur > 0)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    tileMode: TileMode.clamp,
                    sigmaX: aff.bgBlur,
                    sigmaY: aff.bgBlur,
                  ),
                  child: Container(color: Colors.transparent),
                ),
              ),

            // ─── INSET DECORATION LINES ───
            if (aff.borderDecoration != 'None')
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: aff.borderDecoration == 'Fine Line'
                          ? Border.all(color: accentCol.withValues(alpha: 0.2), width: 0.8)
                          : aff.borderDecoration == 'Double Inset'
                              ? Border.all(color: accentCol.withValues(alpha: 0.15), width: 1.6)
                              : null,
                    ),
                    child: aff.borderDecoration == 'Corner Accents'
                        ? Stack(
                            children: [
                              // Top-Left
                              Positioned(
                                top: 0, left: 0,
                                child: Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: accentCol.withValues(alpha: 0.4), width: 1.2),
                                      left: BorderSide(color: accentCol.withValues(alpha: 0.4), width: 1.2),
                                    ),
                                  ),
                                ),
                              ),
                              // Top-Right
                              Positioned(
                                top: 0, right: 0,
                                child: Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: accentCol.withValues(alpha: 0.4), width: 1.2),
                                      right: BorderSide(color: accentCol.withValues(alpha: 0.4), width: 1.2),
                                    ),
                                  ),
                                ),
                              ),
                              // Bottom-Left
                              Positioned(
                                bottom: 0, left: 0,
                                child: Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: accentCol.withValues(alpha: 0.4), width: 1.2),
                                      left: BorderSide(color: accentCol.withValues(alpha: 0.4), width: 1.2),
                                    ),
                                  ),
                                ),
                              ),
                              // Bottom-Right
                              Positioned(
                                bottom: 0, right: 0,
                                child: Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: accentCol.withValues(alpha: 0.4), width: 1.2),
                                      right: BorderSide(color: accentCol.withValues(alpha: 0.4), width: 1.2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),

            // ─── GLASS GLARE / SHIMMER REFLECTION ───
            if (aff.glassReflection != 'None')
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: aff.glassReflection == 'High Glare' ? 0.12 : aff.glassReflection == 'Soft Matte' ? 0.03 : 0.06),
                          Colors.transparent,
                          Colors.white.withValues(alpha: aff.glassReflection == 'High Glare' ? 0.05 : 0.02),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.25, 0.28, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

            // ─── MAIN CONTENT ───
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title & category badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: accentCol.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                aff.title.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.bold,
                                  color: accentCol.withValues(alpha: 0.8),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: textCol.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                aff.category,
                                style: GoogleFonts.outfit(fontSize: 7, color: subCol, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Quote text
                        Text(
                          '"${aff.text}"',
                          textAlign: align,
                          style: quoteStyle.copyWith(color: textCol, height: 1.45),
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Author
                        if (aff.author != null && aff.author!.isNotEmpty)
                          Text(
                            '— ${aff.author}',
                            textAlign: align,
                            style: GoogleFonts.outfit(fontSize: 9, color: subCol, fontStyle: FontStyle.italic),
                          ),
                        const Spacer(),
                        // Schedule badges
                        Row(
                          children: aff.schedule.map((s) => Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: textCol.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(s, style: GoogleFonts.outfit(fontSize: 7, color: subCol)),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                // Quick Actions bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickAction(
                        icon: aff.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: aff.isFavorite ? Colors.redAccent : subCol,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(dailyMotivationProvider.notifier).toggleFavorite(aff.id);
                        },
                      ),
                      _buildQuickAction(
                        icon: aff.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                        color: aff.isPinned ? Colors.amberAccent : subCol,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(dailyMotivationProvider.notifier).togglePin(aff.id);
                          ref.read(osStateProvider.notifier).nextQuote(aff.text, aff.author ?? 'You');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pinned and set as Home wall quote! 🏠'),
                              duration: Duration(milliseconds: 1200),
                            ),
                          );
                        },
                      ),
                      _buildQuickAction(
                        icon: isPlaying ? Icons.pause_circle_filled : Icons.play_circle_outline,
                        color: isPlaying ? Colors.amberAccent : subCol,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _playSoothingAudio(aff.text, aff.id);
                        },
                      ),
                      _buildQuickAction(
                        icon: Icons.share_outlined,
                        color: subCol,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Clipboard.setData(ClipboardData(text: '"${aff.text}" — ${aff.author ?? 'Unknown'}'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied to clipboard'), duration: Duration(milliseconds: 1000)),
                          );
                        },
                      ),
                      _buildQuickAction(
                        icon: Icons.copy_rounded,
                        color: subCol,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(dailyMotivationProvider.notifier).duplicateAffirmation(aff.id);
                        },
                      ),
                      _buildQuickAction(
                        icon: Icons.edit_outlined,
                        color: subCol,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showCreateAffirmationSheet(context, editing: aff);
                        },
                      ),
                      _buildQuickAction(
                        icon: Icons.delete_outline,
                        color: Colors.redAccent.withValues(alpha: 0.5),
                        onTap: () {
                          HapticFeedback.vibrate();
                          ref.read(dailyMotivationProvider.notifier).deleteAffirmation(aff.id);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORIES VIEW
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCategoriesView(MotivationState mState, OSState osState) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final catName = cat['name'] as String;
              final linkedAffs = mState.affirmations.where((a) => a.category == catName).toList();
              final accentColor = Color(cat['color'] as int);

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                  childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  leading: Text(cat['icon'] as String, style: const TextStyle(fontSize: 16)),
                  title: Text(
                    catName,
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${linkedAffs.length} affirmation${linkedAffs.length == 1 ? '' : 's'}',
                    style: GoogleFonts.outfit(fontSize: 9, color: accentColor.withValues(alpha: 0.7)),
                  ),
                  expandedAlignment: Alignment.topLeft,
                  expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                  children: linkedAffs.isEmpty
                      ? [
                          Text(
                            'No affirmations in this category yet.',
                            style: GoogleFonts.outfit(fontSize: 10, color: Colors.white.withValues(alpha: 0.2), fontStyle: FontStyle.italic),
                          ),
                        ]
                      : linkedAffs.map((a) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '"${a.text}"',
                                    style: GoogleFonts.outfit(fontSize: 10, color: Colors.white60),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TODAY'S MISSION & MINDSET GRID
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTodayTab(MotivationState mState, OSState osState) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTodayCard(
            title: "Today's Mission",
            subtitle: "Embrace Deep Work",
            description: "Minimize distractions, set a timer, and commit to completing your top high-leverage tasks today.",
            icon: "🏆",
            accentColor: Colors.amberAccent,
          ),
          const SizedBox(height: 8),
          _buildTodayCard(
            title: "Mindset Challenge",
            subtitle: "Single-Tasking Discipline",
            description: "Work on one task at a time. No social media, no tab-switching, and no phone checks for the next 90 minutes.",
            icon: "⚡",
            accentColor: Colors.cyanAccent,
          ),
          const SizedBox(height: 8),
          _buildTodayCard(
            title: "Daily Reflection",
            subtitle: "Looking Inward",
            description: "What is one small lesson or positive moment you experienced yesterday that you want to carry into today?",
            icon: "🧘",
            accentColor: Colors.purpleAccent,
          ),
          const SizedBox(height: 8),
          _buildTodayCard(
            title: "Gratitude Prompt",
            subtitle: "Appreciation of Space",
            description: "What is one physical item in your current environment or workspace that makes you feel comfortable and focused?",
            icon: "🙏",
            accentColor: Colors.greenAccent,
          ),
          const SizedBox(height: 8),
          _buildTodayCard(
            title: "Daily Reminder",
            subtitle: "Box Breathing",
            description: "Inhale deeply for 4 seconds, hold for 4 seconds, exhale for 4 seconds. Repeat 3 times to ground yourself.",
            icon: "🌬️",
            accentColor: Colors.pinkAccent,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTodayCard({
    required String title,
    required String subtitle,
    required String description,
    required String icon,
    required Color accentColor,
    VoidCallback? onTap,
    String? actionLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 0.8),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: accentColor.withValues(alpha: 0.7),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Spacer(),
                    if (onTap != null && actionLabel != null)
                      GestureDetector(
                        onTap: onTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            actionLabel,
                            style: GoogleFonts.outfit(
                              fontSize: 7.5,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.outfit(
                    fontSize: 9.5,
                    color: Colors.white54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════

  // ═══════════════════════════════════════════════════════════════════════════
  // MOTIVATION FOOTER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMotivationFooter(MotivationState mState) {
    final totalAffs = mState.affirmations.length;
    final readCount = totalAffs.clamp(0, 10);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        children: [
          Text(
            '"The words you repeat become the life you create."',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 9.5,
              color: Colors.white.withValues(alpha: 0.25),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Today\'s mindset: ',
                style: GoogleFonts.outfit(fontSize: 8, color: Colors.white.withValues(alpha: 0.2)),
              ),
              Text(
                '$readCount / 10',
                style: GoogleFonts.outfit(fontSize: 8, color: Colors.amberAccent.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
              ),
              Text(
                ' affirmations',
                style: GoogleFonts.outfit(fontSize: 8, color: Colors.white.withValues(alpha: 0.2)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (readCount / 10.0).clamp(0.0, 1.0),
              minHeight: 2,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amberAccent.withValues(alpha: 0.35)),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CREATE / EDIT AFFIRMATION SHEET
  // ═══════════════════════════════════════════════════════════════════════════

  void _showCreateAffirmationSheet(BuildContext context, {DailyAffirmation? editing}) {
    final textController = TextEditingController(text: editing?.text ?? '');
    final titleController = TextEditingController(text: editing?.title ?? '');
    final authorController = TextEditingController(text: editing?.author ?? '');

    String currentCategory = editing?.category ?? 'General';
    String currentStyle = editing?.backgroundStyle ?? 'Glass';
    String currentFont = editing?.fontStyle ?? 'Serif';
    List<String> currentSchedule = List<String>.from(editing?.schedule ?? ['Morning']);
    bool pinToHome = editing?.isPinned ?? false;

    // Advanced customization options
    String currentWoodFinish = editing?.woodFinish ?? 'Walnut';
    String currentFrameStyle = editing?.frameStyle ?? 'Classic Wood';
    String currentFrameColor = editing?.frameColor ?? 'Warm Walnut';
    String currentGlassReflection = editing?.glassReflection ?? 'Slight Gloss';
    String currentFontWeight = editing?.fontWeight ?? 'Normal';
    String currentQuoteAlignment = editing?.quoteAlignment ?? 'Center';
    double currentQuoteSize = editing?.quoteSize ?? 15.0;
    String currentAccentColor = editing?.accentColor ?? 'Amber';
    double currentBgBlur = editing?.bgBlur ?? 3.0;
    String currentBorderDecoration = editing?.borderDecoration ?? 'None';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF070913),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final osState = ref.read(osStateProvider);
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final mockAff = DailyAffirmation(
              id: 'preview',
              title: titleController.text.isEmpty ? 'PREVIEW' : titleController.text,
              text: textController.text.isEmpty ? 'Your affirmation text here...' : textController.text,
              author: authorController.text,
              category: currentCategory,
              backgroundStyle: currentStyle,
              fontStyle: currentFont,
              woodFinish: currentWoodFinish,
              frameStyle: currentFrameStyle,
              frameColor: currentFrameColor,
              glassReflection: currentGlassReflection,
              fontWeight: currentFontWeight,
              quoteAlignment: currentQuoteAlignment,
              quoteSize: currentQuoteSize,
              accentColor: currentAccentColor,
              bgBlur: currentBgBlur,
              borderDecoration: currentBorderDecoration,
            );

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          editing != null ? 'Customize Mindset Art' : 'Create Mindset Art',
                          style: GoogleFonts.playfairDisplay(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white30, size: 18),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Live Preview
                    Text('Live Studio Preview', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 170,
                      child: _buildAffirmationCard(mockAff, osState, showActions: false),
                    ),
                    const SizedBox(height: 14),

                    // Input Fields
                    _buildSheetInput(titleController, 'Title', 'e.g., Daily Discipline', (v) => setSheetState(() {})),
                    const SizedBox(height: 8),
                    _buildSheetInput(textController, 'Affirmation Text', 'e.g., I prioritize long-term value over short-term pleasure...', (v) => setSheetState(() {})),
                    const SizedBox(height: 8),
                    _buildSheetInput(authorController, 'Author', 'e.g., Epictetus', (v) => setSheetState(() {})),
                    const SizedBox(height: 12),

                    // Category Picker
                    Text('Category', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _categories.map((cat) {
                          final catName = cat['name'] as String;
                          final isSel = currentCategory == catName;
                          return GestureDetector(
                            onTap: () => setSheetState(() => currentCategory = catName),
                            child: Container(
                              margin: const EdgeInsets.only(right: 5),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.amberAccent.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: isSel ? Colors.amberAccent : Colors.transparent),
                              ),
                              child: Text(
                                '${cat['icon']} $catName',
                                style: GoogleFonts.outfit(fontSize: 8.5, color: isSel ? Colors.amberAccent : Colors.white60),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Frame Style Selector
                    Text('Frame Style', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: ['Classic Wood', 'Thin Metal', 'Chunky Border', 'Minimal Bevel', 'None'].map((fStyle) {
                        final isSel = currentFrameStyle == fStyle;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setSheetState(() => currentFrameStyle = fStyle),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.amberAccent.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: isSel ? Colors.amberAccent : Colors.transparent),
                              ),
                              alignment: Alignment.center,
                              child: Text(fStyle.replaceAll(' ', '\n'), textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 7.5, color: isSel ? Colors.amberAccent : Colors.white60)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    if (currentFrameStyle != 'None' && currentFrameStyle != 'Thin Metal') ...[
                      // Wood Finish Selector
                      Text('Wood Finish', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: ['Walnut', 'Oak', 'Mahogany', 'Rosewood', 'Ebony'].map((wFinish) {
                          final isSel = currentWoodFinish == wFinish;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setSheetState(() => currentWoodFinish = wFinish),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSel ? Colors.amberAccent.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(color: isSel ? Colors.amberAccent : Colors.transparent),
                                ),
                                alignment: Alignment.center,
                                child: Text(wFinish, style: GoogleFonts.outfit(fontSize: 8.5, color: isSel ? Colors.amberAccent : Colors.white60)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Frame Color
                    Text('Frame Color Profile', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: ['Warm Walnut', 'Ebony Black', 'Natural Oak', 'Crimson Mahogany', 'Forest Pine'].map((fColor) {
                          final isSel = currentFrameColor == fColor;
                          return GestureDetector(
                            onTap: () => setSheetState(() => currentFrameColor = fColor),
                            child: Container(
                              margin: const EdgeInsets.only(right: 5),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.amberAccent.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: isSel ? Colors.amberAccent : Colors.transparent),
                              ),
                              child: Text(fColor, style: GoogleFonts.outfit(fontSize: 8.5, color: isSel ? Colors.amberAccent : Colors.white60)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Card Background Theme
                    Text('Canvas Texture Theme', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          'Glass', 'Minimal Black', 'Warm Wood', 'Paper Card', 'Notebook',
                          'Dark Gradient', 'Luxury Gold', 'Aurora', 'Stone', 'Canvas'
                        ].map((styleName) {
                          final isSel = currentStyle == styleName;
                          return GestureDetector(
                            onTap: () => setSheetState(() => currentStyle = styleName),
                            child: Container(
                              margin: const EdgeInsets.only(right: 5),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.amberAccent.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: isSel ? Colors.amberAccent : Colors.transparent),
                              ),
                              child: Text(styleName, style: GoogleFonts.outfit(fontSize: 8.5, color: isSel ? Colors.amberAccent : Colors.white60)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Accent Colors
                    Text('Accent Highlights', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: ['Gold', 'Amber', 'Emerald', 'Sapphire', 'Ruby', 'Rose'].map((acc) {
                        final isSel = currentAccentColor == acc;
                        Color dotColor = Colors.amberAccent;
                        if (acc == 'Gold') {
                          dotColor = const Color(0xFFD4A853);
                        } else if (acc == 'Emerald') {
                          dotColor = const Color(0xFF10B981);
                        } else if (acc == 'Sapphire') {
                          dotColor = const Color(0xFF3B82F6);
                        } else if (acc == 'Ruby') {
                          dotColor = const Color(0xFFEF4444);
                        } else if (acc == 'Rose') {
                          dotColor = const Color(0xFFEC4899);
                        }

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setSheetState(() => currentAccentColor = acc),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? dotColor.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: isSel ? dotColor : Colors.transparent),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                                  const SizedBox(width: 4),
                                  Text(acc, style: GoogleFonts.outfit(fontSize: 8, color: isSel ? dotColor : Colors.white60)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Glass Glare Reflection
                    Text('Glass Reflection', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: ['High Glare', 'Slight Gloss', 'Soft Matte', 'None'].map((refVal) {
                        final isSel = currentGlassReflection == refVal;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setSheetState(() => currentGlassReflection = refVal),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.amberAccent.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: isSel ? Colors.amberAccent : Colors.transparent),
                              ),
                              alignment: Alignment.center,
                              child: Text(refVal, style: GoogleFonts.outfit(fontSize: 8.5, color: isSel ? Colors.amberAccent : Colors.white60)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Inset borders decoration
                    Text('Border Decoration', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: ['None', 'Fine Line', 'Double Inset', 'Corner Accents'].map((borderDec) {
                        final isSel = currentBorderDecoration == borderDec;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setSheetState(() => currentBorderDecoration = borderDec),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.amberAccent.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: isSel ? Colors.amberAccent : Colors.transparent),
                              ),
                              alignment: Alignment.center,
                              child: Text(borderDec.replaceAll(' ', '\n'), textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 7.5, color: isSel ? Colors.amberAccent : Colors.white60)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Sliders for Text Size & Blur
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Font Size: ${currentQuoteSize.toInt()}', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
                              Slider(
                                value: currentQuoteSize,
                                min: 11.0,
                                max: 20.0,
                                divisions: 9,
                                activeColor: Colors.amberAccent,
                                inactiveColor: Colors.white12,
                                onChanged: (val) => setSheetState(() => currentQuoteSize = val),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Canvas Blur: ${currentBgBlur.toInt()}', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
                              Slider(
                                value: currentBgBlur,
                                min: 0.0,
                                max: 10.0,
                                divisions: 10,
                                activeColor: Colors.amberAccent,
                                inactiveColor: Colors.white12,
                                onChanged: (val) => setSheetState(() => currentBgBlur = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Typography selectors
                    Text('Font Family Style', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: ['Serif', 'Sans-Serif', 'Handwriting'].map((fontName) {
                        final isSel = currentFont == fontName;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setSheetState(() => currentFont = fontName),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.amberAccent.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: isSel ? Colors.amberAccent : Colors.transparent),
                              ),
                              alignment: Alignment.center,
                              child: Text(fontName, style: GoogleFonts.outfit(fontSize: 8.5, color: isSel ? Colors.amberAccent : Colors.white60)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    Text('Font Weight Profile', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: ['Light', 'Normal', 'Semi-Bold', 'Bold'].map((fWeight) {
                        final isSel = currentFontWeight == fWeight;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setSheetState(() => currentFontWeight = fWeight),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.amberAccent.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: isSel ? Colors.amberAccent : Colors.transparent),
                              ),
                              alignment: Alignment.center,
                              child: Text(fWeight, style: GoogleFonts.outfit(fontSize: 8.5, color: isSel ? Colors.amberAccent : Colors.white60)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    Text('Quote Text Alignment', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: ['Left', 'Center', 'Right'].map((alignVal) {
                        final isSel = currentQuoteAlignment == alignVal;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setSheetState(() => currentQuoteAlignment = alignVal),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.amberAccent.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: isSel ? Colors.amberAccent : Colors.transparent),
                              ),
                              alignment: Alignment.center,
                              child: Text(alignVal, style: GoogleFonts.outfit(fontSize: 8.5, color: isSel ? Colors.amberAccent : Colors.white60)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Schedule
                    Text('Daily Schedule Routine', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: ['Morning', 'Afternoon', 'Night'].map((time) {
                        final isSel = currentSchedule.contains(time);
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                if (isSel) {
                                  currentSchedule.remove(time);
                                } else {
                                  currentSchedule.add(time);
                                }
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? Colors.amberAccent.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: isSel ? Colors.amberAccent : Colors.transparent),
                              ),
                              alignment: Alignment.center,
                              child: Text(time, style: GoogleFonts.outfit(fontSize: 8.5, color: isSel ? Colors.amberAccent : Colors.white60)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Pin toggle
                    GestureDetector(
                      onTap: () => setSheetState(() => pinToHome = !pinToHome),
                      child: Row(
                        children: [
                          Icon(
                            pinToHome ? Icons.push_pin : Icons.push_pin_outlined,
                            color: pinToHome ? Colors.amberAccent : Colors.white30,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pin to Active Workspace Wall Frame',
                            style: GoogleFonts.outfit(fontSize: 10, color: pinToHome ? Colors.amberAccent : Colors.white.withValues(alpha: 0.4)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Save Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent,
                        foregroundColor: const Color(0xFF1A0E06),
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        if (textController.text.trim().isEmpty) return;
                        if (editing != null) {
                          ref.read(dailyMotivationProvider.notifier).updateAffirmation(
                            editing.copyWith(
                              title: titleController.text.isEmpty ? 'Affirmation' : titleController.text,
                              text: textController.text,
                              author: authorController.text.isEmpty ? null : authorController.text,
                              category: currentCategory,
                              backgroundStyle: currentStyle,
                              fontStyle: currentFont,
                              schedule: currentSchedule.isEmpty ? ['Morning'] : currentSchedule,
                              isPinned: pinToHome,
                              woodFinish: currentWoodFinish,
                              frameStyle: currentFrameStyle,
                              frameColor: currentFrameColor,
                              glassReflection: currentGlassReflection,
                              fontWeight: currentFontWeight,
                              quoteAlignment: currentQuoteAlignment,
                              quoteSize: currentQuoteSize,
                              accentColor: currentAccentColor,
                              bgBlur: currentBgBlur,
                              borderDecoration: currentBorderDecoration,
                            ),
                          );
                        } else {
                          ref.read(dailyMotivationProvider.notifier).addAffirmation(
                            DailyAffirmation(
                              id: const Uuid().v4(),
                              title: titleController.text.isEmpty ? 'My Focus' : titleController.text,
                              text: textController.text,
                              author: authorController.text.isEmpty ? null : authorController.text,
                              category: currentCategory,
                              backgroundStyle: currentStyle,
                              fontStyle: currentFont,
                              schedule: currentSchedule.isEmpty ? ['Morning'] : currentSchedule,
                              isPinned: pinToHome,
                              woodFinish: currentWoodFinish,
                              frameStyle: currentFrameStyle,
                              frameColor: currentFrameColor,
                              glassReflection: currentGlassReflection,
                              fontWeight: currentFontWeight,
                              quoteAlignment: currentQuoteAlignment,
                              quoteSize: currentQuoteSize,
                              accentColor: currentAccentColor,
                              bgBlur: currentBgBlur,
                              borderDecoration: currentBorderDecoration,
                            ),
                          );
                        }
                        Navigator.pop(context);
                      },
                      child: Text(
                        editing != null ? 'Update Affirmation Frame' : 'Save to Mindset Room',
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSheetInput(TextEditingController controller, String label, String hint, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 9, color: Colors.white.withValues(alpha: 0.4), fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: GoogleFonts.outfit(fontSize: 12, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.outfit(fontSize: 10, color: Colors.white.withValues(alpha: 0.2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            fillColor: Colors.white.withValues(alpha: 0.04),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CARD DECORATION HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  BoxDecoration _resolveCardDecoration(String style) {
    switch (style) {
      case 'Minimal Black':
        return BoxDecoration(
          color: const Color(0xFF070913),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 0.8),
        );
      case 'Warm Wood':
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3E2723), Color(0xFF1B0000)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF8D6E63), width: 1.0),
        );
      case 'Glass':
        return BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.0),
        );
      case 'Paper Card':
        return BoxDecoration(
          color: const Color(0xFFF9F6F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E2D9), width: 0.8),
        );
      case 'Notebook':
        return BoxDecoration(
          color: const Color(0xFFFCFDFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCFD8DC), width: 0.8),
        );
      case 'Dark Gradient':
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF311042)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.3), width: 1.0),
        );
      case 'Luxury Gold':
        return BoxDecoration(
          color: const Color(0xFF110D08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC5A059), width: 1.2),
        );
      case 'Aurora':
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        );
      case 'Stone':
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF212121), Color(0xFF424242)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade700, width: 0.8),
        );
      case 'Canvas':
      default:
        return BoxDecoration(
          color: const Color(0xFFEFEBE9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD7CCC8), width: 1.0),
        );
    }
  }

  Map<String, Color> _resolveCardColors(String style) {
    switch (style) {
      case 'Minimal Black':
        return {'text': Colors.white.withValues(alpha: 0.9), 'sub': Colors.white38};
      case 'Warm Wood':
        return {'text': const Color(0xFFFFD180), 'sub': const Color(0xFF8D6E63)};
      case 'Glass':
        return {'text': Colors.white, 'sub': Colors.white38};
      case 'Paper Card':
        return {'text': const Color(0xFF263238), 'sub': Colors.black38};
      case 'Notebook':
        return {'text': const Color(0xFF1E293B), 'sub': Colors.black38};
      case 'Dark Gradient':
        return {'text': Colors.white.withValues(alpha: 0.95), 'sub': Colors.white30};
      case 'Luxury Gold':
        return {'text': const Color(0xFFE5C158), 'sub': const Color(0xFF8C713B)};
      case 'Aurora':
        return {'text': const Color(0xFFE0F7FA), 'sub': const Color(0xFF80DEEA)};
      case 'Stone':
        return {'text': Colors.grey.shade200, 'sub': Colors.grey.shade500};
      case 'Canvas':
      default:
        return {'text': const Color(0xFF4E342E), 'sub': const Color(0xFF8D6E63)};
    }
  }

  TextStyle _resolveQuoteStyle(String fontStyle) {
    switch (fontStyle) {
      case 'Sans-Serif':
        return GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500);
      case 'Handwriting':
        return GoogleFonts.architectsDaughter(fontSize: 14);
      case 'Serif':
      default:
        return GoogleFonts.playfairDisplay(fontSize: 14, fontStyle: FontStyle.italic);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// AMBIENT PARTICLE MODELS
// ═══════════════════════════════════════════════════════════════════════════════

class _DustMote {
  double x;
  double y;
  final double speed;
  final double size;
  final double swaySpeed;

  _DustMote({required this.x, required this.y, required this.speed, required this.size, required this.swaySpeed});
}

class _SteamWisp {
  double xOffset;
  double progress;
  final double speed;
  final double size;

  _SteamWisp({required this.xOffset, required this.progress, required this.speed, required this.size});
}

// ═══════════════════════════════════════════════════════════════════════════════
// STUDY ROOM CUSTOM PAINTER
// ═══════════════════════════════════════════════════════════════════════════════

class _StudyRoomPainter extends CustomPainter {
  final String woodTexture;
  final double ambientTime;
  final List<_DustMote> dustMotes;
  final List<_SteamWisp> steamWisps;

  const _StudyRoomPainter({
    required this.woodTexture,
    required this.ambientTime,
    required this.dustMotes,
    required this.steamWisps,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final hour = DateTime.now().hour;
    final isNight = hour >= 18 || hour < 6;

    // ─── 1. ROOM BASE (dark plaster wall with morning/night ambient tint) ────────────────
    final roomPaint = Paint()
      ..shader = LinearGradient(
        colors: isNight
            ? [const Color(0xFF04060C), const Color(0xFF080D1A), const Color(0xFF030509)]
            : [const Color(0xFF090E1A), const Color(0xFF14203B), const Color(0xFF070B14)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), roomPaint);

    // ─── 2. VERTICAL WOOD PANELING (subtle wall texture) ─────────────────
    Color woodColor;
    if (woodTexture == 'Oak') {
      woodColor = const Color(0xFFC7B3A3);
    } else if (woodTexture == 'Mahogany') {
      woodColor = const Color(0xFF4A2C22);
    } else {
      woodColor = const Color(0xFF2E1912); // walnut
    }

    final plankPaint = Paint()
      ..color = Color.lerp(woodColor, Colors.black, 0.92)!.withValues(alpha: isNight ? 0.08 : 0.12)
      ..strokeWidth = 0.8;

    final int numPlanks = 12;
    final double plankW = w / numPlanks;
    for (int i = 1; i < numPlanks; i++) {
      final x = i * plankW;
      canvas.drawLine(Offset(x, 0), Offset(x, h), plankPaint);
    }

    // ─── 3. WOODEN DESK SURFACE (bottom 22%) ─────────────────────────────
    final deskTop = h * 0.78;
    final deskPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color.lerp(woodColor, Colors.black, isNight ? 0.45 : 0.35)!,
          Color.lerp(woodColor, Colors.black, isNight ? 0.65 : 0.55)!,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, deskTop, w, h - deskTop));

    final deskPath = Path()
      ..moveTo(w * 0.02, deskTop)
      ..lineTo(w * 0.98, deskTop)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(deskPath, deskPaint);

    // Desk edge highlight
    canvas.drawLine(
      Offset(w * 0.02, deskTop),
      Offset(w * 0.98, deskTop),
      Paint()..color = Colors.white.withValues(alpha: isNight ? 0.04 : 0.08)..strokeWidth = 1.0,
    );

    // Desk front bevel
    final bevelTop = deskTop;
    final bevelBot = deskTop + 10;
    final bevelPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color.lerp(woodColor, Colors.black, isNight ? 0.35 : 0.25)!,
          Color.lerp(woodColor, Colors.black, isNight ? 0.60 : 0.50)!,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, bevelTop, w, bevelBot - bevelTop));
    canvas.drawRect(Rect.fromLTWH(w * 0.02, bevelTop, w * 0.96, bevelBot - bevelTop), bevelPaint);

    // Horizontal wood grain on desk
    final grainPaint = Paint()
      ..color = Color.lerp(woodColor, Colors.black, 0.60)!.withValues(alpha: 0.08)
      ..strokeWidth = 0.5;
    for (double y = deskTop + 15; y < h; y += 8) {
      canvas.drawLine(Offset(w * 0.04, y), Offset(w * 0.96, y), grainPaint);
    }

    // ─── 4. FLOATING SHELF (mid-left) ────────────────────────────────────
    final shelfY = h * 0.32;
    final shelfW = w * 0.20;
    final shelfPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color.lerp(woodColor, Colors.black, 0.30)!,
          Color.lerp(woodColor, Colors.black, 0.50)!,
        ],
      ).createShader(Rect.fromLTWH(0, shelfY, shelfW, 8));
    canvas.drawRect(Rect.fromLTWH(0, shelfY, shelfW, 7), shelfPaint);
    canvas.drawRect(Rect.fromLTWH(0, shelfY + 7, shelfW, 2), Paint()..color = Colors.black45);

    // Books on shelf
    canvas.drawRect(Rect.fromLTWH(10, shelfY - 22, 6, 22), Paint()..color = const Color(0xFF1E3A8A));
    canvas.drawRect(Rect.fromLTWH(17, shelfY - 18, 5, 18), Paint()..color = const Color(0xFF991B1B));
    canvas.drawRect(Rect.fromLTWH(23, shelfY - 15, 5, 15), Paint()..color = const Color(0xFF065F46));
    canvas.drawRect(Rect.fromLTWH(30, shelfY - 20, 4, 20), Paint()..color = const Color(0xFF92400E));

    // ─── 5. INDOOR PLANT (trailing ivy with sway) ─────────────────────────
    final plantPotPaint = Paint()..color = const Color(0xFFCFD8DC);
    canvas.drawRect(Rect.fromLTWH(42, shelfY - 9, 10, 9), plantPotPaint);

    final stemPaint = Paint()
      ..color = const Color(0xFF065F46)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final leafPaint = Paint()..color = const Color(0xFF047857);

    // Calculate dynamic leaf sways using ambientTime
    final sway1 = math.sin(ambientTime * 2 * math.pi + 1.0) * 1.5;
    final sway2 = math.cos(ambientTime * 2 * math.pi + 2.0) * 1.2;
    final sway3 = math.sin(ambientTime * 2 * math.pi + 3.0) * 1.8;

    final vine = Path()
      ..moveTo(47, shelfY - 4)
      ..quadraticBezierTo(49 + sway1, shelfY + 12, 45 + sway2, shelfY + 24)
      ..quadraticBezierTo(42 + sway3, shelfY + 32, 46 + sway1, shelfY + 42);
    canvas.drawPath(vine, stemPaint);
    canvas.drawCircle(Offset(49 + sway1, shelfY + 8), 2.2, leafPaint);
    canvas.drawCircle(Offset(44 + sway2, shelfY + 18), 1.8, leafPaint);
    canvas.drawCircle(Offset(46 + sway3, shelfY + 28), 2.4, leafPaint);
    canvas.drawCircle(Offset(43 + sway1, shelfY + 38), 1.6, leafPaint);

    // ─── 6. DESK LAMP (right side of desk) ───────────────────────────────
    final lampX = w * 0.85;
    final lampBaseY = deskTop - 4;

    // Lamp glow cone (warm flickering)
    final candleFlicker = 0.06 + math.sin(ambientTime * 2 * math.pi * 3) * 0.03;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.amberAccent.withValues(alpha: isNight ? (0.08 + candleFlicker) : (0.04 + candleFlicker * 0.5)),
          Colors.transparent,
        ],
        center: Alignment.center,
        radius: 0.8,
      ).createShader(Rect.fromCircle(center: Offset(lampX, lampBaseY - 35), radius: 60));
    canvas.drawCircle(Offset(lampX, lampBaseY - 35), 60, glowPaint);

    // Lamp stem
    canvas.drawLine(
      Offset(lampX, lampBaseY),
      Offset(lampX, lampBaseY - 40),
      Paint()..color = const Color(0xFF3A3A3A)..strokeWidth = 2.5,
    );
    // Lamp shade
    final shadePath = Path()
      ..moveTo(lampX - 14, lampBaseY - 38)
      ..lineTo(lampX + 14, lampBaseY - 38)
      ..lineTo(lampX + 8, lampBaseY - 50)
      ..lineTo(lampX - 8, lampBaseY - 50)
      ..close();
    canvas.drawPath(shadePath, Paint()..color = const Color(0xFF1A472A).withValues(alpha: 0.9));
    // Lamp base
    canvas.drawRect(
      Rect.fromLTWH(lampX - 10, lampBaseY - 3, 20, 3),
      Paint()..color = const Color(0xFF2A2A2A),
    );

    // ─── 7. CANDLE (left side of desk) ───────────────────────────────────
    final candleX = w * 0.12;
    final candleBaseY = deskTop - 4;

    // Candle body
    canvas.drawRect(
      Rect.fromLTWH(candleX - 4, candleBaseY - 18, 8, 18),
      Paint()..color = const Color(0xFFF5F0E8),
    );
    // Wick
    canvas.drawLine(
      Offset(candleX, candleBaseY - 18),
      Offset(candleX, candleBaseY - 22),
      Paint()..color = const Color(0xFF333333)..strokeWidth = 0.8,
    );
    // Flame
    final flameSize = 3.0 + math.sin(ambientTime * 2 * math.pi * 5) * 0.8;
    canvas.drawCircle(
      Offset(candleX, candleBaseY - 24),
      flameSize,
      Paint()..color = Colors.amberAccent.withValues(alpha: 0.7),
    );
    canvas.drawCircle(
      Offset(candleX, candleBaseY - 24),
      flameSize * 0.5,
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );
    // Candle glow
    canvas.drawCircle(
      Offset(candleX, candleBaseY - 22),
      20,
      Paint()..color = Colors.amberAccent.withValues(alpha: candleFlicker * 0.5),
    );

    // ─── 8. COFFEE MUG (right-center of desk) ───────────────────────────
    final mugX = w * 0.70;
    final mugBaseY = deskTop - 4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(mugX - 6, mugBaseY - 12, 12, 12), const Radius.circular(2)),
      Paint()..color = const Color(0xFF3E2723),
    );
    // Mug handle
    final handlePath = Path()
      ..moveTo(mugX + 6, mugBaseY - 10)
      ..quadraticBezierTo(mugX + 12, mugBaseY - 6, mugX + 6, mugBaseY - 3);
    canvas.drawPath(handlePath, Paint()
      ..color = const Color(0xFF3E2723)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    // Steam wisps
    for (var s in steamWisps) {
      final sx = mugX + s.xOffset;
      final sy = mugBaseY - 14 - (s.progress * 25);
      final steamAlpha = (1.0 - s.progress) * 0.06;
      canvas.drawCircle(
        Offset(sx, sy),
        s.size,
        Paint()..color = Colors.white.withValues(alpha: steamAlpha),
      );
    }

    // ─── 9. REAL-TIME WALL CLOCK (top right) ──────────────────────────────
    final clockX = w * 0.82;
    final clockY = h * 0.16;
    final clockRadius = 22.0;

    // Clock wood frame
    canvas.drawCircle(Offset(clockX, clockY), clockRadius, Paint()..color = Color.lerp(woodColor, Colors.black, 0.4)!);
    canvas.drawCircle(Offset(clockX, clockY), clockRadius - 2, Paint()..color = const Color(0xFF0F121C));

    // Clock dial ticks (12 points)
    final tickPaint = Paint()..color = Colors.white24..strokeWidth = 0.8;
    for (int i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final start = Offset(clockX + (clockRadius - 5) * math.cos(angle), clockY + (clockRadius - 5) * math.sin(angle));
      final end = Offset(clockX + (clockRadius - 2) * math.cos(angle), clockY + (clockRadius - 2) * math.sin(angle));
      canvas.drawLine(start, end, tickPaint);
    }

    // Get exact local time
    final now = DateTime.now();
    final secondAngle = (now.second * 6 - 90) * math.pi / 180;
    final minuteAngle = ((now.minute + now.second / 60.0) * 6 - 90) * math.pi / 180;
    final hourAngle = (((now.hour % 12) + now.minute / 60.0) * 30 - 90) * math.pi / 180;

    // Hour hand (thick, short)
    canvas.drawLine(
      Offset(clockX, clockY),
      Offset(clockX + (clockRadius - 9) * math.cos(hourAngle), clockY + (clockRadius - 9) * math.sin(hourAngle)),
      Paint()..color = Colors.white70..strokeWidth = 1.8..strokeCap = StrokeCap.round,
    );
    // Minute hand (medium, long)
    canvas.drawLine(
      Offset(clockX, clockY),
      Offset(clockX + (clockRadius - 5) * math.cos(minuteAngle), clockY + (clockRadius - 5) * math.sin(minuteAngle)),
      Paint()..color = Colors.white54..strokeWidth = 1.0..strokeCap = StrokeCap.round,
    );
    // Second hand (thin, amber Accent)
    canvas.drawLine(
      Offset(clockX, clockY),
      Offset(clockX + (clockRadius - 4) * math.cos(secondAngle), clockY + (clockRadius - 4) * math.sin(secondAngle)),
      Paint()..color = Colors.amberAccent.withValues(alpha: 0.8)..strokeWidth = 0.5..strokeCap = StrokeCap.round,
    );
    // Center cap
    canvas.drawCircle(Offset(clockX, clockY), 1.2, Paint()..color = Colors.amberAccent);

    // ─── 10. LEATHER NOTEBOOK & GOLDEN PEN (on desk) ──────────────────────
    final nbX = w * 0.38;
    final nbY = deskTop + 35;
    final nbW = 34.0;
    final nbH = 22.0;

    // Leather cover shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(nbX - nbW/2 - 1, nbY - nbH/2 - 1, nbW + 2, nbH + 2), const Radius.circular(2.5)),
      Paint()..color = Colors.black.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    // Leather cover back
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(nbX - nbW/2 - 1, nbY - nbH/2 - 1, nbW + 2, nbH + 2), const Radius.circular(2)),
      Paint()..color = const Color(0xFF5D4037),
    );
    // Paper pages
    canvas.drawRect(Rect.fromLTWH(nbX - nbW/2 + 1, nbY - nbH/2 + 1, nbW/2 - 1.5, nbH - 2), Paint()..color = const Color(0xFFFBF8EE));
    canvas.drawRect(Rect.fromLTWH(nbX + 0.5, nbY - nbH/2 + 1, nbW/2 - 1.5, nbH - 2), Paint()..color = const Color(0xFFFBF8EE));
    // Book spine crease
    canvas.drawLine(Offset(nbX, nbY - nbH/2 + 1), Offset(nbX, nbY + nbH/2 - 1), Paint()..color = Colors.black38..strokeWidth = 0.6);

    // Notebook ruled lines
    final ruledLinePaint = Paint()..color = const Color(0xFFE0E0E0)..strokeWidth = 0.4;
    for (double ly = nbY - nbH/2 + 3; ly < nbY + nbH/2 - 1; ly += 3.5) {
      canvas.drawLine(Offset(nbX - nbW/2 + 3, ly), Offset(nbX - 1.5, ly), ruledLinePaint);
      canvas.drawLine(Offset(nbX + 2, ly), Offset(nbX + nbW/2 - 3, ly), ruledLinePaint);
    }

    // Golden stylus/pen resting on page right edge
    final penPaint = Paint()..color = const Color(0xFFC5A059)..strokeWidth = 1.0..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(nbX + nbW/2 + 3, nbY - nbH/2 + 4),
      Offset(nbX + nbW/2 + 7, nbY + nbH/2 - 3),
      penPaint,
    );

    // ─── 11. WARM SPOTLIGHT (top center, above hero frame area) ───────────
    final spotlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.amberAccent.withValues(alpha: isNight ? (0.04 + candleFlicker * 0.25) : (0.02 + candleFlicker * 0.12)),
          Colors.transparent,
        ],
        center: const Alignment(0, -0.8),
        radius: 0.8,
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.5));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.5), spotlightPaint);

    // ─── 12. FLOATING DUST MOTES ─────────────────────────────────────────
    for (var d in dustMotes) {
      final dx = d.x * w + math.sin(ambientTime * 2 * math.pi * d.swaySpeed + d.x * 10) * 3;
      final dy = d.y * h;
      canvas.drawCircle(
        Offset(dx, dy),
        d.size,
        Paint()..color = Colors.white.withValues(alpha: isNight ? 0.05 : 0.03),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StudyRoomPainter oldDelegate) => true;
}
