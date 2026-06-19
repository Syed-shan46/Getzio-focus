import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../todo/presentation/widgets/wallpaper_background.dart';
import '../providers/auth_providers.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
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
      await ref.read(authProvider.notifier).verifyOtp(
            widget.phoneNumber,
            otp,
          );
      
      if (mounted) {
        // Pop back to root so main.dart renders HomeScreen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: WallpaperBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 100,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '🔒',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  Text(
                    'Verification Code',
                    textAlign: TextAlign.center,
                    style: AppTypography.displayLarge(),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'We sent a verification code to\n${widget.phoneNumber}',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Glass box
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: GlassDecoration.card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'ENTER OTP CODE',
                          style: AppTypography.captionSmall(
                            color: AppColors.textSecondary,
                          ).copyWith(letterSpacing: 1.2),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Input field
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 255, 255, 0.04),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: _error != null 
                                  ? AppColors.error.withValues(alpha: 0.5)
                                  : AppColors.glassBorder,
                              width: 0.8,
                            ),
                          ),
                          child: TextField(
                            controller: _otpController,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 6,
                            style: AppTypography.displayMedium().copyWith(
                              letterSpacing: 8,
                            ),
                            cursorColor: AppColors.accentBlue,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              hintText: '••••••',
                              hintStyle: TextStyle(
                                color: AppColors.textMuted,
                                letterSpacing: 8,
                              ),
                              border: InputBorder.none,
                              counterText: '',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            onChanged: (val) {
                              if (val.length == 4 || val.length == 6) {
                                _verify();
                              }
                            },
                          ),
                        ),

                        if (_error != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: AppTypography.caption(color: AppColors.error),
                          ),
                        ],

                        const SizedBox(height: AppSpacing.lg),

                        // Action Button
                        GestureDetector(
                          onTap: _loading ? null : _verify,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentBlue.withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _loading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Verify & Continue',
                                      style: AppTypography.bodyLarge(
                                        color: Colors.white,
                                      ).copyWith(fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                        ),
                      ],
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
}
