import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/tasks_provider.dart';
import '../widgets/task_bottom_sheet.dart';
import '../widgets/task_card.dart';
import '../../domain/models/task_model.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  String _activeFilter = 'Today';

  Widget _buildDashboard(WidgetRef ref) {
    final state = ref.watch(tasksProvider);
    final allTodayTasks = state.allTasks.where((t) {
      if (t.dueDate == null) return true;
      final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      final today = DateTime.now();
      return d == DateTime(today.year, today.month, today.day);
    }).toList();
    final completedTasks = allTodayTasks
        .where((t) => t.status == TaskStatus.completed || t.completed)
        .length;
    final totalTasks = allTodayTasks.length;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    final progressPercent = (progress * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 96,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Streak & XP small containers
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  Opacity(
                    opacity: 0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSmallStatContainer(
                          '12',
                          'Day Streak',
                          Icons.local_fire_department_rounded,
                          Colors.orangeAccent,
                        ),
                        const SizedBox(height: 6),
                        _buildSmallStatContainer(
                          '1,250',
                          'XP Today',
                          Icons.star_rounded,
                          Colors.amber,
                        ),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          'Coming Soon',
                          style: GoogleFonts.outfit(
                            color: Colors.amber,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Dynamic Progress Card
            Expanded(
              flex: 3,
              child: _buildDynamicProgressCard(
                completedTasks,
                totalTasks,
                progressPercent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStatContainer(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 12),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.outfit(color: Colors.white54, fontSize: 8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicProgressCard(int completed, int total, int percent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: Stack(
                  children: [
                    ShaderMask(
                      shaderCallback: (rect) {
                        return const SweepGradient(
                          startAngle: 0.0,
                          endAngle: 3.14 * 2,
                          stops: [0.0, 0.5, 1.0],
                          colors: [
                            Color(0xFF8B5CF6),
                            Color(0xFFF97316),
                            Color(0xFF8B5CF6),
                          ],
                        ).createShader(rect);
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '$percent%',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Progress",
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '$completed / ${total == 0 ? 1 : total}',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.white.withValues(alpha: 0.05),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percent / 100,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFF97316)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysFocusCard(WidgetRef ref) {
    final state = ref.watch(tasksProvider);
    final allTodayTasks = state.allTasks.where((t) {
      if (t.dueDate == null) return true;
      final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      final today = DateTime.now();
      return d == DateTime(today.year, today.month, today.day);
    }).toList();

    final todayPendingTasks = allTodayTasks
        .where((t) => t.status != TaskStatus.completed && !t.completed)
        .toList();
    todayPendingTasks.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      if (a.priority != b.priority) {
        if (a.priority == TaskPriority.high) return -1;
        if (b.priority == TaskPriority.high) return 1;
        if (a.priority == TaskPriority.medium) return -1;
        if (b.priority == TaskPriority.medium) return 1;
      }
      return 0;
    });

    final focusTask = todayPendingTasks.isNotEmpty
        ? todayPendingTasks.first
        : null;

    final String title = focusTask?.title ?? "No focus task for today";
    final String description =
        (focusTask?.description != null && focusTask!.description!.isNotEmpty)
        ? focusTask.description!
        : "Add or select a task to focus on.";
    final String remaining = "${todayPendingTasks.length} Tasks";
    final String priority = focusTask != null
        ? focusTask.priority.name[0].toUpperCase() +
              focusTask.priority.name.substring(1)
        : "None";

    return Container(
      width: double.infinity,
      height: 165,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/images/focus_mountain.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.2),
              Colors.black.withValues(alpha: 0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 10),
                  const SizedBox(width: 4),
                  Text(
                    "TODAY'S FOCUS",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.work_outline_rounded,
                  color: Colors.amber,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remaining',
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 9,
                      ),
                    ),
                    Text(
                      remaining,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Priority',
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 9,
                      ),
                    ),
                    Text(
                      priority,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(WidgetRef ref) {
    final state = ref.watch(tasksProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayCount = state.allTasks.where((t) {
      if (t.dueDate == null) return t.status != TaskStatus.completed;
      final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return d == today && t.status != TaskStatus.completed;
    }).length;

    final upcomingCount = state.allTasks.where((t) {
      if (t.dueDate == null) return false;
      final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return d.isAfter(today) && t.status != TaskStatus.completed;
    }).length;

    final completedCount = state.allTasks
        .where((t) => t.status == TaskStatus.completed || t.completed)
        .length;
    final overdueCount = state.allTasks
        .where((t) => t.status == TaskStatus.overdue)
        .length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildChip('Today', todayCount, Icons.wb_sunny_rounded, ref),
          _buildChip(
            'Upcoming',
            upcomingCount,
            Icons.calendar_month_rounded,
            ref,
          ),
          _buildChip(
            'Completed',
            completedCount,
            Icons.check_circle_outline,
            ref,
          ),
          _buildChip('Overdue', overdueCount, Icons.access_time_rounded, ref),
        ],
      ),
    );
  }

  Widget _buildChip(String label, int count, IconData icon, WidgetRef ref) {
    final isSelected = _activeFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = label;
        });

        TaskFilter filter;
        switch (label) {
          case 'Today':
            filter = TaskFilter.today;
            break;
          case 'Upcoming':
            filter = TaskFilter.upcoming;
            break;
          case 'Completed':
            filter = TaskFilter.completed;
            break;
          case 'Overdue':
            filter = TaskFilter.overdue;
            break;
          default:
            filter = TaskFilter.all;
            break;
        }
        ref.read(tasksProvider.notifier).setFilter(filter);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.amber.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.amber
                : Colors.white.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.amber : Colors.white54,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.amber : Colors.white70,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.amber.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.outfit(
                  color: isSelected ? Colors.amber : Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList(WidgetRef ref) {
    final state = ref.watch(tasksProvider);

    if (state.isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
        ),
      );
    }

    if (state.filteredTasks.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.assignment_turned_in_outlined,
                size: 64,
                color: Colors.white24,
              ),
              const SizedBox(height: 16),
              Text(
                'No tasks here yet',
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 120), // Space for FAB
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final task = state.filteredTasks[index];
          return TaskCard(
            task: task,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => TaskBottomSheet(existingTask: task),
              );
            },
            onToggleComplete: (val) {
              ref
                  .read(tasksProvider.notifier)
                  .updateTask(
                    task.copyWith(
                      completed: val ?? false,
                      updatedAt: DateTime.now(),
                    ),
                  );
            },
          );
        }, childCount: state.filteredTasks.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A13),
      body: Stack(
        children: [
          RefreshIndicator(
            color: const Color(0xFF8B5CF6),
            backgroundColor: const Color(0xFF1E1E2A),
            onRefresh: () async {
              await ref.read(tasksProvider.notifier).refresh();
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDashboard(ref),
                          _buildTodaysFocusCard(ref),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _buildFilterChips(ref),
                  ),
                ),

                _buildTasksList(ref),
              ],
            ),
          ),

          // Floating Action Buttons
          Positioned(
            bottom: 90,
            right: 20,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const TaskBottomSheet(),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF97316), Color(0xFF8B5CF6)],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Add Task',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
