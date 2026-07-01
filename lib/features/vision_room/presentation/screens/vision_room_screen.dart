import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/vision_item.dart';
import '../providers/vision_room_providers.dart';
import '../providers/sticky_note_provider.dart';
import '../widgets/sticky_note_bottom_sheet.dart';
import '../providers/canvas_providers.dart';
import '../providers/customization_provider.dart';
import '../providers/canvas_providers.dart';
import '../walls/vision_wall.dart';
import '../walls/habit_wall.dart';
import '../walls/motivation_wall.dart';
import '../walls/achievement_wall.dart';
import '../walls/finance_wall.dart';
import '../walls/timeline_wall.dart';
import '../widgets/hanging_pen.dart';
import '../widgets/room_scene.dart';
import '../widgets/vision_creation_sheet.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../data/services/vision_upload_service.dart';
import '../widgets/quote_builder_modal.dart';
import '../widgets/goal_builder_modal.dart';
import '../widgets/task_builder_modal.dart';
import '../widgets/plan_builder_modal.dart';
import '../widgets/finance_builder_modal.dart';
import '../widgets/countdown_builder_modal.dart';
import '../widgets/due_date_progress_selector.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/premium_auth_sheet.dart';
import '../../../auth/presentation/providers/preview_mode_provider.dart';
import '../../../auth/presentation/widgets/start_workspace_sheet.dart';

class VisionRoomScreen extends ConsumerStatefulWidget {
  const VisionRoomScreen({super.key});

  @override
  ConsumerState<VisionRoomScreen> createState() => _VisionRoomScreenState();
}

