import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../domain/models/focus_session_model.dart';
import '../../data/focus_storage_service.dart';

// Provider for the storage service
final focusStorageServiceProvider = Provider<FocusStorageService>((ref) {
  // In a real app, this is initialized during app startup
  return FocusStorageService();
});

// The state of the controller is the active session
class FocusTimerController extends Notifier<FocusSessionModel?> with WidgetsBindingObserver {
  Timer? _ticker;
  DateTime? _lastTickTime;

  @override
  FocusSessionModel? build() {
    WidgetsBinding.instance.addObserver(this);
    
    // Attempt to load an active session on startup
    final storage = ref.read(focusStorageServiceProvider);
    final activeSession = storage.getActiveSession();
    
    if (activeSession != null && activeSession.isRunning) {
      // Resume timer if it was running
      _startTicker();
    }
    
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _ticker?.cancel();
    });
    
    return activeSession;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recalculate remaining time if running
      final session = this.state;
      if (session != null && session.isRunning && _lastTickTime != null) {
        final now = DateTime.now();
        final diff = now.difference(_lastTickTime!).inSeconds;
        
        if (diff > 0) {
          int newRemaining = session.remainingSeconds - diff;
          if (newRemaining <= 0) {
            newRemaining = 0;
            _completeSession();
          } else {
            _updateState(session.copyWith(remainingSeconds: newRemaining));
          }
        }
      }
      _lastTickTime = DateTime.now();
    } else if (state == AppLifecycleState.paused) {
      _lastTickTime = DateTime.now();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _lastTickTime = DateTime.now();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      final session = state;
      if (session == null || !session.isRunning) {
        timer.cancel();
        return;
      }
      
      _lastTickTime = DateTime.now();
      
      if (session.remainingSeconds > 0) {
        _updateState(session.copyWith(remainingSeconds: session.remainingSeconds - 1));
      } else {
        _completeSession();
      }
    });
  }

  void _updateState(FocusSessionModel newState) {
    state = newState;
    ref.read(focusStorageServiceProvider).updateSession(newState);
  }

  void startSession({required String mode, required int durationSeconds, String title = 'Focus Session'}) async {
    // Acquire wakelock
    WakelockPlus.enable();
    
    final newSession = FocusSessionModel(
      id: const Uuid().v4(),
      mode: mode,
      startTime: DateTime.now(),
      duration: durationSeconds,
      remainingSeconds: durationSeconds,
      isRunning: true,
      sessionTitle: title,
      date: DateTime.now(),
    );
    
    await ref.read(focusStorageServiceProvider).saveSession(newSession);
    state = newSession;
    _startTicker();
  }

  void pauseSession() {
    final session = state;
    if (session != null) {
      WakelockPlus.disable();
      _updateState(session.copyWith(isRunning: false, isPaused: true));
      _ticker?.cancel();
    }
  }

  void resumeSession() {
    final session = state;
    if (session != null) {
      WakelockPlus.enable();
      _updateState(session.copyWith(isRunning: true, isPaused: false));
      _startTicker();
    }
  }

  void endSessionEarly() {
    final session = state;
    if (session != null) {
      WakelockPlus.disable();
      _ticker?.cancel();
      _updateState(session.copyWith(
        isRunning: false,
        interrupted: true,
        endTime: DateTime.now(),
      ));
      // Notify UI or do cleanup
      state = null; // Clear active session
    }
  }

  void _completeSession() {
    final currentSession = state;
    if (currentSession != null) {
      WakelockPlus.disable();
      _ticker?.cancel();
      final completedSession = currentSession.copyWith(
        completed: true,
        remainingSeconds: 0,
        isRunning: false,
        endTime: DateTime.now(),
      );
      _updateState(completedSession);
      
      // Auto-transition to break if we just finished a focus block
      if (currentSession.mode != 'Break') {
        Future.delayed(const Duration(seconds: 4), () {
          startSession(
            mode: 'Break',
            durationSeconds: 5 * 60, // 5 minutes
            title: 'Rest & Recover',
          );
        });
      } else {
        // If break finished, just clear it or show completion
        Future.delayed(const Duration(seconds: 4), () {
          if (state?.id == completedSession.id) {
            state = null;
          }
        });
      }
    }
  }
}

final focusTimerControllerProvider = NotifierProvider<FocusTimerController, FocusSessionModel?>(() {
  return FocusTimerController();
});

// A derived provider that only updates when focus mode starts/stops, 
// preventing 1-second rebuilds for the ambient room animations.
final isFocusModeActiveProvider = Provider<bool>((ref) {
  final session = ref.watch(focusTimerControllerProvider);
  return session != null && session.isRunning;
});
