import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FocusMotivationalText extends StatefulWidget {
  final bool isRunning;
  final bool isBreakMode;
  
  const FocusMotivationalText({
    super.key,
    required this.isRunning,
    this.isBreakMode = false,
  });

  @override
  State<FocusMotivationalText> createState() => _FocusMotivationalTextState();
}

class _FocusMotivationalTextState extends State<FocusMotivationalText> {
  Timer? _timer;
  int _currentIndex = 0;
  
  final List<String> _focusQuotes = [
    "Every second matters.",
    "Stay present.",
    "Keep going.",
    "Progress is invisible until it isn't.",
    "One minute at a time.",
    "Deep work wins.",
    "Small focus. Big future."
  ];

  final List<String> _breakQuotes = [
    "Take a deep breath.",
    "Stretch.",
    "Drink water.",
    "Rest is productive.",
    "Reset your mind.",
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }
  
  @override
  void didUpdateWidget(FocusMotivationalText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !oldWidget.isRunning) {
      _startTimer();
    } else if (!widget.isRunning && oldWidget.isRunning) {
      _timer?.cancel();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.isRunning) {
      _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
        setState(() {
          final quotes = widget.isBreakMode ? _breakQuotes : _focusQuotes;
          _currentIndex = (_currentIndex + 1) % quotes.length;
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quotes = widget.isBreakMode ? _breakQuotes : _focusQuotes;
    // Safety check just in case
    final text = quotes.isNotEmpty ? quotes[_currentIndex % quotes.length] : "";
    
    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      child: Text(
        text,
        key: ValueKey<String>(text),
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.6),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
