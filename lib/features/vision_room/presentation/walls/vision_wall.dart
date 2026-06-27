import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import '../../domain/models/vision_item.dart';
import '../../domain/models/vision_customization.dart';
import '../providers/canvas_providers.dart';
import '../providers/customization_provider.dart';
import '../widgets/attachment_widgets.dart';
import '../widgets/premium_creation_hub.dart';
import '../widgets/quote_builder_modal.dart';
import '../widgets/quote_card_widget.dart';
import '../widgets/goal_builder_modal.dart';
import '../widgets/goal_card_widget.dart';
import '../widgets/task_builder_modal.dart';
import '../widgets/plan_builder_modal.dart';
import '../widgets/finance_builder_modal.dart';
import '../widgets/countdown_builder_modal.dart';
import '../widgets/premium_cards.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/screens/phone_login_screen.dart';

class VisionWall extends ConsumerStatefulWidget {
  const VisionWall({super.key});

  @override
  ConsumerState<VisionWall> createState() => _VisionWallState();
}

class _VisionWallState extends ConsumerState<VisionWall>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  String? _interactingItemId;

  double _itemStartWidth = 0;
  double _itemStartHeight = 0;
  double _itemStartRotation = 0;

  late AnimationController _decorController;
  late AnimationController _springController;
  late Animation<double> _springAnimation;
  String? _springItemId;

  String _pinStyleString(PinStyle style) {
    return switch (style) {
      PinStyle.gold => 'gold',
      PinStyle.silver => 'silver',
      PinStyle.black => 'black',
      PinStyle.wood => 'gold',
      PinStyle.transparent => 'gold',
      PinStyle.modernMagnetic => 'silver',
      PinStyle.luxuryBrass => 'gold',
      PinStyle.colored => 'red',
    };
  }

  @override
  void initState() {
    super.initState();
    _decorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _springAnimation = _springController.drive(
      Tween<double>(begin: 0, end: 1).chain(
        CurveTween(curve: Curves.elasticOut),
      ),
    );
    _springController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _springItemId = null);
      }
    });
  }

  @override
  void dispose() {
    _decorController.dispose();
    _springController.dispose();
    super.dispose();
  }

  void _showPremiumAuthSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.fromBorderSide(
                  BorderSide(color: Colors.white10, width: 1.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Save Your Vision Forever',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Create a free account to unlock unlimited Vision Boards, securely back up your workspace and sync across all your devices.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PhoneLoginScreen()),
                      );
                    },
                    icon: const Icon(Icons.phone_android_rounded,
                        color: Colors.black, size: 24),
                    label: const Text(
                      'Continue with Phone',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Maybe Later',
                    style: TextStyle(
                        color: Colors.white30,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final isGuest = ref.read(authProvider).value == null;
    final items = ref.read(canvasStateProvider).items;
    final count =
        items.where((i) => i.type == VisionItemType.image.name).length;
    if (isGuest && count >= 5) {
      _showPremiumAuthSheet(context);
      return;
    }

    final size = MediaQuery.of(context).size;
    final transform = ref.read(canvasStateProvider).viewportTransform;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final screenCenter = Offset(size.width / 2, size.height / 2);
      final canvasCenter = _toCanvasCoordinates(screenCenter, transform);

      final random = Random();
      final newItem = VisionItem(
        id: const Uuid().v4(),
        type: VisionItemType.image.name,
        content: image.path,
        x: canvasCenter.dx - 125,
        y: canvasCenter.dy - 125,
        width: 250,
        height: 250,
        rotation: (random.nextDouble() - 0.5) * 0.2,
      );
      ref.read(canvasStateProvider.notifier).addItem(newItem);
    }
  }

  void _showAddStickyNoteDialog(BuildContext context) {
    final textController = TextEditingController();
    int selectedColorValue = 0xFFF59E0B;
    final List<int> stickyColors = [
      0xFFF59E0B,
      0xFFEC4899,
      0xFF3B82F6,
      0xFFA855F7,
      0xFF10B981,
      0xFFF8FAFC,
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F172A),
              title: const Text('New Sticky Note',
                  style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: textController,
                    autofocus: true,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type your note...',
                      hintStyle:
                          TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Color',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: stickyColors.map((colorValue) {
                      final isSelected = selectedColorValue == colorValue;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => selectedColorValue = colorValue),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(colorValue),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                    color: Color(colorValue)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 8)
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue),
                  onPressed: () {
                    final text = textController.text.trim();
                    if (text.isNotEmpty) {
                      final isGuest = ref.read(authProvider).value == null;
                      final items = ref.read(canvasStateProvider).items;
                      final count = items
                          .where((i) =>
                              i.type == VisionItemType.stickyNote.name)
                          .length;
                      if (isGuest && count >= 10) {
                        Navigator.pop(dialogContext);
                        _showPremiumAuthSheet(context);
                        return;
                      }
                      Navigator.pop(dialogContext);
                      _addStickyNote(text, selectedColorValue);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addStickyNote(String text, int colorValue) {
    final transform = ref.read(canvasStateProvider).viewportTransform;
    final size = MediaQuery.of(context).size;
    final screenCenter = Offset(size.width / 2, size.height / 2);
    final canvasCenter = _toCanvasCoordinates(screenCenter, transform);
    final cust = ref.read(visionCustomizationProvider);

    final random = Random();
    final newItem = VisionItem(
      id: const Uuid().v4(),
      type: VisionItemType.stickyNote.name,
      content: text,
      colorValue: colorValue,
      x: canvasCenter.dx - 90,
      y: canvasCenter.dy - 90,
      width: 180,
      height: 180,
      rotation: (random.nextDouble() - 0.5) * 0.3,
      attachmentType: 'pin',
      attachmentStyle: _pinStyleString(cust.defaultPinStyle),
    );
    ref.read(canvasStateProvider.notifier).addItem(newItem);
  }

  void _addQuote(Map<String, dynamic> metadata) {
    final isGuest = ref.read(authProvider).value == null;
    final items = ref.read(canvasStateProvider).items;
    final count =
        items.where((i) => i.type == VisionItemType.quote.name).length;
    if (isGuest && count >= 5) {
      _showPremiumAuthSheet(context);
      return;
    }

    final transform = ref.read(canvasStateProvider).viewportTransform;
    final size = MediaQuery.of(context).size;
    final screenCenter = Offset(size.width / 2, size.height / 2);
    final canvasCenter = _toCanvasCoordinates(screenCenter, transform);

    final random = Random();
    final newItem = VisionItem(
      id: const Uuid().v4(),
      type: VisionItemType.quote.name,
      content: metadata['quote'],
      secondaryContent: metadata['author'],
      metadata: metadata,
      x: canvasCenter.dx - 140,
      y: canvasCenter.dy - 80,
      width: 280,
      height: 160,
      rotation: (random.nextDouble() - 0.5) * 0.15,
      attachmentType: 'tape',
      attachmentStyle: 'beige',
    );
    ref.read(canvasStateProvider.notifier).addItem(newItem);
  }

  void _addGoal(Map<String, dynamic> metadata) {
    final transform = ref.read(canvasStateProvider).viewportTransform;
    final size = MediaQuery.of(context).size;
    final screenCenter = Offset(size.width / 2, size.height / 2);
    final canvasCenter = _toCanvasCoordinates(screenCenter, transform);

    final random = Random();
    final newItem = VisionItem(
      id: const Uuid().v4(),
      type: VisionItemType.goal.name,
      content: metadata['title'],
      metadata: metadata,
      x: canvasCenter.dx - 150,
      y: canvasCenter.dy - 100,
      width: 300,
      height: 200,
      rotation: (random.nextDouble() - 0.5) * 0.1,
      attachmentType: 'pin',
      attachmentStyle: 'bluePin',
    );
    ref.read(canvasStateProvider.notifier).addItem(newItem);
  }

  void _addPlan(Map<String, dynamic> metadata) {
    final transform = ref.read(canvasStateProvider).viewportTransform;
    final size = MediaQuery.of(context).size;
    final canvasCenter =
        _toCanvasCoordinates(Offset(size.width / 2, size.height / 2), transform);
    ref.read(canvasStateProvider.notifier).addItem(VisionItem(
      id: const Uuid().v4(),
      type: VisionItemType.plan.name,
      content: metadata['title'] ?? 'Plan',
      metadata: metadata,
      x: canvasCenter.dx - 160,
      y: canvasCenter.dy - 120,
      width: 320,
      height: 240,
      attachmentType: 'tape',
      attachmentStyle: 'blackTape',
    ));
  }

  void _addTask(Map<String, dynamic> metadata) {
    final transform = ref.read(canvasStateProvider).viewportTransform;
    final size = MediaQuery.of(context).size;
    final canvasCenter =
        _toCanvasCoordinates(Offset(size.width / 2, size.height / 2), transform);
    ref.read(canvasStateProvider.notifier).addItem(VisionItem(
      id: const Uuid().v4(),
      type: VisionItemType.task.name,
      content: metadata['title'] ?? 'Task',
      metadata: metadata,
      x: canvasCenter.dx - 125,
      y: canvasCenter.dy - 60,
      width: 250,
      height: 120,
    ));
  }

  void _addFinance(Map<String, dynamic> metadata) {
    final transform = ref.read(canvasStateProvider).viewportTransform;
    final size = MediaQuery.of(context).size;
    final canvasCenter =
        _toCanvasCoordinates(Offset(size.width / 2, size.height / 2), transform);
    ref.read(canvasStateProvider.notifier).addItem(VisionItem(
      id: const Uuid().v4(),
      type: VisionItemType.financeGoal.name,
      content: metadata['title'] ?? 'Finance',
      metadata: metadata,
      x: canvasCenter.dx - 140,
      y: canvasCenter.dy - 80,
      width: 280,
      height: 160,
    ));
  }

  void _addCountdown(Map<String, dynamic> metadata) {
    final transform = ref.read(canvasStateProvider).viewportTransform;
    final size = MediaQuery.of(context).size;
    final canvasCenter =
        _toCanvasCoordinates(Offset(size.width / 2, size.height / 2), transform);
    ref.read(canvasStateProvider.notifier).addItem(VisionItem(
      id: const Uuid().v4(),
      type: VisionItemType.countdown.name,
      content: metadata['title'] ?? 'Countdown',
      metadata: metadata,
      x: canvasCenter.dx - 110,
      y: canvasCenter.dy - 110,
      width: 220,
      height: 220,
    ));
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
    final viewportTransform = canvasState.viewportTransform;
    final selectedIds = canvasState.selectedIds;
    final isGuest = ref.watch(authProvider).value == null;
    final cust = ref.watch(visionCustomizationProvider);
    final decorProgress = _decorController;

    return SafeArea(
      child: Stack(
        children: [
          // 0. Board Style Background
          Positioned.fill(
            child: _BoardBackground(style: cust.boardStyle),
          ),

          // 0.5. Board Decorations (behind items)
          if (cust.decorations.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: decorProgress,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _BoardDecorPainter(
                        decorations: cust.decorations,
                        boardStyle: cust.boardStyle,
                        progress: decorProgress.value,
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
              ),
            ),

          // 1. The Unified Canvas Area
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ref.read(canvasStateProvider.notifier).clearSelection();
                FocusScope.of(context).unfocus();
              },
              onScaleStart: (details) {
                final canvasPoint =
                    _toCanvasCoordinates(details.localFocalPoint, viewportTransform);

                _interactingItemId = null;
                for (var item in items.reversed) {
                  final rect =
                      Rect.fromLTWH(item.x, item.y, item.width, item.height);
                  if (rect.contains(canvasPoint)) {
                    _interactingItemId = item.id;
                    _itemStartWidth = item.width;
                    _itemStartHeight = item.height;
                    _itemStartRotation = item.rotation;

                    ref.read(canvasStateProvider.notifier).selectItem(item.id);
                    HapticFeedback.selectionClick();
                    break;
                  }
                }
              },
              onScaleUpdate: (details) {
                if (_interactingItemId != null) {
                  final scaleX = viewportTransform.entry(0, 0);
                  final scaleY = viewportTransform.entry(1, 1);
                  final dx = details.focalPointDelta.dx / scaleX;
                  final dy = details.focalPointDelta.dy / scaleY;

                  ref
                      .read(canvasStateProvider.notifier)
                      .updatePosition(_interactingItemId!, dx, dy);

                  ref.read(canvasStateProvider.notifier).commitTransform(
                        _interactingItemId!,
                        _itemStartWidth * details.scale,
                        _itemStartHeight * details.scale,
                        _itemStartRotation + details.rotation,
                      );
                }
              },
              onScaleEnd: (details) {
                if (_interactingItemId != null) {
                  final item =
                      items.firstWhere((i) => i.id == _interactingItemId);
                  ref.read(canvasStateProvider.notifier).commitTransform(
                        item.id,
                        item.width,
                        item.height,
                        item.rotation,
                      );
                  HapticFeedback.lightImpact();
                  _springItemId = _interactingItemId;
                  _springController.reset();
                  _springController.forward();
                  setState(() {
                    _interactingItemId = null;
                  });
                } else {
                  ref.read(canvasStateProvider.notifier).commitViewport();
                }
              },
              child: ClipRect(
                child: Transform(
                  transform: viewportTransform,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.transparent,
                      ),
                      ...items.map((item) {
                        final isSelected = selectedIds.contains(item.id);
                        final isInteracting =
                            _interactingItemId == item.id;
                        final springValue = _springItemId == item.id
                            ? _springAnimation.value
                            : 0.0;

                        return Positioned(
                          left: item.x,
                          top: item.y,
                          child: _CanvasItemWidget(
                            item: item,
                            isSelected: isSelected,
                            isInteracting: isInteracting,
                            boardStyle: cust.boardStyle,
                            springValue: springValue,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Floating Toolbar
          if (selectedIds.isNotEmpty)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: _buildFloatingToolbar(context, selectedIds.first),
            ),

          // 2.5. Save Board Button
          Positioned(
            bottom: 30,
            left: 20,
            child: FloatingActionButton.extended(
              heroTag: 'save_room_btn',
              backgroundColor: const Color(0xFF10B981),
              onPressed: () async {
                HapticFeedback.mediumImpact();
                if (isGuest) {
                  _showPremiumAuthSheet(context);
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saving Vision Room...'),
                    duration: Duration(milliseconds: 600),
                  ),
                );
                try {
                  await ref
                      .read(canvasStateProvider.notifier)
                      .saveRoomToServer();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vision Room saved successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to save Vision Room: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
              label: const Text('Save Board',
                  style:
                      TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),

          // 3. Add Button
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'add_btn',
              backgroundColor: AppColors.accentBlue,
              onPressed: () => _showAddMenu(),
              child:
                  const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildFloatingToolbar(BuildContext context, String itemId) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.push_pin_rounded,
                        color: Colors.redAccent, size: 20),
                    tooltip: 'Use Pin',
                    onPressed: () {
                      ref
                          .read(canvasStateProvider.notifier)
                          .updateAttachment(itemId, 'pin', 'redPin');
                      HapticFeedback.lightImpact();
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.horizontal_rule_rounded,
                        color: Colors.orangeAccent, size: 20),
                    tooltip: 'Use Tape',
                    onPressed: () {
                      ref
                          .read(canvasStateProvider.notifier)
                          .updateAttachment(itemId, 'tape', 'beige');
                      HapticFeedback.lightImpact();
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.flip_to_front_rounded,
                        color: Colors.white70, size: 20),
                    tooltip: 'Bring to Front',
                    onPressed: () {
                      ref
                          .read(canvasStateProvider.notifier)
                          .bringToFront(itemId);
                      HapticFeedback.lightImpact();
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.flip_to_back_rounded,
                        color: Colors.white70, size: 20),
                    tooltip: 'Send to Back',
                    onPressed: () {
                      ref
                          .read(canvasStateProvider.notifier)
                          .sendToBack(itemId);
                      HapticFeedback.lightImpact();
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded,
                        color: Colors.white, size: 20),
                    tooltip: 'Duplicate',
                    onPressed: () {
                      final items = ref.read(canvasStateProvider).items;
                      final item =
                          items.firstWhere((i) => i.id == itemId);
                      final newItem = item.copyWith(
                        id: const Uuid().v4(),
                        x: item.x + 40,
                        y: item.y + 40,
                        zIndex: item.zIndex + 1,
                      );
                      ref
                          .read(canvasStateProvider.notifier)
                          .addItem(newItem);
                      ref
                          .read(canvasStateProvider.notifier)
                          .selectItem(newItem.id);
                      HapticFeedback.lightImpact();
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Colors.redAccent, size: 20),
                    tooltip: 'Delete',
                    onPressed: () {
                      ref
                          .read(canvasStateProvider.notifier)
                          .removeItem(itemId);
                      HapticFeedback.heavyImpact();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddMenu() {
    PremiumCreationHub.show(
      context,
      onAddImage: _pickImage,
      onAddStickyNote: () => _showAddStickyNoteDialog(context),
      onAddQuote: () {
        QuoteBuilderModal.show(context, onSubmit: _addQuote);
      },
      onAddGoal: () {
        GoalBuilderModal.show(context, onSubmit: _addGoal);
      },
      onAddPlan: () {
        PlanBuilderModal.show(context, onSubmit: _addPlan);
      },
      onAddTask: () {
        TaskBuilderModal.show(context, onSubmit: _addTask);
      },
      onAddFinance: () {
        FinanceBuilderModal.show(context, onSubmit: _addFinance);
      },
      onAddCountdown: () {
        CountdownBuilderModal.show(context, onSubmit: _addCountdown);
      },
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
      child: CustomPaint(
        painter: _BoardBgPainter(style),
        size: Size.infinite,
      ),
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
              color: Colors.grey.withValues(alpha: 0.3), width: 1),
        );
      case VisionBoardStyle.canvasWall:
        return const BoxDecoration(
          color: Color(0xFFF5F0E8),
        );
      case VisionBoardStyle.floatingGallery:
        return BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
        );
      case VisionBoardStyle.scrapbook:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDF6E3), Color(0xFFF5E6CC)],
          ),
        );
      case VisionBoardStyle.custom:
        return BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
        );
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
        // Dark wood border
        paint.color = const Color(0xFF3E1F0D).withValues(alpha: 0.6);
        paint.strokeWidth = 6;
        canvas.drawRect(
            Rect.fromLTWH(3, 3, size.width - 6, size.height - 6), paint);
        paint.strokeWidth = 2;
        paint.color = const Color(0xFF5C3A1E).withValues(alpha: 0.4);
        canvas.drawRect(
            Rect.fromLTWH(6, 6, size.width - 12, size.height - 12), paint);
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
        // Reflection shine
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
        canvas.drawRect(
            Rect.fromLTWH(0, 0, size.width, size.height), shine);
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
        // Warm glow
        final warmGlow = Paint()
          ..shader = RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [
              const Color(0xFFFFD699).withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
        canvas.drawRect(
            Rect.fromLTWH(0, 0, size.width, size.height), warmGlow);
        break;

      case VisionBoardStyle.magneticMetal:
        paint.color = Colors.grey.withValues(alpha: 0.08);
        paint.strokeWidth = 1;
        for (double x = 0; x < size.width; x += 80) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
        // Subtle metallic gradient
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
        canvas.drawRect(
            Rect.fromLTWH(0, 0, size.width, size.height), metal);
        // Corner screws
        final screwPaint = Paint()
          ..color = Colors.grey.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(20, 20), 6, screwPaint);
        canvas.drawCircle(
            Offset(size.width - 20, 20), 6, screwPaint);
        canvas.drawCircle(
            Offset(20, size.height - 20), 6, screwPaint);
        canvas.drawCircle(
            Offset(size.width - 20, size.height - 20), 6, screwPaint);
        break;

      case VisionBoardStyle.canvasWall:
        paint.color = const Color(0xFFD4C9B8).withValues(alpha: 0.15);
        for (double y = 0; y < size.height; y += 3) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        // Pin at top center
        final pinPaint = Paint()
          ..color = const Color(0xFF8B7355).withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
            Offset(size.width / 2, 15), 4, pinPaint);
        break;

      case VisionBoardStyle.floatingGallery:
        paint.color = Colors.white.withValues(alpha: 0.03);
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(
            Offset(size.width * 0.8, size.height * 0.15), 80, paint);
        canvas.drawCircle(
            Offset(size.width * 0.2, size.height * 0.85), 60, paint);
        canvas.drawCircle(
            Offset(size.width * 0.7, size.height * 0.7), 40, paint);
        break;

      case VisionBoardStyle.scrapbook:
        paint.color = const Color(0xFFE8D5B7).withValues(alpha: 0.2);
        paint.style = PaintingStyle.fill;
        for (int i = 0; i < 6; i++) {
          final x = size.width *
              (0.08 + (i % 3) * 0.35 + sin(i * 1.5) * 0.05);
          final y = size.height *
              (0.08 + (i ~/ 3) * 0.4 + cos(i * 1.2) * 0.05);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(x, y),
                  width: 60 + (i * 8).toDouble(),
                  height: 40 + (i * 5).toDouble()),
              const Radius.circular(3),
            ),
            paint,
          );
        }
        paint.style = PaintingStyle.stroke;
        paint.color = const Color(0xFFD4C9B8).withValues(alpha: 0.15);
        for (int i = 0; i < 6; i++) {
          final x = size.width *
              (0.08 + (i % 3) * 0.35 + sin(i * 1.5) * 0.05);
          final y = size.height *
              (0.08 + (i ~/ 3) * 0.4 + cos(i * 1.2) * 0.05);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(x, y),
                  width: 60 + (i * 8).toDouble(),
                  height: 40 + (i * 5).toDouble()),
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

// ─── BOARD DECORATIONS PAINTER ────────────────────────────────────────────

class _BoardDecorPainter extends CustomPainter {
  final List<BoardDecoration> decorations;
  final VisionBoardStyle boardStyle;
  final double progress;

  _BoardDecorPainter({
    required this.decorations,
    required this.boardStyle,
    required this.progress,
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
      final y = size.height * 0.05 + sin((x / size.width) * pi + progress * 2) * 8;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);

    final bulbPaint = Paint()..style = PaintingStyle.fill;
    for (double x = 0; x <= size.width; x += 60) {
      final y = size.height * 0.05 + sin((x / size.width) * pi + progress * 2) * 8;
      final glow = (sin(progress * 6 + x * 0.1) + 1) * 0.5;
      bulbPaint.color = Color.fromRGBO(
        255,
        200 - (glow * 100).toInt(),
        100 + (glow * 50).toInt(),
        0.4 + glow * 0.4,
      );
      canvas.drawCircle(Offset(x, y + 5), 4, bulbPaint);
    }
  }

  void _drawMiniPlants(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF2D6A4F).withValues(alpha: 0.25);

    final positions = [
      Offset(size.width * 0.05, size.height * 0.6),
      Offset(size.width * 0.95, size.height * 0.55),
    ];

    for (final pos in positions) {
      // Pot
      paint.color = const Color(0xFF8B6914).withValues(alpha: 0.2);
      final potPath = Path()
        ..moveTo(pos.dx - 8, pos.dy)
        ..lineTo(pos.dx - 6, pos.dy + 12)
        ..lineTo(pos.dx + 6, pos.dy + 12)
        ..lineTo(pos.dx + 8, pos.dy)
        ..close();
      canvas.drawPath(potPath, paint);

      // Leaves
      paint.color = const Color(0xFF2D6A4F).withValues(alpha: 0.25);
      for (int i = 0; i < 3; i++) {
        final angle = pi / 4 + i * pi / 3 + sin(progress * 2 + i) * 0.1;
        final leafEnd = Offset(
          pos.dx + cos(angle) * 12,
          pos.dy - 8 + sin(angle.abs()) * 8,
        );
        canvas.drawOval(
          Rect.fromPoints(
            Offset(pos.dx - 1, pos.dy - 2),
            leafEnd,
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

    final positions = [
      Offset(size.width * 0.15, size.height * 0.1),
      Offset(size.width * 0.85, size.height * 0.12),
      Offset(size.width * 0.12, size.height * 0.45),
      Offset(size.width * 0.88, size.height * 0.5),
    ];

    for (final pos in positions) {
      canvas.drawCircle(pos, 4, paint);
      paint.color = Colors.grey.withValues(alpha: 0.1);
      canvas.drawLine(pos, Offset(pos.dx, pos.dy + 10),
          paint..strokeWidth = 1);
      paint.color = Colors.red.withValues(alpha: 0.15);
    }
  }

  void _drawWashiTape(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final tapeRects = [
      Rect.fromLTWH(size.width * 0.05, size.height * 0.05, 40, 14),
      Rect.fromLTWH(size.width * 0.88, size.height * 0.08, 40, 14),
      Rect.fromLTWH(size.width * 0.06, size.height * 0.5, 40, 14),
    ];

    for (final rect in tapeRects) {
      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(-0.15);
      paint.color = Colors.pink.withValues(alpha: 0.08);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset.zero,
              width: rect.width,
              height: rect.height),
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

    // Top-right corner ribbon
    final path = Path()
      ..moveTo(size.width - 20, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 20)
      ..close();
    canvas.drawPath(path, paint);

    // Bottom-left corner ribbon
    paint.color = const Color(0xFF4DA3FF).withValues(alpha: 0.08);
    final path2 = Path()
      ..moveTo(0, size.height - 20)
      ..lineTo(0, size.height)
      ..lineTo(20, size.height)
      ..close();
    canvas.drawPath(path2, paint);
  }

  void _drawPressedFlowers(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final positions = [
      Offset(size.width * 0.25, size.height * 0.15),
      Offset(size.width * 0.72, size.height * 0.18),
    ];

    for (final pos in positions) {
      paint.color = const Color(0xFFFFB7C5).withValues(alpha: 0.12);
      for (int i = 0; i < 5; i++) {
        final angle = i * (2 * pi / 5);
        canvas.drawCircle(
          Offset(
            pos.dx + cos(angle) * 4,
            pos.dy + sin(angle) * 4,
          ),
          3,
          paint,
        );
      }
      paint.color = const Color(0xFFFFD700).withValues(alpha: 0.1);
      canvas.drawCircle(pos, 2, paint);
    }
  }

  void _drawBookmarks(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

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
      final rect = Rect.fromCenter(
        center: pos,
        width: 8,
        height: 30,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        paint,
      );
      // V-shape bottom
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

    // Top shelf
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.02, size.height * 0.25,
          size.width * 0.25, 3),
      paint,
    );

    // Bottom shelf
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.73, size.height * 0.6,
          size.width * 0.25, 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BoardDecorPainter oldDelegate) =>
      oldDelegate.decorations != decorations ||
      oldDelegate.boardStyle != boardStyle ||
      oldDelegate.progress != progress;
}

// ─── CANVAS ITEM WIDGET ───────────────────────────────────────────────────

class _CanvasItemWidget extends ConsumerStatefulWidget {
  final VisionItem item;
  final bool isSelected;
  final bool isInteracting;
  final VisionBoardStyle boardStyle;
  final double springValue;

  const _CanvasItemWidget({
    required this.item,
    this.isSelected = false,
    this.isInteracting = false,
    this.boardStyle = VisionBoardStyle.classicCork,
    this.springValue = 0.0,
  });

  @override
  ConsumerState<_CanvasItemWidget> createState() =>
      _CanvasItemWidgetState();
}

class _CanvasItemWidgetState extends ConsumerState<_CanvasItemWidget> {
  bool _isEditing = false;
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController =
        TextEditingController(text: widget.item.content);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _commitText();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _CanvasItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing &&
        oldWidget.item.content != widget.item.content) {
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
    final boardStyle = widget.boardStyle;
    Widget contentWidget;

    final double liftScale = widget.isInteracting ? 1.05 : 1.0;
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
            child: Image.file(
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
        padding: const EdgeInsets.all(AppSpacing.md),
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
    } else {
      contentWidget = FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: 180,
          height: 180,
          child: Opacity(
            opacity: cardCfg.glassMode ? 0.85 : cardCfg.opacity,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
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
                        style: AppTypography.titleMedium(color: Colors.white)
                            .copyWith(fontSize: 14),
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero),
                        onSubmitted: (_) => _commitText(),
                      )
                    : Text(
                        item.content,
                        style: AppTypography.titleMedium(color: Colors.white)
                            .copyWith(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ),
        ),
      );
    }

    final boardAdjustedWidget = boardStyle == VisionBoardStyle.floatingGallery
        ? ClipRRect(
            borderRadius: BorderRadius.circular(cr),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: contentWidget,
            ),
          )
        : contentWidget;

    return AnimatedScale(
      scale: liftScale,
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
