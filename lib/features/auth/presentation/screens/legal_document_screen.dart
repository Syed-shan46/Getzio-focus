import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final bool isPrivacyPolicy;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.isPrivacyPolicy,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final iconColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          title,
          style: AppTypography.titleLarge(color: textColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: iconColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: bgColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: dividerColor,
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: isPrivacyPolicy 
                  ? _buildPrivacyPolicyContent(textColor, subtitleColor)
                  : _buildTermsOfServiceContent(textColor, subtitleColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.accentBlue,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _bodyText(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: textColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _bulletPoint(String boldText, String descText, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.md, bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.accentBlue, fontSize: 16)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: textColor,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                    text: boldText,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: descText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPrivacyPolicyContent(Color textColor, Color subtitleColor) {
    return [
      Text(
        'Privacy Policy',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: -0.6,
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      Text(
        'Last updated: June 19, 2026',
        style: TextStyle(fontSize: 12, color: subtitleColor),
      ),
      const SizedBox(height: AppSpacing.md),
      
      _bodyText('Your privacy is important to us. This policy explains what data we collect, how it is used, and your rights regarding your personal information while using Getzio Focus.', textColor),
      
      _sectionTitle('1. Overview'),
      _bodyText('Getzio Focus is a modern task management application. We do not sell, rent, or lease your personal information to third parties.', textColor),
      
      _sectionTitle('2. Information We Collect'),
      _bulletPoint('Authentication Data: ', 'Your phone number is securely processed via Firebase Authentication to authenticate you and send one-time OTP codes.', textColor),
      _bulletPoint('App Data: ', 'All tasks, subtasks, checklists, and configurations you create are cached locally on your device in an encrypted Hive database.', textColor),
      
      _sectionTitle('3. How We Use Your Information'),
      _bulletPoint('Identity Verification: ', 'To register/login via secure OTP.', textColor),
      _bulletPoint('Local Caching: ', 'To enable offline-first access to your tasks.', textColor),
      _bulletPoint('Security: ', 'To protect your account and verify logins.', textColor),
      
      _sectionTitle('4. Third-Party Services'),
      _bodyText('We integrate with Firebase Authentication to handle secure phone registry and logins. No analytics trackers or advertising networks are embedded in Getzio Focus.', textColor),
      
      _sectionTitle('5. Account & Data Deletion'),
      _bodyText('Under App Store requirements, you have the absolute right to delete your account and all associated personal data from Firebase and our local caches.', textColor),
      _bodyText('To request complete deletion, please email getzio.official@gmail.com with your registered phone number. Your data will be permanently wiped within 48 hours.', textColor),
      
      _sectionTitle('6. Contact Us'),
      _bodyText('If you have questions regarding this policy, contact us at:', textColor),
      _bodyText('Email: getzio.official@gmail.com', textColor),
      const SizedBox(height: AppSpacing.xxl),
    ];
  }

  List<Widget> _buildTermsOfServiceContent(Color textColor, Color subtitleColor) {
    return [
      Text(
        'Terms of Service',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: -0.6,
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      Text(
        'Last updated: June 19, 2026',
        style: TextStyle(fontSize: 12, color: subtitleColor),
      ),
      const SizedBox(height: AppSpacing.md),
      
      _bodyText('Please read these Terms of Service carefully before using the Getzio Focus mobile application.', textColor),
      
      _sectionTitle('1. Acceptance of Terms'),
      _bodyText('By creating an account or using Getzio Focus, you agree to be bound by these Terms. If you do not agree to all terms, you may not access or use the application.', textColor),
      
      _sectionTitle('2. User Accounts & Verification'),
      _bulletPoint('OTP Registration: ', 'You must verify your identity via phone number verification. You are responsible for all actions taken through your session.', textColor),
      _bulletPoint('Security: ', 'You agree to keep your session secure and notify us immediately of any unauthorized access.', textColor),
      
      _sectionTitle('3. Permitted Use'),
      _bodyText('Getzio Focus is provided for your personal, non-commercial task management and productivity needs. You agree not to exploit or abuse application APIs.', textColor),
      
      _sectionTitle('4. Intellectual Property'),
      _bodyText('All design layouts, visual styles, glassmorphic themes, code base, and branding elements are the exclusive intellectual property of Getzio.', textColor),
      
      _sectionTitle('5. Account Deletion & Termination'),
      _bodyText('You can request account deletion at any time. We reserve the right to suspend accounts that abuse verification services.', textColor),
      
      _sectionTitle('6. Disclaimer & Liability Limit'),
      _bodyText('Getzio Focus is provided "as is". We are not responsible for any task or information loss that may result from device crashes or service outages.', textColor),
      
      _sectionTitle('7. Contact Us'),
      _bodyText('For questions regarding these Terms, contact us at:', textColor),
      _bodyText('Email: getzio.official@gmail.com', textColor),
      const SizedBox(height: AppSpacing.xxl),
    ];
  }
}
