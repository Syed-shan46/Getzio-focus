import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/smart_object_models.dart';
import '../../domain/models/vision_item.dart';

// -----------------------------------------------------------------------------
// PLAN CARD WIDGET
// -----------------------------------------------------------------------------
class PlanCardWidget extends StatelessWidget {
  final VisionItem item;
  const PlanCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final metadata = item.metadata ?? {};
    final title = item.content.isNotEmpty ? item.content : (metadata['title'] as String? ?? 'Project Roadmap');
    final milestones = item.smartMilestones;

    return FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: 320,
        height: 240,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.zero,
            border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 8))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_tree_rounded, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleLarge(color: Colors.black87),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.smartProgressPercent}%',
                      style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1, color: Colors.black12),
              Expanded(
                child: milestones.isEmpty
                    ? const Center(
                        child: Text(
                          'Tap to add milestones & tasks',
                          style: TextStyle(color: Colors.black38, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: milestones.take(4).length,
                        itemBuilder: (context, index) {
                          final m = milestones[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  m.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                  color: m.isCompleted ? Colors.green : Colors.black26,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    m.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodyMedium(color: m.isCompleted ? Colors.black45 : Colors.black87)
                                        .copyWith(decoration: m.isCompleted ? TextDecoration.lineThrough : null),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TASK CARD WIDGET
// -----------------------------------------------------------------------------
class TaskCardWidget extends StatelessWidget {
  final VisionItem item;
  const TaskCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final metadata = item.metadata ?? {};
    final title = item.content.isNotEmpty ? item.content : (metadata['title'] as String? ?? 'Dynamic Task');
    final priority = metadata['priority'] as String? ?? 'High';
    final isDone = item.smartProgress >= 1.0;
    
    Color pColor = priority == 'High' ? Colors.redAccent : Colors.orangeAccent;

    return FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: 260,
        height: 130,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.zero,
            border: Border.all(color: isDone ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: pColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(priority, style: AppTypography.caption(color: pColor).copyWith(fontWeight: FontWeight.bold)),
                  ),
                  Text(
                    '${item.smartProgressPercent}%',
                    style: TextStyle(
                      color: isDone ? Colors.greenAccent : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: isDone ? Colors.greenAccent : Colors.white54,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.titleMedium(color: Colors.white).copyWith(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// FINANCE CARD WIDGET
// -----------------------------------------------------------------------------
class FinanceCardWidget extends StatelessWidget {
  final VisionItem item;
  const FinanceCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final metadata = item.metadata ?? {};
    final title = item.content.isNotEmpty ? item.content : (metadata['title'] as String? ?? 'Finance Goal');
    final current = (metadata['currentAmount'] as num?)?.toDouble() ?? 0.0;
    final target = (metadata['targetAmount'] as num?)?.toDouble() ?? 1000.0;
    final progressRatio = item.smartProgress;
    final progressPercent = item.smartProgressPercent;

    return FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: 280,
        height: 160,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.zero,
            border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(color: Colors.tealAccent.withValues(alpha: 0.1), blurRadius: 20)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium(color: Colors.tealAccent),
                    ),
                  ),
                  const Icon(Icons.savings_rounded, color: Colors.tealAccent),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '\$${current.toStringAsFixed(0)} / \$${target.toStringAsFixed(0)}',
                style: AppTypography.displayMedium(color: Colors.white).copyWith(fontSize: 22),
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressRatio,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.tealAccent),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 6),
              Text('$progressPercent% Reached', style: AppTypography.caption(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// COUNTDOWN CARD WIDGET
// -----------------------------------------------------------------------------
class CountdownCardWidget extends StatelessWidget {
  final VisionItem item;
  const CountdownCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final metadata = item.metadata ?? {};
    final title = item.content.isNotEmpty ? item.content : (metadata['title'] as String? ?? 'Target Countdown');
    final targetDate = item.countdownDate ?? DateTime.now().add(const Duration(days: 30));
    final remainingDays = targetDate.difference(DateTime.now()).inDays.clamp(0, 9999);

    return FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: 220,
        height: 220,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.zero,
            boxShadow: [
              BoxShadow(color: const Color(0xFFDD2476).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_rounded, color: Colors.white, size: 36),
              const SizedBox(height: 12),
              Text(
                '$remainingDays',
                style: AppTypography.displayLarge(color: Colors.white).copyWith(fontSize: 48),
              ),
              Text(
                'DAYS REMAINING',
                style: AppTypography.caption(color: Colors.white).copyWith(fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleMedium(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
