import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PremiumCreationHub extends StatelessWidget {
  final VoidCallback onAddImage;
  final VoidCallback onAddStickyNote;
  final VoidCallback onAddQuote;
  final VoidCallback onAddGoal;
  final VoidCallback onAddPlan;
  final VoidCallback onAddTask;
  final VoidCallback onAddFinance;
  final VoidCallback onAddCountdown;

  const PremiumCreationHub({
    super.key,
    required this.onAddImage,
    required this.onAddStickyNote,
    required this.onAddQuote,
    required this.onAddGoal,
    required this.onAddPlan,
    required this.onAddTask,
    required this.onAddFinance,
    required this.onAddCountdown,
  });

  static void show(
    BuildContext context, {
    required VoidCallback onAddImage,
    required VoidCallback onAddStickyNote,
    required VoidCallback onAddQuote,
    required VoidCallback onAddGoal,
    required VoidCallback onAddPlan,
    required VoidCallback onAddTask,
    required VoidCallback onAddFinance,
    required VoidCallback onAddCountdown,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PremiumCreationHub(
        onAddImage: onAddImage,
        onAddStickyNote: onAddStickyNote,
        onAddQuote: onAddQuote,
        onAddGoal: onAddGoal,
        onAddPlan: onAddPlan,
        onAddTask: onAddTask,
        onAddFinance: onAddFinance,
        onAddCountdown: onAddCountdown,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 16, bottom: 24),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Creation Hub',
                    style: AppTypography.displayMedium(color: Colors.white).copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSectionTitle('Quick Add'),
                  _buildGrid([
                    _ToolItem(icon: Icons.image_rounded, label: 'Image', color: Colors.blueAccent, onTap: onAddImage),
                    _ToolItem(icon: Icons.sticky_note_2_rounded, label: 'Sticky Note', color: Colors.amber, onTap: onAddStickyNote),
                    _ToolItem(icon: Icons.auto_awesome_rounded, label: 'AI Generate', color: Colors.purpleAccent, onTap: () {}),
                  ]),
                  
                  const SizedBox(height: 32),
                  _buildSectionTitle('Goals & Planning'),
                  _buildGrid([
                    _ToolItem(icon: Icons.flag_rounded, label: 'Goal', color: Colors.redAccent, onTap: onAddGoal),
                    _ToolItem(icon: Icons.account_tree_rounded, label: 'Plan', color: Colors.greenAccent, onTap: onAddPlan),
                    _ToolItem(icon: Icons.check_circle_outline_rounded, label: 'Task', color: Colors.orangeAccent, onTap: onAddTask),
                    _ToolItem(icon: Icons.savings_rounded, label: 'Finance', color: Colors.tealAccent, onTap: onAddFinance),
                    _ToolItem(icon: Icons.timer_rounded, label: 'Countdown', color: Colors.cyanAccent, onTap: onAddCountdown),
                  ]),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Life & Memories'),
                  _buildGrid([
                    _ToolItem(icon: Icons.auto_awesome_mosaic_rounded, label: 'Vision Card', color: Colors.pinkAccent, onTap: () {}),
                    _ToolItem(icon: Icons.photo_library_rounded, label: 'Memory', color: Colors.indigoAccent, onTap: () {}),
                    _ToolItem(icon: Icons.loop_rounded, label: 'Habit', color: Colors.lightGreenAccent, onTap: () {}),
                    _ToolItem(icon: Icons.book_rounded, label: 'Journal', color: Colors.brown, onTap: () {}),
                  ]),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Media & Links'),
                  _buildGrid([
                    _ToolItem(icon: Icons.format_quote_rounded, label: 'Quote', color: Colors.deepPurpleAccent, onTap: onAddQuote),
                    _ToolItem(icon: Icons.mic_rounded, label: 'Voice Note', color: Colors.red, onTap: () {}),
                    _ToolItem(icon: Icons.link_rounded, label: 'Link', color: Colors.blue, onTap: () {}),
                    _ToolItem(icon: Icons.description_rounded, label: 'Document', color: Colors.grey, onTap: () {}),
                  ]),
                  
                  const SizedBox(height: 48), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16),
      child: Text(
        title,
        style: AppTypography.titleMedium(color: Colors.white54).copyWith(
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildGrid(List<_ToolItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            Navigator.pop(context); // Close hub
            item.onTap(); // Trigger action
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.color, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption(color: Colors.white).copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ToolItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _ToolItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
