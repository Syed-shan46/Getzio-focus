import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/vision_item.dart';
import '../../domain/models/vision_customization.dart';
import '../providers/canvas_providers.dart';
import '../providers/customization_provider.dart';
import 'attachment_widgets.dart';
import 'quote_card_widget.dart';
import 'goal_card_widget.dart';
import 'premium_cards.dart'
    show PlanCardWidget, TaskCardWidget, FinanceCardWidget, CountdownCardWidget;

class VisionBoardView extends ConsumerWidget {
  const VisionBoardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasStateProvider);
    final items = canvasState.items;
    final cust = ref.watch(visionCustomizationProvider);
    final cardCfg = cust.cardCustomization;

    return Stack(
      children: [
        Positioned.fill(
          child: _BoardBackground(style: cust.boardStyle),
        ),
        if (items.isEmpty)
          const Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb_outline_rounded,
                      color: Colors.white24, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Your Vision Board is empty',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the pen to start adding your dreams',
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ...items.map((item) {
          return Positioned(
            left: item.x,
            top: item.y,
            child: _ViewItemWidget(
              item: item,
              boardStyle: cust.boardStyle,
              cardCfg: cardCfg,
            ),
          );
        }),
      ],
    );
  }
}

class _BoardBackground extends StatelessWidget {
  final VisionBoardStyle style;
  const _BoardBackground({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _boxDecor(style),
    );
  }

  BoxDecoration _boxDecor(VisionBoardStyle style) {
    switch (style) {
      case VisionBoardStyle.classicCork:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD4A574), Color(0xFFC4956A), Color(0xFFB8865E)],
          ),
        );
      case VisionBoardStyle.glassInspiration:
        return BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        );
      case VisionBoardStyle.walnutWooden:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6B3A2A), Color(0xFF5C3020), Color(0xFF4A2618)],
          ),
        );
      case VisionBoardStyle.magneticMetal:
        return BoxDecoration(
          color: const Color(0xFF2A2A2E),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1),
        );
      case VisionBoardStyle.canvasWall:
        return const BoxDecoration(color: Color(0xFFF5F0E8));
      case VisionBoardStyle.floatingGallery:
        return BoxDecoration(color: Colors.black.withValues(alpha: 0.3));
      case VisionBoardStyle.scrapbook:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDF6E3), Color(0xFFF5E6CC)],
          ),
        );
      case VisionBoardStyle.custom:
        return BoxDecoration(color: Colors.white.withValues(alpha: 0.04));
    }
  }
}

class _ViewItemWidget extends StatelessWidget {
  final VisionItem item;
  final VisionBoardStyle boardStyle;
  final CardCustomization cardCfg;

  const _ViewItemWidget({
    required this.item,
    required this.boardStyle,
    required this.cardCfg,
  });

  @override
  Widget build(BuildContext context) {
    final Widget contentWidget = _buildContent();
    final double cr = cardCfg.cornerRadius;

    final boardAdjusted = boardStyle == VisionBoardStyle.floatingGallery
        ? ClipRRect(
            borderRadius: BorderRadius.circular(cr),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: contentWidget,
            ),
          )
        : contentWidget;

    return Transform.rotate(
      angle: item.rotation,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: item.width,
            height: item.height,
            child: boardAdjusted,
          ),
          if (item.attachmentType == 'pin')
            Positioned(
              top: (20 * (item.width / 200.0)) - 36,
              left: item.width / 2 - 12,
              child: Transform.scale(
                scale: item.width / 200.0,
                alignment: Alignment.bottomCenter,
                child: PushPinWidget(style: item.attachmentStyle),
              ),
            )
          else if (item.attachmentType == 'tape')
            Positioned(
              top: -12,
              left: item.width / 2 - 40,
              child: Transform.scale(
                scale: item.width / 200.0,
                alignment: Alignment.center,
                child: TapeWidget(style: item.attachmentStyle),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final double cr = cardCfg.cornerRadius;
    if (item.type == VisionItemType.image.name) {
      return Opacity(
        opacity: cardCfg.opacity,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cardCfg.glassMode ? cr : cr.clamp(4, 20)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: cardCfg.borderThickness),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5 * cardCfg.shadowIntensity),
                blurRadius: cardCfg.shadowIntensity * 30,
                offset: Offset(0, 8 * cardCfg.shadowIntensity),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(cardCfg.roundedMode ? cr : cr.clamp(4, 20)),
            child: Image.file(
              File(item.content),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[800],
                child: const Center(
                  child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 40),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (item.type == VisionItemType.stickyNote.name) {
      final Color noteColor = cardCfg.glassMode
          ? Colors.white.withValues(alpha: 0.15)
          : Color(item.colorValue).withValues(alpha: cardCfg.opacity);
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: noteColor,
          borderRadius: cardCfg.squareMode
              ? BorderRadius.zero
              : BorderRadius.only(
                  topLeft: Radius.circular(cardCfg.roundedMode ? cr : 2),
                  topRight: Radius.circular(cardCfg.roundedMode ? cr : 2),
                  bottomLeft: Radius.circular(cardCfg.roundedMode ? cr : 2),
                  bottomRight: Radius.circular(cardCfg.roundedMode ? 24 : cr),
                ),
          border: cardCfg.borderThickness > 0
              ? Border.all(color: Colors.white.withValues(alpha: 0.1), width: cardCfg.borderThickness)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4 * cardCfg.shadowIntensity),
              blurRadius: cardCfg.shadowIntensity * 30,
              offset: Offset(0, 8 * cardCfg.shadowIntensity),
            ),
          ],
        ),
        child: Center(
          child: Text(
            item.content,
            style: TextStyle(
              color: cardCfg.glassMode ? Colors.white : Colors.black87,
              fontSize: (item.metadata?['fontSize'] as num?)?.toDouble() ?? 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (item.type == VisionItemType.quote.name) {
      return _wrapCard(QuoteCardWidget(item: item));
    }
    if (item.type == VisionItemType.goal.name) {
      return _wrapCard(GoalCardWidget(item: item));
    }
    if (item.type == VisionItemType.plan.name) {
      return _wrapCard(PlanCardWidget(item: item));
    }
    if (item.type == VisionItemType.task.name) {
      return _wrapCard(TaskCardWidget(item: item));
    }
    if (item.type == VisionItemType.financeGoal.name) {
      return _wrapCard(FinanceCardWidget(item: item));
    }
    if (item.type == VisionItemType.countdown.name) {
      return _wrapCard(CountdownCardWidget(item: item));
    }

    return FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: 180,
        height: 180,
        child: Opacity(
          opacity: cardCfg.glassMode ? 0.85 : cardCfg.opacity,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardCfg.glassMode
                  ? Colors.white.withValues(alpha: 0.08)
                  : Color(item.colorValue).withValues(alpha: cardCfg.opacity),
              borderRadius: cardCfg.squareMode
                  ? BorderRadius.zero
                  : BorderRadius.circular(cardCfg.cornerRadius),
              border: cardCfg.borderThickness > 0
                  ? Border.all(color: Colors.white.withValues(alpha: 0.2), width: cardCfg.borderThickness)
                  : null,
            ),
            child: Center(
              child: Text(
                item.content,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wrapCard(Widget card) {
    return Opacity(
      opacity: cardCfg.opacity,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3 * cardCfg.shadowIntensity),
              blurRadius: cardCfg.shadowIntensity * 30,
              offset: Offset(0, 8 * cardCfg.shadowIntensity),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: card,
        ),
      ),
    );
  }
}
