import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../todo/presentation/widgets/wallpaper_background.dart';
import '../providers/auth_providers.dart';
import 'legal_document_screen.dart';
import 'otp_verification_screen.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _focusNode = FocusNode();
  bool _loading = false;
  String? _error;

  void _openLegalDocument(String title, bool isPrivacyPolicy) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(
          title: title,
          isPrivacyPolicy: isPrivacyPolicy,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final rawPhone = _phoneController.text.trim();
    if (rawPhone.length != 10) {
      setState(() => _error = 'Enter a valid 10-digit mobile number');
      HapticFeedback.vibrate();
      return;
    }

    // Standardize phone number with +91 prefix
    final fullPhone = '+91$rawPhone';

    setState(() {
      _loading = true;
      _error = null;
    });
    HapticFeedback.mediumImpact();

    try {
      final success = await ref.read(authProvider.notifier).sendOtp(fullPhone);
      if (success) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(phoneNumber: fullPhone),
            ),
          );
        }
      } else {
        setState(() => _error = 'Failed to send OTP. Try again.');
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  // Logo/Emoji
                  const Text(
                    '⚡',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // App Title
                  Text(
                    'Getzio Focus',
                    textAlign: TextAlign.center,
                    style: AppTypography.displayLarge(),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Sign in or register to secure your tasks',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Glass container for input
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: GlassDecoration.card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'ENTER PHONE NUMBER',
                          style: AppTypography.captionSmall(
                            color: AppColors.textSecondary,
                          ).copyWith(letterSpacing: 1.2),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        
                        // Input box
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                          child: Row(
                            children: [
                              Text(
                                '+91',
                                style: AppTypography.bodyLarge(
                                  color: AppColors.textSecondary,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                width: 1,
                                height: 20,
                                color: AppColors.glassBorder,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  focusNode: _focusNode,
                                  keyboardType: TextInputType.phone,
                                  style: AppTypography.bodyLarge(
                                    color: AppColors.textPrimary,
                                  ),
                                  cursorColor: AppColors.accentBlue,
                                  maxLength: 10,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: '00000 00000',
                                    hintStyle: TextStyle(color: AppColors.textMuted),
                                    border: InputBorder.none,
                                    counterText: '',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onSubmitted: (_) => _submit(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        if (_error != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _error!,
                            style: AppTypography.caption(color: AppColors.error),
                          ),
                        ],

                        const SizedBox(height: AppSpacing.lg),

                        // Action Button
                        GestureDetector(
                          onTap: _loading ? null : _submit,
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
                                      'Get OTP',
                                      style: AppTypography.bodyLarge(
                                        color: Colors.white,
                                      ).copyWith(fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Terms & Privacy Agreement Footnote
                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: AppTypography.caption(
                                color: AppColors.textSecondary,
                              ).copyWith(fontSize: 11, height: 1.4),
                              children: [
                                const TextSpan(text: 'By continuing, you agree to our '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: const TextStyle(
                                    color: AppColors.accentBlue,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _openLegalDocument('Terms of Service', false),
                                ),
                                const TextSpan(text: ' & '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(
                                    color: AppColors.accentBlue,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _openLegalDocument('Privacy Policy', true),
                                ),
                                const TextSpan(text: '.'),
                              ],
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
