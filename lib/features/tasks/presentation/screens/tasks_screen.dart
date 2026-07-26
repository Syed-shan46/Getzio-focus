import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/tasks_provider.dart';
import '../widgets/task_bottom_sheet.dart';
import '../../domain/models/task_model.dart';
import 'package:getzio_todo_app/core/theme/app_theme.dart';
import 'package:getzio_todo_app/shared/widgets/design_system.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  String _activeFilter = 'Today';
  String _secondaryFilter = 'All';
  String _searchQuery = '';
  bool _isSearchActive = false;
  final Set<String> _expandedTaskIds = {};
  final TextEditingController _searchController = TextEditingController();

  // Bottom Sheet Filter & Sort state
  String _selectedPriority = 'All';
  String _selectedCategory = 'All';
  String _sortBy = 'Due Date';
  bool _showCompleted = true;
  bool _showIncomplete = true;
  bool _showStarredOnly = false;
  bool _showHasReminderOnly = false;
  bool _showHasSubtasksOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // HELPER METHODS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  bool _isTaskOverdue(TaskModel task) {
    if (task.effectiveCompleted) return false;
    if (task.dueDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final targetDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      if (targetDate.isBefore(today)) return true;
      if (targetDate == today && task.dueTime != null) {
        try {
          final timeFormat = DateFormat('h:mm a');
          final parsedTime = timeFormat.parse(task.dueTime!);
          final targetDateTime = DateTime(
            today.year,
            today.month,
            today.day,
            parsedTime.hour,
            parsedTime.minute,
          );
          if (targetDateTime.isBefore(now)) return true;
        } catch (_) {}
      }
    }
    for (final sub in task.subtasks) {
      if (_isSubtaskOverdue(sub)) return true;
    }
    return false;
  }

  bool _isSubtaskOverdue(SubtaskModel sub) {
    if (sub.completed) return false;
    if (sub.dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(
      sub.dueDate!.year,
      sub.dueDate!.month,
      sub.dueDate!.day,
    );
    if (targetDate.isBefore(today)) return true;
    if (targetDate == today && sub.dueTime != null) {
      try {
        final timeFormat = DateFormat('h:mm a');
        final parsedTime = timeFormat.parse(sub.dueTime!);
        final targetDateTime = DateTime(
          today.year,
          today.month,
          today.day,
          parsedTime.hour,
          parsedTime.minute,
        );
        return targetDateTime.isBefore(now);
      } catch (_) {}
    }
    return false;
  }

  String _getCountdownString(DateTime? date, String? timeStr, [bool completed = false]) {
    if (completed) return 'Completed';
    if (date == null) return 'No deadline set';
    final now = DateTime.now();

    DateTime targetDateTime;
    if (timeStr != null) {
      final timeFormat = DateFormat('h:mm a');
      try {
        final parsedTime = timeFormat.parse(timeStr);
        targetDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          parsedTime.hour,
          parsedTime.minute,
        );
      } catch (_) {
        targetDateTime = DateTime(date.year, date.month, date.day);
      }
    } else {
      targetDateTime = DateTime(date.year, date.month, date.day, 23, 59);
    }

    final diff = targetDateTime.difference(now);

    if (diff.isNegative) {
      if (diff.inDays.abs() > 0) {
        return 'Overdue by ${diff.inDays.abs()} Days';
      } else if (diff.inHours.abs() > 0) {
        return 'Overdue by ${diff.inHours.abs()}h';
      } else {
        return 'Overdue';
      }
    }

    if (timeStr != null) {
      if (diff.inHours > 0) {
        return '${diff.inHours}h ${diff.inMinutes % 60}m left';
      } else {
        return '${diff.inMinutes} mins left';
      }
    } else {
      final today = DateTime(now.year, now.month, now.day);
      final targetDate = DateTime(date.year, date.month, date.day);
      final daysDiff = targetDate.difference(today).inDays;
      if (daysDiff == 0) {
        return 'Today';
      } else if (daysDiff == 1) {
        return 'Tomorrow';
      } else {
        return '$daysDiff Days Left';
      }
    }
  }

  Color _getCountdownColor(DateTime? date, String? timeStr, bool completed) {
    if (completed) return Colors.grey;
    if (date == null) return Colors.grey;
    final now = DateTime.now();

    DateTime targetDateTime;
    if (timeStr != null) {
      final timeFormat = DateFormat('h:mm a');
      try {
        final parsedTime = timeFormat.parse(timeStr);
        targetDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          parsedTime.hour,
          parsedTime.minute,
        );
      } catch (_) {
        targetDateTime = DateTime(date.year, date.month, date.day);
      }
    } else {
      targetDateTime = DateTime(date.year, date.month, date.day, 23, 59);
    }

    final diff = targetDateTime.difference(now);
    if (diff.isNegative) return Colors.redAccent;

    if (timeStr != null) {
      if (diff.inHours < 3) return Colors.redAccent;
      return Colors.amber;
    } else {
      final today = DateTime(now.year, now.month, now.day);
      final targetDate = DateTime(date.year, date.month, date.day);
      final daysDiff = targetDate.difference(today).inDays;
      if (daysDiff <= 0) {
        return Colors.amber;
      } else if (daysDiff <= 3) {
        return Colors.amber;
      } else {
        return Colors.greenAccent;
      }
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return const Color(0xFF8B5CF6);
      case 'personal':
        return const Color(0xFF10B981);
      case 'study':
        return const Color(0xFF3B82F6);
      case 'finance':
        return const Color(0xFF14B8A6);
      case 'health':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF97316);
    }
  }

  List<TargetItem> _getTodaysTargets(List<TaskModel> allTasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<TargetItem> targets = [];

    for (final task in allTasks) {
      bool taskIsToday = false;
      if (task.dueDate != null) {
        final d = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        if (d == today) {
          taskIsToday = true;
        }
      } else {
        if (!task.effectiveCompleted) {
          taskIsToday = true;
        }
      }

      if (taskIsToday) {
        targets.add(
          TargetItem(
            id: task.id,
            title: task.title,
            completed: task.effectiveCompleted,
            isSubtask: false,
            priority: task.priority,
            pinned: task.pinned,
            dueDate: task.dueDate,
            dueTime: task.dueTime,
          ),
        );
      }
    }

    targets.sort((a, b) {
      if (a.completed != b.completed) {
        return a.completed ? 1 : -1;
      }

      final aOverdue = _isOverdue(a);
      final bOverdue = _isOverdue(b);
      if (aOverdue != bOverdue) {
        return aOverdue ? -1 : 1;
      }

      if (a.pinned != b.pinned) {
        return a.pinned ? -1 : 1;
      }

      if (a.priority != b.priority) {
        if (a.priority == TaskPriority.high) return -1;
        if (b.priority == TaskPriority.high) return 1;
        if (a.priority == TaskPriority.medium) return -1;
        if (b.priority == TaskPriority.medium) return 1;
      }

      if (a.dueTime != null && b.dueTime == null) return -1;
      if (a.dueTime == null && b.dueTime != null) return 1;
      if (a.dueTime != null && b.dueTime != null) {
        return a.dueTime!.compareTo(b.dueTime!);
      }

      return 0;
    });

    return targets;
  }

  bool _isOverdue(TargetItem item) {
    if (item.completed) return false;
    if (item.dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(
      item.dueDate!.year,
      item.dueDate!.month,
      item.dueDate!.day,
    );
    if (targetDate.isBefore(today)) return true;
    if (targetDate == today && item.dueTime != null) {
      final timeFormat = DateFormat('h:mm a');
      try {
        final parsedTime = timeFormat.parse(item.dueTime!);
        final targetDateTime = DateTime(
          today.year,
          today.month,
          today.day,
          parsedTime.hour,
          parsedTime.minute,
        );
        return targetDateTime.isBefore(now);
      } catch (_) {}
    }
    return false;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CENTRALIZED FILTER & SORT ENGINE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  List<TargetListItem> _getFilteredTargets(
    List<TaskModel> allTasks,
    TaskFilter activeFilter,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<TargetListItem> targets = [];

    // Map active primary filter to TaskFilter
    TaskFilter pFilter = TaskFilter.all;
    if (_activeFilter == 'Today')
      pFilter = TaskFilter.today;
    else if (_activeFilter == 'Upcoming')
      pFilter = TaskFilter.upcoming;
    else if (_activeFilter == 'Completed')
      pFilter = TaskFilter.completed;
    else if (_activeFilter == 'Overdue')
      pFilter = TaskFilter.overdue;
    else if (_activeFilter == 'All')
      pFilter = TaskFilter.all;

    // Filter Loop
    for (final task in allTasks) {
      // ── Main Task Filter ──
      bool includeTask = false;
      switch (pFilter) {
        case TaskFilter.today:
          if (task.dueDate == null) {
            includeTask = !task.effectiveCompleted;
          } else {
            final d = DateTime(
              task.dueDate!.year,
              task.dueDate!.month,
              task.dueDate!.day,
            );
            includeTask = d == today && !task.effectiveCompleted;
          }
          break;
        case TaskFilter.upcoming:
          if (task.dueDate != null) {
            final d = DateTime(
              task.dueDate!.year,
              task.dueDate!.month,
              task.dueDate!.day,
            );
            includeTask = d.isAfter(today) && !task.effectiveCompleted;
          }
          break;
        case TaskFilter.completed:
          includeTask = task.effectiveCompleted;
          break;
        case TaskFilter.overdue:
          includeTask = _isTaskOverdue(task) && !task.effectiveCompleted;
          break;
        case TaskFilter.all:
        default:
          includeTask = true;
          break;
      }

      // Advanced bottom sheet checks
      if (includeTask) {
        if (_selectedPriority != 'All' &&
            task.priority.name.toLowerCase() !=
                _selectedPriority.toLowerCase()) {
          includeTask = false;
        }
        if (_selectedCategory != 'All' &&
            task.category.toLowerCase() != _selectedCategory.toLowerCase()) {
          includeTask = false;
        }
        if (!_showCompleted && task.effectiveCompleted) includeTask = false;
        if (!_showIncomplete && !task.effectiveCompleted) includeTask = false;
        if (_showStarredOnly && !task.pinned) includeTask = false;
        if (_showHasReminderOnly && !task.reminder) includeTask = false;
        if (_showHasSubtasksOnly && task.subtasks.isEmpty) includeTask = false;
      }

      // Search Query filter
      if (includeTask && _searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = task.title.toLowerCase().contains(query);
        final matchesDesc = task.description.toLowerCase().contains(query);
        final matchesCat = task.category.toLowerCase().contains(query);
        final matchesSub = task.subtasks.any(
          (s) => s.title.toLowerCase().contains(query),
        );
        if (!matchesTitle && !matchesDesc && !matchesCat && !matchesSub) {
          includeTask = false;
        }
      }

      // Secondary scrollable filter checks (All, Tasks, Subtasks, Starred, High, Medium, Low)
      if (includeTask) {
        if (_secondaryFilter == 'Tasks' && task.subtasks.isNotEmpty) {
          // keep them
        } else if (_secondaryFilter == '⭐ Starred' && !task.pinned) {
          includeTask = false;
        } else if (_secondaryFilter == 'High' &&
            task.priority != TaskPriority.high) {
          includeTask = false;
        } else if (_secondaryFilter == 'Medium' &&
            task.priority != TaskPriority.medium) {
          includeTask = false;
        } else if (_secondaryFilter == 'Low' &&
            task.priority != TaskPriority.low) {
          includeTask = false;
        }
      }

      // We do not add the main task card if the active secondary filter is "Subtasks"
      if (includeTask && _secondaryFilter != 'Subtasks') {
        targets.add(TargetListItem(task: task));
      }

      // ── Subtask Extraction (Only active when secondary filter is "Subtasks") ──
      if (_secondaryFilter == 'Subtasks') {
        for (final sub in task.subtasks) {
          bool includeSub = false;
          final isTodaySub =
              sub.dueDate != null &&
              DateTime(
                    sub.dueDate!.year,
                    sub.dueDate!.month,
                    sub.dueDate!.day,
                  ) ==
                  today;

          switch (pFilter) {
            case TaskFilter.today:
              includeSub = isTodaySub;
              break;
            case TaskFilter.upcoming:
              includeSub = sub.dueDate != null && sub.dueDate!.isAfter(today);
              break;
            case TaskFilter.completed:
              includeSub = sub.completed;
              break;
            case TaskFilter.overdue:
              includeSub = _isSubtaskOverdue(sub);
              break;
            case TaskFilter.all:
            default:
              includeSub = true;
              break;
          }

          if (includeSub && _searchQuery.isNotEmpty) {
            if (!sub.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
              includeSub = false;
            }
          }

          if (includeSub) {
            targets.add(TargetListItem(task: task, subtask: sub));
          }
        }
      }
    }

    // ── Sorting ──
    targets.sort((a, b) {
      if (a.completed != b.completed) {
        return a.completed ? 1 : -1;
      }

      // Sort by chosen criteria
      if (_sortBy == 'Priority') {
        final aPriorityVal = a.task.priority.index;
        final bPriorityVal = b.task.priority.index;
        if (aPriorityVal != bPriorityVal)
          return aPriorityVal.compareTo(bPriorityVal);
      } else if (_sortBy == 'Alphabetical') {
        final aTitle = a.isSubtask ? a.subtask!.title : a.task.title;
        final bTitle = b.isSubtask ? b.subtask!.title : b.task.title;
        return aTitle.compareTo(bTitle);
      } else if (_sortBy == 'Recently Created') {
        final aCreated = a.task.createdAt ?? DateTime.now();
        final bCreated = b.task.createdAt ?? DateTime.now();
        return bCreated.compareTo(aCreated);
      }

      // Default: Sort by Due Date
      if (a.dueDate != null && b.dueDate == null) return -1;
      if (a.dueDate == null && b.dueDate != null) return 1;
      if (a.dueDate != null && b.dueDate != null) {
        final aDate = DateTime(
          a.dueDate!.year,
          a.dueDate!.month,
          a.dueDate!.day,
        );
        final bDate = DateTime(
          b.dueDate!.year,
          b.dueDate!.month,
          b.dueDate!.day,
        );
        if (aDate != bDate) return aDate.compareTo(bDate);

        if (a.dueTime != null && b.dueTime == null) return -1;
        if (a.dueTime == null && b.dueTime != null) return 1;
        if (a.dueTime != null && b.dueTime != null) {
          return a.dueTime!.compareTo(b.dueTime!);
        }
      }

      return 0;
    });

    return targets;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // STATS CARD COMPILER
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Map<String, int> _getStats(List<TaskModel> allTasks) {
    int totalToday = 0;
    int highPriority = 0;
    int remindersCount = 0;
    int subtasksCount = 0;
    int completedCount = 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final task in allTasks) {
      final isToday =
          task.dueDate != null &&
          DateTime(
                task.dueDate!.year,
                task.dueDate!.month,
                task.dueDate!.day,
              ) ==
              today;
      if (isToday) totalToday++;
      if (task.priority == TaskPriority.high && !task.effectiveCompleted)
        highPriority++;
      if (task.reminder && !task.effectiveCompleted) remindersCount++;
      subtasksCount += task.subtasks.length;
      completedCount += task.subtasks.where((s) => s.completed).length;
      if (task.effectiveCompleted) completedCount++;
    }

    return {
      'today': totalToday,
      'high': highPriority,
      'reminders': remindersCount,
      'subtasks': subtasksCount,
      'completed': completedCount,
    };
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BUILD METHOD
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasksProvider);
    final targetsList = _getFilteredTargets(state.allTasks, state.activeFilter);
    final stats = _getStats(state.allTasks);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 32.0 : 16.0;

    return Scaffold(
      backgroundColor: context.colors.bg1,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Tasks',
                                  style: GoogleFonts.outfit(
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1E293B),
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Stay focused, make progress.',
                                  style: GoogleFonts.outfit(
                                    color: isDark
                                        ? Colors.white54
                                        : const Color(0xFF64748B),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _isSearchActive
                                        ? Icons.close_rounded
                                        : Icons.search_rounded,
                                    color: isDark
                                        ? Colors.white70
                                        : const Color(0xFF475569),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isSearchActive = !_isSearchActive;
                                      if (!_isSearchActive) {
                                        _searchQuery = '';
                                        _searchController.clear();
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: _isSearchActive ? 60 : 0,
                          child: _isSearchActive
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (val) {
                                      setState(() {
                                        _searchQuery = val;
                                      });
                                    },
                                    style: GoogleFonts.outfit(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1E293B),
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Search tasks, subtasks, descriptions...',
                                      hintStyle: GoogleFonts.outfit(
                                        color: isDark
                                            ? Colors.white30
                                            : const Color(0xFF94A3B8),
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search_rounded,
                                        color: Colors.blueAccent,
                                        size: 20,
                                      ),
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.white.withValues(alpha: 0.05)
                                          : Colors.black.withValues(
                                              alpha: 0.03,
                                            ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 0,
                                            horizontal: 16,
                                          ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Primary Pill Filters
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildPrimaryFilterPills(state.allTasks),
                  ),
                ),

                // 3. Second Filter Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildSecondaryFilterChips(),
                  ),
                ),

                // 4. Task / Subtask Targets List
                if (state.isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  )
                else if (targetsList.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = targetsList[index];
                        if (item.isSubtask) {
                          return _buildSubtaskItemCard(item);
                        } else {
                          return _buildTaskItemCard(item);
                        }
                      }, childCount: targetsList.length),
                    ),
                  ),

                // 5. Bottom Stats Summary
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      top: 32,
                      bottom: 120,
                    ),
                    child: _buildStatsSummarySection(stats),
                  ),
                ),
              ],
            ),

            // FAB
            Positioned(bottom: 24, right: 20, child: _buildPremiumFAB()),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PRIMARY PILLS UI
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildPrimaryFilterPills(List<TaskModel> allTasks) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int todayCount = 0;
    int upcomingCount = 0;
    int completedCount = 0;
    int overdueCount = 0;

    for (final task in allTasks) {
      if (task.dueDate == null) {
        if (!task.effectiveCompleted) todayCount++;
      } else {
        final d = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        if (d == today && !task.effectiveCompleted) {
          todayCount++;
        } else if (d.isAfter(today) && !task.effectiveCompleted) {
          upcomingCount++;
        }
      }
      if (task.effectiveCompleted) {
        completedCount++;
      }
      if (_isTaskOverdue(task)) {
        overdueCount++;
      }
    }

    final pills = [
      {
        'label': 'All',
        'count': allTasks.length,
        'icon': Icons.format_list_bulleted_rounded,
      },
      {'label': 'Today', 'count': todayCount, 'icon': Icons.wb_sunny_rounded},
      {
        'label': 'Upcoming',
        'count': upcomingCount,
        'icon': Icons.calendar_month_rounded,
      },
      {
        'label': 'Completed',
        'count': completedCount,
        'icon': Icons.check_circle_outline,
      },
      {
        'label': 'Overdue',
        'count': overdueCount,
        'icon': Icons.access_time_rounded,
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: pills.map((pill) {
          final label = pill['label'] as String;
          final count = pill['count'] as int;
          final icon = pill['icon'] as IconData;
          final isSelected = _activeFilter == label;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _activeFilter = label;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFF97316), Color(0xFF8B5CF6)],
                      )
                    : null,
                color: isSelected
                    ? null
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.02)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05)),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF475569)),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : const Color(0xFF475569)),
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      key: ValueKey(count),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.2)
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.05)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        style: GoogleFonts.outfit(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? Colors.white70
                                    : const Color(0xFF475569)),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SECONDARY FILTERS UI
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildSecondaryFilterChips() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chips = ['All', 'Tasks', 'Subtasks', 'High', 'Medium', 'Low'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: chips.map((chip) {
          final isSelected = _secondaryFilter == chip;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _secondaryFilter = chip;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.blueAccent.withValues(alpha: 0.1))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? Colors.white54 : Colors.blueAccent)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.03)),
                  width: 0.5,
                ),
              ),
              child: Text(
                chip,
                style: GoogleFonts.outfit(
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.blueAccent)
                      : (isDark ? Colors.white38 : const Color(0xFF64748B)),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // REDESIGNED TASK CARD UI (MAIN CARD)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildTaskItemCard(TargetListItem item) {
    final task = item.task;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpanded = _expandedTaskIds.contains(task.id);
    final categoryColor = _getCategoryColor(task.category);

    final totalSub = task.subtasks.length;
    final completedSub = task.subtasks.where((s) => s.completed).length;
    final progressVal = task.effectiveProgress;

    final dateStr = task.dueDate == null
        ? ''
        : DateFormat('dd MMM').format(task.dueDate!);
    final countdown = _getCountdownString(task.dueDate, task.dueTime);
    final countdownColor = _getCountdownColor(
      task.dueDate,
      task.dueTime,
      task.effectiveCompleted,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.colors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.textPrimary.withValues(alpha: 0.04),
          width: 1,
        ),
      ),
      child: CustomPaint(
        painter: TaskCardPainter(
          backgroundColor: Colors.transparent,
          categoryColor: categoryColor,
          borderColor: Colors.transparent,
          borderWidth: 0.0,
          borderRadius: 16.0,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (isExpanded) {
                      _expandedTaskIds.remove(task.id);
                    } else {
                      _expandedTaskIds.add(task.id);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: Stack(
                          children: [
                            Center(
                              child: CircularProgressIndicator(
                                value: progressVal / 100,
                                strokeWidth: 3,
                                backgroundColor: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.05),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progressVal >= 100
                                      ? Colors.greenAccent
                                      : categoryColor,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                '${progressVal.toInt()}%',
                                style: GoogleFonts.outfit(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: GoogleFonts.outfit(
                                color: task.effectiveCompleted
                                    ? (isDark ? Colors.white38 : Colors.grey)
                                    : (isDark
                                          ? Colors.white
                                          : const Color(0xFF1E293B)),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                decoration: task.effectiveCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (task.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                task.description,
                                style: GoogleFonts.outfit(
                                  color: isDark
                                      ? Colors.white54
                                      : const Color(0xFF64748B),
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                if (totalSub > 0) ...[
                                  Icon(
                                    Icons.check_box_outlined,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.grey,
                                    size: 10,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '$completedSub / $totalSub',
                                    style: GoogleFonts.outfit(
                                      color: isDark
                                          ? Colors.white38
                                          : const Color(0xFF64748B),
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    task.category,
                                    style: GoogleFonts.outfit(
                                      color: categoryColor,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.flag_rounded,
                                color: task.priority == TaskPriority.high
                                    ? Colors.redAccent
                                    : (task.priority == TaskPriority.medium
                                          ? Colors.orangeAccent
                                          : Colors.blueAccent),
                                size: 11,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                task.priority.name[0].toUpperCase() +
                                    task.priority.name.substring(1),
                                style: GoogleFonts.outfit(
                                  color: isDark
                                      ? Colors.white38
                                      : const Color(0xFF64748B),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (task.dueDate != null) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: countdownColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                countdown,
                                style: GoogleFonts.outfit(
                                  color: countdownColor,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: isDark ? Colors.white38 : Colors.grey,
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                clipBehavior: Clip.none,
                child: isExpanded
                    ? Column(
                        children: [
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              children: [
                                if (task.subtasks.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Text(
                                      'No subtasks scheduled. Tap Edit to add target subtasks.',
                                      style: GoogleFonts.outfit(
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                else
                                  ...List.generate(task.subtasks.length, (
                                    subIndex,
                                  ) {
                                    final sub = task.subtasks[subIndex];
                                    final subCountdown = _getCountdownString(
                                      sub.dueDate,
                                      sub.dueTime,
                                    );
                                    final subColor = _getCountdownColor(
                                      sub.dueDate,
                                      sub.dueTime,
                                      sub.completed,
                                    );

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              HapticFeedback.lightImpact();
                                              final updatedList = task.subtasks
                                                  .map((s) {
                                                    if (s.id == sub.id) {
                                                      return s.copyWith(
                                                        completed: !s.completed,
                                                        completedAt:
                                                            !s.completed
                                                            ? DateTime.now()
                                                            : null,
                                                      );
                                                    }
                                                    return s;
                                                  })
                                                  .toList();
                                              ref
                                                  .read(tasksProvider.notifier)
                                                  .updateTask(
                                                    task.copyWith(
                                                      subtasks: updatedList,
                                                      updatedAt: DateTime.now(),
                                                    ),
                                                  );
                                            },
                                            child: Container(
                                              width: 18,
                                              height: 18,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: sub.completed
                                                      ? Colors.greenAccent
                                                      : (isDark
                                                            ? Colors.white38
                                                            : Colors.grey),
                                                  width: 1.5,
                                                ),
                                                color: sub.completed
                                                    ? Colors.greenAccent
                                                          .withValues(
                                                            alpha: 0.2,
                                                          )
                                                    : Colors.transparent,
                                              ),
                                              child: sub.completed
                                                  ? const Icon(
                                                      Icons.check,
                                                      size: 10,
                                                      color: Colors.greenAccent,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              sub.title,
                                              style: GoogleFonts.outfit(
                                                color: sub.completed
                                                    ? (isDark
                                                          ? Colors.white38
                                                          : Colors.grey)
                                                    : (isDark
                                                          ? Colors.white70
                                                          : const Color(
                                                              0xFF1E293B,
                                                            )),
                                                fontSize: 12,
                                                decoration: sub.completed
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          if (sub.dueDate != null) ...[
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 1,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: subColor.withValues(
                                                  alpha: 0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                subCountdown,
                                                style: GoogleFonts.outfit(
                                                  color: subColor,
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  }),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) => TaskBottomSheet(
                                            existingTask: task,
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.edit_rounded,
                                        size: 12,
                                        color: Colors.blueAccent,
                                      ),
                                      label: Text(
                                        'Edit Task & Subtasks',
                                        style: GoogleFonts.outfit(
                                          color: Colors.blueAccent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // REDESIGNED STANDALONE SUBTASK CARD
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildSubtaskItemCard(TargetListItem item) {
    final sub = item.subtask!;
    final parent = item.task;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final countdown = _getCountdownString(sub.dueDate, sub.dueTime, sub.completed);
    final countdownColor = _getCountdownColor(
      sub.dueDate,
      sub.dueTime,
      sub.completed,
    );
    final dateStr = sub.dueDate == null
        ? ''
        : DateFormat('dd MMM').format(sub.dueDate!);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              final updatedSubtasks = parent.subtasks.map((s) {
                if (s.id == sub.id) {
                  return s.copyWith(
                    completed: !s.completed,
                    completedAt: !s.completed ? DateTime.now() : null,
                  );
                }
                return s;
              }).toList();
              ref
                  .read(tasksProvider.notifier)
                  .updateTask(
                    parent.copyWith(
                      subtasks: updatedSubtasks,
                      updatedAt: DateTime.now(),
                    ),
                  );
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: sub.completed
                      ? Colors.greenAccent
                      : (isDark ? Colors.white38 : Colors.grey),
                  width: 1.5,
                ),
                color: sub.completed
                    ? Colors.greenAccent.withValues(alpha: 0.2)
                    : Colors.transparent,
              ),
              child: sub.completed
                  ? const Icon(Icons.check, size: 12, color: Colors.greenAccent)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.title,
                  style: GoogleFonts.outfit(
                    color: sub.completed
                        ? (isDark ? Colors.white38 : Colors.grey)
                        : (isDark ? Colors.white : const Color(0xFF1E293B)),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    decoration: sub.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Part of: ${parent.title}',
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white30 : const Color(0xFF64748B),
                    fontSize: 10,
                  ),
                ),
                if (sub.dueDate != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          dateStr,
                          style: GoogleFonts.outfit(
                            color: isDark
                                ? Colors.white38
                                : const Color(0xFF64748B),
                            fontSize: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: countdownColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          countdown,
                          style: GoogleFonts.outfit(
                            color: countdownColor,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: Colors.white24,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => TaskBottomSheet(existingTask: parent),
              );
            },
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // STATS SECTION UI
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildStatsSummarySection(Map<String, int> stats) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final statConfigs = [
      {
        'label': 'Today',
        'val': stats['today']!,
        'icon': Icons.wb_sunny_rounded,
        'color': Colors.amber,
      },
      {
        'label': 'Priority',
        'val': stats['high']!,
        'icon': Icons.flag_rounded,
        'color': Colors.redAccent,
      },
      {
        'label': 'Reminders',
        'val': stats['reminders']!,
        'icon': Icons.notifications_active_outlined,
        'color': Colors.blueAccent,
      },
      {
        'label': 'Subtasks',
        'val': stats['subtasks']!,
        'icon': Icons.check_box_outlined,
        'color': Colors.purpleAccent,
      },
      {
        'label': 'Completed',
        'val': stats['completed']!,
        'icon': Icons.check_circle_outline,
        'color': Colors.greenAccent,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Overview',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white70 : const Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemCount: statConfigs.length,
          itemBuilder: (context, index) {
            final cfg = statConfigs[index];
            final color = cfg['color'] as Color;
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131722) : context.colors.bg2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      cfg['icon'] as IconData,
                      color: color,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cfg['val'].toString(),
                          style: GoogleFonts.outfit(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cfg['label'] as String,
                          style: GoogleFonts.outfit(
                            color: isDark
                                ? Colors.white38
                                : const Color(0xFF64748B),
                            fontSize: 9,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // FAB UI
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildPremiumFAB() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const TaskBottomSheet(),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFF97316), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // EMPTY STATE UI
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.blur_on_rounded,
              size: 72,
              color: isDark ? Colors.white12 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create your first task and start building momentum.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white38 : const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const TaskBottomSheet(),
                );
              },
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: Text(
                'Create Task',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ADVANCED FILTER BOTTOM SHEET
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  void _openFilterBottomSheet() {
    AppBottomSheet.show(
      context,
      title: 'Filters & Sort',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Priority',
                style: AppTypography.titleMedium(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ['All', 'High', 'Medium', 'Low'].map((p) {
                  final isSel = _selectedPriority == p;
                  return AppCategoryChip(
                    label: p,
                    isSelected: isSel,
                    onTap: () => setSheetState(() => _selectedPriority = p),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Sort By',
                style: AppTypography.titleMedium(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    [
                      'Due Date',
                      'Priority',
                      'Recently Created',
                      'Alphabetical',
                    ].map((s) {
                      final isSel = _sortBy == s;
                      return AppCategoryChip(
                        label: s,
                        isSelected: isSel,
                        onTap: () => setSheetState(() => _sortBy = s),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  'Show Completed Tasks',
                  style: AppTypography.bodyLarge(
                    color: context.colors.textPrimary,
                  ),
                ),
                value: _showCompleted,
                onChanged: (val) => setSheetState(() => _showCompleted = val),
                activeColor: context.colors.accentBlue,
              ),
              SwitchListTile(
                title: Text(
                  'Show Starred Only',
                  style: AppTypography.bodyLarge(
                    color: context.colors.textPrimary,
                  ),
                ),
                value: _showStarredOnly,
                onChanged: (val) => setSheetState(() => _showStarredOnly = val),
                activeColor: context.colors.accentBlue,
              ),
              SwitchListTile(
                title: Text(
                  'Show Has Reminder Only',
                  style: AppTypography.bodyLarge(
                    color: context.colors.textPrimary,
                  ),
                ),
                value: _showHasReminderOnly,
                onChanged: (val) =>
                    setSheetState(() => _showHasReminderOnly = val),
                activeColor: context.colors.accentBlue,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppOutlineButton(
                      text: 'Reset',
                      onPressed: () {
                        setSheetState(() {
                          _selectedPriority = 'All';
                          _selectedCategory = 'All';
                          _sortBy = 'Due Date';
                          _showCompleted = true;
                          _showIncomplete = true;
                          _showStarredOnly = false;
                          _showHasReminderOnly = false;
                          _showHasSubtasksOnly = false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Apply Filters',
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class TargetItem {
  final String id;
  final String title;
  final String? parentTaskId;
  final String? parentTaskTitle;
  final DateTime? dueDate;
  final String? dueTime;
  final bool completed;
  final bool isSubtask;
  final TaskPriority priority;
  final bool pinned;

  TargetItem({
    required this.id,
    required this.title,
    this.parentTaskId,
    this.parentTaskTitle,
    this.dueDate,
    this.dueTime,
    required this.completed,
    required this.isSubtask,
    required this.priority,
    required this.pinned,
  });
}

class TargetListItem {
  final TaskModel task;
  final SubtaskModel? subtask;

  TargetListItem({required this.task, this.subtask});

  String get id => subtask?.id ?? task.id;
  bool get isSubtask => subtask != null;
  bool get completed => subtask?.completed ?? task.effectiveCompleted;
  DateTime? get dueDate => subtask?.dueDate ?? task.dueDate;
  String? get dueTime => subtask?.dueTime ?? task.dueTime;
}

class TaskCardPainter extends CustomPainter {
  final Color backgroundColor;
  final Color categoryColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  TaskCardPainter({
    required this.backgroundColor,
    required this.categoryColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // 1. Draw background
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, bgPaint);

    // 2. Draw category indicator strip (left side)
    canvas.save();
    canvas.clipRRect(rrect);
    final stripePaint = Paint()
      ..color = categoryColor
      ..style = PaintingStyle.fill;
    final stripeRect = Rect.fromLTWH(0, 0, 4, size.height);
    canvas.drawRect(stripeRect, stripePaint);
    canvas.restore();

    // 3. Draw border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant TaskCardPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.categoryColor != categoryColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.borderRadius != borderRadius;
  }
}
