import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/os_providers.dart';
import '../../../affirmations/domain/models/affirmation_model.dart';
import '../../../affirmations/presentation/providers/affirmations_provider.dart';
import '../../../affirmations/presentation/screens/guest_preview_screen.dart';
import '../../../affirmations/presentation/screens/reader_view_screen.dart';
import '../../../affirmations/presentation/screens/dedicated_editor_screen.dart';
import '../../../affirmations/presentation/widgets/affirmation_bottom_sheet.dart';

class DailyMotivationScreen extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const DailyMotivationScreen({super.key, required this.onClose});

  @override
  ConsumerState<DailyMotivationScreen> createState() => _DailyMotivationScreenState();
}

class _DailyMotivationScreenState extends ConsumerState<DailyMotivationScreen>
    with TickerProviderStateMixin {
  late AnimationController _ambientController;
  late AnimationController _glowController;
  
  // Ambient particles
  final List<_DustMote> _dustMotes = [];
  
  // Searching / Header actions
  bool _isSearching = false;
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
    'Custom'
  ];

  @override
  void initState() {
    super.initState();
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
    _dustMotes.addAll(List.generate(12, (_) => _DustMote(
      x: random.nextDouble(),
      y: random.nextDouble(),
      speed: 0.01 + random.nextDouble() * 0.02,
      size: 0.8 + random.nextDouble() * 1.5,
      swaySpeed: 0.05 + random.nextDouble() * 0.08,
    )));

    _searchController.addListener(() {
      ref.read(affirmationsProvider.notifier).setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _glowController.dispose();
    _searchController.dispose();
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
    // 1. Check Authentication State
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.hasValue && authState.value != null;

    if (!isLoggedIn) {
      return GuestPreviewScreen(onClose: widget.onClose);
    }

    final osState = ref.watch(osStateProvider);
    final affState = ref.watch(affirmationsProvider);
    final filteredAffirmations = ref.watch(affirmationsProvider.notifier).getFilteredAffirmations();
    
    // Split into pinned and normal lists
    final pinnedCards = filteredAffirmations.where((a) => a.isPinned).toList();
    final normalCards = filteredAffirmations.where((a) => !a.isPinned).toList();
    
    // Sort so pinned are kept at top of list
    final sortedAffirmations = [...pinnedCards, ...normalCards];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ─── BACKGROUND ENVIRONMENT & ANIMATED WINDOW ───
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambientController,
              builder: (context, _) {
                // Update dust motes positions
                for (var d in _dustMotes) {
                  d.y = (d.y - 0.002 * d.speed) % 1.0;
                }
                return CustomPaint(
                  painter: _ReflectionSpacePainter(
                    ambientProgress: _ambientController.value,
                    glowProgress: _glowController.value,
                    dustMotes: _dustMotes,
                  ),
                );
              },
            ),
          ),

          // ─── SCROLLABLE CORE INTERFACE ───
          SafeArea(
            child: Column(
              children: [
                // Header Bar
                _buildHeader(osState, affState),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Today's Pinned Hero Section
                      _buildHeroCard(pinnedCards.isNotEmpty ? pinnedCards.first : null, osState),
                      const SizedBox(height: 20),

                      // Horizontal Category selector chips
                      _buildCategoryChips(affState),
                      const SizedBox(height: 16),

                      // List of Affirmation Cards
                      if (sortedAffirmations.isEmpty)
                        _buildEmptyPlaceholder()
                      else
                        ...sortedAffirmations.map((aff) => _buildAnimatedAffirmationCard(aff, osState)),

                      const SizedBox(height: 80), // spacer for FAB
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── FLOATING ACTION BUTTON FOR CREATING ───
          Positioned(
            bottom: 24,
            right: 20,
            child: FloatingActionButton.extended(
              heroTag: 'create_aff_fab',
              backgroundColor: const Color(0xFF6366F1),
              onPressed: () => AffirmationBottomSheet.show(context),
              icon: const Icon(Icons.spa_rounded, color: Colors.white, size: 18),
              label: Text(
                'Anchor Mantra',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
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
    final todayStr = DateFormat('EEEE, MMMM d').format(DateTime.now());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
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
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 15),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: GoogleFonts.outfit(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w400),
                    ),
                    Text(
                      'Affirmations',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Search & Menu triggers
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search_rounded, color: Colors.white70, size: 20),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      ref.read(affirmationsProvider.notifier).setSearchQuery('');
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
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search mental affirmations...',
                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54, size: 18),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.04),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6366F1)),
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
    Color col = Colors.greenAccent;

    if (affState.isSyncing) {
      icon = Icons.sync_rounded;
      col = Colors.amberAccent;
    } else if (affState.isOffline) {
      icon = Icons.cloud_off_rounded;
      col = Colors.white30;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Icon(icon, color: col, size: 16),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HERO CARD
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeroCard(DailyAffirmation? pinned, OSState osState) {
    final title = pinned != null ? pinned.title : 'Morning Anchor';
    final text = pinned != null ? pinned.text : osState.dailyQuote;
    final author = pinned != null ? (pinned.author ?? 'Anonymous') : osState.dailyQuoteAuthor;
    final theme = pinned?.colorTheme ?? 'Sunrise Orange';

    return GestureDetector(
      onTap: () {
        if (pinned != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ReaderViewScreen(affirmation: pinned)),
          );
        }
      },
      child: Container(
        height: 145,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.push_pin, color: Color(0xFFF59E0B), size: 10),
                            const SizedBox(width: 4),
                            Text(
                              'PINNED FOCUS',
                              style: GoogleFonts.outfit(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFF59E0B),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Theme: $theme',
                        style: GoogleFonts.outfit(fontSize: 9, color: Colors.white30, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '"$text"',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.45,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    '— $author',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: Colors.white54,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORIES
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCategoryChips(AffirmationsState state) {
    return SizedBox(
      height: 38,
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
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.08),
                  width: 0.8,
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: GoogleFonts.outfit(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
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

    return Dismissible(
      key: Key(aff.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
      ),
      onDismissed: (_) {
        HapticFeedback.vibrate();
        ref.read(affirmationsProvider.notifier).deleteAffirmation(aff.id);
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ReaderViewScreen(affirmation: aff)),
          );
        },
        onLongPress: () {
          HapticFeedback.heavyImpact();
          // Open Dedicated Editor screen directly!
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DedicatedEditorScreen(affirmation: aff)),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: aff.isPinned ? Colors.amberAccent.withOpacity(0.5) : Colors.white.withOpacity(0.06),
              width: aff.isPinned ? 1.5 : 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    if (aff.emoji != null && aff.emoji!.isNotEmpty) ...[
                      Text(aff.emoji!, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: textCol.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        aff.category.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: textCol.withOpacity(0.7),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (aff.isPinned)
                      Icon(Icons.push_pin, color: textCol.withOpacity(0.7), size: 12),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  '"${aff.text}"',
                  style: GoogleFonts.playfairDisplay(
                    color: textCol,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Row(
                  children: [
                    Text(
                      aff.author != null && aff.author!.isNotEmpty ? '— ${aff.author}' : '— Anonymous',
                      style: GoogleFonts.outfit(fontSize: 10, color: subCol, fontStyle: FontStyle.italic),
                    ),
                    const Spacer(),
                    // Favorite Toggle
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(affirmationsProvider.notifier).toggleFavorite(aff.id);
                      },
                      child: Icon(
                        aff.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: aff.isFavorite ? Colors.redAccent : subCol,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Duplicate Trigger
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(affirmationsProvider.notifier).duplicateAffirmation(aff.id);
                      },
                      child: Icon(Icons.copy_rounded, color: subCol, size: 16),
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
              style: GoogleFonts.playfairDisplay(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'No affirmations created inside this category. Tap the button below to anchor a new morning mantra.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.white30, fontSize: 11, height: 1.45),
            ),
          ],
        ),
      ),
    );
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

  _DustMote({required this.x, required this.y, required this.speed, required this.size, required this.swaySpeed});
}

class _ReflectionSpacePainter extends CustomPainter {
  final double ambientProgress;
  final double glowProgress;
  final List<_DustMote> dustMotes;

  _ReflectionSpacePainter({
    required this.ambientProgress,
    required this.glowProgress,
    required this.dustMotes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Draw animated vertical gradient (Sky/Atmospheric sunrise look)
    final topColor = Color.lerp(const Color(0xFF0F172A), const Color(0xFF1E1B4B), ambientProgress)!;
    final bottomColor = Color.lerp(const Color(0xFF1E1B4B), const Color(0xFF311A4D), ambientProgress)!;
    final bgGradient = LinearGradient(
      colors: [topColor, bottomColor],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = bgGradient.createShader(Rect.fromLTWH(0, 0, w, h)));

    // 2. Large background animated visualizer window (sun/moon glow peaks)
    final windowCenter = Offset(w * 0.5, h * 0.35);
    final glowRadius = 140.0 + (glowProgress * 20.0);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFD700).withOpacity(0.08),
          const Color(0xFF6366F1).withOpacity(0.02),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: windowCenter, radius: glowRadius));
    canvas.drawCircle(windowCenter, glowRadius, glowPaint);

    // 3. Draw ambient floating particles
    for (var d in dustMotes) {
      final dx = d.x * w + math.sin(ambientProgress * 2 * math.pi * d.swaySpeed) * 10;
      final dy = d.y * h;
      canvas.drawCircle(
        Offset(dx, dy),
        d.size,
        Paint()..color = Colors.white.withOpacity(0.08),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ReflectionSpacePainter oldDelegate) => true;
}
