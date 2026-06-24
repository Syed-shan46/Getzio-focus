import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
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
    final title = metadata['title'] as String? ?? 'Project Plan';
    final objectives = (metadata['objectives'] as List<dynamic>?)?.cast<String>() ?? ['Research', 'Design', 'Development', 'Launch'];
    
    return FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: 320,
        height: 240,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC), // Off-white premium paper
            borderRadius: BorderRadius.circular(16),
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
                  Text(
                    title,
                    style: AppTypography.titleLarge(color: Colors.black87),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1, color: Colors.black12),
              Expanded(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: objectives.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(index == 0 ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, 
                               color: index == 0 ? Colors.green : Colors.black26, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            objectives[index],
                            style: AppTypography.bodyMedium(color: index == 0 ? Colors.black45 : Colors.black87)
                                .copyWith(decoration: index == 0 ? TextDecoration.lineThrough : null),
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
    final title = metadata['title'] as String? ?? 'Important Task';
    final priority = metadata['priority'] as String? ?? 'High';
    
    Color pColor = priority == 'High' ? Colors.redAccent : Colors.orangeAccent;

    return FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: 250,
        height: 120,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                  const Icon(Icons.more_horiz_rounded, color: Colors.white54),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white54, width: 2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.titleMedium(color: Colors.white),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
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
    final title = metadata['title'] as String? ?? 'Savings Goal';
    final amount = metadata['amount'] as String? ?? '\$10,000';
    final progress = (metadata['progress'] as num?)?.toDouble() ?? 45.0;

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
            borderRadius: BorderRadius.circular(20),
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
                  Text(title, style: AppTypography.titleMedium(color: Colors.tealAccent)),
                  const Icon(Icons.savings_rounded, color: Colors.tealAccent),
                ],
              ),
              const SizedBox(height: 8),
              Text(amount, style: AppTypography.displayMedium(color: Colors.white)),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.tealAccent),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text('${progress.toInt()}% Reached', style: AppTypography.caption(color: Colors.white70)),
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
    final title = metadata['title'] as String? ?? 'Trip to Japan';
    final days = metadata['days'] as int? ?? 142;

    return FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: 220,
        height: 220,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFF512F), // Vibrant gradient
            gradient: const LinearGradient(
              colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: const Color(0xFFDD2476).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 40),
              const SizedBox(height: 16),
              Text(
                '$days',
                style: AppTypography.displayLarge(color: Colors.white).copyWith(fontSize: 48),
              ),
              Text(
                'DAYS LEFT',
                style: AppTypography.caption(color: Colors.white).copyWith(fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.titleMedium(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
