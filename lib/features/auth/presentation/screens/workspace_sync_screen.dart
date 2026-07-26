import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../domain/services/guest_migration_service.dart';

import '../../../../core/storage/sync_manager.dart';

class WorkspaceSyncScreen extends ConsumerStatefulWidget {
  const WorkspaceSyncScreen({super.key});

  @override
  ConsumerState<WorkspaceSyncScreen> createState() => _WorkspaceSyncScreenState();
}

class _WorkspaceSyncScreenState extends ConsumerState<WorkspaceSyncScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _checklistItems = [
    'Tasks',
    'Vision Room',
    'Goals',
    'Sticky Notes',
    'Quotes',
    'Finance Goals',
    'Countdown',
    'Settings',
  ];

  int _currentIndex = -1;
  bool _isUploading = false;
  bool _isCompleted = false;
  bool _isSuccess = false;
  String? _errorMessage;
  Timer? _animationTimer;
  late AnimationController _checkController;
  late Animation<double> _checkScale;

  double get _progressValue {
    if (_isCompleted) return 1.0;
    if (_isUploading) return 0.95;
    if (_currentIndex == -1) return 0.0;
    return ((_currentIndex + 1) / _checklistItems.length) * 0.9;
  }

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
    _startChecklistAnimation();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _checkController.dispose();
    super.dispose();
  }

  void _startChecklistAnimation() {
    _animationTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (_currentIndex < _checklistItems.length - 1) {
        setState(() {
          _currentIndex++;
        });
        HapticFeedback.selectionClick();
      } else {
        timer.cancel();
        _startMigration();
      }
    });
  }

  Future<void> _startMigration() async {
    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      // Pause background sync to avoid concurrent write conflicts on backend
      ref.read(syncQueueServiceProvider).isSyncPaused = true;

      final success = await GuestDataMigrationService.migrate(ref);
      if (success) {
        // Save current timestamp as last sync time
        final settings = Map<String, dynamic>.from(
          ref.read(hiveDatabaseProvider).getWorkspaceSettings(),
        );
        settings['last_sync_time'] = DateTime.now().toIso8601String();
        await ref.read(hiveDatabaseProvider).saveWorkspaceSettings(settings);

        setState(() {
          _isUploading = false;
          _isCompleted = true;
        });

        await Future.delayed(const Duration(milliseconds: 1000));

        setState(() {
          _isSuccess = true;
        });
        _checkController.forward();
        HapticFeedback.mediumImpact();
      } else {
        setState(() {
          _isUploading = false;
          _errorMessage = 'An error occurred during workspace backup. Please try again.';
        });
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      HapticFeedback.heavyImpact();
    } finally {
      // Resume background sync queue
      ref.read(syncQueueServiceProvider).isSyncPaused = false;
      ref.read(syncQueueServiceProvider).triggerSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B132B) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_isSuccess) ...[
                  _buildSyncingWidget(isDark),
                ] else ...[
                  _buildSuccessWidget(isDark),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentIndex = -1;
                        _errorMessage = null;
                        _isCompleted = false;
                      });
                      _startChecklistAnimation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97316),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Retry Backup',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.white54 : const Color(0xFF64748B),
                    ),
                    child: Text(
                      'Skip for Now',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncingWidget(bool isDark) {
    final String currentTitle = _isCompleted
        ? 'Completed.'
        : (_isUploading ? 'Uploading...' : 'Preparing your workspace');
    final String currentSubtitle = _isCompleted
        ? 'Workspace successfully backed up to cloud!'
        : (_isUploading
            ? 'Uploading your dashboard and room configuration...'
            : 'Configuring local sync indexes...');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          _isCompleted ? Icons.check_circle_rounded : Icons.cloud_upload_rounded,
          color: _isCompleted ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
          size: 64,
        ),
        const SizedBox(height: 24),
        Text(
          currentTitle,
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          currentSubtitle,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: isDark ? Colors.white54 : const Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progressValue,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isCompleted ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_progressValue * 100).toInt()}%',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white54 : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_checklistItems.length, (index) {
              final isCompleted = _currentIndex >= index;
              final isProcessing = _currentIndex == index && !_isUploading;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFF10B981)
                            : isProcessing
                                ? const Color(0xFF3B82F6).withOpacity(0.2)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted
                              ? const Color(0xFF10B981)
                              : isProcessing
                                  ? const Color(0xFF3B82F6)
                                  : isDark
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : Colors.black.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 12)
                          : isProcessing
                              ? const SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                                  ),
                                )
                              : null,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _checklistItems[index],
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: isCompleted || isProcessing
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isCompleted
                            ? (isDark ? Colors.white : const Color(0xFF1E293B))
                            : isProcessing
                                ? const Color(0xFF3B82F6)
                                : isDark
                                    ? Colors.white.withValues(alpha: 0.3)
                                    : Colors.black.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 24),
          Text(
            _errorMessage!,
            style: GoogleFonts.outfit(
              color: Colors.redAccent,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildSuccessWidget(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _checkScale,
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Workspace Backed Up',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Everything has been securely saved to the cloud.\nYour workspace will now sync automatically across all your devices.',
          style: GoogleFonts.outfit(
            fontSize: 14.5,
            color: isDark ? Colors.white70 : const Color(0xFF475569),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Text(
            'Continue',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
