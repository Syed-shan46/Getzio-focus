import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/tasks_provider.dart';

class AnimatedFilterChips extends StatelessWidget {
  final TaskFilter activeFilter;
  final Function(TaskFilter) onFilterChanged;

  const AnimatedFilterChips({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'label': 'All', 'value': TaskFilter.all},
      {'label': 'Today', 'value': TaskFilter.today},
      {'label': 'Upcoming', 'value': TaskFilter.upcoming},
      {'label': 'High Priority', 'value': TaskFilter.highPriority},
      {'label': 'Completed', 'value': TaskFilter.completed},
      {'label': 'Overdue', 'value': TaskFilter.overdue},
      {'label': 'Pinned', 'value': TaskFilter.pinned},
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final label = filter['label'] as String;
          final value = filter['value'] as TaskFilter;
          final isActive = activeFilter == value;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onFilterChanged(value);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: isActive ? Colors.black : Colors.white70,
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
