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
    final item = canvasState.items.firstWhere((i) => i.id == widget.item.id,
        orElse: () => widget.item);

    final double originalProgress =
        (item.metadata?['progress'] as num?)?.toDouble() ?? 0.0;
    final double currentProgressVal = _draggedProgress ?? originalProgress;
    final int progressPercent = currentProgressVal.round();
    final bool hasChanges = _draggedProgress != null &&
        _draggedProgress!.round() != originalProgress.round();

    return Container(
      height: MediaQuery.of(context).size.height * 0.40,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white12, width: 1.5),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(10)),
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
                        child: const Icon(Icons.sticky_note_2_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('STICKY NOTE DETAILS',
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1)),
                            const SizedBox(height: 2),
                            Text(
                              item.content.isNotEmpty
                                  ? item.content
                                  : 'Sticky Note Tasks',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Text('$progressPercent%',
                          style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Due Date & Current Progress
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
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
                                  const Icon(Icons.calendar_today_rounded,
                                      color: Colors.white54, size: 14),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      item.countdownDate != null
                                          ? 'Due: ${item.countdownDate!.day}/${item.countdownDate!.month}/${item.countdownDate!.year}'
                                          : 'No due date set',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
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
                                      fontWeight: FontWeight.bold),
                                ),
                                if (hasChanges) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      final newMeta = Map<String, dynamic>.from(item.metadata ?? {});
                                      newMeta['progress'] = _draggedProgress;
                                      ref.read(canvasStateProvider.notifier).updateItemDetails(
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
                            inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
                            thumbColor: Colors.white,
                            overlayColor: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                            trackHeight: 6.0,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
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
    );
  }
}

// -----------------------------------------------------------------------------
// 2. DYNAMIC TASK SMART SHEET
// -----------------------------------------------------------------------------
class TaskSmartSheet extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasStateProvider);
    final currentItem = canvasState.items.firstWhere((i) => i.id == item.id,
        orElse: () => item);
    final metadata = currentItem.metadata ?? {};
    final title = currentItem.content.isNotEmpty
        ? currentItem.content
        : (metadata['title'] as String? ?? 'Task');
    final priority = metadata['priority'] as String? ?? 'High';
    final subtasks = currentItem.smartChecklist;
    final progressPercent = currentItem.smartProgressPercent;
    final subtaskCtrl = TextEditingController();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.92),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_outline_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DYNAMIC TASK',
                                style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1)),
                            const SizedBox(height: 2),
                            Text(title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(priority,
                            style: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Due Date & Current Progress Section
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
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
                                  const Icon(Icons.calendar_today_rounded,
                                      color: Colors.white54, size: 14),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      currentItem.countdownDate != null
                                          ? 'Due: ${currentItem.countdownDate!.day}/${currentItem.countdownDate!.month}/${currentItem.countdownDate!.year}'
                                          : 'No due date set',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Progress: $progressPercent%',
                              style: const TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: currentItem.smartProgress,
                            minHeight: 6,
                            backgroundColor: Colors.white10,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFEF4444)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('SUBTASKS',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: subtaskCtrl,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Add subtask (e.g. Design Header)...',
                            hintStyle: const TextStyle(color: Colors.white30),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444)),
                        icon: const Icon(Icons.add_rounded, color: Colors.white),
                        onPressed: () {
                          if (subtaskCtrl.text.trim().isEmpty) return;
                          final list = currentItem.smartChecklist;
                          list.add(SmartChecklistItem(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: subtaskCtrl.text.trim(),
                          ));
                          ref
                              .read(canvasStateProvider.notifier)
                              .updateItemDetails(currentItem.id, metadata: {
                            'checklist': list.map((c) => c.toJson()).toList()
                          });
                          subtaskCtrl.clear();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: subtasks.isEmpty
                        ? const Center(
                            child: Text('No subtasks yet',
                                style: TextStyle(color: Colors.white38, fontSize: 13)),
                          )
                        : ListView.builder(
                            itemCount: subtasks.length,
                            itemBuilder: (context, idx) {
                              final st = subtasks[idx];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: st.isCompleted,
                                    activeColor: const Color(0xFFEF4444),
                                    onChanged: (val) {
                                      final list = currentItem.smartChecklist;
                                      list[idx] = list[idx]
                                          .copyWith(isCompleted: val ?? false);
                                      ref
                                          .read(canvasStateProvider.notifier)
                                          .updateItemDetails(currentItem.id,
                                              metadata: {
                                            'checklist': list
                                                .map((l) => l.toJson())
                                                .toList()
                                          });
                                    },
                                  ),
                                  title: Text(st.title,
                                      style: TextStyle(
                                          color: st.isCompleted
                                              ? Colors.white38
                                              : Colors.white,
                                          fontSize: 14,
                                          decoration: st.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null)),
                                ),
                              );
                            },
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
// 3. FINANCE GOAL SMART SHEET
// -----------------------------------------------------------------------------
class FinanceGoalSmartSheet extends ConsumerWidget {
  final VisionItem item;
  const FinanceGoalSmartSheet({super.key, required this.item});

