import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/screens/phone_login_screen.dart';



class PremiumPreviewOverlay extends ConsumerWidget {
  final String featureId;
  final VoidCallback onContinue;

  const PremiumPreviewOverlay({
    super.key,
    required this.featureId,
    required this.onContinue,
  });

  static void show({
    required BuildContext context,
    required String featureId,
    required VoidCallback onContinue,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: PremiumPreviewOverlay(
            featureId: featureId,
            onContinue: () {
              Navigator.pop(context);
              onContinue();
            },
          ),
        );
      },
    );
  }

  String _getTitle() {
    switch (featureId) {
      case 'vision_room':
        return 'Vision Room';
      case 'affirmations':
        return 'Daily Affirmations';
      case 'focus':
      case 'routine':
      case 'goals':
        return 'Daily Focus & Goals';
      case 'journal':
        return 'Daily Journaling';
      case 'learning':
        return 'Reading & Learning';
      case 'finance':
        return 'Financial Tracker';
      case 'health':
        return 'Health & Lifestyle';
      case 'achievements':
        return 'Achievements Wall';
      default:
        return 'Premium Feature';
    }
  }

  String _getDescription() {
    switch (featureId) {
      case 'vision_room':
        return 'Design a modular workspace for your ambitions. Pin quotes, sticky notes, target boards, and images on a 3D living canvas.';
      case 'affirmations':
        return 'Center your day around positive reinforcement. Read curated and custom mantras rendered on beautiful widgets and frame walls.';
      case 'focus':
      case 'routine':
      case 'goals':
        return 'Plan your mission with structured, elegant task cards. Track daily habits, consistency scores, and level up your discipline.';
      case 'journal':
        return 'Reflect on your daily journey, capture ideas, track moods, and save memories in a secure personal journal.';
      case 'learning':
        return 'Build a consistent reading habit. Track book targets, pages read daily, and capture key lessons from your books.';
      case 'finance':
        return 'Take control of your personal finances. Set savings targets, log daily habits of saving, and reach your goals.';
      case 'health':
        return 'Monitor water intake, sleep quality, and daily exercise. Stay physically primed for high performance.';
      case 'achievements':
        return 'Unlock achievements, earn experience points (XP), and track consistency streaks as you level up your life.';
      default:
        return 'Elevate your daily routine with curated personal growth features.';
    }
  }

  Widget _buildFeaturePreview() {
    switch (featureId) {
      case 'vision_room':
        return _buildVisionRoomPreview();
      case 'affirmations':
        return _buildAffirmationsPreview();
      case 'focus':
      case 'routine':
      case 'goals':
        return _buildFocusPreview();
      default:
        return _buildGenericComingSoonPreview();
    }
  }

  Widget _buildGenericComingSoonPreview() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1424),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(
                Icons.construction_rounded,
                color: Colors.amberAccent,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Feature Under Development',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'We are polishing this workspace tool for the next release.',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisionRoomPreview() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          children: [
            // Corkboard/Wall textured background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF181B26), Color(0xFF1E2230)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // Decorative background lights
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber.withValues(alpha: 0.1),
                ),
              ),
            ),
            
            // Polaroid 1
            Positioned(
              left: 18,
              top: 20,
              child: Transform.rotate(
                angle: -0.06,
                child: Container(
                  width: 90,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 5,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 65,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Center(
                          child: Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 24),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Morning Routine',
                        style: GoogleFonts.outfit(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Polaroid 2
            Positioned(
              right: 18,
              top: 15,
              child: Transform.rotate(
                angle: 0.08,
                child: Container(
                  width: 85,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 5,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Center(
                          child: Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dream Goal',
                        style: GoogleFonts.outfit(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Sticky Note
            Positioned(
              left: 24,
              bottom: 12,
              child: Transform.rotate(
                angle: 0.04,
                child: Container(
                  width: 95,
                  height: 75,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF08A),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.push_pin_rounded, color: Colors.redAccent, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            'REMINDER',
                            style: GoogleFonts.outfit(
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          'Read 20 pages\nevery morning.',
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF78350F),
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Pinned Quote Frame
            Positioned(
              right: 28,
              bottom: 24,
              child: Transform.rotate(
                angle: -0.05,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFC9A96E),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Text(
                    '"Consistency is key"',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFC9A96E),
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAffirmationsPreview() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF140D07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF332014)),
      ),
      child: Center(
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF8B5A2B), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'I am the architect of my life; I build its foundation and choose its contents.',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  color: const Color(0xFF2D1500),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'DAILY INSPIRATION',
                style: TextStyle(
                  fontSize: 8,
                  letterSpacing: 1.2,
                  color: Color(0xFF8B5A2B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFocusPreview() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0C101B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TODAY\'S MISSIONS',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  letterSpacing: 1.0,
                  color: Colors.white54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '3 / 5 Done',
                  style: TextStyle(fontSize: 9, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                const SizedBox(width: 8),
                Text(
                  'Drink 2.5L Water today',
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle_outlined, color: Colors.blueAccent, size: 14),
                const SizedBox(width: 8),
                Text(
                  'Read 15 pages of book',
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isComingSoon = featureId != 'vision_room';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.88,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0F1A).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isComingSoon 
                          ? [const Color(0xFFD97706), const Color(0xFFB45309)]
                          : [const Color(0xFFF1C40F), const Color(0xFFE67E22)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isComingSoon ? 'COMING SOON' : 'PREMIUM PREVIEW',
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                _getTitle(),
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                _getDescription(),
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  color: Colors.white60,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              _buildFeaturePreview(),
              const SizedBox(height: 20),

              if (featureId == 'vision_room') ...[
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onContinue();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onContinue();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isComingSoon ? 'Got it' : 'Continue',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
