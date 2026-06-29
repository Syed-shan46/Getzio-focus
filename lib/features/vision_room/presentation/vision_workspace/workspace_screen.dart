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
import '../widgets/quote_builder_modal.dart';
import '../widgets/goal_builder_modal.dart';
import '../widgets/task_builder_modal.dart';
import '../widgets/plan_builder_modal.dart';
import '../widgets/finance_builder_modal.dart';
import '../widgets/countdown_builder_modal.dart';
import '../widgets/customization_sheet.dart';
import '../widgets/roadmap_bottom_sheet.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/premium_auth_sheet.dart';
import 'widgets/canvas_item_widget.dart';
import 'painters/paper_texture_painter.dart';

enum _AutoSaveStatus { saving, saved, offline, syncing }

class VisionWorkspaceScreen extends ConsumerStatefulWidget {
  const VisionWorkspaceScreen({super.key});

  @override
  ConsumerState<VisionWorkspaceScreen> createState() =>
      _VisionWorkspaceScreenState();
}

class _VisionWorkspaceScreenState extends ConsumerState<VisionWorkspaceScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  String? _interactingItemId;
  double _itemStartWidth = 0;
  double _itemStartHeight = 0;
  double _itemStartRotation = 0;

  Matrix4? _startViewportTransform;
  Offset? _startFocalPoint;

  late AnimationController _decorController;
  late AnimationController _springController;
  late Animation<double> _springAnimation;
  String? _springItemId;

  late AnimationController _toolbarAnimController;
  late Animation<double> _toolbarAnim;

  late AnimationController _propertiesAnimController;
  late Animation<double> _propertiesAnim;

  _AutoSaveStatus _saveStatus = _AutoSaveStatus.saved;

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

    _toolbarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _toolbarAnim = CurvedAnimation(
      parent: _toolbarAnimController,
      curve: Curves.elasticOut,
    );
    _toolbarAnimController.forward();

    _propertiesAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _propertiesAnim = CurvedAnimation(
      parent: _propertiesAnimController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _decorController.dispose();
    _springController.dispose();
    _toolbarAnimController.dispose();
    _propertiesAnimController.dispose();
    super.dispose();
  }

  void _showPremiumAuthSheet(BuildContext context) {
    PremiumAuthSheet.show(context);
  }

  Future<void> _pickImage() async {
    final isGuest = ref.read(authProvider).value == null;
    final items = ref.read(canvasStateProvider).items;
    final count = items
        .where((i) => i.type == VisionItemType.image.name)
        .length;
    if (isGuest && count >= 2) {
      _showPremiumAuthSheet(context);
      return;
    }
    final size = MediaQuery.of(context).size;
    final transform = ref.read(canvasStateProvider).viewportTransform;
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final canvasCenter = _toCanvasCoordinates(
        Offset(size.width / 2, size.height / 2),
        transform,
      );
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
      _setSaving();
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
              title: const Text(
                'New Sticky Note',
                style: TextStyle(color: Colors.white),
              ),
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
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Color',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
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
                                  color: Color(
                                    colorValue,
                                  ).withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
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
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                  ),
                  onPressed: () {
                    final text = textController.text.trim();
                    if (text.isNotEmpty) {
                      final isGuest = ref.read(authProvider).value == null;
                      final items = ref.read(canvasStateProvider).items;
                      final count = items
                          .where(
                            (i) => i.type == VisionItemType.stickyNote.name,
                          )
                          .length;
                      if (isGuest && count >= 3) {
                        Navigator.pop(dialogContext);
                        _showPremiumAuthSheet(context);
                        return;
                      }
                      Navigator.pop(dialogContext);
                      _addStickyNote(text, selectedColorValue);
                      _setSaving();
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
    final canvasCenter = _toCanvasCoordinates(
      Offset(size.width / 2, size.height / 2),
      transform,
    );
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
    final count = items
        .where((i) => i.type == VisionItemType.quote.name)
        .length;
    if (isGuest && count >= 2) {
      _showPremiumAuthSheet(context);
      return;
    }
    final transform = ref.read(canvasStateProvider).viewportTransform;
    final size = MediaQuery.of(context).size;
    final canvasCenter = _toCanvasCoordinates(
      Offset(size.width / 2, size.height / 2),
      transform,
    );
    final random = Random();
    ref
        .read(canvasStateProvider.notifier)
        .addItem(
          VisionItem(
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
          ),
        );
    _setSaving();
  }

  void _addGoal(Map<String, dynamic> metadata) {
    final transform = ref.read(canvasStateProvider).viewportTransform;
    final size = MediaQuery.of(context).size;
    final canvasCenter = _toCanvasCoordinates(
      Offset(size.width / 2, size.height / 2),
      transform,
    );
    final random = Random();
    ref
        .read(canvasStateProvider.notifier)
        .addItem(
          VisionItem(
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
          ),
        );
    _setSaving();
  }

  void _addPlan(Map<String, dynamic> metadata) {
    final transform = ref.read(canvasStateProvider).viewportTransform;
    final size = MediaQuery.of(context).size;
    final canvasCenter = _toCanvasCoordinates(
      Offset(size.width / 2, size.height / 2),
      transform,
    );
    ref
        .read(canvasStateProvider.notifier)
        .addItem(
          VisionItem(
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
          ),
        );
    _setSaving();
  }

  void _addTask(Map<String, dynamic> metadata) {
    final transform = ref.read(canvasStateProvider).viewportTransform;
    final size = MediaQuery.of(context).size;
    final canvasCenter = _toCanvasCoordinates(
      Offset(size.width / 2, size.height / 2),
      transform,
    );
    ref
        .read(canvasStateProvider.notifier)
        .addItem(
          VisionItem(
            id: const Uuid().v4(),
            type: VisionItemType.task.name,
            content: metadata['title'] ?? 'Task',
            metadata: metadata,
            x: canvasCenter.dx - 125,
            y: canvasCenter.dy - 60,
            width: 250,
            height: 120,
          ),
        );
    _setSaving();
  }

  void _addFinance(Map<String, dynamic> metadata) {
    final transform = ref.read(canvasStateProvider).viewportTransform;
    final size = MediaQuery.of(context).size;
    final canvasCenter = _toCanvasCoordinates(
      Offset(size.width / 2, size.height / 2),
      transform,
    );
    ref
        .read(canvasStateProvider.notifier)
        .addItem(
          VisionItem(
            id: const Uuid().v4(),
            type: VisionItemType.financeGoal.name,
            content: metadata['title'] ?? 'Finance',
            metadata: metadata,
            x: canvasCenter.dx - 140,
            y: canvasCenter.dy - 80,
            width: 280,
            height: 160,
          ),
        );
    _setSaving();
  }

  void _addCountdown(Map<String, dynamic> metadata) {
    final transform = ref.read(canvasStateProvider).viewportTransform;
    final size = MediaQuery.of(context).size;
    final canvasCenter = _toCanvasCoordinates(
      Offset(size.width / 2, size.height / 2),
      transform,
    );
    ref
        .read(canvasStateProvider.notifier)
        .addItem(
          VisionItem(
            id: const Uuid().v4(),
            type: VisionItemType.countdown.name,
            content: metadata['title'] ?? 'Countdown',
            metadata: metadata,
            x: canvasCenter.dx - 110,
            y: canvasCenter.dy - 110,
            width: 220,
            height: 220,
          ),
        );
    _setSaving();
  }

  void _addText() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Add Text',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Type your text...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBlue,
            ),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(ctx);
                final transform = ref
                    .read(canvasStateProvider)
                    .viewportTransform;
                final size = MediaQuery.of(context).size;
                final center = _toCanvasCoordinates(
                  Offset(size.width / 2, size.height / 2),
                  transform,
                );
                final random = Random();
                ref
                    .read(canvasStateProvider.notifier)
                    .addItem(
                      VisionItem(
                        id: const Uuid().v4(),
                        type: VisionItemType.stickyNote.name,
                        content: text,
                        colorValue: 0xFF1E293B,
                        x: center.dx - 100,
                        y: center.dy - 60,
                        width: 200,
                        height: 120,
                        rotation: (random.nextDouble() - 0.5) * 0.1,
                        attachmentType: 'none',
                      ),
                    );
                _setSaving();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addShape() {
    final shapes = [
      ('Circle', Icons.circle_outlined),
      ('Square', Icons.square_outlined),
      ('Triangle', Icons.change_history),
      ('Star', Icons.star_outline),
      ('Diamond', Icons.diamond_outlined),
      ('Heart', Icons.favorite_border),
    ];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Add Shape',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: SizedBox(
          width: 280,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: shapes.map((s) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  final transform = ref
                      .read(canvasStateProvider)
                      .viewportTransform;
                  final size = MediaQuery.of(context).size;
                  final center = _toCanvasCoordinates(
                    Offset(size.width / 2, size.height / 2),
                    transform,
                  );
                  final random = Random();
                  ref
                      .read(canvasStateProvider.notifier)
                      .addItem(
                        VisionItem(
                          id: const Uuid().v4(),
                          type: VisionItemType.decoration.name,
                          content: s.$1,
                          colorValue: 0xFF3B82F6,
                          x: center.dx - 60,
                          y: center.dy - 60,
                          width: 120,
                          height: 120,
                          rotation: (random.nextDouble() - 0.5) * 0.1,
                          attachmentType: 'none',
                        ),
                      );
                  _setSaving();
                },
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(s.$2, color: Colors.white, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        s.$1,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _addFrame() {
    final frames = [
      ('Modern', 0xFF3B82F6, Icons.crop_square_rounded),
      ('Warm', 0xFFF59E0B, Icons.crop_square_rounded),
      ('Rose', 0xFFEC4899, Icons.crop_square_rounded),
      ('Forest', 0xFF10B981, Icons.crop_square_rounded),
      ('Royal', 0xFF8B5CF6, Icons.crop_square_rounded),
      ('Slate', 0xFF64748B, Icons.crop_square_rounded),
    ];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'Add Frame',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: SizedBox(
          width: 280,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: frames.map((f) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  final transform = ref
                      .read(canvasStateProvider)
                      .viewportTransform;
                  final size = MediaQuery.of(context).size;
                  final center = _toCanvasCoordinates(
                    Offset(size.width / 2, size.height / 2),
                    transform,
                  );
                  final random = Random();
                  ref
                      .read(canvasStateProvider.notifier)
                      .addItem(
                        VisionItem(
                          id: const Uuid().v4(),
                          type: VisionItemType.decoration.name,
                          content: 'frame_${f.$1}',
                          colorValue: f.$2,
                          x: center.dx - 100,
                          y: center.dy - 80,
                          width: 200,
                          height: 160,
                          rotation: (random.nextDouble() - 0.5) * 0.08,
                          attachmentType: 'none',
                        ),
                      );
                  _setSaving();
                },
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Color(f.$2).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color(f.$2).withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(f.$3, color: Color(f.$2), size: 28),
                      const SizedBox(height: 4),
                      Text(
                        f.$1,
                        style: TextStyle(
                          color: Color(f.$2),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Offset _toCanvasCoordinates(Offset screenPoint, Matrix4 transform) {
    final inverse = Matrix4.copy(transform);
    if (inverse.invert() == 0.0) return screenPoint;
    final vector = Vector3(screenPoint.dx, screenPoint.dy, 0);
    final result = inverse.transform3(vector);
    return Offset(result.x, result.y);
  }

  void _setSaving() {
    setState(() => _saveStatus = _AutoSaveStatus.saving);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _saveStatus = _AutoSaveStatus.saved);
        ref.read(canvasStateProvider.notifier).saveRoomToServer();
      }
    });
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

    ref.listen<String?>(premiumAuthTriggerProvider, (previous, next) {
      if (next != null) {
        _showPremiumAuthSheet(context);
        ref.read(premiumAuthTriggerProvider.notifier).state = null;
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // Paper texture canvas background
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: PaperTexturePainter(
                  baseColor: const Color(0xFFF5F0E8),
                  accentColor: const Color(0xFFE8E0D0),
                ),
                size: Size.infinite,
              ),
            ),
          ),

          // Board decorations overlay
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

          // Canvas with gesture handling
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ref.read(canvasStateProvider.notifier).clearSelection();
                _propertiesAnimController.reverse();
                FocusScope.of(context).unfocus();
              },
              onScaleStart: (details) {
                final canvasPoint = _toCanvasCoordinates(
                  details.localFocalPoint,
                  viewportTransform,
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
                    ref.read(canvasStateProvider.notifier).selectItem(item.id);
                    _propertiesAnimController.forward();
                    HapticFeedback.selectionClick();
                    break;
                  }
                }
                if (_interactingItemId == null) {
                  _startViewportTransform = Matrix4.copy(viewportTransform);
                  _startFocalPoint = details.localFocalPoint;
                } else {
                  _startViewportTransform = null;
                  _startFocalPoint = null;
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
                  ref
                      .read(canvasStateProvider.notifier)
                      .commitTransform(
                        _interactingItemId!,
                        _itemStartWidth * details.scale,
                        _itemStartHeight * details.scale,
                        _itemStartRotation + details.rotation,
                      );
                } else if (_startViewportTransform != null) {
                  final scale = details.scale.clamp(0.3, 5.0);
                  final currentFocal = details.localFocalPoint;
                  final panDelta = currentFocal - _startFocalPoint!;
                  final newTransform = Matrix4.copy(_startViewportTransform!);
                  newTransform.translateByDouble(
                    panDelta.dx,
                    panDelta.dy,
                    0,
                    1.0,
                  );
                  newTransform.translateByDouble(
                    currentFocal.dx,
                    currentFocal.dy,
                    0,
                    1.0,
                  );
                  newTransform.scaleByDouble(scale, scale, 1, 1.0);
                  newTransform.translateByDouble(
                    -currentFocal.dx,
                    -currentFocal.dy,
                    0,
                    1.0,
                  );
                  ref
                      .read(canvasStateProvider.notifier)
                      .updateViewport(newTransform);
                }
              },
              onScaleEnd: (details) {
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
                } else {
                  _startViewportTransform = null;
                  _startFocalPoint = null;
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
                        final isInteracting = _interactingItemId == item.id;
                        final springValue = _springItemId == item.id
                            ? _springAnimation.value
                            : 0.0;
                        return Positioned(
                          left: item.x,
                          top: item.y,
                          child: _buildCanvasItem(
                            item,
                            isSelected,
                            isInteracting,
                            springValue,
                            cust.boardStyle,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Selection glow overlay
          if (selectedIds.isNotEmpty)
            ..._buildSelectionGlows(items, selectedIds, viewportTransform),

          // Selection floating controls
          if (selectedIds.isNotEmpty)
            Positioned(
              bottom: 160,
              left: 0,
              right: 0,
              child: _buildSelectionControls(context, selectedIds.first),
            ),

          // Glass top bar
          Positioned(top: 0, left: 0, right: 0, child: _buildTopBar(context)),

          // Floating tool palette (animated)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _toolbarAnim,
              builder: (context, _) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * _toolbarAnim.value),
                  child: Opacity(
                    opacity: _toolbarAnim.value,
                    child: _buildToolPalette(context, isGuest),
                  ),
                );
              },
            ),
          ),

          // Properties panel
          if (selectedIds.isNotEmpty)
            AnimatedBuilder(
              animation: _propertiesAnim,
              builder: (context, _) {
                return Positioned(
                  bottom: 210,
                  left: 20,
                  right: 20,
                  child: Transform.translate(
                    offset: Offset(0, 120 * (1 - _propertiesAnim.value)),
                    child: Opacity(
                      opacity: _propertiesAnim.value,
                      child: _buildPropertiesPanel(context, selectedIds.first),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCanvasItem(
    VisionItem item,
    bool isSelected,
    bool isInteracting,
    double springValue,
    VisionBoardStyle boardStyle,
  ) {
    return AnimatedBuilder(
      animation: _springController,
      builder: (context, _) {
        return CanvasItemWidget(
          item: item,
          isSelected: isSelected,
          isInteracting: isInteracting,
          boardStyle: boardStyle,
          springValue: springValue,
          onViewRoadmap: () => RoadmapBottomSheet.show(context, item: item),
        );
      },
    );
  }

  List<Widget> _buildSelectionGlows(
    List<VisionItem> items,
    Set<String> selectedIds,
    Matrix4 transform,
  ) {
    return selectedIds.map((id) {
      final item = items.firstWhere((i) => i.id == id);
      return Positioned(
        left: item.x - 6,
        top: item.y - 6,
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
      );
    }).toList();
  }

  // ─── TOP BAR ────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    final selectedIds = ref.watch(canvasStateProvider).selectedIds;
    final isSelection = selectedIds.isNotEmpty;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(canvasStateProvider.notifier).saveRoomToServer();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isSelection ? 'Edit Item' : 'Vision Workspace',
                style: const TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _buildSaveStatus(),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => ref.read(canvasStateProvider.notifier).undo(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.undo_rounded,
                    size: 18,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => ref.read(canvasStateProvider.notifier).redo(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.redo_rounded,
                    size: 18,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => VisionCustomizationSheet.show(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.more_horiz_rounded,
                    size: 20,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveStatus() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Row(
        key: ValueKey(_saveStatus),
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: switch (_saveStatus) {
                _AutoSaveStatus.saving => const Color(0xFFF59E0B),
                _AutoSaveStatus.saved => const Color(0xFF10B981),
                _AutoSaveStatus.offline => Colors.grey,
                _AutoSaveStatus.syncing => const Color(0xFF3B82F6),
              },
            ),
          ),
          const SizedBox(width: 6),
          Text(
            switch (_saveStatus) {
              _AutoSaveStatus.saving => 'Saving...',
              _AutoSaveStatus.saved => 'Saved',
              _AutoSaveStatus.offline => 'Offline',
              _AutoSaveStatus.syncing => 'Syncing...',
            },
            style: TextStyle(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── FLOATING TOOL PALETTE ─────────────────────────────────────────────

  Widget _buildToolPalette(BuildContext context, bool isGuest) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _toolButton(Icons.image_rounded, 'Image', () => _pickImage()),
                _toolButton(
                  Icons.sticky_note_2_rounded,
                  'Note',
                  () => _showAddStickyNoteDialog(context),
                ),
                _toolButton(Icons.auto_awesome_rounded, 'Quote', () {
                  QuoteBuilderModal.show(context, onSubmit: _addQuote);
                }),
                _toolButton(Icons.flag_rounded, 'Goal', () {
                  GoalBuilderModal.show(context, onSubmit: _addGoal);
                }),
                _toolButton(Icons.account_tree_rounded, 'Plan', () {
                  PlanBuilderModal.show(context, onSubmit: _addPlan);
                }),
                _toolButton(Icons.check_circle_outline_rounded, 'Task', () {
                  TaskBuilderModal.show(context, onSubmit: _addTask);
                }),
                _toolButton(Icons.savings_rounded, 'Finance', () {
                  FinanceBuilderModal.show(context, onSubmit: _addFinance);
                }),
                _toolButton(Icons.timer_rounded, 'Countdown', () {
                  CountdownBuilderModal.show(context, onSubmit: _addCountdown);
                }),
                _toolButton(
                  Icons.crop_square_rounded,
                  'Frame',
                  () => _addFrame(),
                ),
                _toolButton(
                  Icons.category_rounded,
                  'Shapes',
                  () => _addShape(),
                ),
                _toolButton(
                  Icons.text_fields_rounded,
                  'Text',
                  () => _addText(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolButton(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SELECTION CONTROLS ─────────────────────────────────────────────────

  Widget _buildSelectionControls(BuildContext context, String itemId) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _selectionAction(Icons.copy_rounded, 'Duplicate', () {
                    final items = ref.read(canvasStateProvider).items;
                    final item = items.firstWhere((i) => i.id == itemId);
                    final newItem = item.copyWith(
                      id: const Uuid().v4(),
                      x: item.x + 40,
                      y: item.y + 40,
                      zIndex: item.zIndex + 1,
                    );
                    ref.read(canvasStateProvider.notifier).addItem(newItem);
                    ref
                        .read(canvasStateProvider.notifier)
                        .selectItem(newItem.id);
                    _setSaving();
                    HapticFeedback.lightImpact();
                  }),
                  _selectionAction(Icons.lock_outline_rounded, 'Lock', () {}),
                  _selectionAction(Icons.delete_outline_rounded, 'Delete', () {
                    ref.read(canvasStateProvider.notifier).removeItem(itemId);
                    _propertiesAnimController.reverse();
                    _setSaving();
                    HapticFeedback.heavyImpact();
                  }),
                  _selectionAction(Icons.flip_to_front_rounded, 'Front', () {
                    ref.read(canvasStateProvider.notifier).bringToFront(itemId);
                    _setSaving();
                  }),
                  _selectionAction(Icons.flip_to_back_rounded, 'Back', () {
                    ref.read(canvasStateProvider.notifier).sendToBack(itemId);
                    _setSaving();
                  }),
                  _selectionAction(Icons.rotate_right_rounded, 'Rotate', () {
                    final items = ref.read(canvasStateProvider).items;
                    final item = items.firstWhere((i) => i.id == itemId);
                    ref
                        .read(canvasStateProvider.notifier)
                        .commitTransform(
                          itemId,
                          item.width,
                          item.height,
                          item.rotation + 0.15,
                        );
                    _setSaving();
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectionAction(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: const Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PROPERTIES PANEL ──────────────────────────────────────────────────

  Widget _buildPropertiesPanel(BuildContext context, String itemId) {
    final items = ref.watch(canvasStateProvider).items;
    final item = items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => items.first,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _propertyChip('W', item.width.toStringAsFixed(0), (val) {
                  ref
                      .read(canvasStateProvider.notifier)
                      .updateSize(
                        itemId,
                        double.tryParse(val) ?? item.width,
                        item.height,
                      );
                  _setSaving();
                }),
                const SizedBox(width: 12),
                _propertyChip('H', item.height.toStringAsFixed(0), (val) {
                  ref
                      .read(canvasStateProvider.notifier)
                      .updateSize(
                        itemId,
                        item.width,
                        double.tryParse(val) ?? item.height,
                      );
                  _setSaving();
                }),
                const SizedBox(width: 12),
                _propertySlider('Rot', item.rotation, 0, 6.28, (val) {
                  ref
                      .read(canvasStateProvider.notifier)
                      .commitTransform(itemId, item.width, item.height, val);
                  _setSaving();
                }),
                const SizedBox(width: 12),
                _propertySlider('Op', 1.0, 0.1, 1.0, (val) {}),
                const SizedBox(width: 12),
                _propertyChip('Pin', item.attachmentStyle, (_) {}),
                const SizedBox(width: 12),
                _propertyChip('Tape', item.attachmentType, (_) {}),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _propertyChip(String label, String value, Function(String) onChanged) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.4),
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _propertySlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 80,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: const Color(0xFF1A1A2E),
              inactiveTrackColor: const Color(
                0xFF1A1A2E,
              ).withValues(alpha: 0.1),
              thumbColor: const Color(0xFF1A1A2E),
              overlayColor: const Color(0xFF1A1A2E).withValues(alpha: 0.08),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.4),
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
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
      final y =
          size.height * 0.05 + sin((x / size.width) * pi + progress * 2) * 8;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
    final bulbPaint = Paint()..style = PaintingStyle.fill;
    for (double x = 0; x <= size.width; x += 60) {
      final y =
          size.height * 0.05 + sin((x / size.width) * pi + progress * 2) * 8;
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
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = const Color(0xFF2D6A4F).withValues(alpha: 0.25);
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
        final angle = pi / 4 + i * pi / 3 + sin(progress * 2 + i) * 0.1;
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
    final data = [
      (Offset(size.width * 0.92, size.height * 0.25), const Color(0xFFE74C3C)),
      (Offset(size.width * 0.08, size.height * 0.72), const Color(0xFF3498DB)),
    ];
    for (final (pos, color) in data) {
      paint.color = color.withValues(alpha: 0.1);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: pos, width: 8, height: 30),
          const Radius.circular(2),
        ),
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
  bool shouldRepaint(covariant _BoardDecorPainter oldDelegate) =>
      oldDelegate.decorations != decorations ||
      oldDelegate.boardStyle != boardStyle ||
      oldDelegate.progress != progress;
}
