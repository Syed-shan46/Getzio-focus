import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DueDateAndProgressSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final double currentProgress;
  final ValueChanged<DateTime?> onDateChanged;
  final ValueChanged<double> onProgressChanged;
  final Color accentColor;

  const DueDateAndProgressSelector({
    super.key,
    required this.selectedDate,
    required this.currentProgress,
    required this.onDateChanged,
    required this.onProgressChanged,
    this.accentColor = const Color(0xFF38BDF8),
  });

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate != null
        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
        : 'Select Due Date';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Due Date Picker Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_month_rounded,
                        color: accentColor, size: 16),
                    const SizedBox(width: 6),
                    const Flexible(
                      child: Text('DUE DATE',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: InkWell(
                  onTap: () async {
                    HapticFeedback.selectionClick();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      onDateChanged(picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      dateText,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Current Progress Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text('INITIAL PROGRESS',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8)),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${currentProgress.toInt()}%',
                  style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Draggable Beautiful Progress Bar & Slider
          Stack(
            alignment: Alignment.center,
            children: [
              // Glowing background track
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: accentColor,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
                  thumbColor: Colors.white,
                  overlayColor: accentColor.withValues(alpha: 0.3),
                  trackHeight: 6.0,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9.0),
                ),
                child: Slider(
                  value: currentProgress.clamp(0, 100),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (val) {
                    HapticFeedback.selectionClick();
                    onProgressChanged(val);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
