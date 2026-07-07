import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';
import '../../../vision_room/presentation/providers/sticky_note_provider.dart';
import '../providers/preview_mode_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  String? _error;
  int _resendSeconds = 30;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    // Backspace listener to move back when empty
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].onKeyEvent = (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
          if (_controllers[i].text.isEmpty && i > 0) {
            _focusNodes[i - 1].requestFocus();
            _controllers[i - 1].clear();
            setState(() {});
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      };
    }
    // Auto-focus first box
    Future.microtask(() => _focusNodes[0].requestFocus());

    // Start resend timer
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendSeconds = 0);
      } else {
        if (mounted) setState(() => _resendSeconds--);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  String get _otpValue => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    final otp = _otpValue.trim();
    if (otp.length < 4 || otp.length > 6) {
      setState(() => _error = 'Enter a valid OTP (4 to 6 digits)');
      HapticFeedback.vibrate();
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    HapticFeedback.mediumImpact();

    try {
      await ref.read(authProvider.notifier).verifyOtp(widget.phoneNumber, otp);

      if (!mounted) return;

      await ref.read(previewModeProvider.notifier).setPreviewMode(false);

      final authState = ref.read(authProvider);
      final newUserId = authState.value?.id;

      if (newUserId != null) {
        await ref
            .read(stickyNotesProvider.notifier)
            .handleLoginContinueAndSave(newUserId);
      }

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
        // Shake the OTP boxes by clearing and refocusing
        for (final c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0) return;
    HapticFeedback.selectionClick();
    try {
      await ref.read(authProvider.notifier).sendOtp(widget.phoneNumber);
      _startResendTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('OTP sent again!'),
            backgroundColor: const Color(0xFFE5C07B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (_) {}
  }

  Widget _buildFeatureCard(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFDEBB2), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/login/otp.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.3, 0.55, 1.0],
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0D0D0D).withValues(alpha: 0.9),
                    const Color(0xFF0D0D0D),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back Button
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161616),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 120), // Spacer from top image
                        // Title
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            children: [
                              TextSpan(text: 'Verify '),
                              TextSpan(
                                text: 'your number',
                                style: TextStyle(color: Color(0xFFFDEBB2)),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          "We've sent a 6-digit code to\n${widget.phoneNumber}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // OTP Boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            final isFocused = _focusNodes[index].hasFocus;
                            return SizedBox(
                              width: 48,
                              height: 56,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _error != null
                                        ? context.colors.error
                                        : isFocused
                                        ? const Color(0xFFFDEBB2)
                                        : Colors.white.withValues(alpha: 0.15),
                                    width: isFocused ? 1.5 : 1,
                                  ),
                                ),
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  cursorColor: const Color(0xFFFDEBB2),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    counterText: '',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  onChanged: (val) {
                                    if (val.isEmpty) {
                                      if (index > 0) {
                                        _focusNodes[index - 1].requestFocus();
                                      }
                                      setState(() {});
                                      return;
                                    }

                                    // Handle fast typing or pasting multiple digits
                                    if (val.length > 1) {
                                      final cleanVal = val.replaceAll(RegExp(r'\D'), '');
                                      int charsToDistribute = cleanVal.length;
                                      for (int i = 0; i < charsToDistribute && (index + i) < 6; i++) {
                                        _controllers[index + i].text = cleanVal[i];
                                      }
                                      
                                      int nextFocusIndex = index + charsToDistribute;
                                      if (nextFocusIndex > 5) nextFocusIndex = 5;
                                      _focusNodes[nextFocusIndex].requestFocus();
                                      setState(() {});
                                      
                                      if (_otpValue.length == 6) {
                                        _verify();
                                      }
                                      return;
                                    }

                                    if (index < 5) {
                                      _focusNodes[index + 1].requestFocus();
                                    }
                                    setState(() {});
                                    if (_otpValue.length == 6) {
                                      _verify();
                                    }
                                  },
                                  onTap: () => setState(() {}),
                                ),
                              ),
                            );
                          }),
                        ),

                        // Error message
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 14,
                                color: context.colors.error,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  _error!,
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 13,
                                    color: context.colors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Resend OTP
                        GestureDetector(
                          onTap: _resendSeconds == 0 ? _resendOtp : null,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              children: [
                                const TextSpan(
                                  text: "Didn't receive the code? ",
                                ),
                                TextSpan(
                                  text: _resendSeconds > 0
                                      ? 'Resend OTP in 00:${_resendSeconds.toString().padLeft(2, '0')}'
                                      : 'Resend OTP',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _resendSeconds > 0
                                        ? const Color(0xFFFDEBB2)
                                        : const Color(0xFFFDEBB2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Verify Button
                        GestureDetector(
                          onTap: _loading ? null : _verify,
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5C07B), // Golden color
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Verify & Continue',
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Feature Cards
                        _buildFeatureCard(
                          Icons.security_rounded,
                          'Secure & Private',
                          'Your information is 100% safe with us.',
                        ),
                        _buildFeatureCard(
                          Icons.sync_rounded,
                          'Sync Across Devices',
                          'Access your workspace anywhere.',
                        ),
                        _buildFeatureCard(
                          Icons.cloud_done_rounded,
                          'Never Lose Progress',
                          'All your goals and plans, always saved.',
                        ),

                        const SizedBox(height: 24),

                        // Shield Icon & text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              color: const Color(
                                0xFFFDEBB2,
                              ).withValues(alpha: 0.7),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Your data is safe with us.',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
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
