import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/vision_item.dart';
import '../../../domain/models/vision_customization.dart';
import '../../providers/canvas_providers.dart';
import '../../providers/customization_provider.dart';
import '../../widgets/attachment_widgets.dart';
import '../../widgets/quote_card_widget.dart';
import '../../widgets/goal_card_widget.dart';
import '../../widgets/premium_cards.dart'
    show PlanCardWidget, TaskCardWidget, FinanceCardWidget, CountdownCardWidget;
import '../../../../../core/theme/app_theme.dart';

class _ShapePainter extends CustomPainter {
  final String shape;
  final Color color;
  final double opacity;

  _ShapePainter({
    required this.shape,
    required this.color,
    this.opacity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.5;
    final borderPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(size.width, size.height) / 2 - 8;

    switch (shape) {
      case 'circle':
        canvas.drawCircle(Offset(cx, cy), r, paint);
        canvas.drawCircle(Offset(cx, cy), r, borderPaint);
      case 'square':
        final rect = Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), paint);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), borderPaint);
      case 'triangle':
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx - r * 0.866, cy + r * 0.5)
          ..lineTo(cx + r * 0.866, cy + r * 0.5)
          ..close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
      case 'star':
        final path = Path();
        for (var i = 0; i < 10; i++) {
          final angle = -pi / 2 + i * pi / 5;
          final radius = i.isEven ? r : r * 0.4;
          final pt = Offset(cx + radius * cos(angle), cy + radius * sin(angle));
          if (i == 0) { path.moveTo(pt.dx, pt.dy); } else { path.lineTo(pt.dx, pt.dy); }
        }
        path.close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
      case 'diamond':
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r, cy)
          ..lineTo(cx, cy + r)
          ..lineTo(cx - r, cy)
          ..close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
      case 'hexagon':
        final path = Path();
        for (var i = 0; i < 6; i++) {
          final angle = -pi / 2 + i * pi / 3;
          final pt = Offset(cx + r * cos(angle), cy + r * sin(angle));
          if (i == 0) { path.moveTo(pt.dx, pt.dy); } else { path.lineTo(pt.dx, pt.dy); }
        }
        path.close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
      case 'heart':
        final path = Path();
        path.moveTo(cx, cy + r * 0.3);
        path.cubicTo(cx - r * 1.2, cy - r * 0.4, cx - r * 0.3, cy - r * 0.9, cx, cy - r * 0.2);
        path.cubicTo(cx + r * 0.3, cy - r * 0.9, cx + r * 1.2, cy - r * 0.4, cx, cy + r * 0.3);
        path.close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) =>
      oldDelegate.shape != shape || oldDelegate.color != color || oldDelegate.opacity != opacity;
}

class CanvasItemWidget extends ConsumerStatefulWidget {
  final VisionItem item;
  final bool isSelected;
  final bool isInteracting;
  final VisionBoardStyle boardStyle;
  final double springValue;
  final VoidCallback? onViewRoadmap;

  const CanvasItemWidget({
    super.key,
    required this.item,
    this.isSelected = false,
    this.isInteracting = false,
    this.boardStyle = VisionBoardStyle.classicCork,
    this.springValue = 0.0,
    this.onViewRoadmap,
  });

  @override
  ConsumerState<CanvasItemWidget> createState() => _CanvasItemWidgetState();
}

