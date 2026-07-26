import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openLegalDocument(String title, bool isPrivacyPolicy) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LegalDocumentScreen(title: title, isPrivacyPolicy: isPrivacyPolicy),
      ),
    );
  }

  Future<void> _submit() async {
    final rawPhone = _phoneController.text.trim();
    if (rawPhone.length != 10) {
      setState(() => _error = 'Enter a valid 10-digit mobile number');
      HapticFeedback.vibrate();
      return;
    }

    // Check connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = !connectivityResult.contains(ConnectivityResult.none);
    if (!hasInternet) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No internet connection. Please connect to the internet and try again.',
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

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
            PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  OtpVerificationScreen(phoneNumber: fullPhone),
              transitionsBuilder: (_, anim, __, child) {
                return SlideTransition(
                  position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                      .animate(
                        CurvedAnimation(
                          parent: anim,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send OTP. Please try again.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString().replaceFirst('Exception: ', '');
        if (errorMsg.contains('notification-not-forwarded')) {
          errorMsg =
              'Verification service setup pending. You can use test number +918888888888 or +919999999999 to test instantly.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
              'assets/images/login/login.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          // Gradient Overlay to blend the bottom part
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 0.7, 1.0],
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0D0D0D).withValues(alpha: 0.8),
                    const Color(0xFF0D0D0D),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Spacer(),
                                  Row(
                                    children: [
                                      const Text(
                                        '✨',
                                        style: TextStyle(fontSize: 24),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Welcome to\nGetzio Focus',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFFDEBB2), // Golden text
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Your space to dream, plan and achieve\nyour best life.',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
                          ),

                          // Bottom Card
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161616), // Dark grey card
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF232323),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.phone_iphone_rounded,
                                        color: Color(0xFFFDEBB2),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Login or Sign up',
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Enter your mobile number to continue',
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 12,
                                            color: Colors.white.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Input Field
                                Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1F1F1F),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Row(
                                          children: [
                                            const Text(
                                              '+91',
                                              style: TextStyle(
                                                fontFamily: 'Outfit',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: Colors.white.withValues(
                                                alpha: 0.5,
                                              ),
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 24,
                                        color: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextField(
                                          controller: _phoneController,
                                          focusNode: _focusNode,
                                          keyboardType: TextInputType.phone,
                                          style: const TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                          cursorColor: const Color(0xFFFDEBB2),
                                          maxLength: 10,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          decoration: InputDecoration(
                                            hintText: 'Enter mobile number',
                                            hintStyle: TextStyle(
                                              fontFamily: 'Outfit',
                                              color: Colors.white.withValues(
                                                alpha: 0.3,
                                              ),
                                              fontSize: 15,
                                            ),
                                            border: InputBorder.none,
                                            counterText: '',
                                          ),
                                          onSubmitted: (_) => _submit(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Error message
                                if (_error != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline_rounded,
                                        size: 14,
                                        color: context.colors.error,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          _error!,
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 12,
                                            color: context.colors.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],

                                const SizedBox(height: 20),

                                // Continue Button
                                GestureDetector(
                                  onTap: _loading ? null : _submit,
                                  child: Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFE5C07B,
                                      ), // Golden color
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
                                                  'Continue',
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

                                const SizedBox(height: 24),

                                // Shield Icon & text
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shield_outlined,
                                      color: const Color(
                                        0xFFFDEBB2,
                                      ).withValues(alpha: 0.7),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Your data is safe and secure with us.',
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 12,
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Terms & Privacy
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  height: 1.5,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'By continuing, you agree to our\n',
                                  ),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: const TextStyle(
                                      color: Color(0xFFFDEBB2),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => _openLegalDocument(
                                        'Terms of Service',
                                        false,
                                      ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(
                                      color: Color(0xFFFDEBB2),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => _openLegalDocument(
                                        'Privacy Policy',
                                        true,
                                      ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
