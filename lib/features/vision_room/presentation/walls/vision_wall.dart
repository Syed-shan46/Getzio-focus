import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import '../../domain/models/vision_item.dart';
import '../../domain/models/vision_customization.dart';
import '../providers/canvas_providers.dart';
import '../providers/customization_provider.dart';
import '../providers/vision_room_providers.dart';
import '../widgets/attachment_widgets.dart';
import '../widgets/quote_card_widget.dart';
import '../widgets/goal_card_widget.dart';
import '../widgets/premium_cards.dart'
    show PlanCardWidget, TaskCardWidget, FinanceCardWidget, CountdownCardWidget;
import '../widgets/roadmap_bottom_sheet.dart';
import '../../../../core/theme/app_theme.dart';

class VisionWall extends ConsumerStatefulWidget {
  const VisionWall({super.key});

  @override
  ConsumerState<VisionWall> createState() => _VisionWallState();
}

class _VisionWallState extends ConsumerState<VisionWall>
    with TickerProviderStateMixin {
  String? _interactingItemId;
  double _itemStartWidth = 0;
  double _itemStartHeight = 0;
  double _itemStartRotation = 0;

  late AnimationController _springController;
  late Animation<double> _springAnimation;
  String? _springItemId;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _springAnimation = _springController.drive(
      Tween<double>(
        begin: 0,
        end: 1,
      ).chain(CurveTween(curve: Curves.elasticOut)),
    );
    _springController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _springItemId = null);
      }
    });
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  Offset _toCanvasCoordinates(Offset screenPoint, Matrix4 transform) {
    final inverse = Matrix4.copy(transform);
    if (inverse.invert() == 0.0) return screenPoint;
    final vector = Vector3(screenPoint.dx, screenPoint.dy, 0);
    final result = inverse.transform3(vector);
    return Offset(result.x, result.y);
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasStateProvider);
    final items = canvasState.items;
    final cust = ref.watch(visionCustomizationProvider);
    final isEditMode = ref.watch(editModeProvider);
    final selectedIds = canvasState.selectedIds;

    return Stack(
      children: [
        // Items Layer
        Positioned.fill(
          child: GestureDetector(
            behavior: isEditMode
                ? HitTestBehavior.opaque
                : HitTestBehavior.deferToChild,
            onTap: () {
              if (isEditMode) {
                ref.read(canvasStateProvider.notifier).clearSelection();
              }
            },
            onScaleStart: isEditMode
                ? (details) {
                    final canvasPoint = _toCanvasCoordinates(
                      details.localFocalPoint,
                      Matrix4.identity(),
                    );
                    _interactingItemId = null;
                    for (var item in items.reversed) {
                      final rect = Rect.fromLTWH(
                        item.x,
                        item.y,
                        item.width,
                        item.height,
                      );
                      if (rect.contains(canvasPoint)) {
                        _interactingItemId = item.id;
                        _itemStartWidth = item.width;
                        _itemStartHeight = item.height;
                        _itemStartRotation = item.rotation;
                        ref
                            .read(canvasStateProvider.notifier)
                            .selectItem(item.id);
                        HapticFeedback.selectionClick();
                        break;
                      }
                    }
                  }
                : null,
            onScaleUpdate: isEditMode
                ? (details) {
                    if (_interactingItemId != null) {
                      final dx = details.focalPointDelta.dx;
                      final dy = details.focalPointDelta.dy;
                      ref
                          .read(canvasStateProvider.notifier)
                          .updatePosition(_interactingItemId!, dx, dy);
                      ref
                          .read(canvasStateProvider.notifier)
                          .commitTransform(
                            _interactingItemId!,
                            _itemStartWidth * details.scale,
                            _itemStartHeight * details.scale,
                            _itemStartRotation + details.rotation,
                          );
                    }
                  }
                : null,
            onScaleEnd: isEditMode
                ? (details) {
                    if (_interactingItemId != null) {
                      final item = items.firstWhere(
                        (i) => i.id == _interactingItemId,
                      );
                      ref
                          .read(canvasStateProvider.notifier)
                          .commitTransform(
                            item.id,
                            item.width,
                            item.height,
                            item.rotation,
                          );
                      HapticFeedback.lightImpact();
                      _springItemId = _interactingItemId;
                      _springController.reset();
                      _springController.forward();
                      setState(() => _interactingItemId = null);
                    }
                  }
                : null,
            child: Stack(
              children: items.map((item) {
                final isSelected = selectedIds.contains(item.id);
                final isInteracting = _interactingItemId == item.id;
                final springValue = _springItemId == item.id
                    ? _springAnimation.value
                    : 0.0;

                return Positioned(
                  left: item.x,
                  top: item.y,
                  child: _VisionItemWidget(
                    item: item,
                    isSelected: isSelected,
                    isInteracting: isInteracting,
                    isEditMode: isEditMode,
                    boardStyle: cust.boardStyle,
                    springValue: springValue,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── VISION ITEM WIDGET (supports both viewing and edit modes) ─────────────

class _VisionItemWidget extends ConsumerStatefulWidget {
  final VisionItem item;
  final bool isSelected;
  final bool isInteracting;
  final bool isEditMode;
  final VisionBoardStyle boardStyle;
  final double springValue;

  const _VisionItemWidget({
    required this.item,
    this.isSelected = false,
    this.isInteracting = false,
    this.isEditMode = false,
    this.boardStyle = VisionBoardStyle.classicCork,
    this.springValue = 0.0,
  });

  @override
  ConsumerState<_VisionItemWidget> createState() => _VisionItemWidgetState();
}

class _VisionItemWidgetState extends ConsumerState<_VisionItemWidget> {
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
  void didUpdateWidget(covariant _VisionItemWidget oldWidget) {
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
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final cust = ref.watch(visionCustomizationProvider);
    final cardCfg = cust.cardCustomization;
    Widget contentWidget;

    final double baseShadow = cardCfg.shadowIntensity * 30;
    final double shadowBlur = widget.isInteracting
        ? baseShadow * 1.5
        : baseShadow;
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
            borderRadius: BorderRadius.circular(
              cardCfg.glassMode ? cr : cr.clamp(4, 20),
            ),
            border:
                selectionBorder ??
                Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: bt,
                ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.5 * cardCfg.shadowIntensity,
                ),
                blurRadius: shadowBlur,
                offset: shadowOffset,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              cardCfg.roundedMode ? cr : cr.clamp(4, 20),
            ),
            child: Image.file(
              File(item.content),
              width: item.width,
              height: item.height,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[800],
                child: const Center(
                  child: Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white54,
                    size: 40,
                  ),
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
        width: item.width,
        height: item.height,
        padding: const EdgeInsets.all(16),
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
          border:
              selectionBorder ??
              (bt > 0
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: bt,
                    )
                  : null),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.4 * cardCfg.shadowIntensity,
              ),
              blurRadius: shadowBlur,
              offset: shadowOffset,
            ),
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
                    fontSize: (item.metadata?['fontSize'] as num?)?.toDouble() ?? 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (_) => _commitText(),
                )
              : Text(
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
    } else if (item.type == VisionItemType.quote.name) {
      contentWidget = SizedBox(
        width: item.width,
        height: item.height,
        child: QuoteCardWidget(item: item),
      );
    } else if (item.type == VisionItemType.goal.name) {
      contentWidget = SizedBox(
        width: item.width,
        height: item.height,
        child: GoalCardWidget(item: item),
      );
    } else if (item.type == VisionItemType.plan.name) {
      contentWidget = SizedBox(
        width: item.width,
        height: item.height,
        child: PlanCardWidget(item: item),
      );
    } else if (item.type == VisionItemType.task.name) {
      contentWidget = SizedBox(
        width: item.width,
        height: item.height,
        child: TaskCardWidget(item: item),
      );
    } else if (item.type == VisionItemType.financeGoal.name) {
      contentWidget = SizedBox(
        width: item.width,
        height: item.height,
        child: FinanceCardWidget(item: item),
      );
    } else if (item.type == VisionItemType.countdown.name) {
      contentWidget = SizedBox(
        width: item.width,
        height: item.height,
        child: CountdownCardWidget(item: item),
      );
    } else {
      contentWidget = Container(
        width: item.width,
        height: item.height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(item.colorValue).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(cr),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
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
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (_) => _commitText(),
                )
              : Text(
                  item.content,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
        ),
      );
    }

    final boardAdjustedWidget =
        widget.boardStyle == VisionBoardStyle.floatingGallery
        ? ClipRRect(
            borderRadius: BorderRadius.circular(cr),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: contentWidget,
            ),
          )
        : contentWidget;

    // Selection glow overlay (edit mode only)
    final selectionGlow = widget.isSelected && widget.isEditMode
        ? Positioned(
            left: -6,
            top: -6,
            child: IgnorePointer(
              child: Container(
                width: item.width + 12,
                height: item.height + 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentBlue.withValues(alpha: 0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentBlue.withValues(alpha: 0.25),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          )
        : const SizedBox.shrink();

    return AnimatedScale(
      scale: 1.0 + (widget.springValue * 0.03),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTap: () {
          if (widget.isEditMode) {
            ref.read(canvasStateProvider.notifier).selectItem(item.id);
            HapticFeedback.selectionClick();
          } else {
            // Viewing mode: tap goals/plans/tasks to open roadmap
            if (item.type == VisionItemType.goal.name ||
                item.type == VisionItemType.plan.name ||
                item.type == VisionItemType.task.name) {
              RoadmapBottomSheet.show(context, item: item);
            }
          }
        },
        onDoubleTap: () {
          if (widget.isEditMode && item.type != VisionItemType.image.name) {
            setState(() => _isEditing = true);
            _focusNode.requestFocus();
          }
        },
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
              selectionGlow,
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
        ),
      ),
    );
  }
}

// ─── BOARD BACKGROUND ─────────────────────────────────────────────────────

class _BoardBackground extends StatelessWidget {
  final VisionBoardStyle style;

  const _BoardBackground({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _boardBoxDecor(style),
      child: CustomPaint(painter: _BoardBgPainter(style), size: Size.infinite),
    );
  }

  BoxDecoration _boardBoxDecor(VisionBoardStyle style) {
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
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
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

class _BoardBgPainter extends CustomPainter {
  final VisionBoardStyle style;

  _BoardBgPainter(this.style);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;

    switch (style) {
      case VisionBoardStyle.classicCork:
        paint.color = const Color(0xFFB8865E).withValues(alpha: 0.3);
        for (double y = 0; y < size.height; y += 4) {
          for (double x = 0; x < size.width; x += 4) {
            canvas.drawCircle(Offset(x, y), 0.5, paint);
          }
        }
        paint.color = const Color(0xFF3E1F0D).withValues(alpha: 0.6);
        paint.strokeWidth = 6;
        canvas.drawRect(
          Rect.fromLTWH(3, 3, size.width - 6, size.height - 6),
          paint,
        );
        paint.strokeWidth = 2;
        paint.color = const Color(0xFF5C3A1E).withValues(alpha: 0.4);
        canvas.drawRect(
          Rect.fromLTWH(6, 6, size.width - 12, size.height - 12),
          paint,
        );
        break;

      case VisionBoardStyle.glassInspiration:
        paint.color = Colors.white.withValues(alpha: 0.06);
        paint.strokeWidth = 0.5;
        for (double x = 0; x < size.width; x += 40) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
        for (double y = 0; y < size.height; y += 40) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        final shine = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.08),
              Colors.transparent,
              Colors.white.withValues(alpha: 0.04),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), shine);
        break;

      case VisionBoardStyle.walnutWooden:
        paint.color = const Color(0xFF8B6914).withValues(alpha: 0.15);
        for (double y = 0; y < size.height; y += 8) {
          double x = 0;
          while (x < size.width) {
            final wave = sin((x + y) * 0.03) * 3;
            canvas.drawCircle(Offset(x, y + wave), 1, paint);
            x += 3;
          }
        }
        final warmGlow = Paint()
          ..shader = RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [
              const Color(0xFFFFD699).withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), warmGlow);
        break;

      case VisionBoardStyle.magneticMetal:
        paint.color = Colors.grey.withValues(alpha: 0.08);
        paint.strokeWidth = 1;
        for (double x = 0; x < size.width; x += 80) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
        final metal = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.06),
              Colors.transparent,
              Colors.white.withValues(alpha: 0.03),
            ],
            stops: const [0.0, 0.3, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), metal);
        final screwPaint = Paint()
          ..color = Colors.grey.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(20, 20), 6, screwPaint);
        canvas.drawCircle(Offset(size.width - 20, 20), 6, screwPaint);
        canvas.drawCircle(Offset(20, size.height - 20), 6, screwPaint);
        canvas.drawCircle(
          Offset(size.width - 20, size.height - 20),
          6,
          screwPaint,
        );
        break;

      case VisionBoardStyle.canvasWall:
        paint.color = const Color(0xFFD4C9B8).withValues(alpha: 0.15);
        for (double y = 0; y < size.height; y += 3) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        final pinPaint = Paint()
          ..color = const Color(0xFF8B7355).withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(size.width / 2, 15), 4, pinPaint);
        break;

      case VisionBoardStyle.floatingGallery:
        paint.color = Colors.white.withValues(alpha: 0.03);
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(size.width * 0.8, size.height * 0.15),
          80,
          paint,
        );
        canvas.drawCircle(
          Offset(size.width * 0.2, size.height * 0.85),
          60,
          paint,
        );
        canvas.drawCircle(
          Offset(size.width * 0.7, size.height * 0.7),
          40,
          paint,
        );
        break;

      case VisionBoardStyle.scrapbook:
        paint.color = const Color(0xFFE8D5B7).withValues(alpha: 0.2);
        paint.style = PaintingStyle.fill;
        for (int i = 0; i < 6; i++) {
          final x = size.width * (0.08 + (i % 3) * 0.35 + sin(i * 1.5) * 0.05);
          final y = size.height * (0.08 + (i ~/ 3) * 0.4 + cos(i * 1.2) * 0.05);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(x, y),
                width: 60 + (i * 8).toDouble(),
                height: 40 + (i * 5).toDouble(),
              ),
              const Radius.circular(3),
            ),
            paint,
          );
        }
        paint.style = PaintingStyle.stroke;
        paint.color = const Color(0xFFD4C9B8).withValues(alpha: 0.15);
        for (int i = 0; i < 6; i++) {
          final x = size.width * (0.08 + (i % 3) * 0.35 + sin(i * 1.5) * 0.05);
          final y = size.height * (0.08 + (i ~/ 3) * 0.4 + cos(i * 1.2) * 0.05);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(x, y),
                width: 60 + (i * 8).toDouble(),
                height: 40 + (i * 5).toDouble(),
              ),
              const Radius.circular(3),
            ),
            paint,
          );
        }
        break;

      case VisionBoardStyle.custom:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _BoardBgPainter oldDelegate) =>
      oldDelegate.style != style;
}

