import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final proceduralWindProvider = Provider<ProceduralWindController>((ref) {
  final controller = ProceduralWindController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

class ProceduralWindController extends ChangeNotifier {
  Ticker? _ticker;
  double _time = 0.0;
  
  // Current global wind properties
  double globalIntensity = 0.0; // 0 to 1
  
  // Wind state
  double _targetIntensity = 0.1;
  
  final _random = Random();
  
  ProceduralWindController() {
    _ticker = Ticker(_onTick);
    _ticker?.start();
    _scheduleWindChange();
  }
  
  void _scheduleWindChange() {
    Future.delayed(Duration(milliseconds: 2000 + _random.nextInt(4000)), () {
      if (_ticker == null) return;
      
      // Randomly pick a new wind state: 
      // 0.0 = calm, 0.3 = weak breeze, 0.8 = tiny gust
      final r = _random.nextDouble();
      if (r < 0.4) {
        _targetIntensity = 0.0; // Calm
      } else if (r < 0.85) {
        _targetIntensity = 0.15 + _random.nextDouble() * 0.2; // Weak
      } else {
        _targetIntensity = 0.5 + _random.nextDouble() * 0.3; // Gust
      }
      
      _scheduleWindChange();
    });
  }

  void _onTick(Duration elapsed) {
    _time += 0.016; // Approx 60fps step
    
    // Smoothly approach target intensity
    globalIntensity += (_targetIntensity - globalIntensity) * 0.01;
    
    notifyListeners();
  }
  
  // Method for a specific sticky note to sample the wind
  double sampleWindForNote(int seed) {
    // Overlapping sine waves for procedural noise
    final phase1 = seed * 0.1;
    final phase2 = seed * 0.5;
    
    final wave1 = sin(_time * 1.1 + phase1);
    final wave2 = sin(_time * 0.6 + phase2) * 0.5;
    final wave3 = sin(_time * 2.3 + phase1 * phase2) * 0.25;
    
    final rawNoise = (wave1 + wave2 + wave3) / 1.75; 
    
    // Scale by current global intensity
    return rawNoise * globalIntensity;
  }

  @override
  void dispose() {
    _ticker?.stop();
    _ticker?.dispose();
    _ticker = null;
    super.dispose();
  }
}