class _VisionRoomScreenState extends ConsumerState<VisionRoomScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final ImagePicker _picker = ImagePicker();

  final List<String> _wallNames = [
    'Finance Wall',
    'Achievement Wall',
    'Habit Wall',
    'Vision Board',
    'Motivation Wall',
    'Future Timeline',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 3, viewportFraction: 1.0);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _showPremiumAuthSheet(BuildContext context) {
    PremiumAuthSheet.show(context);
  }

  // ─── ITEM CREATION METHODS ──────────────────────────────────────────────

  bool _canCreateItem(String itemType) {
    final isPreviewMode = ref.read(previewModeProvider);
    if (isPreviewMode) {
      StartWorkspaceSheet.show(context);
      return false;
    }

    final isGuest = ref.read(authProvider).value == null;
    if (!isGuest) return true;

    if (itemType == 'sticky_note') {
      _showPremiumAuthSheet(context);
      return false;
    }

    _showPremiumAuthSheet(context);
    return false;
  }

  Future<void> _pickImage() async {
    if (!_canCreateItem(VisionItemType.image.name)) return;
    final size = MediaQuery.of(context).size;
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      DateTime? selectedDueDate;
      double selectedProgress = 0;
      bool addToShelf = false;
      await showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setDlgState) => AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Image Vision Goal Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DueDateAndProgressSelector(
                    selectedDate: selectedDueDate,
                    currentProgress: selectedProgress,
                    accentColor: const Color(0xFF10B981),
                    onDateChanged: (d) => setDlgState(() => selectedDueDate = d),
                    onProgressChanged: (p) => setDlgState(() => selectedProgress = p),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.archive_outlined, color: Colors.white70, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Add to Wooden Shelf',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                      Switch(
                        value: addToShelf,
                        activeColor: const Color(0xFF10B981),
                        onChanged: (val) => setDlgState(() => addToShelf = val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Skip', style: TextStyle(color: Colors.white60)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Save Details'),
              ),
            ],
          ),
        ),
      );

      final random = Random();
      final newItem = VisionItem(
        id: const Uuid().v4(),
        type: VisionItemType.image.name,
        content: image.path, // Temporary local cache path
        countdownDate: selectedDueDate,
        x: (size.width / 2) - 125,
        y: (size.height / 2) - 125,
        width: 250,
        height: 250,
        rotation: (random.nextDouble() - 0.5) * 0.2,
        metadata: {
          'progress': selectedProgress,
          'isOnShelf': addToShelf,
        },
      );
      
      // Optimistically add the item to the canvas using local cache
      ref.read(canvasStateProvider.notifier).addItem(newItem);

      // Upload in the background
      final dio = ref.read(dioClientProvider).dio;
      final uploadService = VisionUploadService(dio: dio);
      
      uploadService.uploadImage(image.path).then((uploadedUrl) {
        if (uploadedUrl != null && mounted) {
          // Replace the local path with the actual Cloudinary URL
          ref.read(canvasStateProvider.notifier).updateItemDetails(
            newItem.id,
            content: uploadedUrl,
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image to Cloudinary. Please try again later.')),
          );
        }
      });
    }
  }

  void _addStickyNote() {
    _showStickyNoteDialog();
  }

  void _showStickyNoteDialog({VisionItem? existingItem}) {
    if (existingItem == null) {
      if (!_canCreateItem('sticky_note')) return;
    }

    // Replace old generic dialog with the new premium sheet
    StickyNoteBottomSheet.show(context);
  }

  void _addQuote() {
    if (!_canCreateItem(VisionItemType.quote.name)) return;
    QuoteBuilderModal.show(
      context,
      onSubmit: (metadata) {
        final size = MediaQuery.of(context).size;
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
                x: (size.width / 2) - 140,
                y: (size.height / 2) - 80,
                width: 280,
                height: 160,
                rotation: (random.nextDouble() - 0.5) * 0.15,
                attachmentType: 'tape',
                attachmentStyle: 'beige',
              ),
            );
      },
    );
  }

  void _addGoal() {
    if (!_canCreateItem(VisionItemType.goal.name)) return;
    GoalBuilderModal.show(
      context,
      onSubmit: (metadata) {
        final size = MediaQuery.of(context).size;
        final random = Random();
        ref
            .read(canvasStateProvider.notifier)
            .addItem(
              VisionItem(
                id: const Uuid().v4(),
                type: VisionItemType.goal.name,
                content: metadata['title'],
                metadata: metadata,
                x: (size.width / 2) - 150,
                y: (size.height / 2) - 100,
                width: 300,
                height: 200,
                rotation: (random.nextDouble() - 0.5) * 0.1,
                attachmentType: 'pin',
                attachmentStyle: 'bluePin',
              ),
            );
      },
    );
  }

  void _addPlan() {
    if (!_canCreateItem(VisionItemType.plan.name)) return;
    PlanBuilderModal.show(
      context,
      onSubmit: (metadata) {
        final size = MediaQuery.of(context).size;
        ref
            .read(canvasStateProvider.notifier)
            .addItem(
              VisionItem(
                id: const Uuid().v4(),
                type: VisionItemType.plan.name,
                content: metadata['title'] ?? 'Plan',
                metadata: metadata,
                x: (size.width / 2) - 160,
                y: (size.height / 2) - 120,
                width: 320,
                height: 240,
                attachmentType: 'tape',
                attachmentStyle: 'blackTape',
              ),
            );
      },
    );
  }

  void _addTask() {
    if (!_canCreateItem(VisionItemType.task.name)) return;
    TaskBuilderModal.show(
      context,
      onSubmit: (metadata) {
        final size = MediaQuery.of(context).size;
        ref
            .read(canvasStateProvider.notifier)
            .addItem(
              VisionItem(
                id: const Uuid().v4(),
                type: VisionItemType.task.name,
                content: metadata['title'] ?? 'Task',
                metadata: metadata,
                x: (size.width / 2) - 125,
                y: (size.height / 2) - 60,
                width: 250,
                height: 120,
              ),
            );
      },
    );
  }

  void _addCountdown() {
    if (!_canCreateItem(VisionItemType.countdown.name)) return;
    CountdownBuilderModal.show(
      context,
      onSubmit: (metadata) {
        final size = MediaQuery.of(context).size;
        ref
            .read(canvasStateProvider.notifier)
            .addItem(
              VisionItem(
                id: const Uuid().v4(),
                type: VisionItemType.countdown.name,
                content: metadata['title'] ?? 'Countdown',
                metadata: metadata,
                x: (size.width / 2) - 110,
                y: (size.height / 2) - 110,
                width: 220,
                height: 220,
              ),
            );
      },
    );
  }





  void _addFinance() {
    FinanceBuilderModal.show(
      context,
      onSubmit: (metadata) {
        final size = MediaQuery.of(context).size;
        ref
            .read(canvasStateProvider.notifier)
            .addItem(
              VisionItem(
                id: const Uuid().v4(),
                type: VisionItemType.financeGoal.name,
                content: metadata['title'] ?? 'Finance',
                metadata: metadata,
                x: (size.width / 2) - 140,
                y: (size.height / 2) - 80,
                width: 280,
                height: 160,
              ),
            );
      },
    );
  }

  void _addFrame() {
    final frames = [
      ('Modern', 0xFF3B82F6),
      ('Warm', 0xFFF59E0B),
      ('Rose', 0xFFEC4899),
      ('Forest', 0xFF10B981),
      ('Royal', 0xFF8B5CF6),
      ('Slate', 0xFF64748B),
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
                  final size = MediaQuery.of(context).size;
                  final random = Random();
                  ref
                      .read(canvasStateProvider.notifier)
                      .addItem(
                        VisionItem(
                          id: const Uuid().v4(),
                          type: VisionItemType.decoration.name,
                          content: 'frame_${f.$1}',
                          colorValue: f.$2,
                          x: (size.width / 2) - 100,
                          y: (size.height / 2) - 80,
                          width: 200,
                          height: 160,
                          rotation: (random.nextDouble() - 0.5) * 0.08,
                          attachmentType: 'none',
                        ),
                      );
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
                  child: Center(
                    child: Text(
                      f.$1,
                      style: TextStyle(
                        color: Color(f.$2),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _addText() {
    final controller = TextEditingController();
    bool addToShelf = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          title: const Text(
            'Add Text',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.archive_outlined, color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Add to Wooden Shelf',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    Switch(
                      value: addToShelf,
                      activeColor: AppColors.accentBlue,
                      onChanged: (val) => setDlgState(() => addToShelf = val),
                    ),
                  ],
                ),
              ],
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
                  final size = MediaQuery.of(context).size;
                  final random = Random();
                  ref
                      .read(canvasStateProvider.notifier)
                      .addItem(
                        VisionItem(
                          id: const Uuid().v4(),
                          type: VisionItemType.stickyNote.name,
                          content: text,
                          colorValue: 0xFF1E293B,
                          x: (size.width / 2) - 100,
                          y: (size.height / 2) - 60,
                          width: 200,
                          height: 120,
                          rotation: (random.nextDouble() - 0.5) * 0.1,
                          attachmentType: 'none',
                          metadata: {'isOnShelf': addToShelf},
                        ),
                      );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _openCreationSheet() {
    void withEditMode(VoidCallback action) {
      ref.read(editModeProvider.notifier).state = true;
      action();
    }

    VisionCreationSheet.show(
      context,
      onAddImage: () => withEditMode(_pickImage),
      onAddStickyNote: () => withEditMode(_addStickyNote),
      onAddQuote: () => withEditMode(_addQuote),
      onAddGoal: () => withEditMode(_addGoal),
      onAddPlan: () => withEditMode(_addPlan),
      onAddTask: () => withEditMode(_addTask),
      onAddCountdown: () => withEditMode(_addCountdown),
      onAddFinance: () => withEditMode(_addFinance),
      onAddFrame: () => withEditMode(_addFrame),
      onAddText: () => withEditMode(_addText),
      onEnterEditMode: () {
        ref.read(editModeProvider.notifier).state = true;
      },
    );
  }

  void _exitEditMode() {
    ref.read(canvasStateProvider.notifier).clearSelection();
    ref.read(editModeProvider.notifier).state = false;
    ref.read(canvasStateProvider.notifier).saveRoomToServer().catchError((e) {
      debugPrint('[CanvasSync] Error auto-saving on exit edit mode: $e');
    });
    HapticFeedback.mediumImpact();

    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text('✓ Vision Room Updated'),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final focusMode = ref.watch(focusModeProvider);
    final customization = ref.watch(visionCustomizationProvider);
    final canvasState = ref.watch(canvasStateProvider);
    final isEditMode = ref.watch(editModeProvider);

    ref.listen<String?>(premiumAuthTriggerProvider, (previous, next) {
      if (next != null) {
        _showPremiumAuthSheet(context);
        ref.read(premiumAuthTriggerProvider.notifier).state = null;
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: AnimatedBuilder(
        animation: _entryController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Stack(
                children: [
                  // 1-10. Room Scene
                  AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, _) {
                      final pageOffset =
                          _pageController.hasClients &&
                              _pageController.position.haveDimensions
                          ? _pageController.page! - 3
                          : 0.0;
                      return RoomScene(
                        customization: customization,
                        items: canvasState.items,
                        pageOffset: pageOffset,
                        child: PageView.builder(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (index) {
                            ref.read(currentWallIndexProvider.notifier).state =
                                index;
                          },
                          itemCount: _wallNames.length,
                          itemBuilder: (context, index) {
                            return AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                double value = 1.0;
                                if (_pageController.hasClients &&
                                    _pageController.position.haveDimensions) {
                                  value = _pageController.page! - index;
                                  value = (1 - (value.abs() * 0.3)).clamp(
                                    0.0,
                                    1.0,
                                  );
                                }

                                final tilt =
                                    (_pageController.hasClients &&
                                        _pageController.position.haveDimensions)
                                    ? (_pageController.page! - index) * 0.1
                                    : 0.0;

                                return Transform(
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateY(-tilt),
                                  alignment: Alignment.center,
                                  child: Opacity(
                                    opacity: value.clamp(0.5, 1.0),
                                    child: _buildWallContent(index),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),

                  // 3. Hanging Pen (entry to creation sheet)
                  Positioned.fill(child: HangingPen(onTap: _openCreationSheet)),

                  // 4. Focus Mode Overlay
                  if (focusMode)
                    Container(color: Colors.black.withValues(alpha: 0.7)),

                  // 5. Edit Mode dimming overlay (subtle)
                  if (isEditMode)
                    IgnorePointer(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.15),
                      ),
                    ),

                  // 6. UI Overlay (Top Bar)
                  SafeArea(
                    child: IgnorePointer(
                      ignoring: focusMode,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: focusMode ? 0.0 : 1.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [_buildTopBar()],
                        ),
                      ),
                    ),
                  ),

                  // 7. Edit Mode Floating Toolbar
                  if (isEditMode)
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: _buildEditToolbar(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWallContent(int index) {
    switch (index) {
      case 0:
        return const FinanceWall();
      case 1:
        return const AchievementWall();
      case 2:
        return const HabitWall();
      case 3:
        return const VisionWall();
      case 4:
        return const MotivationWall();
      case 5:
        return const TimelineWall();
      default:
        return const SizedBox();
    }
  }

  Widget _buildTopBar() {
    final isEditMode = ref.watch(editModeProvider);
    final isPreviewMode = ref.watch(previewModeProvider);

    return Column(
      children: [
        if (isPreviewMode)
          GestureDetector(
            onTap: () => StartWorkspaceSheet.show(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                border: const Border(bottom: BorderSide(color: Color(0xFFF59E0B), width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Preview Mode. Start your permanent workspace to begin saving.',
                    style: GoogleFonts.outfit(color: const Color(0xFFFCD34D), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Close button
              GestureDetector(
                onTap: () {
                  if (isEditMode) {
                    _exitEditMode();
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.glass,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.glassBorder, width: 0.5),
                  ),
                  child: Icon(
                    isEditMode
                        ? Icons.check_rounded
                        : Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),

              // Edit Mode indicator
              if (isEditMode)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accentBlue.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text(
                    'Edit Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── EDIT MODE FLOATING TOOLBAR ─────────────────────────────────────────

  Widget _buildEditToolbar() {
    final selectedIds = ref.watch(canvasStateProvider).selectedIds;
    final hasSelection = selectedIds.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Done button
                      _toolbarButton(
                        icon: Icons.check_rounded,
                        label: 'Done',
                        color: const Color(0xFF10B981),
                        onTap: _exitEditMode,
                      ),
                      _divider(),
                      _toolbarButton(
                        icon: Icons.undo_rounded,
                        label: 'Undo',
                        color: Colors.white70,
                        onTap: () =>
                            ref.read(canvasStateProvider.notifier).undo(),
                      ),
                      _toolbarButton(
                        icon: Icons.redo_rounded,
                        label: 'Redo',
                        color: Colors.white70,
                        onTap: () =>
                            ref.read(canvasStateProvider.notifier).redo(),
                      ),
                      if (hasSelection) ...[
                        _divider(),
                        Builder(
                          builder: (context) {
                            final items = ref.read(canvasStateProvider).items;
                            final selectedItem = items.firstWhere(
                              (i) => i.id == selectedIds.first,
                              orElse: () => items.first,
                            );
                            if (selectedItem.type == VisionItemType.stickyNote.name) {
                              return _toolbarButton(
                                icon: Icons.edit_note_rounded,
                                label: 'Edit Note',
                                color: AppColors.accentBlue,
                                onTap: () {
                                  _showStickyNoteDialog(existingItem: selectedItem);
                                },
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        _toolbarButton(
                          icon: Icons.copy_rounded,
                          label: 'Duplicate',
                          color: Colors.white,
                          onTap: () {
                            final items = ref.read(canvasStateProvider).items;
                            final item = items.firstWhere(
                              (i) => i.id == selectedIds.first,
                            );
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
                        _toolbarButton(
                          icon: Icons.delete_outline_rounded,
                          label: 'Delete',
                          color: Colors.redAccent,
                          onTap: () {
                            ref
                                .read(canvasStateProvider.notifier)
                                .removeItem(selectedIds.first);
                            HapticFeedback.heavyImpact();
                          },
                        ),
                        _toolbarButton(
                          icon: Icons.lock_outline_rounded,
                          label: 'Lock',
                          color: Colors.white70,
                          onTap: () {
                            // Toggle pin
                            final items = ref.read(canvasStateProvider).items;
                            final item = items.firstWhere(
                              (i) => i.id == selectedIds.first,
                            );
                            ref
                                .read(canvasStateProvider.notifier)
                                .updateAttachment(
                                  item.id,
                                  'pin',
                                  item.attachmentStyle == 'redPin'
                                      ? 'bluePin'
                                      : 'redPin',
                                );
                          },
                        ),
                        _toolbarButton(
                          icon: Icons.flip_to_front_rounded,
                          label: 'Forward',
                          color: Colors.white70,
                          onTap: () => ref
                              .read(canvasStateProvider.notifier)
                              .bringToFront(selectedIds.first),
                        ),
                        _toolbarButton(
                          icon: Icons.flip_to_back_rounded,
                          label: 'Backward',
                          color: Colors.white70,
                          onTap: () => ref
                              .read(canvasStateProvider.notifier)
                              .sendToBack(selectedIds.first),
                        ),
                        _toolbarButton(
                          icon: Icons.rotate_right_rounded,
                          label: 'Rotate',
                          color: Colors.white70,
                          onTap: () {
                            final items = ref.read(canvasStateProvider).items;
                            final item = items.firstWhere(
                              (i) => i.id == selectedIds.first,
                            );
                            ref
                                .read(canvasStateProvider.notifier)
                                .commitTransform(
                                  item.id,
                                  item.width,
                                  item.height,
                                  item.rotation + 0.15,
                                );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolbarButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white.withValues(alpha: 0.1),
    );
  }
}