// ─── STATIC BOARD DECORATIONS PAINTER ─────────────────────────────────────

class _BoardDecorStaticPainter extends CustomPainter {
  final List<BoardDecoration> decorations;
  final VisionBoardStyle boardStyle;

  _BoardDecorStaticPainter({
    required this.decorations,
    required this.boardStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final decor in decorations) {
      switch (decor) {
        case BoardDecoration.stringLights:
          _drawStringLights(canvas, size);
        case BoardDecoration.miniPlants:
          _drawMiniPlants(canvas, size);
        case BoardDecoration.pushPins:
          _drawPushPins(canvas, size);
        case BoardDecoration.washiTape:
          _drawWashiTape(canvas, size);
        case BoardDecoration.ribbons:
          _drawRibbons(canvas, size);
        case BoardDecoration.pressedFlowers:
          _drawPressedFlowers(canvas, size);
        case BoardDecoration.bookmarks:
          _drawBookmarks(canvas, size);
        case BoardDecoration.minimalShelves:
          _drawMinimalShelves(canvas, size);
        default:
          break;
      }
    }
  }

  void _drawStringLights(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.brown.withValues(alpha: 0.3);
    final path = Path();
    path.moveTo(0, size.height * 0.05);
    for (double x = 0; x <= size.width; x += 30) {
      final y = size.height * 0.05 + sin((x / size.width) * pi) * 8;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);

    final bulbPaint = Paint()..style = PaintingStyle.fill;
    for (double x = 0; x <= size.width; x += 60) {
      final y = size.height * 0.05 + sin((x / size.width) * pi) * 8;
      bulbPaint.color = const Color(0xFFFFD700).withValues(alpha: 0.3);
      canvas.drawCircle(Offset(x, y + 5), 4, bulbPaint);
    }
  }

