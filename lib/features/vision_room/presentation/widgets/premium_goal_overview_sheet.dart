import 'package:getzio_todo_app/core/theme/app_theme.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/smart_object_models.dart';
import '../../domain/models/vision_item.dart';
import '../providers/canvas_providers.dart';

class PremiumGoalOverviewSheet extends ConsumerStatefulWidget {
  final VisionItem item;

  const PremiumGoalOverviewSheet({super.key, required this.item});

  static void show(BuildContext context, VisionItem item) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: context.colors.bg1.withValues(alpha: 0.6),
      builder: (context) => PremiumGoalOverviewSheet(item: item),
    );
  }

  @override
  ConsumerState<PremiumGoalOverviewSheet> createState() =>
      _PremiumGoalOverviewSheetState();
}

class _PremiumGoalOverviewSheetState
    extends ConsumerState<PremiumGoalOverviewSheet>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _expandedMilestoneIds = {};
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted && _selectedTabIndex != _tabController.index) {
        setState(() => _selectedTabIndex = _tabController.index);
        HapticFeedback.selectionClick();
      }
    });

    // Expand the first 3 milestones by default to match the premium roadmap mockup
    final milestones = widget.item.smartMilestones;
    for (int i = 0; i < milestones.length && i < 3; i++) {
      _expandedMilestoneIds.add(milestones[i].id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasStateProvider);
    final currentItem = canvasState.items.firstWhere(
      (i) => i.id == widget.item.id,
      orElse: () => widget.item,
    );

    final progressRatio = currentItem.smartProgress;
    final progressPercent = currentItem.smartProgressPercent;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: context.colors.bg2.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: context.colors.bg1.withValues(alpha: 0.7),
            blurRadius: 36,
            spreadRadius: 12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                // 1. Top Drag Handle
                SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colors.textMuted.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // 2. Mission Control Header Section
                _buildMissionHeader(
                  currentItem,
                  progressRatio,
                  progressPercent,
                ),
                SizedBox(height: 12),

                // 3. Apple-Style Animated Pill Tab Bar
                _buildAnimatedTabBar(),
                SizedBox(height: 10),

                // 4. Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(
                        currentItem,
                        progressRatio,
                        progressPercent,
                      ),
                      _buildJourneyTab(currentItem),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── HEADER SECTION ────────────────────────────────────────────────────────
  Widget _buildMissionHeader(
    VisionItem item,
    double progressRatio,
    int progressPercent,
  ) {
    final metadata = item.metadata ?? {};
    final title = item.content.isNotEmpty
        ? item.content
        : (metadata['title'] as String? ?? 'Master Goal');
    final status = _calculateStatus(progressRatio);
    final description = metadata['description'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Glowing Goal Icon Pill
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF047857)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              Icons.stars_rounded,
              color: context.colors.textPrimary,
              size: 20,
            ),
          ),
          SizedBox(width: 12),

          // Title & Status Pills
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusPill(status),
                SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showEditDialog(item),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          color: context.colors.textMuted.withValues(alpha: 0.5),
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: context.colors.textMuted,
                      size: 9,
                    ),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        item.countdownDate != null
                            ? 'Target ${item.countdownDate!.day}/${item.countdownDate!.month}/${item.countdownDate!.year}'
                            : 'Target 2026',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.colors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  SizedBox(height: 6),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 10.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Large Animated Progress Ring
          SizedBox(width: 12),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progressRatio),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(
                      value: val,
                      backgroundColor: context.colors.glassBorder,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        val == 1.0
                            ? Colors.greenAccent
                            : const Color(0xFF10B981),
                      ),
                      strokeWidth: 4.0,
                    ),
                  ),
                  Text(
                    '${(val * 100).round()}%',
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── ANIMATED TAB BAR ─────────────────────────────────────────────────────
  Widget _buildAnimatedTabBar() {
    final tabs = [
      {'label': 'Overview', 'icon': Icons.dashboard_customize_rounded},
      {'label': 'Journey', 'icon': Icons.explore_rounded},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.colors.textPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF10B981)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? const Color(0xFF10B981).withValues(alpha: 0.3)
                          : Colors.transparent,
                      blurRadius: isSelected ? 10 : 0,
                      offset: isSelected ? const Offset(0, 4) : Offset.zero,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tabs[index]['icon'] as IconData,
                      color: isSelected ? context.colors.bg1 : context.colors.textSecondary,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      tabs[index]['label'] as String,
                      style: TextStyle(
                        color: isSelected ? context.colors.bg1 : context.colors.textSecondary,
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── TAB 1: OVERVIEW DASHBOARD ─────────────────────────────────────────────
  Widget _buildOverviewTab(
    VisionItem item,
    double progressRatio,
    int progressPercent,
  ) {
    final milestones = item.smartMilestones;
    final completedCount = milestones.where((m) => m.isCompleted).length;
    final totalCount = milestones.length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Statistics 4-Grid Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Days Left',
                  item.countdownDate != null
                      ? '${DateTime(item.countdownDate!.year, item.countdownDate!.month, item.countdownDate!.day).difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays}'
                      : '120',
                  Icons.timer_rounded,
                  const Color(0xFFF59E0B),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Target',
                  item.countdownDate != null
                      ? '${item.countdownDate!.month}/${item.countdownDate!.year}'
                      : '12/26',
                  Icons.event_available_rounded,
                  const Color(0xFF10B981),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Milestones',
                  '$completedCount / ${totalCount > 0 ? totalCount : 4}',
                  Icons.flag_circle_rounded,
                  const Color(0xFF8B5CF6),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Progress',
                  '$progressPercent%',
                  Icons.donut_large_rounded,
                  const Color(0xFF0EA5E9),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),

          // 2. Upcoming Milestone Section
          _buildUpcomingMilestoneCard(item),
          SizedBox(height: 14),

          // 3. Milestone Roadmap Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: context.colors.textPrimary.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context.colors.textPrimary.withValues(alpha: 0.05),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMilestoneRoadmapHeader(item.smartMilestones),
                SizedBox(height: 14),
                _buildJourneyTimeline(item),
              ],
            ),
          ),
          SizedBox(height: 16),
          _buildJourneySummary(item),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUpcomingMilestoneCard(VisionItem item) {
    // Find the first uncompleted milestone
    final milestones = item.smartMilestones;
    final upcomingList = milestones.where((m) => !m.isCompleted).toList();
    final upcoming = upcomingList.isNotEmpty ? upcomingList.first : null;

    if (upcoming == null) return SizedBox.shrink();

    // Calculate days left
    int? daysLeft;
    if (upcoming.dueDate != null) {
      daysLeft = upcoming.dueDate!.difference(DateTime.now()).inDays;
    }

    final totalSubtasks = upcoming.subtasks.length;
    final completedSubtasks = upcoming.subtasks
        .where((s) => s.isCompleted)
        .length;
    final hasTasks = totalSubtasks > 0;

    // Status color
    final status = getMilestoneStatus(upcoming, milestones);
    final themeColor = status == 'completed'
        ? const Color(0xFF10B981)
        : (status == 'current'
              ? const Color(0xFFF59E0B)
              : const Color(0xFF8B5CF6));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColor.withValues(alpha: 0.08),
            context.colors.textPrimary.withValues(alpha: 0.01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.15),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UPCOMING MILESTONE',
            style: TextStyle(
              color: context.colors.textMuted.withValues(alpha: 0.5),
              fontSize: 7.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 6),
          Row(
            children: [
              // Left: Calendar Painted Widget
              Container(
                width: 44,
                height: 46,
                decoration: BoxDecoration(
                  color: context.colors.bg2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.colors.textPrimary.withValues(alpha: 0.08),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    // Top header of calendar
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(7),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'DAYS LEFT',
                        style: TextStyle(
                          color: context.colors.bg1,
                          fontSize: 6.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    // Days count
                    Expanded(
                      child: Center(
                        child: Text(
                          daysLeft != null
                              ? (daysLeft < 0 ? 'Overdue' : '$daysLeft')
                              : '--',
                          style: TextStyle(
                            color: daysLeft != null && daysLeft < 0
                                ? Colors.redAccent
                                : context.colors.textPrimary,
                            fontSize: daysLeft != null && daysLeft < 0 ? 8 : 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),

              // Right: Milestone details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: themeColor,
                              fontSize: 7.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        if (upcoming.dueDate != null)
                          Text(
                            'Due: ${upcoming.dueDate!.day} ${_getMonthName(upcoming.dueDate!.month)}',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 8.5,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      upcoming.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    // Subtasks summary
                    Text(
                      hasTasks
                          ? '$completedSubtasks of $totalSubtasks tasks completed'
                          : (upcoming.isCompleted
                                ? 'Completed'
                                : 'No tasks added yet'),
                      style: TextStyle(
                        color: context.colors.textMuted,
                        fontSize: 8.5,
                      ),
                    ),
                    if (hasTasks) ...[
                      SizedBox(height: 4),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(1.5),
                        child: LinearProgressIndicator(
                          value: completedSubtasks / totalSubtasks,
                          backgroundColor: context.colors.textPrimary.withValues(alpha: 0.05),
                          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                          minHeight: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneRoadmapHeader(List<SmartMilestone> milestones) {
    final allCollapsed = _expandedMilestoneIds.isEmpty;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Milestone Roadmap',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Playfair Display',
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              if (allCollapsed) {
                for (final m in milestones) {
                  _expandedMilestoneIds.add(m.id);
                }
              } else {
                _expandedMilestoneIds.clear();
              }
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                allCollapsed ? 'Expand All' : 'Collapse All',
                style: TextStyle(
                  color: Color(0xFFF59E0B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                allCollapsed
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.keyboard_arrow_up_rounded,
                color: const Color(0xFFF59E0B),
                size: 12,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyTimeline(VisionItem item) {
    final milestones = item.smartMilestones;
    if (milestones.isEmpty) {
      return _buildJourneyEmptyState(item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          children: List.generate(milestones.length, (index) {
            final milestone = milestones[index];
            final isLast = index == milestones.length - 1;
            final status = getMilestoneStatus(milestone, milestones);

            return Stack(
              key: ValueKey(milestone.id),
              children: [
                // Left Connector Line
                if (!isLast)
                  Positioned(
                    left:
                        13, // Center of the 28px indicator (13 + 1px half-width = 14px center)
                    top: 28, // Starts from bottom of the 28px indicator
                    bottom: 0,
                    child: _buildTimelineConnector(status),
                  ),
                // Row content
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimelineIndicator(status, index),
                    SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                        child: _buildMilestoneExpandableCard(
                          item: item,
                          milestone: milestone,
                          index: index,
                          status: status,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),

        // Inline Add Milestone Button (aligned with cards)
        Padding(
          padding: const EdgeInsets.only(left: 44, top: 4, bottom: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _showAddMilestoneSheet(item),
              icon: Icon(
                Icons.add_rounded,
                color: Colors.greenAccent,
                size: 16,
              ),
              label: Text(
                'Add Milestone',
                style: TextStyle(color: Colors.greenAccent, fontSize: 12),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineIndicator(String status, int index) {
    final numberStr = (index + 1).toString();

    switch (status) {
      case 'completed':
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.check_rounded,
            color: context.colors.textPrimary,
            size: 14,
            fontWeight: FontWeight.bold,
          ),
        );
      case 'current':
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: context.colors.bg2,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            numberStr,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'overdue':
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: context.colors.bg2,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFEF4444), width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            numberStr,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'upcoming':
      default:
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: context.colors.bg2,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            numberStr,
            style: TextStyle(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
    }
  }

  Widget _buildTimelineConnector(String status) {
    Color color;

    if (status == 'completed') {
      color = const Color(0xFF10B981);
    } else if (status == 'current') {
      color = const Color(0xFFF59E0B);
    } else {
      color = const Color(0xFF8B5CF6).withValues(alpha: 0.3);
    }

    return Container(
      width: 0.6,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildMilestoneExpandableCard({
    required VisionItem item,
    required SmartMilestone milestone,
    required int index,
    required String status,
  }) {
    final isExpanded = _expandedMilestoneIds.contains(milestone.id);
    final totalSubtasks = milestone.subtasks.length;
    final completedSubtasks = milestone.subtasks
        .where((s) => s.isCompleted)
        .length;
    final double milestoneProgress = totalSubtasks == 0
        ? (milestone.isCompleted ? 1.0 : 0.0)
        : (completedSubtasks / totalSubtasks);
    final milestoneProgressPercent = (milestoneProgress * 100).round();

    final themeColor = status == 'completed'
        ? const Color(0xFF10B981)
        : (status == 'current'
              ? const Color(0xFFF59E0B)
              : const Color(0xFF8B5CF6));

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColor.withValues(alpha: 0.07),
            context.colors.textPrimary.withValues(alpha: 0.01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.22),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header (always visible)
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                if (isExpanded) {
                  _expandedMilestoneIds.remove(milestone.id);
                } else {
                  _expandedMilestoneIds.add(milestone.id);
                }
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: isExpanded ? 12 : 8,
              ),
              decoration: BoxDecoration(
                color: isExpanded
                    ? context.colors.textPrimary.withValues(alpha: 0.02)
                    : Colors.transparent,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12),
                  bottom: Radius.circular(isExpanded ? 0 : 12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left: Title & Status Pill
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                milestone.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.colors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            _buildMilestoneStatusPill(status),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      // Right: Due Date & Chevron
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (milestone.dueDate != null) ...[
                            Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.white38,
                              size: 10,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${milestone.dueDate!.day} ${_getMonthName(milestone.dueDate!.month)} ${milestone.dueDate!.year}',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                              ),
                            ),
                            SizedBox(width: 4),
                          ],
                          if (isExpanded)
                            Icon(
                              Icons.keyboard_arrow_right_rounded,
                              color: context.colors.textMuted.withValues(alpha: 0.5),
                              size: 14,
                            )
                          else
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: context.colors.textMuted.withValues(alpha: 0.5),
                              size: 14,
                            ),
                        ],
                      ),
                    ],
                  ),

                  // Row 2 (only if expanded)
                  if (isExpanded) ...[
                    SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Description (if any)
                        Expanded(
                          child: Text(
                            milestone.description.isNotEmpty
                                ? milestone.description
                                : 'No description provided.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Large Progress percentage
                        Text(
                          '$milestoneProgressPercent%',
                          style: TextStyle(
                            color: themeColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Expanded Content (Animated expand/collapse)
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            top: 4,
                            bottom: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Milestone tasks checklist
                              if (totalSubtasks > 0) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        context.colors.bg1.withValues(alpha: 0.20),
                                        context.colors.bg1.withValues(alpha: 0.05),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: context.colors.textPrimary.withValues(
                                        alpha: 0.03,
                                      ),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Theme(
                                    data: Theme.of(
                                      context,
                                    ).copyWith(canvasColor: Colors.transparent),
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        maxHeight: 250,
                                      ),
                                      child: Scrollbar(
                                        thumbVisibility: false,
                                        child: ReorderableListView.builder(
                                          shrinkWrap: true,
                                          itemCount: totalSubtasks,
                                          onReorder: (oldIdx, newIdx) =>
                                              _reorderSubtasks(
                                                item,
                                                milestone.id,
                                                oldIdx,
                                                newIdx,
                                              ),
                                          itemBuilder: (context, sIdx) {
                                            final subtask =
                                                milestone.subtasks[sIdx];
                                            return _buildTimelineSubtaskRow(
                                              key: ValueKey(subtask.id),
                                              item: item,
                                              milestoneId: milestone.id,
                                              subtask: subtask,
                                              themeColor: themeColor,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                              ] else ...[
                                // Milestone itself completion toggle
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        context.colors.bg1.withValues(alpha: 0.20),
                                        context.colors.bg1.withValues(alpha: 0.05),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: context.colors.textPrimary.withValues(
                                        alpha: 0.03,
                                      ),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            _toggleMilestoneCompletion(
                                              item,
                                              milestone.id,
                                              !milestone.isCompleted,
                                            );
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              color: milestone.isCompleted
                                                  ? themeColor
                                                  : Colors.transparent,
                                              border: Border.all(
                                                color: milestone.isCompleted
                                                    ? Colors.transparent
                                                    : const Color(0xFF475569),
                                                width: 1.5,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: milestone.isCompleted
                                                ? Icon(
                                                    Icons.check,
                                                    color: context.colors.textPrimary,
                                                    size: 10,
                                                    fontWeight: FontWeight.bold,
                                                  )
                                                : null,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              HapticFeedback.lightImpact();
                                              _toggleMilestoneCompletion(
                                                item,
                                                milestone.id,
                                                !milestone.isCompleted,
                                              );
                                            },
                                            behavior: HitTestBehavior.opaque,
                                            child: Text(
                                              'Mark Milestone as Completed',
                                              style: TextStyle(
                                                color: milestone.isCompleted
                                                    ? context.colors.textMuted.withValues(alpha: 0.5)
                                                    : context.colors.textPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                              ],

                              // Add task row and actions
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _showAddSubtaskSheet(
                                      item,
                                      milestone.id,
                                    ),
                                    icon: Icon(
                                      Icons.add_rounded,
                                      color: Colors.greenAccent,
                                      size: 14,
                                    ),
                                    label: Text(
                                      'Add Task',
                                      style: TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 11,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_horiz_rounded,
                                      color: context.colors.textMuted,
                                      size: 16,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    style: IconButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    color: const Color(0xFF1E293B),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    onSelected: (value) {
                                      if (value == 'duplicate') {
                                        _duplicateMilestone(item, milestone);
                                      } else if (value == 'edit') {
                                        _showEditMilestoneSheet(
                                          item,
                                          milestone,
                                        );
                                      } else if (value == 'delete') {
                                        _deleteMilestone(item, milestone.id);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'duplicate',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.copy_rounded,
                                              color: context.colors.textSecondary,
                                              size: 14,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Duplicate',
                                              style: TextStyle(
                                                color: context.colors.textPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit_rounded,
                                              color: context.colors.textSecondary,
                                              size: 14,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Edit',
                                              style: TextStyle(
                                                color: context.colors.textPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.redAccent,
                                              size: 14,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.redAccent,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSubtaskRow({
    required Key key,
    required VisionItem item,
    required String milestoneId,
    required SmartSubtask subtask,
    required Color themeColor,
  }) {
    return Dismissible(
      key: Key(subtask.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: Colors.redAccent,
          size: 18,
        ),
      ),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        _deleteSubtask(item, milestoneId, subtask.id);
      },
      child: Container(
        key: key,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(color: Colors.transparent),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _toggleSubtask(
                  item,
                  milestoneId,
                  subtask.id,
                  !subtask.isCompleted,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: subtask.isCompleted ? themeColor : Colors.transparent,
                  border: Border.all(
                    color: subtask.isCompleted
                        ? Colors.transparent
                        : Colors.white38,
                    width: 1.5,
                  ),
                  shape: BoxShape.circle,
                ),
                child: subtask.isCompleted
                    ? Icon(
                        Icons.check,
                        color: context.colors.textPrimary,
                        size: 10,
                        fontWeight: FontWeight.bold,
                      )
                    : null,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => _showEditSubtaskSheet(item, milestoneId, subtask),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtask.title,
                      style: TextStyle(
                        color: subtask.isCompleted
                            ? context.colors.textMuted.withValues(alpha: 0.5)
                            : context.colors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                    if (subtask.notes != null && subtask.notes!.isNotEmpty) ...[
                      SizedBox(height: 2),
                      Text(
                        subtask.notes!,
                        style: TextStyle(
                          color: context.colors.textMuted.withValues(alpha: 0.5),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (subtask.dueDate != null) ...[
              Text(
                '${subtask.dueDate!.day}/${subtask.dueDate!.month}',
                style: TextStyle(color: context.colors.textMuted.withValues(alpha: 0.5), fontSize: 9),
              ),
              SizedBox(width: 8),
            ],
            Icon(
              Icons.drag_handle_rounded,
              color: context.colors.textMuted.withValues(alpha: 0.4),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneySummary(VisionItem item) {
    final milestones = item.smartMilestones;
    final totalMilestones = milestones.length;

    int totalTasks = 0;
    int completedTasks = 0;
    for (final m in milestones) {
      totalTasks += m.subtasks.length;
      completedTasks += m.subtasks.where((s) => s.isCompleted).length;
    }
    final remainingTasks = totalTasks - completedTasks;
    final progressRatio = item.smartProgress;
    final progressPercent = (progressRatio * 100).round();

    DateTime? latestDueDate;
    for (final m in milestones) {
      if (m.dueDate != null) {
        if (latestDueDate == null || m.dueDate!.isAfter(latestDueDate)) {
          latestDueDate = m.dueDate;
        }
      }
    }
    final estFinish = latestDueDate != null
        ? '${latestDueDate.day} ${_getMonthName(latestDueDate.month)} ${latestDueDate.year}'
        : 'Not Set';

    return _buildGlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'JOURNEY SUMMARY',
            style: TextStyle(
              color: context.colors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryStat('Milestones', '$totalMilestones'),
              _buildSummaryStat('Total Tasks', '$totalTasks'),
              _buildSummaryStat('Completed', '$completedTasks'),
              _buildSummaryStat('Remaining', '$remainingTasks'),
            ],
          ),
          SizedBox(height: 12),
          Divider(color: context.colors.glassBorder, height: 1),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Progress',
                    style: TextStyle(color: Colors.white38, fontSize: 9),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$progressPercent%',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Estimated Finish',
                    style: TextStyle(color: Colors.white38, fontSize: 9),
                  ),
                  SizedBox(height: 4),
                  Text(
                    estFinish,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2),
        Text(title, style: TextStyle(color: Colors.white38, fontSize: 9)),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  String getMilestoneStatus(
    SmartMilestone m,
    List<SmartMilestone> allMilestones,
  ) {
    final isMilestoneCompleted = m.subtasks.isEmpty
        ? m.isCompleted
        : m.subtasks.every((t) => t.isCompleted);

    if (isMilestoneCompleted) return 'completed';

    if (m.dueDate != null && m.dueDate!.isBefore(DateTime.now())) {
      return 'overdue';
    }

    final firstUncompleted = allMilestones.firstWhere(
      (item) => item.subtasks.isEmpty
          ? !item.isCompleted
          : !item.subtasks.every((t) => t.isCompleted),
      orElse: () => allMilestones.first,
    );

    final hasStarted =
        m.subtasks.isNotEmpty && m.subtasks.any((t) => t.isCompleted);

    if (m.id == firstUncompleted.id || hasStarted) {
      return 'current';
    }

    return 'upcoming';
  }

  String getCircledNumber(int index) {
    const circledNumbers = ['①', '②', '③', '④', '⑤', '⑥', '⑦', '⑧', '⑨', '⑩'];
    if (index >= 0 && index < circledNumbers.length) {
      return circledNumbers[index];
    }
    return '(${index + 1})';
  }

  Widget _buildMilestoneStatusPill(String status) {
    Color color;
    String label;
    if (status == 'completed') {
      color = const Color(0xFF10B981);
      label = 'Completed';
    } else if (status == 'current') {
      color = const Color(0xFFF59E0B);
      label = 'In Progress';
    } else if (status == 'overdue') {
      color = const Color(0xFFEF4444);
      label = 'Overdue';
    } else {
      color = Colors.white38;
      label = 'Upcoming';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  void _showEditSubtaskSheet(
    VisionItem item,
    String milestoneId,
    SmartSubtask subtask,
  ) {
    final titleCtrl = TextEditingController(text: subtask.title);
    final notesCtrl = TextEditingController(text: subtask.notes ?? '');
    DateTime? chosenDate = subtask.dueDate;
    String priority = subtask.priority ?? 'medium';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return Container(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
            decoration: BoxDecoration(
              color: context.colors.bg2.withValues(alpha: 0.98),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border.all(color: context.colors.glassBorder),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Edit Subtask',
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 18),
                  TextField(
                    controller: titleCtrl,
                    style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
                    decoration: _inputDecoration('Subtask Title'),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    style: TextStyle(color: context.colors.textPrimary, fontSize: 12),
                    decoration: _inputDecoration('Notes / Details (optional)'),
                  ),
                  SizedBox(height: 16),

                  // Date Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Due Date',
                        style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: chosenDate ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 3650),
                            ),
                          );
                          if (date != null) {
                            setModalState(() => chosenDate = date);
                          }
                        },
                        icon: Icon(
                          Icons.calendar_month_rounded,
                          size: 16,
                          color: Colors.greenAccent,
                        ),
                        label: Text(
                          chosenDate != null
                              ? '${chosenDate!.day}/${chosenDate!.month}/${chosenDate!.year}'
                              : 'Select Date',
                          style: TextStyle(color: Colors.greenAccent),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Priority Selector
                  Text(
                    'Priority',
                    style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['low', 'medium', 'high'].map((p) {
                      final isSelected = p == priority;
                      return GestureDetector(
                        onTap: () => setModalState(() => priority = p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.greenAccent.withValues(alpha: 0.15)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.greenAccent
                                  : context.colors.textMuted.withValues(alpha: 0.4),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            p.toUpperCase(),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.greenAccent
                                  : context.colors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty) return;
                      _updateSubtask(
                        item,
                        milestoneId,
                        subtask.id,
                        subtask.copyWith(
                          title: titleCtrl.text.trim(),
                          notes: notesCtrl.text.trim(),
                          dueDate: chosenDate,
                          priority: priority,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Save Subtask',
                      style: TextStyle(
                        color: context.colors.bg1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _updateSubtask(
    VisionItem item,
    String milestoneId,
    String subtaskId,
    SmartSubtask updated,
  ) {
    final list = item.smartMilestones;
    final mIndex = list.indexWhere((m) => m.id == milestoneId);
    if (mIndex != -1) {
      final milestone = list[mIndex];
      final updatedSubtasks = milestone.subtasks.map((s) {
        return s.id == subtaskId ? updated : s;
      }).toList();
      final allCompleted =
          updatedSubtasks.isNotEmpty &&
          updatedSubtasks.every((s) => s.isCompleted);
      list[mIndex] = milestone.copyWith(
        subtasks: updatedSubtasks,
        isCompleted: allCompleted,
      );
      _saveMilestones(item, list);
    }
  }

  Widget _buildJourneyTab(VisionItem item) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Column(
        children: [
          _buildJourneyTimeline(item),
          SizedBox(height: 16),
          _buildJourneySummary(item),
        ],
      ),
    );
  }

  Widget _buildJourneyEmptyState(VisionItem item) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.explore_rounded,
              color: Color(0xFF10B981),
              size: 48,
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Begin Your Journey',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Break down your goal into premium milestones\nand execute step-by-step subtasks.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.textMuted, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ─── HELPER COMPONENTS ──────────────────────────────────────────────────────
  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.textPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.textPrimary.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.textPrimary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.textPrimary.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 12),
          SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: context.colors.textMuted, fontSize: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color color;
    if (status == 'On Track') {
      color = const Color(0xFF10B981);
    } else if (status == 'Behind Schedule') {
      color = const Color(0xFFF59E0B);
    } else {
      color = const Color(0xFF38BDF8);
    }

    return Text(
      'SMART GOAL',
      style: TextStyle(
        color: color,
        fontSize: 8,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: context.colors.textMuted.withValues(alpha: 0.5)),
      filled: true,
      fillColor: context.colors.textPrimary.withValues(alpha: 0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  String _calculateStatus(double ratio) {
    if (ratio >= 0.7) return 'On Track';
    if (ratio > 0.0) return 'Behind Schedule';
    return 'Planning';
  }

  void _showEditDialog(VisionItem item) {
    final meta = item.metadata ?? {};
    final titleCtrl = TextEditingController(
      text: item.content.isNotEmpty
          ? item.content
          : (meta['title'] as String? ?? 'Master Goal'),
    );
    final subtitleCtrl = TextEditingController(
      text: item.secondaryContent ?? '',
    );
    final descCtrl = TextEditingController(
      text: meta['description'] as String? ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          'Edit Goal Details',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Goal Title',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              TextField(
                controller: titleCtrl,
                style: TextStyle(color: context.colors.textPrimary, fontSize: 13),
                decoration: _inputDecoration('Enter goal title...'),
              ),
              SizedBox(height: 12),

              Text(
                'Description',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                style: TextStyle(color: context.colors.textPrimary, fontSize: 13),
                decoration: _inputDecoration('Enter description...'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.colors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
            ),
            onPressed: () {
              ref
                  .read(canvasStateProvider.notifier)
                  .updateItemDetails(
                    item.id,
                    content: titleCtrl.text.trim(),
                    secondaryContent: subtitleCtrl.text.trim(),
                    metadata: {'description': descCtrl.text.trim()},
                  );
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: context.colors.bg1)),
          ),
        ],
      ),
    );
  }

  // ─── JOURNEY CRUD HELPERS ──────────────────────────────────────────────────
  void _addMilestone(
    VisionItem item,
    String title, {
    String? description,
    DateTime? dueDate,
    String? priority,
    Color? color,
  }) {
    final list = item.smartMilestones;
    final newMilestone = SmartMilestone(
      id: 'milestone_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description ?? '',
      dueDate: dueDate,
      priority: priority ?? 'medium',
      colorValue: color?.toARGB32(),
      order: list.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    list.add(newMilestone);
    _saveMilestones(item, list);
  }

  void _updateMilestone(
    VisionItem item,
    String milestoneId,
    SmartMilestone updated,
  ) {
    final list = item.smartMilestones;
    final index = list.indexWhere((m) => m.id == milestoneId);
    if (index != -1) {
      list[index] = updated.copyWith(updatedAt: DateTime.now());
      _saveMilestones(item, list);
    }
  }

  void _deleteMilestone(VisionItem item, String milestoneId) {
    if (milestoneId == 'general_tasks_migration') {
      _saveChecklist(item, []);
      return;
    }
    final list = item.smartMilestones;
    list.removeWhere((m) => m.id == milestoneId);
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(order: i);
    }
    _saveMilestones(item, list);
  }

  void _duplicateMilestone(VisionItem item, SmartMilestone milestone) {
    final list = item.smartMilestones;
    final duplicated = milestone.copyWith(
      id: 'milestone_dup_${DateTime.now().millisecondsSinceEpoch}',
      title: '${milestone.title} (Copy)',
      order: list.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      subtasks: milestone.subtasks
          .map(
            (s) => s.copyWith(
              id: 'subtask_dup_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}',
              createdAt: DateTime.now(),
            ),
          )
          .toList(),
    );
    list.add(duplicated);
    _saveMilestones(item, list);
  }

  // ignore: unused_element
  void _reorderMilestones(VisionItem item, int oldIndex, int newIndex) {
    final list = item.smartMilestones;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final element = list.removeAt(oldIndex);
    list.insert(newIndex, element);
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(order: i);
    }
    _saveMilestones(item, list);
  }

  void _addSubtask(
    VisionItem item,
    String milestoneId,
    String title, {
    DateTime? dueDate,
    String? notes,
  }) {
    final list = item.smartMilestones;
    final mIndex = list.indexWhere((m) => m.id == milestoneId);
    if (mIndex != -1) {
      final milestone = list[mIndex];
      final newSubtask = SmartSubtask(
        id: 'subtask_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        dueDate: dueDate,
        notes: notes,
        order: milestone.subtasks.length,
        createdAt: DateTime.now(),
      );
      final updatedSubtasks = List<SmartSubtask>.from(milestone.subtasks)
        ..add(newSubtask);
      final allCompleted =
          updatedSubtasks.isNotEmpty &&
          updatedSubtasks.every((s) => s.isCompleted);
      list[mIndex] = milestone.copyWith(
        subtasks: updatedSubtasks,
        isCompleted: allCompleted,
      );
      _saveMilestones(item, list);
    }
  }

  void _toggleMilestoneCompletion(
    VisionItem item,
    String milestoneId,
    bool isCompleted,
  ) {
    if (milestoneId == 'general_tasks_migration') {
      final checklist = item.smartChecklist.map((c) {
        return c.copyWith(
          isCompleted: isCompleted,
          completionDate: isCompleted ? DateTime.now() : null,
        );
      }).toList();
      _saveChecklist(item, checklist);
      return;
    }
    final list = item.smartMilestones.map((m) {
      if (m.id == milestoneId) {
        return m.copyWith(isCompleted: isCompleted);
      }
      return m;
    }).toList();
    _saveMilestones(item, list);
  }

  void _toggleSubtask(
    VisionItem item,
    String milestoneId,
    String subtaskId,
    bool isCompleted,
  ) {
    if (milestoneId == 'general_tasks_migration') {
      final list = item.smartChecklist;
      final idx = list.indexWhere((c) => c.id == subtaskId);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(
          isCompleted: isCompleted,
          completionDate: isCompleted ? DateTime.now() : null,
        );
        _saveChecklist(item, list);
      }
      return;
    }
    final list = item.smartMilestones;
    final mIndex = list.indexWhere((m) => m.id == milestoneId);
    if (mIndex != -1) {
      final milestone = list[mIndex];
      final updatedSubtasks = milestone.subtasks.map((s) {
        if (s.id == subtaskId) {
          return s.copyWith(
            isCompleted: isCompleted,
            completionDate: isCompleted ? DateTime.now() : null,
          );
        }
        return s;
      }).toList();
      final allCompleted =
          updatedSubtasks.isNotEmpty &&
          updatedSubtasks.every((s) => s.isCompleted);
      list[mIndex] = milestone.copyWith(
        subtasks: updatedSubtasks,
        isCompleted: allCompleted,
      );
      _saveMilestones(item, list);
    }
  }

  void _deleteSubtask(VisionItem item, String milestoneId, String subtaskId) {
    if (milestoneId == 'general_tasks_migration') {
      final list = item.smartChecklist;
      list.removeWhere((c) => c.id == subtaskId);
      _saveChecklist(item, list);
      return;
    }
    final list = item.smartMilestones;
    final mIndex = list.indexWhere((m) => m.id == milestoneId);
    if (mIndex != -1) {
      final milestone = list[mIndex];
      final updatedSubtasks = milestone.subtasks
          .where((s) => s.id != subtaskId)
          .toList();
      for (int i = 0; i < updatedSubtasks.length; i++) {
        updatedSubtasks[i] = updatedSubtasks[i].copyWith(order: i);
      }
      final allCompleted =
          updatedSubtasks.isNotEmpty &&
          updatedSubtasks.every((s) => s.isCompleted);
      list[mIndex] = milestone.copyWith(
        subtasks: updatedSubtasks,
        isCompleted: allCompleted,
      );
      _saveMilestones(item, list);
    }
  }

  void _reorderSubtasks(
    VisionItem item,
    String milestoneId,
    int oldIndex,
    int newIndex,
  ) {
    if (milestoneId == 'general_tasks_migration') {
      final list = item.smartChecklist;
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final element = list.removeAt(oldIndex);
      list.insert(newIndex, element);
      _saveChecklist(item, list);
      return;
    }
    final list = item.smartMilestones;
    final mIndex = list.indexWhere((m) => m.id == milestoneId);
    if (mIndex != -1) {
      final milestone = list[mIndex];
      final updatedSubtasks = List<SmartSubtask>.from(milestone.subtasks);
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final element = updatedSubtasks.removeAt(oldIndex);
      updatedSubtasks.insert(newIndex, element);
      for (int i = 0; i < updatedSubtasks.length; i++) {
        updatedSubtasks[i] = updatedSubtasks[i].copyWith(order: i);
      }
      list[mIndex] = milestone.copyWith(subtasks: updatedSubtasks);
      _saveMilestones(item, list);
    }
  }

  void _showAddMilestoneSheet(VisionItem item) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime? chosenDate;
    String priority = 'medium';
    Color chosenColor = const Color(0xFF38BDF8);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return Container(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
            decoration: BoxDecoration(
              color: context.colors.bg2.withValues(alpha: 0.98),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border.all(color: context.colors.glassBorder),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add Milestone',
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 18),
                  TextField(
                    controller: titleCtrl,
                    style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
                    decoration: _inputDecoration(
                      'Milestone Title (e.g. Build MVP)',
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    style: TextStyle(color: context.colors.textPrimary, fontSize: 12),
                    decoration: _inputDecoration('Description (optional)'),
                  ),
                  SizedBox(height: 16),

                  // Date Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Due Date',
                        style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 3650),
                            ),
                          );
                          if (date != null) {
                            setModalState(() => chosenDate = date);
                          }
                        },
                        icon: Icon(
                          Icons.calendar_month_rounded,
                          size: 16,
                          color: Colors.greenAccent,
                        ),
                        label: Text(
                          chosenDate != null
                              ? '${chosenDate!.day}/${chosenDate!.month}/${chosenDate!.year}'
                              : 'Select Date',
                          style: TextStyle(color: Colors.greenAccent),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Priority Selector
                  Text(
                    'Priority',
                    style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['low', 'medium', 'high'].map((p) {
                      final isSelected = p == priority;
                      return GestureDetector(
                        onTap: () => setModalState(() => priority = p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.greenAccent.withValues(alpha: 0.15)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.greenAccent
                                  : context.colors.textMuted.withValues(alpha: 0.4),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            p.toUpperCase(),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.greenAccent
                                  : context.colors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty) return;
                      _addMilestone(
                        item,
                        titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        dueDate: chosenDate,
                        priority: priority,
                        color: chosenColor,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Add Milestone',
                      style: TextStyle(
                        color: context.colors.bg1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditMilestoneSheet(VisionItem item, SmartMilestone milestone) {
    final titleCtrl = TextEditingController(text: milestone.title);
    final descCtrl = TextEditingController(text: milestone.description);
    DateTime? chosenDate = milestone.dueDate;
    String priority = milestone.priority ?? 'medium';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return Container(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
            decoration: BoxDecoration(
              color: context.colors.bg2.withValues(alpha: 0.98),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border.all(color: context.colors.glassBorder),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Edit Milestone',
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 18),
                  TextField(
                    controller: titleCtrl,
                    style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
                    decoration: _inputDecoration('Milestone Title'),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    style: TextStyle(color: context.colors.textPrimary, fontSize: 12),
                    decoration: _inputDecoration('Description'),
                  ),
                  SizedBox(height: 16),

                  // Date Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Due Date',
                        style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: chosenDate ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 3650),
                            ),
                          );
                          if (date != null) {
                            setModalState(() => chosenDate = date);
                          }
                        },
                        icon: Icon(
                          Icons.calendar_month_rounded,
                          size: 16,
                          color: Colors.greenAccent,
                        ),
                        label: Text(
                          chosenDate != null
                              ? '${chosenDate!.day}/${chosenDate!.month}/${chosenDate!.year}'
                              : 'Select Date',
                          style: TextStyle(color: Colors.greenAccent),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Priority Selector
                  Text(
                    'Priority',
                    style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['low', 'medium', 'high'].map((p) {
                      final isSelected = p == priority;
                      return GestureDetector(
                        onTap: () => setModalState(() => priority = p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.greenAccent.withValues(alpha: 0.15)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.greenAccent
                                  : context.colors.textMuted.withValues(alpha: 0.4),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            p.toUpperCase(),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.greenAccent
                                  : context.colors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty) return;
                      final updated = milestone.copyWith(
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        dueDate: chosenDate,
                        priority: priority,
                      );
                      _updateMilestone(item, milestone.id, updated);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                        color: context.colors.bg1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddSubtaskSheet(VisionItem item, String milestoneId) {
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime? chosenDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return Container(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
            decoration: BoxDecoration(
              color: context.colors.bg2.withValues(alpha: 0.98),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              border: Border.all(color: context.colors.glassBorder),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add Subtask',
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 18),
                  TextField(
                    controller: titleCtrl,
                    style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
                    decoration: _inputDecoration(
                      'Subtask Title (e.g. Write Schema)',
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    style: TextStyle(color: context.colors.textPrimary, fontSize: 12),
                    decoration: _inputDecoration('Notes / Details (optional)'),
                  ),
                  SizedBox(height: 16),

                  // Date Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Due Date',
                        style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 3650),
                            ),
                          );
                          if (date != null) {
                            setModalState(() => chosenDate = date);
                          }
                        },
                        icon: Icon(
                          Icons.calendar_month_rounded,
                          size: 16,
                          color: Colors.greenAccent,
                        ),
                        label: Text(
                          chosenDate != null
                              ? '${chosenDate!.day}/${chosenDate!.month}/${chosenDate!.year}'
                              : 'Select Date',
                          style: TextStyle(color: Colors.greenAccent),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty) return;
                      _addSubtask(
                        item,
                        milestoneId,
                        titleCtrl.text.trim(),
                        dueDate: chosenDate,
                        notes: notesCtrl.text.trim(),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Add Subtask',
                      style: TextStyle(
                        color: context.colors.bg1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveMilestones(VisionItem item, List<SmartMilestone> list) {
    final filtered = list.where((m) => m.id != 'general_tasks_migration').toList();
    ref
        .read(canvasStateProvider.notifier)
        .updateItemDetails(
          item.id,
          metadata: {'milestones': filtered.map((m) => m.toJson()).toList()},
        );
  }

  void _saveChecklist(VisionItem item, List<SmartChecklistItem> list) {
    ref
        .read(canvasStateProvider.notifier)
        .updateItemDetails(
          item.id,
          metadata: {'checklist': list.map((c) => c.toJson()).toList()},
        );
  }
}
