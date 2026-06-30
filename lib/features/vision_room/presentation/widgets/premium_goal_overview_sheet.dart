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
      barrierColor: Colors.black.withValues(alpha: 0.6),
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
  late AnimationController _pulseController;
  late AnimationController _continuousController;
  late AnimationController _slowRotationController;
  late Animation<double> _pulseAnimation;
  late TextEditingController _newChecklistController;
  late TextEditingController _newMilestoneController;

  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted && _selectedTabIndex != _tabController.index) {
        setState(() => _selectedTabIndex = _tabController.index);
        HapticFeedback.selectionClick();
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _continuousController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 25000), // 25 seconds for falling
    )..repeat();

    _slowRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60000), // 60 seconds for rotation
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _newChecklistController = TextEditingController();
    _newMilestoneController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    _continuousController.dispose();
    _slowRotationController.dispose();
    _newChecklistController.dispose();
    _newMilestoneController.dispose();
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
        color: const Color(0xFF0B1120).withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
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
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Mission Control Header Section
                _buildMissionHeader(
                  currentItem,
                  progressRatio,
                  progressPercent,
                ),
                const SizedBox(height: 18),

                // 3. Apple-Style Animated Pill Tab Bar
                _buildAnimatedTabBar(),
                const SizedBox(height: 14),

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
                      _buildChecklistTab(currentItem),
                      _buildMilestonesTab(currentItem),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Glowing Goal Icon Pill
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF047857)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Title & Status Pills
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusPill(status),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white54,
                      size: 10,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        item.countdownDate != null
                            ? 'Target ${item.countdownDate!.day}/${item.countdownDate!.month}/${item.countdownDate!.year}'
                            : 'Target 2026',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Large Animated Progress Ring
          const SizedBox(width: 14),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progressRatio),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 58,
                    height: 58,
                    child: CircularProgressIndicator(
                      value: val,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        val == 1.0
                            ? Colors.greenAccent
                            : const Color(0xFF10B981),
                      ),
                      strokeWidth: 5.5,
                    ),
                  ),
                  Text(
                    '${(val * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
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
      {'label': 'Checklist', 'icon': Icons.check_circle_outline_rounded},
      {'label': 'Milestones', 'icon': Icons.flag_rounded},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
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
                padding: const EdgeInsets.symmetric(vertical: 6),
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
                      color: isSelected ? Colors.black : Colors.white60,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tabs[index]['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white60,
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
    final metadata = item.metadata ?? {};
    final description =
        metadata['description'] as String? ??
        'Master your goal with step-by-step checklists and milestone tracking.';
    final milestones = item.smartMilestones;
    final completedCount = milestones.where((m) => m.isCompleted).length;
    final totalCount = milestones.length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. About Goal Glass Card
          _buildGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ABOUT THIS GOAL',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showEditDialog(item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              color: Colors.white70,
                              size: 10,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Edit',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. Statistics 4-Grid Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Days Left',
                  '${item.countdownDate?.difference(DateTime.now()).inDays ?? 120}',
                  Icons.timer_rounded,
                  const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 8),
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
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Milestones',
                  '$completedCount / ${totalCount > 0 ? totalCount : 4}',
                  Icons.flag_circle_rounded,
                  const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 8),
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
          const SizedBox(height: 22),

          // 3. Milestone Progress Combined Card
          _buildGlassCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Top yellow gradient glow
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.8),
                          radius: 1.2,
                          colors: [
                            const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Falling particles in top right
                  Positioned(
                    top: 0,
                    right: 0,
                    width: 120,
                    height: 200,
                    child: CustomPaint(
                      painter: _FallingParticlePainter(
                        color: const Color(0xFFF59E0B),
                        animation: _continuousController,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.outlined_flag_rounded,
                              color: Color(0xFF10B981),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Milestone Progress',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildMilestoneTimeline(milestones, progressPercent),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Overall Milestone Progress',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '$completedCount of $totalCount Completed',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progressRatio,
                                  minHeight: 4,
                                  backgroundColor: Colors.white10,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── HERO VERTICAL GLOWING TIMELINE ──────────────────────────────────────
  Widget _buildMilestoneTimeline(
    List<SmartMilestone> milestones,
    int progressPercent,
  ) {
    final displayMilestones = milestones.isNotEmpty
        ? milestones
        : [
            const SmartMilestone(
              id: '1',
              title: 'Phase 1: Research & Blueprint',
              isCompleted: true,
            ),
            const SmartMilestone(
              id: '2',
              title: 'Phase 2: Execution & Prototyping',
              isCompleted: false,
            ),
            const SmartMilestone(
              id: '3',
              title: 'Phase 3: Testing & Polish',
              isCompleted: false,
            ),
          ];

    return Column(
      children: List.generate(displayMilestones.length, (index) {
        final m = displayMilestones[index];
        final isLast = index == displayMilestones.length - 1;
        final isActive =
            !m.isCompleted &&
            (index == 0 || displayMilestones[index - 1].isCompleted);

        Widget statusIndicator;
        if (m.isCompleted) {
          statusIndicator = CustomPaint(
            painter: _ParticlePainter(
              color: const Color(0xFF10B981),
              animation: _slowRotationController,
            ),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3310B981),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          );
        } else if (isActive) {
          statusIndicator = ScaleTransition(
            scale: _pulseAnimation,
            child: CustomPaint(
              painter: _ParticlePainter(
                color: const Color(0xFFF59E0B),
                animation: _slowRotationController,
              ),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                    width: 2.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x44F59E0B),
                      blurRadius: 16,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '$progressPercent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        } else {
          statusIndicator = Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white10,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: Colors.white38,
              size: 12,
            ),
          );
        }

        // Adjust horizontal padding for alignment since active node is larger
        final double horizontalPadding = isActive ? 0 : 3;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: [
                  statusIndicator,
                  if (!isLast)
                    CustomPaint(
                      painter: _LineParticlePainter(
                        color: m.isCompleted
                            ? const Color(0xFF10B981)
                            : Colors.white24,
                        isActive: m.isCompleted,
                        animation: _continuousController,
                      ),
                      child: Container(
                        width: 2,
                        height: 36,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              m.isCompleted
                                  ? const Color(0xFF10B981)
                                  : Colors.white24,
                              Colors.white10,
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: isLast ? 0 : 24,
                  top: isActive ? 4 : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.title,
                            style: TextStyle(
                              color: m.isCompleted || isActive
                                  ? Colors.white
                                  : Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Task Details Here', // Normally m.description, but we don't have it in SmartMilestone right now
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          m.isCompleted
                              ? 'Completed'
                              : isActive
                              ? 'In Progress'
                              : 'Upcoming',
                          style: TextStyle(
                            color: m.isCompleted
                                ? const Color(0xFF10B981)
                                : isActive
                                ? const Color(0xFFF59E0B)
                                : Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '2026', // Placeholder for date
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ─── TAB 2: CHECKLIST TAB ──────────────────────────────────────────────────
  Widget _buildChecklistTab(VisionItem item) {
    final checklist = item.smartChecklist;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newChecklistController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _inputDecoration('Add checklist item...'),
                  onSubmitted: (val) => _addChecklistItem(item, val),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, color: Colors.black),
                onPressed: () =>
                    _addChecklistItem(item, _newChecklistController.text),
              ),
            ],
          ),
        ),
        Expanded(
          child: checklist.isEmpty
              ? const Center(
                  child: Text(
                    'No checklist items yet. Add one above!',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  itemCount: checklist.length,
                  itemBuilder: (context, index) {
                    final c = checklist[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: c.isCompleted,
                          activeColor: const Color(0xFF38BDF8),
                          checkColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            _toggleChecklistItem(item, index, val ?? false);
                          },
                        ),
                        title: Text(
                          c.title,
                          style: TextStyle(
                            color: c.isCompleted
                                ? Colors.white38
                                : Colors.white,
                            decoration: c.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white30,
                            size: 18,
                          ),
                          onPressed: () => _deleteChecklistItem(item, index),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ─── TAB 3: MILESTONES TAB ─────────────────────────────────────────────────
  Widget _buildMilestonesTab(VisionItem item) {
    final milestones = item.smartMilestones;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newMilestoneController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _inputDecoration('Add new milestone...'),
                  onSubmitted: (val) => _addMilestone(item, val),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.flag_rounded, color: Colors.black),
                onPressed: () =>
                    _addMilestone(item, _newMilestoneController.text),
              ),
            ],
          ),
        ),
        Expanded(
          child: milestones.isEmpty
              ? const Center(
                  child: Text(
                    'No milestones defined. Break goal into stages!',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  itemCount: milestones.length,
                  itemBuilder: (context, index) {
                    final m = milestones[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            _toggleMilestone(item, index, !m.isCompleted);
                          },
                          child: Icon(
                            m.isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: m.isCompleted
                                ? const Color(0xFF10B981)
                                : Colors.white38,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          m.title,
                          style: TextStyle(
                            color: m.isCompleted
                                ? Colors.white38
                                : Colors.white,
                            fontWeight: FontWeight.w600,
                            decoration: m.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white30,
                            size: 20,
                          ),
                          onPressed: () => _deleteMilestone(item, index),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ─── HELPER COMPONENTS ──────────────────────────────────────────────────────
  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 12),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 8),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            'SMART GOAL',
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
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
    final descCtrl = TextEditingController(
      text: meta['description'] as String? ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Edit Goal Description',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: descCtrl,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Enter description...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
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
                    metadata: {'description': descCtrl.text.trim()},
                  );
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _addChecklistItem(VisionItem item, String text) {
    if (text.trim().isEmpty) return;
    final list = item.smartChecklist;
    list.add(
      SmartChecklistItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: text.trim(),
      ),
    );
    _saveChecklist(item, list);
    _newChecklistController.clear();
  }

  void _toggleChecklistItem(VisionItem item, int index, bool val) {
    final list = item.smartChecklist;
    list[index] = list[index].copyWith(isCompleted: val);
    _saveChecklist(item, list);
  }

  void _deleteChecklistItem(VisionItem item, int index) {
    final list = item.smartChecklist;
    list.removeAt(index);
    _saveChecklist(item, list);
  }

  void _saveChecklist(VisionItem item, List<SmartChecklistItem> list) {
    ref
        .read(canvasStateProvider.notifier)
        .updateItemDetails(
          item.id,
          metadata: {'checklist': list.map((c) => c.toJson()).toList()},
        );
  }

  void _addMilestone(VisionItem item, String text) {
    if (text.trim().isEmpty) return;
    final list = item.smartMilestones;
    list.add(
      SmartMilestone(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: text.trim(),
      ),
    );
    _saveMilestones(item, list);
    _newMilestoneController.clear();
  }

  void _toggleMilestone(VisionItem item, int index, bool val) {
    final list = item.smartMilestones;
    list[index] = list[index].copyWith(isCompleted: val);
    _saveMilestones(item, list);
  }

  void _deleteMilestone(VisionItem item, int index) {
    final list = item.smartMilestones;
    list.removeAt(index);
    _saveMilestones(item, list);
  }

  void _saveMilestones(VisionItem item, List<SmartMilestone> list) {
    ref
        .read(canvasStateProvider.notifier)
        .updateItemDetails(
          item.id,
          metadata: {'milestones': list.map((m) => m.toJson()).toList()},
        );
  }
}

class _ParticlePainter extends CustomPainter {
  final Color color;
  final Animation<double> animation;
  _ParticlePainter({required this.color, required this.animation})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Use animation value to rotate particles seamlessly (completes exactly 1 full rotation)
    final time = animation.value * 2 * math.pi;

    final random = math.Random(color.hashCode);
    for (int i = 0; i < 12; i++) {
      final initialAngle = random.nextDouble() * 2 * math.pi;
      // Rotate by time
      final angle = initialAngle + time * (random.nextDouble() > 0.5 ? 1 : -1);

      // Pulse distance slightly
      final pulse = math.sin(time + initialAngle) * 2;
      final distance = radius + 2 + random.nextDouble() * 8 + pulse;

      final offset = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );

      // Pulse size slightly
      final dotRadius =
          (0.2 + random.nextDouble() * 0.8) * (1.0 + math.sin(time + i) * 0.3);
      canvas.drawCircle(offset, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}

class _LineParticlePainter extends CustomPainter {
  final Color color;
  final bool isActive;
  final Animation<double> animation;

  _LineParticlePainter({
    required this.color,
    required this.isActive,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    final random = math.Random(color.hashCode);

    final time = animation.value; // 0.0 to 1.0 continuous

    for (int i = 0; i < 8; i++) {
      final initialY = random.nextDouble(); // 0 to 1
      // Fall down continuously - must loop perfectly
      // speed is an integer so that at time=1.0, it falls exactly 1 full loop
      final speed = 1;
      final yProgress = (initialY + time * speed) % 1.0;
      final y = yProgress * size.height;

      final xOffset = (random.nextDouble() - 0.5) * 12;

      // Add slight horizontal sway
      final sway = math.sin(time * math.pi * 4 + i) * 2.0;
      final offset = Offset(size.width / 2 + xOffset + sway, y);

      final dotRadius = 0.5 + random.nextDouble() * 1.0;
      // Fade in at top and out at bottom
      final opacity = math.sin(yProgress * math.pi);
      paint.color = color.withValues(alpha: 0.5 * opacity);

      canvas.drawCircle(offset, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineParticlePainter oldDelegate) => true;
}

// Global falling particles painter for the top right of the container
class _FallingParticlePainter extends CustomPainter {
  final Color color;
  final Animation<double> animation;

  _FallingParticlePainter({required this.color, required this.animation})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(color.hashCode ^ 12345);
    final time = animation.value; // 0.0 to 1.0 continuous

    for (int i = 0; i < 20; i++) {
      final initialY = random.nextDouble();
      final initialX = random.nextDouble();

      // Fall down continuously. Speed MUST be an integer so it loops perfectly when time resets to 0.
      // We use random integers (1 or 2) so they fall at slightly different speeds but still loop.
      final speed = 1 + random.nextInt(2); 
      final yProgress = (initialY + time * speed) % 1.0;
      final y = yProgress * size.height;

      final x = initialX * size.width;

      final offset = Offset(x, y);
      final dotRadius = 0.5 + random.nextDouble() * 1.5;

      // Subtle twinkle and fade
      final twinkle = math.sin(time * math.pi * 10 + initialX * 100);
      final opacity =
          (0.2 + 0.3 * twinkle).clamp(0.0, 1.0) * math.sin(yProgress * math.pi);

      paint.color = color.withValues(alpha: opacity);
      canvas.drawCircle(offset, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FallingParticlePainter oldDelegate) => true;
}
