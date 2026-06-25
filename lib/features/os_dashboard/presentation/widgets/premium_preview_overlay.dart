import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/widgets/save_workspace_sheet.dart';

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
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1424),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: GridPaper(
              color: Colors.blueAccent.withValues(alpha: 0.05),
              interval: 40,
              subdivisions: 1,
            ),
          ),
          Positioned(
            left: 20,
            top: 20,
            child: Transform.rotate(
              angle: -0.05,
              child: Container(
                width: 100,
                height: 80,
                padding: const EdgeInsets.all(8),
                color: Colors.amberAccent,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📌 IDEA', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black)),
                    SizedBox(height: 4),
                    Text('Launch Getzio Focus!', style: TextStyle(fontSize: 10, color: Colors.black87)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 25,
            top: 30,
            child: Transform.rotate(
              angle: 0.08,
              child: Container(
                width: 110,
                height: 110,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6),
                  ],
                ),
                child: Container(
                  color: Colors.blueGrey,
                  child: const Center(
                    child: Text('🏝️ Dream Workspace', style: TextStyle(fontSize: 8, color: Colors.white70)),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 30,
            bottom: 20,
            child: Container(
              width: 150,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: const Text(
                '"Focus creates reality."',
                style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.white70),
              ),
            ),
          ),
        ],
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
              const SizedBox(height: 24),

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
              if (!isComingSoon) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    SaveWorkspaceSheet.show(context);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    'Sign In & Sync to save progress across devices',
                    style: GoogleFonts.outfit(
                      color: Colors.white38,
                      fontSize: 10.5,
                      decoration: TextDecoration.underline,
                    ),
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
