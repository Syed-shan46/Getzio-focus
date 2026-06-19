import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../todo/presentation/widgets/wallpaper_background.dart';

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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          title,
          style: AppTypography.titleLarge(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: WallpaperBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: GlassDecoration.card(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: isPrivacyPolicy 
                          ? _buildPrivacyPolicyContent()
                          : _buildTermsOfServiceContent(),
                    ),
                  ),
                ),
              ),
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
        style: AppTypography.titleMedium(color: AppColors.accentBlue),
      ),
    );
  }

  Widget _bodyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: AppTypography.bodyMedium(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _bulletPoint(String boldText, String descText) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.md, bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: AppColors.accentBlue, fontSize: 16)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTypography.bodyMedium(color: AppColors.textPrimary),
                children: [
                  TextSpan(
                    text: boldText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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

  List<Widget> _buildPrivacyPolicyContent() {
    return [
      Text(
        'Privacy Policy',
        style: AppTypography.displayMedium(color: AppColors.textPrimary),
      ),
      const SizedBox(height: AppSpacing.xs),
      Text(
        'Last updated: June 19, 2026',
        style: AppTypography.caption(color: AppColors.textSecondary),
      ),
      const Divider(color: AppColors.glassBorder, height: AppSpacing.lg),
      
      _bodyText('Your privacy is important to us. This policy explains what data we collect, how it is used, and your rights regarding your personal information while using Getzio Focus.'),
      
      _sectionTitle('1. Overview'),
      _bodyText('Getzio Focus is a modern task management application. We do not sell, rent, or lease your personal information to third parties.'),
      
      _sectionTitle('2. Information We Collect'),
      _bulletPoint('Authentication Data: ', 'Your phone number is securely processed via Firebase Authentication to authenticate you and send one-time OTP codes.'),
      _bulletPoint('App Data: ', 'All tasks, subtasks, checklists, and configurations you create are cached locally on your device in an encrypted Hive database.'),
      
      _sectionTitle('3. How We Use Your Information'),
      _bulletPoint('Identity Verification: ', 'To register/login via secure OTP.'),
      _bulletPoint('Local Caching: ', 'To enable offline-first access to your tasks.'),
      _bulletPoint('Security: ', 'To protect your account and verify logins.'),
      
      _sectionTitle('4. Third-Party Services'),
      _bodyText('We integrate with Firebase Authentication to handle secure phone registry and logins. No analytics trackers or advertising networks are embedded in Getzio Focus.'),
      
      _sectionTitle('5. Account & Data Deletion'),
      _bodyText('Under App Store requirements, you have the absolute right to delete your account and all associated personal data from Firebase and our local caches.'),
      _bodyText('To request complete deletion, please email shihadpalakkad@gmail.com with your registered phone number. Your data will be permanently wiped within 48 hours.'),
      
      _sectionTitle('6. Contact Us'),
      _bodyText('If you have questions regarding this policy, contact us at:'),
      _bodyText('Email: shihadpalakkad@gmail.com'),
      const SizedBox(height: AppSpacing.lg),
    ];
  }

  List<Widget> _buildTermsOfServiceContent() {
    return [
      Text(
        'Terms of Service',
        style: AppTypography.displayMedium(color: AppColors.textPrimary),
      ),
      const SizedBox(height: AppSpacing.xs),
      Text(
        'Last updated: June 19, 2026',
        style: AppTypography.caption(color: AppColors.textSecondary),
      ),
      const Divider(color: AppColors.glassBorder, height: AppSpacing.lg),
      
      _bodyText('Please read these Terms of Service carefully before using the Getzio Focus mobile application.'),
      
      _sectionTitle('1. Acceptance of Terms'),
      _bodyText('By creating an account or using Getzio Focus, you agree to be bound by these Terms. If you do not agree to all terms, you may not access or use the application.'),
      
      _sectionTitle('2. User Accounts & Verification'),
      _bulletPoint('OTP Registration: ', 'You must verify your identity via phone number verification. You are responsible for all actions taken through your session.'),
      _bulletPoint('Security: ', 'You agree to keep your session secure and notify us immediately of any unauthorized access.'),
      
      _sectionTitle('3. Permitted Use'),
      _bodyText('Getzio Focus is provided for your personal, non-commercial task management and productivity needs. You agree not to exploit or abuse application APIs.'),
      
      _sectionTitle('4. Intellectual Property'),
      _bodyText('All design layouts, visual styles, glassmorphic themes, code base, and branding elements are the exclusive intellectual property of Getzio.'),
      
      _sectionTitle('5. Account Deletion & Termination'),
      _bodyText('You can request account deletion at any time. We reserve the right to suspend accounts that abuse verification services.'),
      
      _sectionTitle('6. Disclaimer & Liability limit'),
      _bodyText('Getzio Focus is provided "as is". We are not responsible for any task or information loss that may result from device crashes or service outages.'),
      
      _sectionTitle('7. Contact Us'),
      _bodyText('For questions regarding these Terms, contact us at:'),
      _bodyText('Email: shihadpalakkad@gmail.com'),
      const SizedBox(height: AppSpacing.lg),
    ];
  }
}
