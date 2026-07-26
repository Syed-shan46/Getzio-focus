import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/focus_timer_controller.dart';
import '../../domain/models/focus_session_model.dart';
import 'focus_mode_selector.dart';
import 'focus_animated_digits.dart';
import 'focus_progress_dots.dart';
import 'focus_particles_painter.dart';
import 'focus_motivational_text.dart';

class FocusTimerPanel extends ConsumerStatefulWidget {
  final double? customWidth;
  const FocusTimerPanel({super.key, this.customWidth});

  @override
  ConsumerState<FocusTimerPanel> createState() => _FocusTimerPanelState();
}

class _FocusTimerPanelState extends ConsumerState<FocusTimerPanel> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // 5-second loop
    )..repeat(reverse: true);
    
    _breathingAnimation = Tween<double>(begin: 0.04, end: 0.12).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(focusTimerControllerProvider);
    final isBreakMode = session?.mode == 'Break';
    final Color primaryColor = isBreakMode ? const Color(0xFF66FFB2) : const Color(0xFFFFB266);
    final bool isRunning = session?.isRunning ?? false;

    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        final glowOpacity = isRunning ? _breathingAnimation.value : 0.02;
        
        return Container(
          width: widget.customWidth ?? 340,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.0,
            ),
            boxShadow: [
              if (isRunning)
                BoxShadow(
                  color: primaryColor.withValues(alpha: glowOpacity),
                  blurRadius: 12.0,
                  spreadRadius: 1.0,
                ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
              child: FocusParticlesPainterWidget(
                isRunning: isRunning,
                isBreakMode: isBreakMode,
                child: Padding(
                  padding: widget.customWidth != null 
                        ? const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0)
                        : const EdgeInsets.all(20.0),
                  child: session == null
                      ? (widget.customWidth != null
                          ? _buildIdleCompact(context)
                          : _buildIdleFull(context))
                      : (widget.customWidth != null
                          ? _buildCompactContent(context, ref, session, primaryColor, isBreakMode)
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Header: State and Session Stats
                                _buildHeader(session, primaryColor, isBreakMode),
                                
                                const SizedBox(height: 16),
                                
                                // Animated Timer Digits
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (session.isRunning)
                                      _SecondTickPulse(color: primaryColor),
                                    FocusAnimatedDigits(
                                      remainingSeconds: session.remainingSeconds,
                                      isBreakMode: isBreakMode,
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Glowing Progress Dots
                                FocusProgressDots(
                                  totalDurationSeconds: session.duration,
                                  remainingSeconds: session.remainingSeconds,
                                  isBreakMode: isBreakMode,
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Motivational Microtext
                                FocusMotivationalText(
                                  isRunning: session.isRunning,
                                  isBreakMode: isBreakMode,
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Controls
                                _buildControls(context, ref, session),
                              ],
                            )),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(FocusSessionModel session, Color color, bool isBreakMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: session.isRunning ? color : Colors.grey,
                shape: BoxShape.circle,
                boxShadow: session.isRunning ? [
                  BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4)
                ] : null,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isBreakMode ? 'Rest & Recover' : session.mode,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        // Simple live stat (e.g. Session title)
        Text(
          session.sessionTitle,
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, WidgetRef ref, FocusSessionModel session) {
    final controller = ref.read(focusTimerControllerProvider.notifier);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (session.isRunning)
          _ControlButton(
            icon: Icons.pause_rounded,
            label: 'Pause',
            onTap: () => controller.pauseSession(),
          )
        else ...[
          _ControlButton(
            icon: Icons.play_arrow_rounded,
            label: 'Resume',
            onTap: () => controller.resumeSession(),
          ),
          const SizedBox(width: 16),
          _ControlButton(
            icon: Icons.stop_rounded,
            label: 'End',
            isDestructive: true,
            onTap: () => controller.endSessionEarly(),
          ),
        ]
      ],
    );
  }

  Widget _buildCompactContent(BuildContext context, WidgetRef ref, FocusSessionModel session, Color primaryColor, bool isBreakMode) {
    final controller = ref.read(focusTimerControllerProvider.notifier);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Compact Header: Dot + Mode + Quick Action Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: session.isRunning ? primaryColor : Colors.grey,
                      shape: BoxShape.circle,
                      boxShadow: session.isRunning ? [
                        BoxShadow(color: primaryColor.withValues(alpha: 0.6), blurRadius: 4)
                      ] : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      session.sessionTitle.isNotEmpty ? session.sessionTitle : (isBreakMode ? 'Rest' : session.mode),
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Quick Control Icons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (session.isRunning)
                  GestureDetector(
                    onTap: () => controller.pauseSession(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.pause_rounded, size: 14, color: Colors.white),
                    ),
                  )
                else ...[
                  GestureDetector(
                    onTap: () => controller.resumeSession(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.play_arrow_rounded, size: 14, color: primaryColor),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => controller.endSessionEarly(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stop_rounded, size: 14, color: Colors.redAccent),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Timer Digits (compact 30pt font)
        FocusAnimatedDigits(
          remainingSeconds: session.remainingSeconds,
          isBreakMode: isBreakMode,
          fontSize: 30,
        ),

        const SizedBox(height: 6),

        // Progress Dots
        FocusProgressDots(
          totalDurationSeconds: session.duration,
          remainingSeconds: session.remainingSeconds,
          isBreakMode: isBreakMode,
          isCompact: widget.customWidth != null,
        ),
      ],
    );
  }

  Widget _buildIdleCompact(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusModeSelector.show(context),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFB266),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Focus Mode',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB266).withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 14,
                  color: Color(0xFFFFB266),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '25:00',
            style: GoogleFonts.outfit(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.0,
              letterSpacing: -1.0,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap to Start',
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFFFB266).withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleFull(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusModeSelector.show(context),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFB266),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Focus Session',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              Text(
                'Ready',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '25:00',
            style: GoogleFonts.outfit(
              fontSize: 52,
              fontWeight: FontWeight.w800,
              height: 1.0,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB266).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFB266).withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_arrow_rounded, color: Color(0xFFFFB266), size: 20),
                const SizedBox(width: 6),
                Text(
                  'Start Focus',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFB266),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive ? Colors.red.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isDestructive ? Colors.redAccent : Colors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.redAccent : Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Subtly pulses behind the timer every second
class _SecondTickPulse extends StatefulWidget {
  final Color color;
  const _SecondTickPulse({required this.color});

  @override
  State<_SecondTickPulse> createState() => _SecondTickPulseState();
}

class _SecondTickPulseState extends State<_SecondTickPulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.15, end: 0.0), weight: 50),
    ]).animate(_controller);
    
    // We want to trigger it every second.
    // Instead of aligning with the Riverpod 1-sec ticker precisely, 
    // we can just loop it with a 1-second delay, or listen to didUpdateWidget if we pass a value.
    // Simplest is to just loop it every 1s.
    _pulseLoop();
  }
  
  void _pulseLoop() async {
    while (mounted) {
      _controller.forward(from: 0.0);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: Opacity(
            opacity: _opacityAnim.value,
            child: Container(
              width: 200,
              height: 80,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  )
                ]
              ),
            ),
          ),
        );
      },
    );
  }
}