  void _drawMiniPlants(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF2D6A4F).withValues(alpha: 0.25);

    for (final pos in [
      Offset(size.width * 0.05, size.height * 0.6),
      Offset(size.width * 0.95, size.height * 0.55),
    ]) {
      paint.color = const Color(0xFF8B6914).withValues(alpha: 0.2);
      final potPath = Path()
        ..moveTo(pos.dx - 8, pos.dy)
        ..lineTo(pos.dx - 6, pos.dy + 12)
        ..lineTo(pos.dx + 6, pos.dy + 12)
        ..lineTo(pos.dx + 8, pos.dy)
        ..close();
      canvas.drawPath(potPath, paint);

      paint.color = const Color(0xFF2D6A4F).withValues(alpha: 0.25);
      for (int i = 0; i < 3; i++) {
        final angle = pi / 4 + i * pi / 3;
        canvas.drawOval(
          Rect.fromPoints(
            Offset(pos.dx - 1, pos.dy - 2),
            Offset(pos.dx + cos(angle) * 12, pos.dy - 8 + sin(angle.abs()) * 8),
          ),
          paint,
        );
      }
    }
  }

  void _drawPushPins(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    for (final pos in [
      Offset(size.width * 0.15, size.height * 0.1),
      Offset(size.width * 0.85, size.height * 0.12),
      Offset(size.width * 0.12, size.height * 0.45),
      Offset(size.width * 0.88, size.height * 0.5),
    ]) {
      canvas.drawCircle(pos, 4, paint);
      paint.color = Colors.grey.withValues(alpha: 0.1);
      canvas.drawLine(pos, Offset(pos.dx, pos.dy + 10), paint..strokeWidth = 1);
      paint.color = Colors.red.withValues(alpha: 0.15);
    }
  }

  void _drawWashiTape(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final rect in [
      Rect.fromLTWH(size.width * 0.05, size.height * 0.05, 40, 14),
      Rect.fromLTWH(size.width * 0.88, size.height * 0.08, 40, 14),
      Rect.fromLTWH(size.width * 0.06, size.height * 0.5, 40, 14),
    ]) {
      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(-0.15);
      paint.color = Colors.pink.withValues(alpha: 0.08);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: rect.width,
            height: rect.height,
          ),
          const Radius.circular(1),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  void _drawRibbons(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFF6B6B).withValues(alpha: 0.08);
    final path = Path()
      ..moveTo(size.width - 20, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 20)
      ..close();
    canvas.drawPath(path, paint);
    paint.color = const Color(0xFF4DA3FF).withValues(alpha: 0.08);
    final path2 = Path()
      ..moveTo(0, size.height - 20)
      ..lineTo(0, size.height)
      ..lineTo(20, size.height)
      ..close();
    canvas.drawPath(path2, paint);
  }

  void _drawPressedFlowers(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final pos in [
      Offset(size.width * 0.25, size.height * 0.15),
      Offset(size.width * 0.72, size.height * 0.18),
    ]) {
      paint.color = const Color(0xFFFFB7C5).withValues(alpha: 0.12);
      for (int i = 0; i < 5; i++) {
        final angle = i * (2 * pi / 5);
        canvas.drawCircle(
          Offset(pos.dx + cos(angle) * 4, pos.dy + sin(angle) * 4),
          3,
          paint,
        );
      }
      paint.color = const Color(0xFFFFD700).withValues(alpha: 0.1);
      canvas.drawCircle(pos, 2, paint);
    }
  }

  void _drawBookmarks(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final bookmarkData = [
      Offset(size.width * 0.92, size.height * 0.25),
      Offset(size.width * 0.08, size.height * 0.72),
    ];
    final colors = [
      const Color(0xFFE74C3C).withValues(alpha: 0.1),
      const Color(0xFF3498DB).withValues(alpha: 0.1),
    ];
    for (int i = 0; i < bookmarkData.length; i++) {
      paint.color = colors[i];
      final pos = bookmarkData[i];
      final rect = Rect.fromCenter(center: pos, width: 8, height: 30);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        paint,
      );
      final vPath = Path()
        ..moveTo(pos.dx - 4, pos.dy + 15)
        ..lineTo(pos.dx, pos.dy + 20)
        ..lineTo(pos.dx + 4, pos.dy + 15)
        ..close();
      canvas.drawPath(vPath, paint);
    }
  }

  void _drawMinimalShelves(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B7355).withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.02,
        size.height * 0.25,
        size.width * 0.25,
        3,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.73, size.height * 0.6, size.width * 0.25, 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BoardDecorStaticPainter oldDelegate) =>
      oldDelegate.decorations != decorations ||
      oldDelegate.boardStyle != boardStyle;
}
