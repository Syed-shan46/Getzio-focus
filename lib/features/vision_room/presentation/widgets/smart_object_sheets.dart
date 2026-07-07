import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/smart_object_models.dart';
import '../../domain/models/vision_item.dart';
import '../providers/canvas_providers.dart';
import 'premium_goal_overview_sheet.dart';
import 'universal_smart_object_sheet.dart';
import 'package:getzio_todo_app/core/theme/app_theme.dart';

/// Central Dispatcher: Launches the exact logical sheet based on object type.
class SmartObjectSheetRouter {
  static void open(BuildContext context, VisionItem item) {
    HapticFeedback.mediumImpact();
    final type = item.type;
    if (type == VisionItemType.goal.name || type == VisionItemType.plan.name) {
      PremiumGoalOverviewSheet.show(context, item);
    } else if (type == VisionItemType.stickyNote.name) {
      StickyNoteSmartSheet.show(context, item);
    } else if (type == VisionItemType.task.name) {
      TaskSmartSheet.show(context, item);
    } else if (type == VisionItemType.financeGoal.name) {
      FinanceGoalSmartSheet.show(context, item);
    } else if (type == VisionItemType.countdown.name) {
      CountdownSmartSheet.show(context, item);
    } else if (type == VisionItemType.quote.name) {
      QuoteSmartSheet.show(context, item);
    } else if (type == VisionItemType.image.name) {
      ImageSmartSheet.show(context, item);
    } else {
      UniversalSmartObjectSheet.show(context, item);
    }
  }
}

// -----------------------------------------------------------------------------
// 1. STICKY NOTE SMART SHEET
// -----------------------------------------------------------------------------
class StickyNoteSmartSheet extends ConsumerStatefulWidget {
  final VisionItem item;
  const StickyNoteSmartSheet({super.key, required this.item});

  static void show(BuildContext context, VisionItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => StickyNoteSmartSheet(item: item),
    );
  }

  @override
  ConsumerState<StickyNoteSmartSheet> createState() =>
      _StickyNoteSmartSheetState();
}

