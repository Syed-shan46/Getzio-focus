import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContinueWorkspaceDialog extends StatelessWidget {
  final VoidCallback onContinueAndSave;
  final VoidCallback onStartFresh;

  const ContinueWorkspaceDialog({
    super.key,
    required this.onContinueAndSave,
    required this.onStartFresh,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onContinueAndSave,
    required VoidCallback onStartFresh,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ContinueWorkspaceDialog(
        onContinueAndSave: onContinueAndSave,
        onStartFresh: onStartFresh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E293B).withValues(alpha: 0.95),
                const Color(0xFF0F172A).withValues(alpha: 0.98),
              ],
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_sync_rounded,
                color: Color(0xFF38BDF8),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Continue Your Workspace',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We found items created in Guest Mode.\nChoose how you\'d like to continue.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              _buildOptionButton(
                title: 'Continue Preview',
                subtitle: 'Keep exploring your guest Vision Room exactly as it is without saving.',
                icon: Icons.remove_red_eye_rounded,
                color: const Color(0xFFF59E0B),
                onTap: () {
                  Navigator.pop(context);
                  onContinueAndSave(); // Map to continue preview
                },
              ),
              const SizedBox(height: 16),
              _buildOptionButton(
                title: 'Start My Workspace',
                subtitle: 'Wipe guest data and create a permanent workspace saved securely to the cloud.',
                icon: Icons.rocket_launch_rounded,
                color: const Color(0xFF38BDF8),
                onTap: () {
                  Navigator.pop(context);
                  onStartFresh(); // Map to start workspace
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
