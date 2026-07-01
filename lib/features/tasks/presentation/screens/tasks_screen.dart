import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../providers/tasks_provider.dart';
import '../widgets/animated_filter_chips.dart';
import '../widgets/task_bottom_sheet.dart';
import '../widgets/task_card.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF070A13),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning',
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMMM d').format(DateTime.now()),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Coming Soon Placeholder
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF3B82F6).withValues(alpha: 0.15),
                            const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Today's Focus",
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "AI Planning & Focus Sessions coming soon. Prepare for a smarter workflow.",
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: AnimatedFilterChips(
              activeFilter: state.activeFilter,
              onFilterChanged: (filter) {
                ref.read(tasksProvider.notifier).setFilter(filter);
              },
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          
          if (state.isLoading && state.allTasks.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.filteredTasks.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'No tasks found.',
                  style: GoogleFonts.outfit(color: Colors.white54),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final task = state.filteredTasks[index];
                  return TaskCard(
                    task: task,
                    onToggleComplete: (val) {
                      final updated = task.copyWith(completed: val ?? true);
                      ref.read(tasksProvider.notifier).updateTask(updated);
                    },
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => TaskBottomSheet(existingTask: task),
                      );
                    },
                  );
                },
                childCount: state.filteredTasks.length,
              ),
            ),
            
          const SliverToBoxAdapter(child: SizedBox(height: 80)), // Padding for FAB
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const TaskBottomSheet(),
          );
        },
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