class _StickyNoteSmartSheetState extends ConsumerState<StickyNoteSmartSheet> {
  double? _draggedProgress;

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasStateProvider);
    final item = canvasState.items.firstWhere(
      (i) => i.id == widget.item.id,
      orElse: () => widget.item,
    );

    final double originalProgress =
        parseDoubleHelper(item.metadata?['progress'], 0.0);
    final double currentProgressVal = _draggedProgress ?? originalProgress;
    final int progressPercent = currentProgressVal.round();
    final bool hasChanges =
        _draggedProgress != null &&
        _draggedProgress!.round() != originalProgress.round();

    return Container(
      height: MediaQuery.of(context).size.height * 0.40,
      decoration: BoxDecoration(
        color: context.colors.bg2.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: context.colors.textPrimary.withValues(alpha: 0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: context.colors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: context.colors.textPrimary.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(item.colorValue).withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.sticky_note_2_rounded,
                          color: context.colors.textPrimary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STICKY NOTE DETAILS',
                              style: TextStyle(
                                color: context.colors.textSecondary.withValues(alpha: 0.7),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.content.isNotEmpty
                                  ? item.content
                                  : 'Sticky Note Tasks',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.colors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$progressPercent%',
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Due Date & Current Progress
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.colors.textPrimary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.colors.textPrimary.withValues(alpha: 0.10)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    color: context.colors.textSecondary.withValues(alpha: 0.7),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      item.countdownDate != null
                                          ? 'Due: ${item.countdownDate!.day}/${item.countdownDate!.month}/${item.countdownDate!.year}'
                                          : 'No due date set',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: context.colors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Progress: $progressPercent%',
                                  style: const TextStyle(
                                    color: Color(0xFF38BDF8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (hasChanges) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      final newMeta = Map<String, dynamic>.from(
                                        item.metadata ?? {},
                                      );
                                      newMeta['progress'] = _draggedProgress;
                                      ref
                                          .read(canvasStateProvider.notifier)
                                          .updateItemDetails(
                                            item.id,
                                            metadata: newMeta,
                                          );
                                      setState(() {
                                        _draggedProgress = null;
                                      });
                                    },
                                    child: const Text(
                                      'Save',
                                      style: TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: const Color(0xFF38BDF8),
                            inactiveTrackColor: context.colors.textPrimary.withValues(
                              alpha: 0.08,
                            ),
                            thumbColor: context.colors.textPrimary,
                            overlayColor: const Color(
                              0xFF38BDF8,
                            ).withValues(alpha: 0.3),
                            trackHeight: 6.0,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8.0,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 16.0,
                            ),
                          ),
                          child: SizedBox(
                            height: 24,
                            child: Slider(
                              value: currentProgressVal.clamp(0, 100),
                              min: 0,
                              max: 100,
                              divisions: 100,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _draggedProgress = val;
                                });
                              },
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
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. DYNAMIC TASK SMART SHEET
// -----------------------------------------------------------------------------
class TaskSmartSheet extends ConsumerStatefulWidget {
  final VisionItem item;
  const TaskSmartSheet({super.key, required this.item});

  static void show(BuildContext context, VisionItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => TaskSmartSheet(item: item),
    );
  }

  @override
  ConsumerState<TaskSmartSheet> createState() => _TaskSmartSheetState();
}

class _TaskSmartSheetState extends ConsumerState<TaskSmartSheet> {
  late TextEditingController _subtaskCtrl;

  @override
  void initState() {
    super.initState();
    _subtaskCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _subtaskCtrl.dispose();
    super.dispose();
  }

  void _addSubtask(VisionItem currentItem) {
    if (_subtaskCtrl.text.trim().isEmpty) return;
    final list = currentItem.smartChecklist;
    list.add(
      SmartChecklistItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _subtaskCtrl.text.trim(),
      ),
    );
    ref.read(canvasStateProvider.notifier).updateItemDetails(
      currentItem.id,
      metadata: {
        'checklist': list.map((c) => c.toJson()).toList(),
      },
    );
    _subtaskCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasStateProvider);
    final currentItem = canvasState.items.firstWhere(
      (i) => i.id == widget.item.id,
      orElse: () => widget.item,
    );
    final metadata = currentItem.metadata ?? {};
    final title = currentItem.content.isNotEmpty
        ? currentItem.content
        : (metadata['title'] as String? ?? 'Task');
    final priority = metadata['priority'] as String? ?? 'High';
    final subtasks = currentItem.smartChecklist;
    final progressPercent = currentItem.smartProgressPercent;
    final accentColor = const Color(0xFFEF4444); // Red/coral task accent

    return Container(
      height: MediaQuery.of(context).size.height * 0.40,
      decoration: BoxDecoration(
        color: context.colors.bg2.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: context.colors.glassBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: context.colors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: context.colors.textPrimary.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          color: context.colors.textPrimary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DYNAMIC TASK',
                              style: TextStyle(
                                color: context.colors.textSecondary.withValues(alpha: 0.7),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.colors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          priority,
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Due Date & Current Progress Section
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.colors.textPrimary.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.colors.textPrimary.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    color: context.colors.textSecondary.withValues(alpha: 0.7),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      currentItem.countdownDate != null
                                          ? 'Due: ${currentItem.countdownDate!.day}/${currentItem.countdownDate!.month}/${currentItem.countdownDate!.year}'
                                          : 'No due date set',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: context.colors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Progress: $progressPercent%',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: currentItem.smartProgress,
                            minHeight: 6,
                            backgroundColor: context.colors.textPrimary.withValues(alpha: 0.10),
                            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'SUBTASKS',
                    style: TextStyle(
                      color: context.colors.textSecondary.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Text Field + Add Button Row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _subtaskCtrl,
                          style: TextStyle(
                            color: context.colors.textPrimary,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Add subtask (e.g. Design Header)...',
                            hintStyle: TextStyle(color: context.colors.textPrimary.withValues(alpha: 0.30)),
                            filled: true,
                            fillColor: context.colors.textPrimary.withValues(alpha: 0.05),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: context.colors.textPrimary.withValues(alpha: 0.05)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: context.colors.textPrimary.withValues(alpha: 0.05)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: accentColor),
                            ),
                          ),
                          onSubmitted: (_) => _addSubtask(currentItem),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: Icon(
                          Icons.add_rounded,
                          color: context.colors.textPrimary,
                        ),
                        onPressed: () => _addSubtask(currentItem),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  subtasks.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'No subtasks yet',
                              style: TextStyle(
                                color: context.colors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: subtasks.length,
                          itemBuilder: (context, idx) {
                            final st = subtasks[idx];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: context.colors.textPrimary.withValues(alpha: 0.02),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: context.colors.textPrimary.withValues(alpha: 0.04)),
                              ),
                              child: ListTile(
                                dense: true,
                                leading: Checkbox(
                                  value: st.isCompleted,
                                  activeColor: accentColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  onChanged: (val) {
                                    final list = currentItem.smartChecklist;
                                    list[idx] = list[idx].copyWith(
                                      isCompleted: val ?? false,
                                    );
                                    ref.read(canvasStateProvider.notifier).updateItemDetails(
                                      currentItem.id,
                                      metadata: {
                                        'checklist': list.map((l) => l.toJson()).toList(),
                                      },
                                    );
                                  },
                                ),
                                title: Text(
                                  st.title,
                                  style: TextStyle(
                                    color: st.isCompleted ? context.colors.textMuted : context.colors.textPrimary,
                                    fontSize: 14,
                                    decoration: st.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. FINANCE GOAL SMART SHEET
// -----------------------------------------------------------------------------
class FinanceGoalSmartSheet extends ConsumerStatefulWidget {
  final VisionItem item;
  const FinanceGoalSmartSheet({super.key, required this.item});

  static void show(BuildContext context, VisionItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => FinanceGoalSmartSheet(item: item),
    );
  }

  @override
  ConsumerState<FinanceGoalSmartSheet> createState() =>
      _FinanceGoalSmartSheetState();
}

class _FinanceGoalSmartSheetState extends ConsumerState<FinanceGoalSmartSheet> {
  late TextEditingController _addMoneyController;

  @override
  void initState() {
    super.initState();
    _addMoneyController = TextEditingController();
  }

  @override
  void dispose() {
    _addMoneyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final item = widget.item;
    final canvasState = ref.watch(canvasStateProvider);
    final currentItem = canvasState.items.firstWhere(
      (i) => i.id == item.id,
      orElse: () => item,
    );
    final metadata = currentItem.metadata ?? {};

    final title = currentItem.content.isNotEmpty
        ? currentItem.content
        : (metadata['title'] as String? ?? 'Finance Goal');
    final description = metadata['description'] as String? ?? '';
    final motivation = metadata['motivation'] as String? ?? '';
    final monthlyAmount = metadata['monthlyAmount'] as String? ?? '';

    final current = parseDoubleHelper(metadata['currentAmount'], 0.0);
    final target = parseDoubleHelper(metadata['targetAmount'], 1000.0);
    final progressRatio = currentItem.smartProgress;
    final progressPercent = currentItem.smartProgressPercent;
    final remaining = (target - current).clamp(0.0, double.infinity);

    final targetDateStr = metadata['targetDate'] as String?;
    String formattedDate = 'No Date';
    if (targetDateStr != null) {
      try {
        final dt = DateTime.parse(targetDateStr);
        final months = [
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
        formattedDate = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      } catch (_) {}
    }

    final goldColor = const Color(0xFFD4AF37);

    return Container(
      height: MediaQuery.of(context).size.height * 0.40,
      decoration: BoxDecoration(
        color: context.colors.bg2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: context.colors.textPrimary.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: context.colors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            height: 200,
            width: 180,
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.transparent, context.colors.bg2],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: const Image(
                image: AssetImage('assets/images/freedom.jpeg'),
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colors.textPrimary.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: goldColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: goldColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Icon(
                                Icons.show_chart_rounded,
                                color: goldColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'FINANCE GOAL',
                                    style:
                                        AppTypography.caption(
                                          color: goldColor,
                                        ).copyWith(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                          fontSize: 9,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        AppTypography.titleMedium(
                                          color: context.colors.textPrimary,
                                        ).copyWith(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: context.colors.textSecondary.withValues(alpha: 0.7),
                                size: 18,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),

                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '"$description"',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption(color: context.colors.textSecondary.withValues(alpha: 0.7))
                                .copyWith(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 13,
                                ),
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Progress Box
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.textPrimary.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: context.colors.textPrimary.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${current.toStringAsFixed(0)} / \$${target.toStringAsFixed(0)}',
                                    style: AppTypography.displayMedium(
                                      color: context.colors.textPrimary,
                                    ).copyWith(fontSize: 20),
                                  ),
                                  Text(
                                    '$progressPercent% done',
                                    style:
                                        AppTypography.caption(
                                          color: goldColor,
                                        ).copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 7,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: context.colors.textPrimary.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: progressRatio,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: goldColor,
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: goldColor.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '\$${remaining.toStringAsFixed(0)} to go',
                                  style: AppTypography.caption(
                                    color: context.colors.textMuted,
                                  ).copyWith(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                Icons.calendar_month_outlined,
                                'Target Date',
                                formattedDate,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatCard(
                                Icons.savings_outlined,
                                'Saved',
                                '\$${current.toStringAsFixed(0)}',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatCard(
                                Icons.credit_card_outlined,
                                'Monthly',
                                monthlyAmount.isNotEmpty
                                    ? (monthlyAmount.contains('/mo') ||
                                              monthlyAmount.contains('month')
                                          ? monthlyAmount
                                          : '\$$monthlyAmount/mo')
                                    : '\$100/mo',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Quick Add Money Field
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.textPrimary.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: context.colors.textPrimary.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _addMoneyController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    color: context.colors.textPrimary,
                                    fontSize: 15,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Enter amount to add (e.g. 50)',
                                    hintStyle: TextStyle(
                                      color: context.colors.textPrimary.withValues(
                                        alpha: 0.3,
                                      ),
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    prefixText: '\$ ',
                                    prefixStyle: TextStyle(
                                      color: goldColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: goldColor,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  final text = _addMoneyController.text.trim();
                                  if (text.isEmpty) return;
                                  final value = double.tryParse(text);
                                  if (value == null || value <= 0) return;

                                  final newCurrent = current + value;
                                  final newProgress =
                                      (newCurrent / target * 100).clamp(
                                        0.0,
                                        100.0,
                                      );

                                  ref
                                      .read(canvasStateProvider.notifier)
                                      .updateItemDetails(
                                        currentItem.id,
                                        metadata: {
                                          'currentAmount': newCurrent,
                                          'progress': newProgress,
                                        },
                                      );
                                  _addMoneyController.clear();
                                  FocusScope.of(context).unfocus();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added \$${value.toStringAsFixed(0)} to your goal!',
                                      ),
                                      backgroundColor: context.colors.bg2,
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Add',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.colors.textPrimary.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: context.colors.textPrimary.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left: Motivation Text Box
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.auto_awesome,
                                          color: goldColor,
                                          size: 10,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Motivation',
                                          style:
                                              AppTypography.caption(
                                                color: goldColor,
                                              ).copyWith(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '“',
                                          style: TextStyle(
                                            color: goldColor,
                                            fontSize: 24,
                                            height: 0.8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            motivation.isNotEmpty
                                                ? motivation
                                                : 'The pain of discipline is nothing compared to the pain of regret.',
                                            maxLines: 5,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                AppTypography.caption(
                                                  color: context.colors.textSecondary,
                                                ).copyWith(
                                                  fontSize: 9,
                                                  height: 1.3,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  height: 85,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: context.colors.textPrimary.withValues(
                                        alpha: 0.05,
                                      ),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // The background image
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: const Image(
                                            image: AssetImage(
                                              'assets/images/freedom.jpeg',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      // The gradient overlay: Left side darker (opacity ~0.7), Right side lighter (opacity ~0.15)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                context.colors.bg2.withValues(
                                                  alpha: 0.90,
                                                ),
                                                context.colors.bg2.withValues(
                                                  alpha: 0.40,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Text content over the gradient
                                      Positioned(
                                        left: 10,
                                        right: 10,
                                        top: 0,
                                        bottom: 0,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Visualize Success',
                                                style:
                                                    AppTypography.caption(
                                                      color: context.colors.textPrimary,
                                                    ).copyWith(
                                                      fontSize: 8.5,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 1),
                                              Text(
                                                'Stay focused on your why.',
                                                style: AppTypography.caption(
                                                  color: context.colors.textSecondary,
                                                ).copyWith(fontSize: 7),
                                              ),
                                            ],
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
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: context.colors.textPrimary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.textPrimary.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFD4AF37), size: 14),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.caption(
                    color: context.colors.textMuted,
                  ).copyWith(fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: AppTypography.caption(
              color: context.colors.textPrimary,
            ).copyWith(fontSize: 12, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. COUNTDOWN SMART SHEET
// -----------------------------------------------------------------------------
class CountdownSmartSheet extends ConsumerWidget {
  final VisionItem item;
  const CountdownSmartSheet({super.key, required this.item});

  static void show(BuildContext context, VisionItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => CountdownSmartSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasStateProvider);
    final currentItem = canvasState.items.firstWhere(
      (i) => i.id == item.id,
      orElse: () => item,
    );
    final metadata = currentItem.metadata ?? {};
    final title = currentItem.content.isNotEmpty
        ? currentItem.content
        : (metadata['title'] as String? ?? 'Countdown');
    final targetDate =
        currentItem.countdownDate ??
        DateTime.now().add(const Duration(days: 30));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final remainingDays = target.difference(today).inDays.clamp(0, 9999);

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF800020), Color(0xFF2D0B1E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: context.colors.textPrimary.withValues(alpha: 0.30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Icon(
                    Icons.timer_rounded,
                    color: context.colors.textPrimary,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$remainingDays',
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'DAYS REMAINING UNTIL EVENT',
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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

// -----------------------------------------------------------------------------
// 5. QUOTE SMART SHEET
// -----------------------------------------------------------------------------
class QuoteSmartSheet extends ConsumerWidget {
  final VisionItem item;
  const QuoteSmartSheet({super.key, required this.item});

  static void show(BuildContext context, VisionItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => QuoteSmartSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasStateProvider);
    final currentItem = canvasState.items.firstWhere(
      (i) => i.id == item.id,
      orElse: () => item,
    );
    final metadata = currentItem.metadata ?? {};
    final author = metadata['author'] as String? ?? 'Anonymous';

    return Container(
      height: MediaQuery.of(context).size.height * 0.40,
      decoration: BoxDecoration(
        color: context.colors.bg2.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: context.colors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: context.colors.textPrimary.withValues(alpha: 0.30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Icon(
                    Icons.format_quote_rounded,
                    color: Color(0xFFA855F7),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '"${currentItem.content}"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '— $author',
                    style: const TextStyle(
                      color: Color(0xFFA855F7),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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

// -----------------------------------------------------------------------------
// 6. IMAGE OBJECT SMART SHEET
// -----------------------------------------------------------------------------
class ImageSmartSheet extends ConsumerStatefulWidget {
  final VisionItem item;
  const ImageSmartSheet({super.key, required this.item});

  static void show(BuildContext context, VisionItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => ImageSmartSheet(item: item),
    );
  }

  @override
  ConsumerState<ImageSmartSheet> createState() => _ImageSmartSheetState();
}

class _ImageSmartSheetState extends ConsumerState<ImageSmartSheet> {
  double? _draggedProgress;

  void _showEditCaptionDialog(BuildContext context, VisionItem item) {
    final controller = TextEditingController(text: item.metadata?['caption'] as String? ?? '');
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: context.colors.bg2.withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: context.colors.glassBorder, width: 1.5),
          ),
          title: Text(
            'Edit Polaroid Caption',
            style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: TextField(
            controller: controller,
            maxLength: 32,
            style: TextStyle(color: context.colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter caption...',
              hintStyle: TextStyle(color: context.colors.textPrimary.withValues(alpha: 0.3)),
              filled: true,
              fillColor: context.colors.textPrimary.withValues(alpha: 0.05),
              counterStyle: TextStyle(color: context.colors.textPrimary.withValues(alpha: 0.30)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colors.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: context.colors.textSecondary.withValues(alpha: 0.7))),
            ),
            ElevatedButton(
              onPressed: () {
                final newCaption = controller.text.trim();
                final newMeta = Map<String, dynamic>.from(item.metadata ?? {});
                newMeta['caption'] = newCaption;
                ref.read(canvasStateProvider.notifier).updateItemDetails(
                  item.id,
                  metadata: newMeta,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Caption updated successfully!'),
                    backgroundColor: context.colors.bg2,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasStateProvider);
    final item = canvasState.items.firstWhere(
      (i) => i.id == widget.item.id,
      orElse: () => widget.item,
    );

    final double originalProgress =
        parseDoubleHelper(item.metadata?['progress'], 0.0);
    final double currentProgressVal = _draggedProgress ?? originalProgress;
    final int progressPercent = currentProgressVal.round();
    final bool hasChanges =
        _draggedProgress != null &&
        _draggedProgress!.round() != originalProgress.round();

    final caption = item.metadata?['caption'] as String? ?? '';

    return Container(
      height: MediaQuery.of(context).size.height * 0.40,
      decoration: BoxDecoration(
        color: context.colors.bg2.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: context.colors.glassBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: context.colors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: context.colors.textPrimary.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header with Circular Image & Circular Progress
                  Row(
                    children: [
                      // Left: Circular Image with Green Glow
                      Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.35),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFF10B981),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: item.content.startsWith('http')
                              ? Image.network(
                                  item.content,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Image(
                                    image: AssetImage('assets/images/freedom.jpeg'),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Image(
                                  image: AssetImage('assets/images/freedom.jpeg'),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Center Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'IMAGE VISION',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    caption.isNotEmpty ? caption : 'Smart Image Goal',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.titleMedium(color: context.colors.textPrimary).copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () => _showEditCaptionDialog(context, item),
                                  borderRadius: BorderRadius.circular(4),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Turning vision into reality, every day.',
                              style: AppTypography.caption(color: context.colors.textSecondary.withValues(alpha: 0.7)).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),

                      // Right: Circular Progress Indicator
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 54,
                            height: 54,
                            child: CircularProgressIndicator(
                              value: currentProgressVal / 100.0,
                              strokeWidth: 4.5,
                              backgroundColor: context.colors.textPrimary.withValues(alpha: 0.05),
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          Text(
                            '$progressPercent%',
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Due Date & Slider Progress Row (with Save Button next to it)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: context.colors.textPrimary.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.colors.textPrimary.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  color: context.colors.textSecondary.withValues(alpha: 0.7),
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.countdownDate != null
                                      ? 'Due: ${item.countdownDate!.day}/${item.countdownDate!.month}/${item.countdownDate!.year}'
                                      : 'No due date set',
                                  style: AppTypography.caption(color: context.colors.textSecondary).copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                            Text(
                              'Progress: $progressPercent%',
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: const Color(0xFF10B981),
                                  inactiveTrackColor: context.colors.textPrimary.withValues(alpha: 0.06),
                                  thumbColor: context.colors.textPrimary,
                                  overlayColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                                  trackHeight: 4.0,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                                ),
                                child: SizedBox(
                                  height: 20,
                                  child: Slider(
                                    value: currentProgressVal.clamp(0, 100),
                                    min: 0,
                                    max: 100,
                                    divisions: 100,
                                    onChanged: (val) {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _draggedProgress = val;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.black,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                final newMeta = Map<String, dynamic>.from(item.metadata ?? {});
                                newMeta['progress'] = currentProgressVal;
                                ref.read(canvasStateProvider.notifier).updateItemDetails(
                                  item.id,
                                  metadata: newMeta,
                                );
                                setState(() {
                                  _draggedProgress = null;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Progress updated successfully!'),
                                    backgroundColor: context.colors.bg2,
                                  ),
                                );
                              },
                              child: const Text(
                                'Save',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Milestones Header
                  Text(
                    'MILESTONES',
                    style: TextStyle(
                      color: context.colors.textPrimary.withValues(alpha: 0.24),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Milestones Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMilestoneNode(Icons.flag_outlined, '25%', 'Getting Started', progressPercent >= 25),
                      Icon(Icons.chevron_right_rounded, color: context.colors.textPrimary.withValues(alpha: 0.10), size: 16),
                      _buildMilestoneNode(Icons.trending_up_rounded, '50%', 'On Track', progressPercent >= 50),
                      Icon(Icons.chevron_right_rounded, color: context.colors.textPrimary.withValues(alpha: 0.10), size: 16),
                      _buildMilestoneNode(Icons.emoji_events_outlined, '75%', 'Almost There', progressPercent >= 75),
                      Icon(Icons.chevron_right_rounded, color: context.colors.textPrimary.withValues(alpha: 0.10), size: 16),
                      _buildMilestoneNode(Icons.rocket_launch_outlined, '100%', 'Goal Achieved', progressPercent >= 100),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Bottom Motivation Card
                  Container(
                    height: 95,
                    decoration: BoxDecoration(
                      color: context.colors.textPrimary.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.colors.textPrimary.withValues(alpha: 0.05)),
                    ),
                    child: Stack(
                      children: [
                        // Right-side background image (blended with opacity and gradient)
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          width: 180,
                          child: ShaderMask(
                            shaderCallback: (rect) {
                              return const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Colors.transparent, Colors.black],
                                stops: [0.0, 0.45],
                              ).createShader(rect);
                            },
                            blendMode: BlendMode.dstIn,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              child: const Image(
                                image: AssetImage('assets/images/freedom.jpeg'),
                                fit: BoxFit.cover,
                                alignment: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),

                        // Text content (vertically centered and sized)
                        Positioned(
                          left: 16,
                          right: 150,
                          top: 0,
                          bottom: 0,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Discipline today shapes\nthe freedom of tomorrow.',
                              style: AppTypography.caption(color: context.colors.textSecondary).copyWith(
                                fontSize: 10,
                                height: 1.3,
                                fontStyle: FontStyle.italic,
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
      ),
    );
  }

  Widget _buildMilestoneNode(
    IconData icon,
    String percentage,
    String label,
    bool isReached,
  ) {
    final activeColor = const Color(0xFF10B981);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 62,
          height: 52,
          decoration: BoxDecoration(
            color: context.colors.textPrimary.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isReached ? activeColor.withValues(alpha: 0.4) : context.colors.textPrimary.withValues(alpha: 0.05),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isReached ? activeColor : context.colors.textPrimary.withValues(alpha: 0.24),
                size: 14,
              ),
              const SizedBox(height: 2),
              Text(
                percentage,
                style: TextStyle(
                  color: isReached ? context.colors.textPrimary : context.colors.textPrimary.withValues(alpha: 0.30),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isReached ? context.colors.textSecondary.withValues(alpha: 0.7) : context.colors.textPrimary.withValues(alpha: 0.30),
                  fontSize: 7,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -3,
          right: -3,
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              color: isReached ? activeColor : const Color(0xFF0F172A),
              shape: BoxShape.circle,
              border: Border.all(
                color: isReached ? Colors.transparent : context.colors.textPrimary.withValues(alpha: 0.12),
                width: 0.8,
              ),
            ),
            child: Icon(
              isReached ? Icons.check : Icons.lock_outline,
              color: isReached ? Colors.black : context.colors.textPrimary.withValues(alpha: 0.30),
              size: 8,
            ),
          ),
        ),
      ],
    );
  }
}
