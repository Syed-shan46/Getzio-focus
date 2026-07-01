import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/smart_object_models.dart';
import '../../domain/models/vision_item.dart';
import '../providers/canvas_providers.dart';

class UniversalSmartObjectSheet extends ConsumerStatefulWidget {
  final VisionItem item;

  const UniversalSmartObjectSheet({super.key, required this.item});

  static void show(BuildContext context, VisionItem item) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => UniversalSmartObjectSheet(item: item),
    );
  }

  @override
  ConsumerState<UniversalSmartObjectSheet> createState() =>
      _UniversalSmartObjectSheetState();
}

class _UniversalSmartObjectSheetState
    extends ConsumerState<UniversalSmartObjectSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _newChecklistController;
  late TextEditingController _newMilestoneController;
  late TextEditingController _notesController;
  late TextEditingController _financeCurrentController;
  late TextEditingController _financeTargetController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _titleController = TextEditingController(text: widget.item.content);
    final meta = widget.item.metadata ?? {};
    _descriptionController =
        TextEditingController(text: meta['description'] as String? ?? '');
    _newChecklistController = TextEditingController();
    _newMilestoneController = TextEditingController();
    _notesController =
        TextEditingController(text: meta['notes'] as String? ?? '');
    _financeCurrentController = TextEditingController(
        text: (meta['currentAmount'] ?? 0).toString());
    _financeTargetController = TextEditingController(
        text: (meta['targetAmount'] ?? 1000).toString());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _newChecklistController.dispose();
    _newMilestoneController.dispose();
    _notesController.dispose();
    _financeCurrentController.dispose();
    _financeTargetController.dispose();
    super.dispose();
  }

  void _saveItemDetails({String? content, Map<String, dynamic>? extraMeta}) {
    ref.read(canvasStateProvider.notifier).updateItemDetails(
          widget.item.id,
          content: content ?? _titleController.text.trim(),
          metadata: {
            'description': _descriptionController.text.trim(),
            'notes': _notesController.text.trim(),
            if (extraMeta != null) ...extraMeta,
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasStateProvider);
    // Find latest item version from state
    final currentItem = canvasState.items.firstWhere(
      (i) => i.id == widget.item.id,
      orElse: () => widget.item,
    );

    final progressPercent = currentItem.smartProgressPercent;
    final progressRatio = currentItem.smartProgress;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.88),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 30,
            spreadRadius: 10,
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
            body: Column(
              children: [
                // Drag Handle
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),

                // Header Section with Progress Badge
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(currentItem.colorValue).withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(currentItem.colorValue).withValues(alpha: 0.8),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          _getTypeIcon(currentItem.type),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTypeLabel(currentItem.type),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentItem.content.isNotEmpty
                                  ? currentItem.content
                                  : 'Smart Object',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Progress Ring Badge
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(
                              value: progressRatio,
                              backgroundColor: Colors.white10,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progressRatio == 1.0
                                    ? Colors.greenAccent
                                    : AppColors.accentBlue,
                              ),
                              strokeWidth: 4.5,
                            ),
                          ),
                          Text(
                            '$progressPercent%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Glassmorphic Tab Navigation Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicator: BoxDecoration(
                      color: AppColors.accentBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Checklist'),
                      Tab(text: 'Milestones'),
                      Tab(text: 'Notes'),
                      Tab(text: 'Settings'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Tab Content Area
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(currentItem),
                      _buildChecklistTab(currentItem),
                      _buildMilestonesTab(currentItem),
                      _buildNotesTab(currentItem),
                      _buildSettingsTab(currentItem),
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

  // ─── TAB 1: OVERVIEW ────────────────────────────────────────────────────────
  Widget _buildOverviewTab(VisionItem item) {
    final meta = item.metadata ?? {};
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('Object Title'),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: _inputDecoration('Enter title...'),
            onChanged: (val) => _saveItemDetails(content: val),
          ),
          const SizedBox(height: 18),
          _buildSectionLabel('Description'),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: _inputDecoration('Add a detailed description...'),
            onChanged: (_) => _saveItemDetails(),
          ),
          const SizedBox(height: 20),

          // Show Progress Toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pie_chart_rounded, color: AppColors.accentBlue, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Show Progress on Card',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 24,
                  child: Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      value: meta['showProgress'] as bool? ?? false,
                      activeTrackColor: AppColors.accentBlue,
                      onChanged: (val) {
                        _saveItemDetails(extraMeta: {'showProgress': val});
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Object-Specific Quick Editors
          if (item.type == VisionItemType.financeGoal.name) ...[
            _buildSectionLabel('Finance Goal Amounts'),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Current Saved (\$)',
                          style: TextStyle(color: Colors.white54, fontSize: 11)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _financeCurrentController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Current'),
                        onChanged: (val) {
                          final cur = double.tryParse(val) ?? 0.0;
                          _saveItemDetails(extraMeta: {'currentAmount': cur});
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Target Goal (\$)',
                          style: TextStyle(color: Colors.white54, fontSize: 11)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _financeTargetController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Target'),
                        onChanged: (val) {
                          final tgt = double.tryParse(val) ?? 1000.0;
                          _saveItemDetails(extraMeta: {'targetAmount': tgt});
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          if (item.type == VisionItemType.quote.name) ...[
            _buildSectionLabel('Author'),
            TextField(
              controller: TextEditingController(text: meta['author'] ?? ''),
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Quote Author...'),
              onChanged: (val) => _saveItemDetails(extraMeta: {'author': val}),
            ),
            const SizedBox(height: 20),
          ],

          // Quick Metadata Badges
          Row(
            children: [
              _buildMetricCard(
                'Checklist Items',
                '${item.smartChecklist.where((c) => c.isCompleted).length} / ${item.smartChecklist.length}',
                Icons.check_box_outlined,
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                'Milestones',
                '${item.smartMilestones.where((m) => m.isCompleted).length} / ${item.smartMilestones.length}',
                Icons.flag_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── TAB 2: CHECKLIST ───────────────────────────────────────────────────────
  Widget _buildChecklistTab(VisionItem item) {
    final checklist = item.smartChecklist;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newChecklistController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _inputDecoration('Add new checklist item...'),
                  onSubmitted: (val) => _addChecklistItem(item, val),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: checklist.length,
                  itemBuilder: (context, index) {
                    final cItem = checklist[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: cItem.isCompleted,
                          activeColor: AppColors.accentBlue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) {
                            _toggleChecklistItem(item, index, val ?? false);
                          },
                        ),
                        title: Text(
                          cItem.title,
                          style: TextStyle(
                            color: cItem.isCompleted
                                ? Colors.white38
                                : Colors.white,
                            fontSize: 14,
                            decoration: cItem.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white30, size: 18),
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

  // ─── TAB 3: MILESTONES ──────────────────────────────────────────────────────
  Widget _buildMilestonesTab(VisionItem item) {
    final milestones = item.smartMilestones;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  backgroundColor: AppColors.accentBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.flag_rounded, color: Colors.white),
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
                    'No milestones defined. Break goals into milestones!',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: milestones.length,
                  itemBuilder: (context, index) {
                    final m = milestones[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () => _toggleMilestone(item, index, !m.isCompleted),
                          child: Icon(
                            m.isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: m.isCompleted
                                ? Colors.greenAccent
                                : Colors.white38,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          m.title,
                          style: TextStyle(
                            color: m.isCompleted ? Colors.white38 : Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            decoration:
                                m.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: m.completionDate != null
                            ? Text(
                                'Completed: ${m.completionDate!.day}/${m.completionDate!.month}/${m.completionDate!.year}',
                                style: const TextStyle(
                                    color: Colors.greenAccent, fontSize: 11),
                              )
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.white30, size: 20),
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

  // ─── TAB 4: NOTES ───────────────────────────────────────────────────────────
  Widget _buildNotesTab(VisionItem item) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('Personal Journal & Reflection Notes'),
          Expanded(
            child: TextField(
              controller: _notesController,
              maxLines: null,
              expands: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _inputDecoration('Record thoughts, reflection notes, or roadmap details...'),
              onChanged: (_) => _saveItemDetails(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── TAB 5: SETTINGS & ACTIONS ──────────────────────────────────────────────
  Widget _buildSettingsTab(VisionItem item) {
    final List<int> colors = [
      0xFFF59E0B,
      0xFFEC4899,
      0xFF3B82F6,
      0xFFA855F7,
      0xFF10B981,
      0xFFF8FAFC,
      0xFF1E293B,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('Card Accent Color'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: colors.map((colorVal) {
              final isSel = item.colorValue == colorVal;
              return GestureDetector(
                onTap: () {
                  ref.read(canvasStateProvider.notifier).updateItemDetails(
                        item.id,
                        colorValue: colorVal,
                      );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(colorVal),
                    shape: BoxShape.circle,
                    border: isSel
                        ? Border.all(color: Colors.white, width: 2.5)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          _buildSectionLabel('Object Actions'),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Duplicate'),
                  onPressed: () {
                    ref.read(canvasStateProvider.notifier).duplicateItem(item.id);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Delete'),
                  onPressed: () {
                    ref.read(canvasStateProvider.notifier).removeItem(item.id);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── HELPER METHODS ─────────────────────────────────────────────────────────
  void _addChecklistItem(VisionItem item, String text) {
    if (text.trim().isEmpty) return;
    final list = item.smartChecklist;
    list.add(SmartChecklistItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: text.trim(),
    ));
    _saveChecklist(item, list);
    _newChecklistController.clear();
  }

  void _toggleChecklistItem(VisionItem item, int index, bool isCompleted) {
    final list = item.smartChecklist;
    list[index] = list[index].copyWith(
      isCompleted: isCompleted,
      completionDate: isCompleted ? DateTime.now() : null,
    );
    _saveChecklist(item, list);
  }

  void _deleteChecklistItem(VisionItem item, int index) {
    final list = item.smartChecklist;
    list.removeAt(index);
    _saveChecklist(item, list);
  }

  void _saveChecklist(VisionItem item, List<SmartChecklistItem> list) {
    final serialized = list.map((c) => c.toJson()).toList();
    ref.read(canvasStateProvider.notifier).updateItemDetails(
          item.id,
          metadata: {'checklist': serialized},
        );
  }

  void _addMilestone(VisionItem item, String text) {
    if (text.trim().isEmpty) return;
    final list = item.smartMilestones;
    list.add(SmartMilestone(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: text.trim(),
    ));
    _saveMilestones(item, list);
    _newMilestoneController.clear();
  }

  void _toggleMilestone(VisionItem item, int index, bool isCompleted) {
    final list = item.smartMilestones;
    list[index] = list[index].copyWith(
      isCompleted: isCompleted,
      completionDate: isCompleted ? DateTime.now() : null,
    );
    _saveMilestones(item, list);
  }

  void _deleteMilestone(VisionItem item, int index) {
    final list = item.smartMilestones;
    list.removeAt(index);
    _saveMilestones(item, list);
  }

  void _saveMilestones(VisionItem item, List<SmartMilestone> list) {
    final serialized = list.map((m) => m.toJson()).toList();
    ref.read(canvasStateProvider.notifier).updateItemDetails(
          item.id,
          metadata: {'milestones': serialized},
        );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accentBlue, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
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

  IconData _getTypeIcon(String type) {
    if (type == VisionItemType.goal.name) return Icons.flag_rounded;
    if (type == VisionItemType.plan.name) return Icons.account_tree_rounded;
    if (type == VisionItemType.task.name) return Icons.check_circle_outline_rounded;
    if (type == VisionItemType.financeGoal.name) return Icons.attach_money_rounded;
    if (type == VisionItemType.countdown.name) return Icons.timer_rounded;
    if (type == VisionItemType.quote.name) return Icons.format_quote_rounded;
    if (type == VisionItemType.image.name) return Icons.image_rounded;
    return Icons.sticky_note_2_rounded;
  }

  String _getTypeLabel(String type) {
    if (type == VisionItemType.goal.name) return 'SMART GOAL';
    if (type == VisionItemType.plan.name) return 'ROADMAP & PLAN';
    if (type == VisionItemType.task.name) return 'DYNAMIC TASK';
    if (type == VisionItemType.financeGoal.name) return 'FINANCE GOAL';
    if (type == VisionItemType.countdown.name) return 'COUNTDOWN TIMER';
    if (type == VisionItemType.quote.name) return 'MOTIVATIONAL QUOTE';
    if (type == VisionItemType.image.name) return 'SMART IMAGE OBJECT';
    return 'SMART STICKY NOTE';
  }
}
