import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/todo_model.dart';
import '../providers/todo_providers.dart';
import '../widgets/wallpaper_background.dart';
import '../widgets/glass_progress_ring.dart';
import '../widgets/glass_fab.dart';
import '../widgets/task_card.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../widgets/empty_state.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/models/auth_user_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _getMotivationalGreeting(String? userName) {
    final name = (userName != null && userName.isNotEmpty && userName != 'Getzio User') 
        ? userName 
        : 'Syed';
    final hour = DateTime.now().hour;
    final greetings = [
      'Focus, $name',
      'Keep Growing, $name',
      'Make Progress, $name',
      'Stay Driven, $name',
      'Crush It, $name',
    ];
    return greetings[hour % greetings.length];
  }

  String _getDailyMantra() {
    final mantras = [
      'Consistency transforms average into excellence.',
      'Small actions every day create extraordinary results.',
      'Your focus determines your reality.',
      'One step at a time. Keep moving forward.',
      'The secret of getting ahead is getting started.',
      'Discipline is choosing what you want most over what you want now.',
    ];
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    return mantras[dayOfYear % mantras.length];
  }

  void _confirmAccountDeletion(BuildContext context, WidgetRef ref, StateSetter setModalState) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF071423),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            side: const BorderSide(color: AppColors.glassBorder, width: 0.5),
          ),
          title: Text(
            'Delete Account',
            style: AppTypography.titleLarge(color: AppColors.error),
          ),
          content: Text(
            'Are you sure you want to permanently delete your account and all associated tasks? This action is immediate and cannot be undone.',
            style: AppTypography.bodyMedium(color: AppColors.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: AppTypography.bodyMedium(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Close dialog
                Navigator.pop(context); // Close profile bottom sheet
                
                try {
                  await ref.read(authProvider.notifier).deleteAccount();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Your account has been deleted.',
                          style: AppTypography.bodyMedium(color: Colors.white),
                        ),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to delete account: ${e.toString().replaceFirst('Exception: ', '')}',
                          style: AppTypography.bodyMedium(color: Colors.white),
                        ),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Delete',
                style: AppTypography.bodyMedium(color: AppColors.error).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddTask() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black45,
      builder: (_) => const AddTaskBottomSheet(),
    );
  }

  void _showProfileBottomSheet(AuthUserModel user) {
    HapticFeedback.mediumImpact();
    
    bool loading = false;
    String? error;
    final initialName = user.name == 'Getzio User' ? '' : user.name;
    final nameController = TextEditingController(text: initialName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black45,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            
            return AnimatedPadding(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(15, 20, 35, 0.98),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xl),
                  ),
                  border: Border.all(color: AppColors.glassBorder, width: 0.5),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: AppColors.glassBorder,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text('Profile Settings', style: AppTypography.titleLarge()),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 0.04),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.glassBorder, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Mobile', style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
                                Text(user.mobile, style: AppTypography.bodyLarge()),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'NAME',
                              style: AppTypography.captionSmall(
                                color: AppColors.textSecondary,
                              ).copyWith(letterSpacing: 1.2),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(0, 0, 0, 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.glassBorder, width: 0.5),
                              ),
                              child: TextField(
                                controller: nameController,
                                style: AppTypography.bodyLarge(),
                                cursorColor: AppColors.accentBlue,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your name',
                                  hintStyle: TextStyle(color: AppColors.textMuted),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (error != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          error!,
                          textAlign: TextAlign.center,
                          style: AppTypography.caption(color: AppColors.error),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),

                      // Action buttons
                      Row(
                        children: [
                          // Log out
                          Expanded(
                            child: GestureDetector(
                              onTap: loading
                                  ? null
                                  : () async {
                                      HapticFeedback.mediumImpact();
                                      Navigator.pop(context);
                                      await ref.read(authProvider.notifier).logout();
                                    },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.glass,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                  border: Border.all(
                                    color: AppColors.glassBorder,
                                    width: 0.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Log Out',
                                    style: AppTypography.bodyMedium(
                                      color: AppColors.error,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),

                          // Save
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: loading
                                  ? null
                                  : () async {
                                      final newName = nameController.text.trim();
                                      if (newName.isEmpty) {
                                        setModalState(() {
                                          error = 'Name cannot be empty';
                                        });
                                        HapticFeedback.vibrate();
                                        return;
                                      }
                                      
                                      setModalState(() {
                                        loading = true;
                                        error = null;
                                      });
                                      HapticFeedback.mediumImpact();

                                      try {
                                        await ref.read(authProvider.notifier).updateName(newName);
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Profile updated successfully!',
                                                style: AppTypography.bodyMedium(color: Colors.white),
                                              ),
                                              backgroundColor: AppColors.accentEmerald,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        setModalState(() {
                                          error = e.toString().replaceFirst('Exception: ', '');
                                          loading = false;
                                        });
                                      }
                                    },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.accentBlue,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accentBlue.withValues(alpha: 0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: loading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Save Changes',
                                          style: AppTypography.bodyLarge(
                                            color: Colors.white,
                                          ).copyWith(fontWeight: FontWeight.w600),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Delete Account option
                      Center(
                        child: TextButton(
                          onPressed: loading 
                              ? null 
                              : () => _confirmAccountDeletion(context, ref, setModalState),
                          child: Text(
                            'Delete Account',
                            style: AppTypography.caption(
                              color: AppColors.error.withValues(alpha: 0.8),
                            ).copyWith(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(todosProvider);
    final stats = ref.watch(todoStatsProvider);
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final now = DateTime.now();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: WallpaperBackground(
        child: SafeArea(
          child: todosAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: AppColors.accentBlue,
                strokeWidth: 2,
              ),
            ),
            error: (err, _) => Center(
              child: Text(
                'Something went wrong',
                style: AppTypography.bodyMedium(),
              ),
            ),
            data: (todos) => _buildContent(todos, stats, now, user),
          ),
        ),
      ),
      floatingActionButton: GlassFab(onPressed: _showAddTask),
    );
  }

  Widget _buildContent(List<TodoModel> todos, TodoStats stats, DateTime now, AuthUserModel? user) {
    return RefreshIndicator(
      onRefresh: () => ref.read(todosProvider.notifier).refresh(),
      color: AppColors.accentBlue,
      backgroundColor: const Color.fromRGBO(15, 20, 35, 0.9),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // ── Header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              child: _buildHeader(stats, now, user),
            ),
          ),

          // ── Section Title ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Text("Today's Tasks", style: AppTypography.titleLarge()),
            ),
          ),

          // ── Tasks or Empty ──
          if (todos.isEmpty)
            const SliverToBoxAdapter(child: EmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return TaskCard(todo: todos[index], index: index);
                }, childCount: todos.length),
              ),
            ),

          // Bottom spacing for FAB
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(TodoStats stats, DateTime now, AuthUserModel? user) {
    final greeting = _getMotivationalGreeting(user?.name);
    final mantra = _getDailyMantra();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side — Greeting + Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      greeting, 
                      style: AppTypography.displayMedium(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (user != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    GestureDetector(
                      onTap: () => _showProfileBottomSheet(user),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.glass,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          size: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                mantra,
                style: const TextStyle(fontSize: 8, color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // Right side — Progress Ring
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xxs),
          child: GlassProgressRing(
            completed: stats.completed,
            total: stats.total,
          ),
        ),
      ],
    );
  }
}