  static void show(BuildContext context, VisionItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => FinanceGoalSmartSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasStateProvider);
    final currentItem = canvasState.items.firstWhere((i) => i.id == item.id,
        orElse: () => item);
    final metadata = currentItem.metadata ?? {};
    final title = currentItem.content.isNotEmpty
        ? currentItem.content
        : (metadata['title'] as String? ?? 'Finance Goal');
    final current = (metadata['currentAmount'] as num?)?.toDouble() ?? 0.0;
    final target = (metadata['targetAmount'] as num?)?.toDouble() ?? 1000.0;
    final progressPercent = currentItem.smartProgressPercent;

    return Container(
      height: MediaQuery.of(context).size.height * 0.70,
      decoration: BoxDecoration(
        color: const Color(0xFF0F2027).withValues(alpha: 0.95),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.tealAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.savings_rounded,
                            color: Colors.black, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('FINANCE GOAL TRACKER',
                                style: TextStyle(
                                    color: Colors.tealAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1)),
                            const SizedBox(height: 2),
                            Text(title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Text('$progressPercent%',
                          style: const TextStyle(
                              color: Colors.tealAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Display Amount Progress
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.tealAccent.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Saved Currently',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 13)),
                            Text('\$${current.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: currentItem.smartProgress,
                            minHeight: 10,
                            backgroundColor: Colors.white10,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.tealAccent),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    color: Colors.white54, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  currentItem.countdownDate != null
                                      ? 'Target Date: ${currentItem.countdownDate!.day}/${currentItem.countdownDate!.month}/${currentItem.countdownDate!.year}'
                                      : 'Target Date: 2026',
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                            Text('\$${target.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    color: Colors.tealAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Deposit Add
                  const Text('QUICK SAVINGS DEPOSIT',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [50, 100, 250, 500].map((amount) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.tealAccent.withValues(alpha: 0.15),
                          foregroundColor: Colors.tealAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final newCur = current + amount;
                          ref
                              .read(canvasStateProvider.notifier)
                              .updateItemDetails(currentItem.id, metadata: {
                            'currentAmount': newCur,
                          });
                        },
                        child: Text('+\$$amount'),
                      );
                    }).toList(),
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
    final currentItem = canvasState.items.firstWhere((i) => i.id == item.id,
        orElse: () => item);
    final metadata = currentItem.metadata ?? {};
    final title = currentItem.content.isNotEmpty
        ? currentItem.content
        : (metadata['title'] as String? ?? 'Countdown');
    final targetDate =
        currentItem.countdownDate ?? DateTime.now().add(const Duration(days: 30));
    final remainingDays =
        targetDate.difference(DateTime.now()).inDays.clamp(0, 9999);

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
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 24),

                  const Icon(Icons.timer_rounded, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text('$remainingDays',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.bold)),
                  const Text('DAYS REMAINING UNTIL EVENT',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
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
    final currentItem = canvasState.items.firstWhere((i) => i.id == item.id,
        orElse: () => item);
    final metadata = currentItem.metadata ?? {};
    final author = metadata['author'] as String? ?? 'Anonymous';

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B).withValues(alpha: 0.95),
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 24),

                  const Icon(Icons.format_quote_rounded,
                      color: Color(0xFFA855F7), size: 48),
                  const SizedBox(height: 16),
                  Text('"${currentItem.content}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          height: 1.4)),
                  const SizedBox(height: 12),
                  Text('— $author',
                      style: const TextStyle(
                          color: Color(0xFFA855F7),
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasStateProvider);
    final item = canvasState.items.firstWhere((i) => i.id == widget.item.id,
        orElse: () => widget.item);

    final double originalProgress =
        (item.metadata?['progress'] as num?)?.toDouble() ?? 0.0;
    final double currentProgressVal = _draggedProgress ?? originalProgress;
    final int progressPercent = currentProgressVal.round();
    final bool hasChanges = _draggedProgress != null &&
        _draggedProgress!.round() != originalProgress.round();

    return Container(
      height: MediaQuery.of(context).size.height * 0.40,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.92),
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
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.image_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('IMAGE VISION',
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1)),
                            SizedBox(height: 2),
                            Text('Smart Image Goal',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Text('$progressPercent%',
                          style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Due Date & Current Progress
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
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
                                  const Icon(Icons.calendar_today_rounded,
                                      color: Colors.white54, size: 14),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      item.countdownDate != null
                                          ? 'Due: ${item.countdownDate!.day}/${item.countdownDate!.month}/${item.countdownDate!.year}'
                                          : 'No due date set',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
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
                                      color: Color(0xFF10B981),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                if (hasChanges) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      final newMeta = Map<String, dynamic>.from(item.metadata ?? {});
                                      newMeta['progress'] = _draggedProgress;
                                      ref.read(canvasStateProvider.notifier).updateItemDetails(
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
                            activeTrackColor: const Color(0xFF10B981),
                            inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
                            thumbColor: Colors.white,
                            overlayColor: const Color(0xFF10B981).withValues(alpha: 0.3),
                            trackHeight: 6.0,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
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
    );
  }
}
