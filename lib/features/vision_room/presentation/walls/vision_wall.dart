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
import '../providers/vision_room_providers.dart';
import '../providers/canvas_providers.dart';
import '../widgets/wall_header.dart';
import '../widgets/attachment_widgets.dart';
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

class VisionWall extends ConsumerStatefulWidget {
  const VisionWall({super.key});

  @override
  ConsumerState<VisionWall> createState() => _VisionWallState();
}

class _VisionWallState extends ConsumerState<VisionWall> {
  final ImagePicker _picker = ImagePicker();
  
  // Unified Gesture State
  String? _interactingItemId;
  Matrix4 _initialViewport = Matrix4.identity();
  
  // Per-item interaction state during gesture
  double _itemStartWidth = 0;
  double _itemStartHeight = 0;
  double _itemStartRotation = 0;

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
              border: Border.fromBorderSide(BorderSide(color: Colors.white10, width: 1.5)),
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
                  'Create your free account to unlock unlimited Vision Room items, sync across devices, and securely back up your dreams and goals.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                _buildSocialButton(
                  context,
                  icon: Icons.g_mobiledata_rounded,
                  label: 'Continue with Google',
                  color: Colors.redAccent,
                  provider: 'Google',
                ),
                const SizedBox(height: 12),
                _buildSocialButton(
                  context,
                  icon: Icons.apple_rounded,
                  label: 'Continue with Apple',
                  color: Colors.white,
                  provider: 'Apple',
                ),
                const SizedBox(height: 12),
                _buildSocialButton(
                  context,
                  icon: Icons.mail_outline_rounded,
                  label: 'Continue with Email',
                  color: AppColors.accentBlue,
                  provider: 'Email',
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Maybe Later',
                    style: TextStyle(color: Colors.white30, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required String provider,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          ref.read(authProvider.notifier).simulateSocialLogin(provider);
        },
        icon: Icon(icon, color: color == Colors.white ? Colors.black : Colors.white, size: 24),
        label: Text(
          label,
          style: TextStyle(
            color: color == Colors.white ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color == Colors.white ? Colors.white : Colors.white.withValues(alpha: 0.05),
          side: color == Colors.white ? null : const BorderSide(color: Colors.white10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final isGuest = ref.read(authProvider).value == null;
    final items = ref.read(canvasStateProvider).items;
    final count = items.where((i) => i.type == VisionItemType.image.name).length;
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
        x: canvasCenter.dx - 125, // Center the 250 width item
        y: canvasCenter.dy - 125,
        width: 250,
        height: 250,
        rotation: (random.nextDouble() - 0.5) * 0.2, // slight random rotation
      );
      ref.read(canvasStateProvider.notifier).addItem(newItem);
    }
  }

  void _showAddStickyNoteDialog(BuildContext context) {
    final textController = TextEditingController();
    int selectedColorValue = 0xFFF59E0B; // Default Amber
    final List<int> stickyColors = [
      0xFFF59E0B, // Amber/Yellow
      0xFFEC4899, // Pink
      0xFF3B82F6, // Blue
      0xFFA855F7, // Purple
      0xFF10B981, // Green
      0xFFF8FAFC, // White
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F172A),
              title: const Text('New Sticky Note', style: TextStyle(color: Colors.white)),
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
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Color', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: stickyColors.map((colorValue) {
                      final isSelected = selectedColorValue == colorValue;
                      return GestureDetector(
                        onTap: () => setState(() => selectedColorValue = colorValue),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(colorValue),
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                            boxShadow: [
                              if (isSelected) BoxShadow(color: Color(colorValue).withValues(alpha: 0.5), blurRadius: 8)
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
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentBlue),
                  onPressed: () {
                    final text = textController.text.trim();
                    if (text.isNotEmpty) {
                      final isGuest = ref.read(authProvider).value == null;
                      final items = ref.read(canvasStateProvider).items;
                      final count = items.where((i) => i.type == VisionItemType.stickyNote.name).length;
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
          }
        );
      },
    );
  }

  void _addStickyNote(String text, int colorValue) {
    final transform = ref.read(canvasStateProvider).viewportTransform;
    final size = MediaQuery.of(context).size;
    final screenCenter = Offset(size.width / 2, size.height / 2);
    final canvasCenter = _toCanvasCoordinates(screenCenter, transform);

    final random = Random();
    final newItem = VisionItem(
      id: const Uuid().v4(),
      type: VisionItemType.stickyNote.name,
      content: text,
      colorValue: colorValue,
      x: canvasCenter.dx - 90, // Center the 180 width item
      y: canvasCenter.dy - 90,
      width: 180,
      height: 180,
      rotation: (random.nextDouble() - 0.5) * 0.3,
    );
    ref.read(canvasStateProvider.notifier).addItem(newItem);
  }

  void _addQuote(Map<String, dynamic> metadata) {
    final isGuest = ref.read(authProvider).value == null;
    final items = ref.read(canvasStateProvider).items;
    final count = items.where((i) => i.type == VisionItemType.quote.name).length;
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
    final canvasCenter = _toCanvasCoordinates(Offset(size.width / 2, size.height / 2), transform);
    ref.read(canvasStateProvider.notifier).addItem(VisionItem(
      id: const Uuid().v4(),
      type: VisionItemType.plan.name,
      content: metadata['title'] ?? 'Plan',
      metadata: metadata,
      x: canvasCenter.dx - 160, y: canvasCenter.dy - 120, width: 320, height: 240,
      attachmentType: 'tape', attachmentStyle: 'blackTape',
    ));
  }

  void _addTask(Map<String, dynamic> metadata) {
    final transform = ref.read(canvasStateProvider).viewportTransform;
    final size = MediaQuery.of(context).size;
    final canvasCenter = _toCanvasCoordinates(Offset(size.width / 2, size.height / 2), transform);
    ref.read(canvasStateProvider.notifier).addItem(VisionItem(
      id: const Uuid().v4(),
      type: VisionItemType.task.name,
      content: metadata['title'] ?? 'Task',
      metadata: metadata,
      x: canvasCenter.dx - 125, y: canvasCenter.dy - 60, width: 250, height: 120,
    ));
  }

  void _addFinance(Map<String, dynamic> metadata) {
    final transform = ref.read(canvasStateProvider).viewportTransform;
    final size = MediaQuery.of(context).size;
    final canvasCenter = _toCanvasCoordinates(Offset(size.width / 2, size.height / 2), transform);
    ref.read(canvasStateProvider.notifier).addItem(VisionItem(
      id: const Uuid().v4(),
      type: VisionItemType.financeGoal.name,
      content: metadata['title'] ?? 'Finance',
      metadata: metadata,
      x: canvasCenter.dx - 140, y: canvasCenter.dy - 80, width: 280, height: 160,
    ));
  }

  void _addCountdown(Map<String, dynamic> metadata) {
    final transform = ref.read(canvasStateProvider).viewportTransform;
    final size = MediaQuery.of(context).size;
    final canvasCenter = _toCanvasCoordinates(Offset(size.width / 2, size.height / 2), transform);
    ref.read(canvasStateProvider.notifier).addItem(VisionItem(
      id: const Uuid().v4(),
      type: VisionItemType.countdown.name,
      content: metadata['title'] ?? 'Countdown',
      metadata: metadata,
      x: canvasCenter.dx - 110, y: canvasCenter.dy - 110, width: 220, height: 220,
    ));
  }

  // Convert Screen coordinates to Canvas coordinates
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

    return SafeArea(
      child: Stack(
        children: [
          // 1. The Unified Canvas Area
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // Clear selection if tap on empty space
                ref.read(canvasStateProvider.notifier).clearSelection();
                // Dismiss keyboard
                FocusScope.of(context).unfocus();
              },
              onScaleStart: (details) {
                _initialViewport = viewportTransform.clone();
                final canvasPoint = _toCanvasCoordinates(details.localFocalPoint, viewportTransform);
                
                _interactingItemId = null;
                // Hit test from top to bottom
                for (var item in items.reversed) {
                  final rect = Rect.fromLTWH(item.x, item.y, item.width, item.height);
                  if (rect.contains(canvasPoint)) {
                    _interactingItemId = item.id;
                    _itemStartWidth = item.width;
                    _itemStartHeight = item.height;
                    _itemStartRotation = item.rotation;
                    
                    // Select it
                    ref.read(canvasStateProvider.notifier).selectItem(item.id);
                    // Haptic feedback on pickup
                    HapticFeedback.selectionClick();
                    break;
                  }
                }
              },
              onScaleUpdate: (details) {
                if (_interactingItemId != null) {
                  // Manipulating an item
                  final scaleX = viewportTransform.entry(0, 0);
                  final scaleY = viewportTransform.entry(1, 1);
                  final dx = details.focalPointDelta.dx / scaleX;
                  final dy = details.focalPointDelta.dy / scaleY;

                  ref.read(canvasStateProvider.notifier).updatePosition(_interactingItemId!, dx, dy);
                  
                  ref.read(canvasStateProvider.notifier).commitTransform(
                    _interactingItemId!,
                    _itemStartWidth * details.scale,
                    _itemStartHeight * details.scale,
                    _itemStartRotation + details.rotation,
                  );
                } else {
                  // Manipulating the Board (Pan only)
                  // Disabled as per user request to keep screen fixed
                }
              },
              onScaleEnd: (details) {
                if (_interactingItemId != null) {
                  final item = items.firstWhere((i) => i.id == _interactingItemId);
                  ref.read(canvasStateProvider.notifier).commitTransform(
                    item.id,
                    item.width,
                    item.height,
                    item.rotation,
                  );
                  // Drop haptic
                  HapticFeedback.lightImpact();
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
                      // Base invisible layer to force Stack to fill screen
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Colors.transparent,
                      ),
                      // Items Layer
                      ...items.map((item) {
                        final isSelected = selectedIds.contains(item.id);
                        final isInteracting = _interactingItemId == item.id;
                        
                        return Positioned(
                          left: item.x,
                          top: item.y,
                          child: _CanvasItemWidget(
                            item: item,
                            isSelected: isSelected,
                            isInteracting: isInteracting,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Floating Toolbar (Shows when item is selected)
          if (selectedIds.isNotEmpty)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: _buildFloatingToolbar(context, selectedIds.first),
            ),

          // 3. Action Controls (Add / Undo / Redo)
          Positioned(
            bottom: 30,
            right: 20,
            child: Row(
              children: [
                FloatingActionButton(
                  heroTag: 'add_btn',
                  backgroundColor: AppColors.accentBlue,
                  onPressed: () => _showAddMenu(),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                FloatingActionButton.small(
                  heroTag: 'undo_btn',
                  backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.8),
                  child: const Icon(Icons.undo, color: Colors.white),
                  onPressed: () {
                    ref.read(canvasStateProvider.notifier).undo();
                  },
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  heroTag: 'redo_btn',
                  backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.8),
                  child: const Icon(Icons.redo, color: Colors.white),
                  onPressed: () {
                    ref.read(canvasStateProvider.notifier).redo();
                  },
                ),
              ],
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
                    icon: const Icon(Icons.push_pin_rounded, color: Colors.redAccent, size: 20),
                    tooltip: 'Use Pin',
                    onPressed: () {
                      ref.read(canvasStateProvider.notifier).updateAttachment(itemId, 'pin', 'redPin');
                      HapticFeedback.lightImpact();
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.horizontal_rule_rounded, color: Colors.orangeAccent, size: 20),
                    tooltip: 'Use Tape',
                    onPressed: () {
                      ref.read(canvasStateProvider.notifier).updateAttachment(itemId, 'tape', 'beige');
                      HapticFeedback.lightImpact();
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.flip_to_front_rounded, color: Colors.white70, size: 20),
                    tooltip: 'Bring to Front',
                    onPressed: () {
                      ref.read(canvasStateProvider.notifier).bringToFront(itemId);
                      HapticFeedback.lightImpact();
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.flip_to_back_rounded, color: Colors.white70, size: 20),
                    tooltip: 'Send to Back',
                    onPressed: () {
                      ref.read(canvasStateProvider.notifier).sendToBack(itemId);
                      HapticFeedback.lightImpact();
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 20),
                    tooltip: 'Duplicate',
                    onPressed: () {
                      // Duplicate item logic
                      final items = ref.read(canvasStateProvider).items;
                      final item = items.firstWhere((i) => i.id == itemId);
                      final newItem = item.copyWith(
                        id: const Uuid().v4(),
                        x: item.x + 40,
                        y: item.y + 40,
                        zIndex: item.zIndex + 1,
                      );
                      ref.read(canvasStateProvider.notifier).addItem(newItem);
                      ref.read(canvasStateProvider.notifier).selectItem(newItem.id);
                      HapticFeedback.lightImpact();
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                    tooltip: 'Delete',
                    onPressed: () {
                      ref.read(canvasStateProvider.notifier).removeItem(itemId);
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



class _CanvasItemWidget extends ConsumerStatefulWidget {
  final VisionItem item;
  final bool isSelected;
  final bool isInteracting;

  const _CanvasItemWidget({
    required this.item,
    this.isSelected = false,
    this.isInteracting = false,
  });

  @override
  ConsumerState<_CanvasItemWidget> createState() => _CanvasItemWidgetState();
}

class _CanvasItemWidgetState extends ConsumerState<_CanvasItemWidget> {
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
  void didUpdateWidget(covariant _CanvasItemWidget oldWidget) {
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
      ref.read(canvasStateProvider.notifier).updateContent(widget.item.id, _textController.text);
    } else {
      // Revert if empty
      _textController.text = widget.item.content;
    }
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    Widget contentWidget;
    
    // Dynamic shadow and scale for lift effect
    final double liftScale = widget.isInteracting ? 1.05 : 1.0;
    final double shadowBlur = widget.isInteracting ? 30.0 : 15.0;
    final Offset shadowOffset = widget.isInteracting ? const Offset(0, 15) : const Offset(0, 8);
    
    // Glowing border for selection
    final Border? selectionBorder = widget.isSelected 
        ? Border.all(color: AppColors.accentBlue, width: 3)
        : null;

    if (item.type == VisionItemType.image.name) {
      contentWidget = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: selectionBorder ?? Border.all(color: Colors.white, width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: shadowBlur, offset: shadowOffset)
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
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
      );
    } else if (item.type == VisionItemType.stickyNote.name) {
      contentWidget = Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Color(item.colorValue),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(2),
            bottomLeft: Radius.circular(2),
            bottomRight: Radius.circular(24),
          ),
          border: selectionBorder,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: shadowBlur, offset: shadowOffset)
          ],
        ),
        child: Center(
          child: _isEditing 
            ? TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: null,
                textAlign: TextAlign.center,
                style: AppTypography.titleMedium(color: Colors.black87),
                decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                onSubmitted: (_) => _commitText(),
              )
            : Text(
                item.content,
                style: AppTypography.titleMedium(color: Colors.black87),
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
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Color(item.colorValue),
              borderRadius: BorderRadius.circular(12),
              border: selectionBorder ?? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Center(
              child: _isEditing 
                ? TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    maxLines: null,
                    textAlign: TextAlign.center,
                    style: AppTypography.titleMedium(color: Colors.white).copyWith(fontSize: 14),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                    onSubmitted: (_) => _commitText(),
                  )
                : Text(
                    item.content,
                    style: AppTypography.titleMedium(color: Colors.white).copyWith(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
            ),
          ),
        ),
      );
    }

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
            angle: item.rotation,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: item.width,
                  height: item.height,
                  child: contentWidget,
                ),
                
                // Attachment rendering
                if (item.attachmentType == 'pin')
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutCubic,
                    top: (20 * (item.width / 200.0)) - 36 - (widget.isInteracting ? (10 * (item.width / 200.0)) : 0),
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
                    top: -12 - (widget.isInteracting ? (5 * (item.width / 200.0)) : 0),
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
