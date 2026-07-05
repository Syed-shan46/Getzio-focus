import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getzio_todo_app/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/os_providers.dart';
import '../../../affirmations/domain/models/affirmation_model.dart';
import '../../../affirmations/presentation/providers/affirmations_provider.dart';
import '../../../affirmations/presentation/screens/reader_view_screen.dart';
import '../../../affirmations/presentation/screens/dedicated_editor_screen.dart';
import '../../../affirmations/presentation/widgets/affirmation_bottom_sheet.dart';
import '../../../affirmations/presentation/widgets/daily_spark_sheet.dart';
import '../../../affirmations/presentation/widgets/hanging_daily_spark.dart';

import '../../../auth/presentation/widgets/premium_auth_sheet.dart';

class DailyMotivationScreen extends ConsumerStatefulWidget {
  final VoidCallback? onClose;
  final bool isTab;

  const DailyMotivationScreen({super.key, this.onClose, this.isTab = false});

  @override
  ConsumerState<DailyMotivationScreen> createState() =>
      _DailyMotivationScreenState();
}

class _DailyMotivationScreenState extends ConsumerState<DailyMotivationScreen>
    with TickerProviderStateMixin {
  late AnimationController _ambientController;
  late AnimationController _glowController;

  // Page Controller for Horizontal View
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  // Category-specific controllers and pages for the 'All' section grouping
  final Map<String, int> _categoryCurrentPages = {};
  final Map<String, ScrollController> _categoryScrollControllers = {};
  late ScrollController _singleScrollController;

  // Ambient particles
  final List<_DustMote> _dustMotes = [];

  // Searching / Header actions
  bool _isSearching = false;
  bool _isDailySparkOpen = false;
  final TextEditingController _searchController = TextEditingController();

  // Active Category selector (maps to provider)
  final List<String> _categories = [
    'All',
    'Mindset',
    'Confidence',
    'Gratitude',
    'Discipline',
    'Business',
    'Fitness',
    'Health',
    'Success',
    'Relationships',
    'Faith',
    'Learning',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    _singleScrollController = ScrollController();
    _pageController = PageController(initialPage: 0);

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // Initialize floating dust particles
    final random = math.Random();
    _dustMotes.addAll(
      List.generate(
        12,
        (_) => _DustMote(
          x: random.nextDouble(),
          y: random.nextDouble(),
          speed: 0.01 + random.nextDouble() * 0.02,
          size: 0.8 + random.nextDouble() * 1.5,
          swaySpeed: 0.05 + random.nextDouble() * 0.08,
        ),
      ),
    );

    _searchController.addListener(() {
      ref
          .read(affirmationsProvider.notifier)
          .setSearchQuery(_searchController.text);
    });

    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final filtered = ref
          .read(affirmationsProvider.notifier)
          .getFilteredAffirmations();
      if (filtered.isEmpty) return;

      final pinned = filtered.where((a) => a.isPinned).toList();
      final normal = filtered.where((a) => !a.isPinned).toList();
      final totalCount = pinned.length + normal.length;
      if (totalCount <= 1) return;

      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= totalCount) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _ambientController.dispose();
    _glowController.dispose();
    _searchController.dispose();
    _singleScrollController.dispose();
    for (var controller in _categoryScrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(premiumAuthTriggerProvider, (previous, next) {
      if (next != null) {
        PremiumAuthSheet.show(context);
        ref.read(premiumAuthTriggerProvider.notifier).state = null; // reset
      }
    });

    final osState = ref.watch(osStateProvider);
    final affState = ref.watch(affirmationsProvider);
    final filteredAffirmations = ref
        .watch(affirmationsProvider.notifier)
        .getFilteredAffirmations();

    // Split into pinned and normal lists
    final pinnedCards = filteredAffirmations.where((a) => a.isPinned).toList();
    final normalCards = filteredAffirmations.where((a) => !a.isPinned).toList();

    // Sort so pinned are kept at top of list
    final sortedAffirmations = [...pinnedCards, ...normalCards];

    return Scaffold(
      backgroundColor: context.colors.bg1,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ─── SCROLLABLE CORE INTERFACE ───
          RepaintBoundary(
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(osState, affState),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount:
                          2 +
                          (sortedAffirmations.isEmpty
                              ? 2
                              : sortedAffirmations.length + 1),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            children: [
                              _buildHeroCard(
                                pinnedCards.isNotEmpty
                                    ? pinnedCards.first
                                    : null,
                                osState,
                              ),
                              const SizedBox(height: 20),
                              _buildCategoryChips(affState),
                              const SizedBox(height: 16),
                            ],
                          );
                        }
                        if (sortedAffirmations.isEmpty) {
                          if (index == 1) return _buildEmptyPlaceholder();
                          return const SizedBox(height: 80);
                        }
                        final cardIndex = index - 1;
                        if (cardIndex < sortedAffirmations.length) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildVertical3DCard(
                              sortedAffirmations[cardIndex],
                              osState,
                            ),
                          );
                        }
                        return const SizedBox(height: 80);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 90,
            right: 20,
            child: GestureDetector(
              onTap: () {
                final isGuest = ref.read(authProvider).valueOrNull == null;
                if (isGuest) {
                  PremiumAuthSheet.show(context);
                } else {
                  AffirmationBottomSheet.show(context);
                }
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8B5A2B),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3C2E24).withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white.withOpacity(0.85),
                  size: 28,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: HangingDailySpark(
              isSheetOpen: _isDailySparkOpen,
              onTap: () async {
                setState(() => _isDailySparkOpen = true);
                await DailySparkSheet.show(context);
                if (mounted) {
                  setState(() => _isDailySparkOpen = false);
                }
              },
            ),
          ),

        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(OSState osState, AffirmationsState affState) {
    final authUser = ref.watch(authProvider).valueOrNull;
    final greetingName = authUser != null && authUser.name.isNotEmpty
        ? authUser.name
        : 'Syed';
    final greeting = '${_getGreeting()}, $greetingName 👏';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (!widget.isTab && widget.onClose != null) ...[
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3ECE4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE6DFD5),
                        width: 0.8,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF6B4E3D),
                      size: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [const SizedBox(height: 2)],
                ),
              ),
              // Search trigger
              IconButton(
                icon: Icon(
                  _isSearching ? Icons.close : Icons.search_rounded,
                  color: const Color(0xFF6B4E3D),
                  size: 24,
                ),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      ref
                          .read(affirmationsProvider.notifier)
                          .setSearchQuery('');
                    }
                  });
                },
              ),
              _buildSyncBadge(affState),
            ],
          ),
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF3C2E24),
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Search mental affirmations...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8B7355),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF6B4E3D),
                    size: 18,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFFFDF9),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE6DFD5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6B4E3D)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSyncBadge(AffirmationsState affState) {
    IconData icon = Icons.cloud_done_rounded;
    Color col = const Color(0xFF2E7D32); // Deep green for light theme

    if (affState.isSyncing) {
      icon = Icons.sync_rounded;
      col = const Color(0xFFF59E0B);
    } else if (affState.isOffline) {
      icon = Icons.cloud_off_rounded;
      col = const Color(0xFF8B7355);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3ECE4),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE6DFD5), width: 0.8),
      ),
      child: Icon(icon, color: col, size: 16),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HERO CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeroCard(DailyAffirmation? pinned, OSState osState) {
    final text = pinned != null ? pinned.text : osState.dailyQuote;
    final author = pinned != null
        ? (pinned.author ?? 'Anonymous')
        : osState.dailyQuoteAuthor;
    final theme = pinned?.colorTheme ?? 'Abundance';

    return GestureDetector(
      onTap: () {
        if (pinned != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReaderViewScreen(affirmation: pinned),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAF6F0), // Matching mockup background
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE6DFD5), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3C2E24).withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top tag row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3ECE4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.push_pin,
                        size: 8,
                        color: Color(0xFF6B4E3D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'PINNED FOCUS',
                        style: GoogleFonts.outfit(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6B4E3D),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Theme: $theme ☀️',
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    color: const Color(0xFF8B7355),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Middle layout: Sun picture on left, text on right
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Rising Sun circular illustration
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const CustomPaint(painter: _SunRisePainter()),
                ),
                const SizedBox(width: 12),

                // Text section with quotation marks
                Expanded(
                  child: Stack(
                    children: [
                      // Left quotation mark
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Text(
                          '“',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            color: const Color(0xFFE6DFD5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              text,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 13,
                                color: const Color(0xFF3C2E24),
                                fontWeight: FontWeight.bold,
                                height: 1.35,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '— $author',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                color: const Color(0xFF8B7355),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Right quotation mark
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Text(
                          '”',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            color: const Color(0xFFE6DFD5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORIES
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCategoryChips(AffirmationsState state) {
    return SizedBox(
      height: 30,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, idx) {
          final cat = _categories[idx];
          final isSelected = state.activeCategory == cat;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(affirmationsProvider.notifier).setActiveCategory(cat);
              setState(() {
                _currentPage = 0;
              });
              if (_singleScrollController.hasClients) {
                _singleScrollController.jumpTo(0);
              }
              _startAutoScroll();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6B4E3D) // Dark brown selected chip
                    : const Color(0xFFFFFDF9), // Unselected chip background
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6B4E3D)
                      : const Color(0xFFE6DFD5),
                  width: 1.0,
                ),
                boxShadow: [
                  if (!isSelected)
                    BoxShadow(
                      color: const Color(0xFF3C2E24).withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected && cat == 'All') ...[
                      const Icon(
                        Icons.auto_awesome,
                        size: 10,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      cat,
                      style: GoogleFonts.outfit(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF8B7355),
                        fontSize: 10.5,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AFFIRMATION CARD RENDER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAnimatedAffirmationCard(DailyAffirmation aff, OSState osState) {
    // Resolve theme colors
    Color cardBg = Colors.white;
    Color textCol = Colors.black;
    Color subCol = Colors.black54;

    switch (aff.colorTheme) {
      case 'Minimal White':
        cardBg = Colors.white.withOpacity(0.95);
        textCol = const Color(0xFF1F2937);
        subCol = const Color(0xFF6B7280);
        break;
      case 'Dark Glass':
        cardBg = const Color(0xFF1F2937).withOpacity(0.7);
        textCol = Colors.white;
        subCol = Colors.white60;
        break;
      case 'Midnight Black':
        cardBg = const Color(0xFF030712);
        textCol = const Color(0xFFF9FAFB);
        subCol = const Color(0xFF9CA3AF);
        break;
      case 'Sunrise Orange':
        cardBg = const Color(0xFFFFF7ED);
        textCol = const Color(0xFF7C2D12);
        subCol = const Color(0xFFC2410C);
        break;
      case 'Ocean Blue':
        cardBg = const Color(0xFFF0F9FF);
        textCol = const Color(0xFF0C4A6E);
        subCol = const Color(0xFF0284C7);
        break;
      case 'Forest Green':
        cardBg = const Color(0xFFF0FDF4);
        textCol = const Color(0xFF14532D);
        subCol = const Color(0xFF16A34A);
        break;
      case 'Lavender':
        cardBg = const Color(0xFFFAF5FF);
        textCol = const Color(0xFF581C87);
        subCol = const Color(0xFF9333EA);
        break;
      case 'Coffee Brown':
        cardBg = const Color(0xFFFDF8F5);
        textCol = const Color(0xFF431407);
        subCol = const Color(0xFFB45309);
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReaderViewScreen(affirmation: aff)),
        );
      },
      onLongPress: () {
        HapticFeedback.heavyImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DedicatedEditorScreen(affirmation: aff),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          // 3D Bevel/Shadow border lines
          border: Border.all(
            color: aff.isPinned
                ? Colors.amberAccent.withOpacity(0.7)
                : Colors.white.withOpacity(0.12),
            width: aff.isPinned ? 1.5 : 1.0,
          ),
          boxShadow: [
            // Bottom-right dark 3D drop shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 8,
              offset: const Offset(3, 4),
            ),
            // Top-left light bezel glow
            BoxShadow(
              color: Colors.white.withOpacity(0.04),
              blurRadius: 1,
              offset: const Offset(-1, -1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Section (Emoji / Category tag)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  aff.emoji != null && aff.emoji!.isNotEmpty ? aff.emoji! : '✨',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _getCategoryDisplayName(aff.category).toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: textCol.withOpacity(0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            // Middle text
            Expanded(
              child: Center(
                child: Text(
                  aff.text,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.playfairDisplay(
                    color: textCol,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
              ),
            ),

            // Bottom author
            Text(
              aff.author != null && aff.author!.isNotEmpty
                  ? '— ${aff.author}'
                  : '— Anon',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 8,
                color: subCol.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.spa_outlined, color: Colors.white24, size: 40),
            const SizedBox(height: 16),
            Text(
              'Peaceful Reflection Space',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No affirmations created inside this category. Tap the button below to anchor a new morning mantra.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white30,
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isSelected = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isSelected ? 14.0 : 6.0,
          height: 6.0,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6366F1)
                : Colors.white.withOpacity(0.24),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  List<Widget> _buildGroupedCategorySections(
    List<DailyAffirmation> sorted,
    OSState osState,
  ) {
    final Map<String, List<DailyAffirmation>> grouped = {};
    for (var a in sorted) {
      final displayName = _getCategoryDisplayName(a.category);
      grouped.putIfAbsent(displayName, () => []).add(a);
    }

    final List<Widget> widgets = [];
    for (var entry in grouped.entries) {
      final catName = entry.key;
      final catAffs = entry.value;

      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    catName.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.85),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(height: 0.5, color: Colors.white10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 145,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: catAffs.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final aff = catAffs[index];
                  return RepaintBoundary(
                    child: Container(
                      width: 240,
                      margin: const EdgeInsets.only(right: 8, bottom: 4),
                      child: _buildAnimatedAffirmationCard(aff, osState),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }
    return widgets;
  }

  Widget _buildCategoryDotIndicator(String category, int count) {
    final currentPage = _categoryCurrentPages[category] ?? 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isSelected = currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isSelected ? 14.0 : 6.0,
          height: 6.0,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6366F1)
                : Colors.white.withOpacity(0.24),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  String _getCategoryDisplayName(String cat) {
    if (cat.trim().isEmpty) return 'General';
    final map = {
      'def_1': 'Mindset',
      'def_2': 'Discipline',
      'def_3': 'Gratitude',
      'mindset': 'Mindset',
      'confidence': 'Confidence',
      'gratitude': 'Gratitude',
      'discipline': 'Discipline',
      'business': 'Business',
      'fitness': 'Fitness',
      'health': 'Health',
      'success': 'Success',
      'relationships': 'Relationships',
      'faith': 'Faith',
      'learning': 'Learning',
      'custom': 'Custom',
      'general': 'General',
    };
    final lower = cat.trim().toLowerCase();
    if (map.containsKey(lower)) {
      return map[lower]!;
    }
    return lower
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  Widget _buildVertical3DCard(DailyAffirmation aff, OSState osState) {
    final cardBg = _getCategoryCardBg(aff.category);
    final themeCol = _getCategoryColor(aff.category);
    final iconData = _getCategoryIcon(aff.category);
    final catName = _getCategoryDisplayName(aff.category).toUpperCase();

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReaderViewScreen(affirmation: aff),
            ),
          );
        },
        onLongPress: () {
          HapticFeedback.heavyImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DedicatedEditorScreen(affirmation: aff),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE6DFD5).withOpacity(0.3),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3C2E24).withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side: Category-specific circular icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      themeCol.withOpacity(0.04),
                      themeCol.withOpacity(0.14),
                    ],
                  ),
                ),
                child: Center(child: Icon(iconData, color: themeCol, size: 18)),
              ),
              const SizedBox(width: 10),

              // Middle: Category badge + Affirmation text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      catName,
                      style: GoogleFonts.outfit(
                        fontSize: 7.5,
                        fontWeight: FontWeight.bold,
                        color: themeCol,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      aff.text,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF3C2E24),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Right: Action button (Chevron Right)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF3ECE4).withOpacity(0.5),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF6B4E3D),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    final lower = cat.trim().toLowerCase();
    if (lower.contains('wealth') ||
        lower.contains('business') ||
        lower.contains('success')) {
      return Icons.eco_rounded;
    }
    if (lower.contains('productivity') || lower.contains('discipline')) {
      return Icons.track_changes_rounded;
    }
    if (lower.contains('health') || lower.contains('fitness')) {
      return Icons.self_improvement_rounded;
    }
    if (lower.contains('growth') || lower.contains('learning')) {
      return Icons.park_rounded;
    }
    if (lower.contains('gratitude')) {
      return Icons.volunteer_activism_rounded;
    }
    if (lower.contains('peace') ||
        lower.contains('faith') ||
        lower.contains('relationships')) {
      return Icons.spa_rounded;
    }
    return Icons.wb_sunny_rounded; // Default fallback
  }

  Color _getCategoryColor(String cat) {
    final lower = cat.trim().toLowerCase();
    if (lower.contains('wealth') ||
        lower.contains('business') ||
        lower.contains('success')) {
      return const Color(0xFF2E7D32); // Green
    }
    if (lower.contains('productivity') || lower.contains('discipline')) {
      return const Color(0xFFC62828); // Red
    }
    if (lower.contains('health') || lower.contains('fitness')) {
      return const Color(0xFF1565C0); // Blue
    }
    if (lower.contains('growth') || lower.contains('learning')) {
      return const Color(0xFF2E7D32); // Green
    }
    if (lower.contains('gratitude')) {
      return const Color(0xFF8D6E63); // Brown
    }
    if (lower.contains('peace') ||
        lower.contains('faith') ||
        lower.contains('relationships')) {
      return const Color(0xFF6A1B9A); // Purple
    }
    return const Color(0xFFE65100); // Orange
  }

  Color _getCategoryCardBg(String cat) {
    final lower = cat.trim().toLowerCase();
    if (lower.contains('wealth') ||
        lower.contains('business') ||
        lower.contains('success')) {
      return const Color(0xFFE8F5E9); // Light green
    }
    if (lower.contains('productivity') || lower.contains('discipline')) {
      return const Color(0xFFFFEBEE); // Light red
    }
    if (lower.contains('health') || lower.contains('fitness')) {
      return const Color(0xFFE3F2FD); // Light blue
    }
    if (lower.contains('growth') || lower.contains('learning')) {
      return const Color(0xFFE8F5E9); // Light green
    }
    if (lower.contains('gratitude')) {
      return const Color(0xFFEFEBE9); // Light brown
    }
    if (lower.contains('peace') ||
        lower.contains('faith') ||
        lower.contains('relationships')) {
      return const Color(0xFFF3E5F5); // Light purple
    }
    return const Color(0xFFFFF3E0); // Light orange
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUPPORTING PAINTERS
// ═══════════════════════════════════════════════════════════════════════════

class _DustMote {
  double x;
  double y;
  final double speed;
  final double size;
  final double swaySpeed;

  _DustMote({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.swaySpeed,
  });
}

class _SunRisePainter extends CustomPainter {
  const _SunRisePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    // Clip to circle
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.save();
    canvas.clipPath(path);

    // 1. Sky Background (warm orange gradient)
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFDE68A), // Light warm yellow
          Color(0xFFFCD34D), // Soft amber
          Color(0xFFF59E0B), // Warm orange
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // 2. Rising Sun
    final sunCenter = Offset(w * 0.5, h * 0.55);
    final sunPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);
    canvas.drawCircle(sunCenter, radius * 0.35, sunPaint);

    // 3. Sun rays/glow (soft outer circles)
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sunCenter, radius * 0.5, glowPaint);
    canvas.drawCircle(
      sunCenter,
      radius * 0.65,
      Paint()..color = Colors.white.withOpacity(0.1),
    );

    // 4. Mountains / Sand Dunes (from back to front)
    // Mountain 1 (Back - light orange/brown)
    final m1Paint = Paint()..color = const Color(0xFFFDBA74); // Orange-300
    final m1Path = Path()
      ..moveTo(0, h * 0.7)
      ..quadraticBezierTo(w * 0.3, h * 0.55, w * 0.6, h * 0.72)
      ..quadraticBezierTo(w * 0.8, h * 0.78, w, h * 0.68)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(m1Path, m1Paint);

    // Mountain 2 (Middle - amber/brown)
    final m2Paint = Paint()..color = const Color(0xFFF59E0B); // Amber-500
    final m2Path = Path()
      ..moveTo(0, h * 0.8)
      ..quadraticBezierTo(w * 0.4, h * 0.72, w * 0.7, h * 0.82)
      ..quadraticBezierTo(w * 0.85, h * 0.85, w, h * 0.75)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(m2Path, m2Paint);

    // Mountain 3 (Front - dark warm brown)
    final m3Paint = Paint()..color = const Color(0xFFD97706); // Amber-600
    final m3Path = Path()
      ..moveTo(0, h * 0.9)
      ..quadraticBezierTo(w * 0.25, h * 0.85, w * 0.5, h * 0.92)
      ..quadraticBezierTo(w * 0.75, h * 0.95, w, h * 0.86)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(m3Path, m3Paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
