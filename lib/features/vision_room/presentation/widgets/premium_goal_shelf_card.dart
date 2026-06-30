import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/vision_item.dart';
import '../../domain/models/smart_object_models.dart';
import 'smart_object_sheets.dart';

class PremiumGoalShelfCard extends StatefulWidget {
  final VisionItem item;
  final bool isSelected;
  final double scale;

  const PremiumGoalShelfCard({
    super.key,
    required this.item,
    this.isSelected = false,
    this.scale = 1.0,
  });

  @override
  State<PremiumGoalShelfCard> createState() => _PremiumGoalShelfCardState();
}

class _PremiumGoalShelfCardState extends State<PremiumGoalShelfCard> {
  bool _isHovered = false;

  String _getHeroImageUrl(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('mountain') || lower.contains('summit')) {
      return 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80';
    } else if (lower.contains('ocean') || lower.contains('sea')) {
      return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80';
    } else if (lower.contains('rocket') || lower.contains('space') || lower.contains('launch')) {
      return 'https://images.unsplash.com/photo-1517976487492-5750f3195933?w=800&q=80';
    } else if (lower.contains('city') || lower.contains('skyline')) {
      return 'https://images.unsplash.com/photo-1449844908441-8829872d2607?w=800&q=80';
    } else if (lower.contains('office') || lower.contains('work')) {
      return 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&q=80';
    } else if (lower.contains('home') || lower.contains('house')) {
      return 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&q=80';
    } else if (lower.contains('fit') || lower.contains('health')) {
      return 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800&q=80';
    } else if (lower.contains('business') || lower.contains('money')) {
      return 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&q=80';
    } else if (lower.contains('travel') || lower.contains('trip')) {
      return 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800&q=80';
    }
    // Default premium abstract gradient-like photo
    return 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?w=800&q=80';
  }

  @override
  Widget build(BuildContext context) {
    final metadata = widget.item.metadata ?? {};
    final title = widget.item.content.isNotEmpty ? widget.item.content : (metadata['title'] as String? ?? 'My Goal');
    final progressRatio = widget.item.smartProgress;
    final progressPercent = widget.item.smartProgressPercent;
    
    // Milestones and tasks
    final List milestones = metadata['milestones'] ?? [];
    final int milestoneCount = milestones.length;
    final List tasks = metadata['checklist'] ?? [];
    final int taskCount = tasks.length;
    
    final dueDateRaw = widget.item.countdownDate;
    final String dueDateStr = dueDateRaw != null 
        ? '${dueDateRaw.day}/${dueDateRaw.month}/${dueDateRaw.year}'
        : 'No target';

    final colorValue = metadata['color'] as int? ?? Colors.blueAccent.toARGB32();
    final themeColor = Color(colorValue);
    final heroUrl = _getHeroImageUrl(title);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isHovered = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isHovered = false);
        SmartObjectSheetRouter.open(context, widget.item);
      },
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 0.98 : widget.scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.9), // Glass + Matte
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isSelected 
                  ? themeColor.withValues(alpha: 0.6) 
                  : Colors.white.withValues(alpha: 0.15),
              width: widget.isSelected ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected 
                    ? themeColor.withValues(alpha: 0.4) 
                    : Colors.black.withValues(alpha: 0.3),
                blurRadius: widget.isSelected ? 30 : 20,
                spreadRadius: widget.isSelected ? 4 : 0,
                offset: const Offset(0, 10),
              ),
              if (_isHovered)
                 BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Upper Half: Hero Illustration
                  Expanded(
                    flex: 5,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Parallax effect could be added here later with a PageView listener
                        Image.network(
                          heroUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => Container(
                            color: themeColor.withValues(alpha: 0.3),
                          ),
                        ),
                        // Dark Gradient Overlay
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF1E293B).withValues(alpha: 0.8),
                                const Color(0xFF1E293B),
                              ],
                              stops: const [0.4, 0.9, 1.0],
                            ),
                          ),
                        ),
                        // Floating progress ring
                        Positioned(
                          right: 16,
                          bottom: -20,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF0F172A),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)
                              ],
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: CircularProgressIndicator(
                                    value: progressRatio,
                                    strokeWidth: 4,
                                    backgroundColor: themeColor.withValues(alpha: 0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    '$progressPercent%',
                                    style: AppTypography.caption(color: Colors.white).copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Lower Half: Minimal Data
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.titleLarge(color: Colors.white).copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          
                          // Custom Road Progress Bar
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final double width = constraints.maxWidth;
                              const double roadHeight = 8.0;
                              return Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.centerLeft,
                                children: [
                                  Container(
                                    width: width,
                                    height: roadHeight,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOut,
                                    width: width * progressRatio,
                                    height: roadHeight,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [themeColor.withValues(alpha: 0.5), themeColor],
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(color: themeColor.withValues(alpha: 0.3), blurRadius: 6)
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          
                          const Spacer(),
                          
                          // Stats row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStat(Icons.flag_rounded, milestoneCount.toString(), 'Milestones', themeColor),
                              _buildStat(Icons.check_circle_outline_rounded, taskCount.toString(), 'Tasks', themeColor),
                              _buildStat(Icons.calendar_today_rounded, dueDateStr, 'Target', themeColor, isDate: true),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildStat(IconData icon, String value, String label, Color color, {bool isDate = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color.withValues(alpha: 0.8), size: 14),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTypography.titleMedium(color: Colors.white).copyWith(
                fontSize: isDate ? 12 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption(color: Colors.white54).copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