class _CanvasItemWidgetState extends ConsumerState<CanvasItemWidget> {
  bool _isEditing = false;
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.item.content);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _commitText();
      }
    });
  }

  @override
  void didUpdateWidget(covariant CanvasItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing && oldWidget.item.content != widget.item.content) {
      _textController.text = widget.item.content;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _commitText() {
    if (_textController.text.trim().isNotEmpty) {
      ref
          .read(canvasStateProvider.notifier)
          .updateContent(widget.item.id, _textController.text);
    } else {
      _textController.text = widget.item.content;
    }
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final cust = ref.watch(visionCustomizationProvider);
    final cardCfg = cust.cardCustomization;
    Widget contentWidget;

    final double baseShadow = cardCfg.shadowIntensity * 30;
    final double shadowBlur =
        widget.isInteracting ? baseShadow * 1.5 : baseShadow;
    final Offset shadowOffset = widget.isInteracting
        ? const Offset(0, 15)
        : Offset(0, 8 * cardCfg.shadowIntensity);

    final Border? selectionBorder = widget.isSelected
        ? Border.all(color: AppColors.accentBlue, width: 3)
        : null;

    final double cr = cardCfg.cornerRadius;
    final double bt = cardCfg.borderThickness;

    if (item.type == VisionItemType.image.name) {
      contentWidget = Opacity(
        opacity: cardCfg.opacity,
        child: Container(
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(cardCfg.glassMode ? cr : cr.clamp(4, 20)),
            border: selectionBorder ??
                Border.all(
                    color: Colors.white.withValues(alpha: 0.3), width: bt),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(
                      alpha: 0.5 * cardCfg.shadowIntensity),
                  blurRadius: shadowBlur,
                  offset: shadowOffset)
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
                cardCfg.roundedMode ? cr : cr.clamp(4, 20)),
            child: item.content.startsWith('http')
                ? Image.network(
                    item.content,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.broken_image_rounded,
                            color: Colors.white54, size: 40),
                      ),
                    ),
                  )
                : Image.file(
                    File(item.content),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.broken_image_rounded,
                            color: Colors.white54, size: 40),
                      ),
                    ),
                  ),
          ),
        ),
      );
    } else if (item.type == VisionItemType.stickyNote.name) {
      final Color noteColor = cardCfg.glassMode
          ? Colors.white.withValues(alpha: 0.15)
          : Color(item.colorValue).withValues(alpha: cardCfg.opacity);
      contentWidget = Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: noteColor,
          borderRadius: cardCfg.squareMode
              ? BorderRadius.zero
              : BorderRadius.only(
                  topLeft: Radius.circular(cardCfg.roundedMode ? cr : 2),
                  topRight: Radius.circular(cardCfg.roundedMode ? cr : 2),
                  bottomLeft: Radius.circular(cardCfg.roundedMode ? cr : 2),
                  bottomRight:
                      Radius.circular(cardCfg.roundedMode ? 24 : cr),
                ),
          border: selectionBorder ??
              (bt > 0
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.1), width: bt)
                  : null),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(
                    alpha: 0.4 * cardCfg.shadowIntensity),
                blurRadius: shadowBlur,
                offset: shadowOffset)
          ],
        ),
        child: Center(
          child: _isEditing
              ? TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: null,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: cardCfg.glassMode ? Colors.white : Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero),
                  onSubmitted: (_) => _commitText(),
                )
              : Text(
                  item.content,
                  style: TextStyle(
                      color: cardCfg.glassMode ? Colors.white : Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
        ),
      );
    } else if (item.type == VisionItemType.quote.name) {
      contentWidget = QuoteCardWidget(item: item);
    } else if (item.type == VisionItemType.goal.name) {
      contentWidget = GoalCardWidget(item: item);
    } else if (item.type == VisionItemType.plan.name) {
      contentWidget = PlanCardWidget(item: item);
    } else if (item.type == VisionItemType.task.name) {
      contentWidget = TaskCardWidget(item: item);
    } else if (item.type == VisionItemType.financeGoal.name) {
      contentWidget = FinanceCardWidget(item: item);
    } else if (item.type == VisionItemType.countdown.name) {
      contentWidget = CountdownCardWidget(item: item);
    } else if (item.type == VisionItemType.decoration.name &&
        item.content.startsWith('frame_')) {
      final frameColor = Color(item.colorValue);
      contentWidget = Container(
        decoration: BoxDecoration(
          color: cardCfg.glassMode
              ? Colors.white.withValues(alpha: 0.03)
              : frameColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: frameColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: frameColor.withValues(alpha: 0.15),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
      );
    } else if (item.type == VisionItemType.decoration.name &&
        ['circle','square','triangle','star','diamond','hexagon','heart']
            .contains(item.content.toLowerCase())) {
      final shapeColor = Color(item.colorValue);
      contentWidget = ClipRRect(
        borderRadius: BorderRadius.circular(cr),
        child: CustomPaint(
          painter: _ShapePainter(
            shape: item.content.toLowerCase(),
            color: shapeColor,
            opacity: cardCfg.opacity,
          ),
          child: const SizedBox.expand(),
        ),
      );
    } else {
      contentWidget = FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: 180,
          height: 180,
          child: Opacity(
            opacity: cardCfg.glassMode ? 0.85 : cardCfg.opacity,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardCfg.glassMode
                    ? Colors.white.withValues(alpha: 0.08)
                    : Color(item.colorValue)
                        .withValues(alpha: cardCfg.opacity),
                borderRadius: cardCfg.squareMode
                    ? BorderRadius.zero
                    : BorderRadius.circular(cr),
                border: selectionBorder ??
                    (bt > 0
                        ? Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: bt)
                        : null),
              ),
              child: Center(
                child: _isEditing
                    ? TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        maxLines: null,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero),
                        onSubmitted: (_) => _commitText(),
                      )
                    : Text(
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

    final boardAdjustedWidget = widget.boardStyle == VisionBoardStyle.floatingGallery
        ? ClipRRect(
            borderRadius: BorderRadius.circular(cr),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: contentWidget,
            ),
          )
        : contentWidget;

    return AnimatedScale(
      scale: 1.0 + (widget.springValue * 0.03),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onDoubleTap: () {
          if (item.type != VisionItemType.image.name) {
            setState(() {
              _isEditing = true;
            });
            _focusNode.requestFocus();
          }
        },
        child: Hero(
          tag: 'vision_item_${item.id}',
          child: Transform.rotate(
            angle: item.rotation + sin(widget.springValue * pi) * 0.06,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: item.width,
                  height: item.height,
                  child: boardAdjustedWidget,
                ),
                if (item.attachmentType == 'pin')
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutCubic,
                    top: (20 * (item.width / 200.0)) -
                        36 -
                        (widget.isInteracting
                            ? (10 * (item.width / 200.0))
                            : 0),
                    left: item.width / 2 - 12,
                    child: Transform.scale(
                      scale: item.width / 200.0,
                      alignment: Alignment.bottomCenter,
                      child: PushPinWidget(style: item.attachmentStyle),
                    ),
                  )
                else if (item.attachmentType == 'tape')
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutCubic,
                    top: -12 -
                        (widget.isInteracting
                            ? (5 * (item.width / 200.0))
                            : 0),
                    left: item.width / 2 - 40,
                    child: Transform.scale(
                      scale: item.width / 200.0,
                      alignment: Alignment.center,
                      child: TapeWidget(style: item.attachmentStyle),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
