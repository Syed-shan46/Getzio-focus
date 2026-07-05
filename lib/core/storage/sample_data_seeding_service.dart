import 'dart:convert';
import 'dart:developer' as dev;
import '../../core/storage/hive_database.dart';

class SampleDataSeedingService {
  static const String _logTag = '[SampleDataSeeding]';
  static const int currentVersion = 2;

  /// Seeds all premium sample data to Hive database for a beautiful first-time experience.
  static Future<void> seedAll(HiveDatabase hiveDb) async {
    dev.log('$_logTag Initializing premium sample database seeding...');

    // 1. Identity & Life Areas
    await hiveDb.saveSelectedIdentity('🚀 Entrepreneur');
    await hiveDb.saveSelectedLifeAreas(['health', 'reading', 'finance', 'productivity']);
    await hiveDb.saveSelectedGoal('Become Consistent');

    // 2. Trackers Preferences
    await hiveDb.saveReadingPreferences({
      'categories': ['Self-Improvement', 'Business', 'Philosophy'],
      'bookTarget': 12,
      'dailyReadingMinutes': 25,
    });

    await hiveDb.saveHealthPreferences({
      'waterTarget': 2500,
      'sleepTarget': 8,
      'exerciseTarget': 30,
    });

    await hiveDb.saveFinancePreferences({
      'monthlySavings': 15000,
    });

    // 3. User Statistics
    await hiveDb.saveUserStatistics({
      'disciplinePoints': 120,
      'level': 1,
      'currentStreak': 3,
      'bestStreak': 5,
      'totalHabitsCompleted': 14,
    });

    // 4. Workspace Settings
    await hiveDb.saveWorkspaceSettings({
      'woodTexture': 'Oak',
      'wallColor': 'Deep Indigo',
      'plantType': 'Bonsai',
      'ambientMode': 'Auto',
      'rainMode': false,
      'homeExperience': 'classic',
    });

    // 5. Goals with Milestones and Tasks
    final now = DateTime.now();
    await hiveDb.saveSelectedGoals([
      {
        'id': 'goal_sample_1',
        'localId': 'goal_sample_1',
        'title': 'Launch My Side Hustle MVP',
        'category': 'Productivity',
        'target': 100,
        'currentProgress': 35,
        'status': 'in-progress',
        'priority': 'high',
        'deadline': now.add(const Duration(days: 30)).toIso8601String(),
        'syncStatus': 'pending',
        'milestones': [
          {
            'id': 'm_sample_1_1',
            'title': 'Market Research & Wireframing',
            'isCompleted': true,
            'order': 0,
            'subtasks': [
              {
                'id': 'sub_sample_1_1_1',
                'title': 'Interview 5 potential customers',
                'isCompleted': true,
              },
              {
                'id': 'sub_sample_1_1_2',
                'title': 'Sketch basic visual layout wireframes',
                'isCompleted': true,
              }
            ]
          },
          {
            'id': 'm_sample_1_2',
            'title': 'Develop Frontend & Backend MVP',
            'isCompleted': false,
            'order': 1,
            'subtasks': [
              {
                'id': 'sub_sample_1_2_1',
                'title': 'Build responsive dashboard interface',
                'isCompleted': false,
              },
              {
                'id': 'sub_sample_1_2_2',
                'title': 'Create Auth and Sync REST APIs',
                'isCompleted': false,
              }
            ]
          },
          {
            'id': 'm_sample_1_3',
            'title': 'User Beta Testing & Launch',
            'isCompleted': false,
            'order': 2,
            'subtasks': [
              {
                'id': 'sub_sample_1_3_1',
                'title': 'Invite 10 beta testers to try app',
                'isCompleted': false,
              },
              {
                'id': 'sub_sample_1_3_2',
                'title': 'Deploy project to production server',
                'isCompleted': false,
              }
            ]
          }
        ]
      },
      {
        'id': 'goal_sample_2',
        'localId': 'goal_sample_2',
        'title': 'Run a Half Marathon',
        'category': 'Health',
        'target': 100,
        'currentProgress': 0,
        'status': 'in-progress',
        'priority': 'medium',
        'deadline': now.add(const Duration(days: 90)).toIso8601String(),
        'syncStatus': 'pending',
        'milestones': [
          {
            'id': 'm_sample_2_1',
            'title': 'Build Base Conditioning',
            'isCompleted': false,
            'order': 0,
            'subtasks': [
              {
                'id': 'sub_sample_2_1_1',
                'title': 'Run 5km without stopping',
                'isCompleted': false,
              },
              {
                'id': 'sub_sample_2_1_2',
                'title': 'Run 3 times a week consistently',
                'isCompleted': false,
              }
            ]
          },
          {
            'id': 'm_sample_2_2',
            'title': 'Increase Mileage & Stamina',
            'isCompleted': false,
            'order': 1,
            'subtasks': [
              {
                'id': 'sub_sample_2_2_1',
                'title': 'Complete a 12km long run',
                'isCompleted': false,
              }
            ]
          }
        ]
      }
    ]);

    // 6. Sample Habits
    await hiveDb.saveSelectedHabits([
      {
        'id': 'habit_sample_1',
        'localId': 'habit_sample_1',
        'title': '🏋 Workout Routine',
        'category': 'Health',
        'difficulty': 'Medium',
        'isEnabled': true,
        'syncStatus': 'pending',
      },
      {
        'id': 'habit_sample_2',
        'localId': 'habit_sample_2',
        'title': '📖 Read 25 Pages',
        'category': 'Productivity',
        'difficulty': 'Easy',
        'isEnabled': true,
        'syncStatus': 'pending',
      },
      {
        'id': 'habit_sample_3',
        'localId': 'habit_sample_3',
        'title': '💰 Track Expenses',
        'category': 'Finance',
        'difficulty': 'Easy',
        'isEnabled': true,
        'syncStatus': 'pending',
      },
    ]);

    // 7. Sample Tasks/Todos
    await hiveDb.saveTodos([
      {
        'id': 'todo_sample_1',
        'title': '🚀 Design Landing Page Copy',
        'isCompleted': false,
        'syncStatus': 'pendingCreate',
        'createdAt': now.subtract(const Duration(hours: 4)).toIso8601String(),
        'subTodos': [
          {'id': 'sub_t_1', 'title': 'Write headline and value proposition', 'isCompleted': true},
          {'id': 'sub_t_2', 'title': 'Draft product feature explanations', 'isCompleted': false},
          {'id': 'sub_t_3', 'title': 'Add CTA buttons and social proof', 'isCompleted': false},
        ]
      },
      {
        'id': 'todo_sample_2',
        'title': '🥦 Meal Prep for the Week',
        'isCompleted': true,
        'syncStatus': 'pendingCreate',
        'createdAt': now.subtract(const Duration(hours: 12)).toIso8601String(),
        'subTodos': [
          {'id': 'sub_t_4', 'title': 'Grocery shopping for healthy greens', 'isCompleted': true},
          {'id': 'sub_t_5', 'title': 'Cook and pack lunches for Mon-Fri', 'isCompleted': true},
        ]
      },
      {
        'id': 'todo_sample_3',
        'title': '📈 Audit Investment Portfolio',
        'isCompleted': false,
        'syncStatus': 'pendingCreate',
        'createdAt': now.toIso8601String(),
        'subTodos': [
          {'id': 'sub_t_6', 'title': 'Check performance of equity index fund', 'isCompleted': false},
          {'id': 'sub_t_7', 'title': 'Rebalance assets to match risk profile', 'isCompleted': false},
        ]
      }
    ]);

    // 8. Sample Daily Affirmations in almost all categories
    await hiveDb.saveSelectedAffirmations([
      {
        'id': 'aff_sample_1',
        'localId': 'aff_sample_1',
        'text': 'I focus deeply on what matters, executing with clarity and precision.',
        'author': 'Daily Focus',
        'category': 'Productivity',
        'colorTheme': 'Deep Indigo',
        'isPinned': true,
        'syncStatus': 'pending',
      },
      {
        'id': 'aff_sample_2',
        'localId': 'aff_sample_2',
        'text': 'Abundance flows naturally into my life as I provide massive value to the world.',
        'author': 'Daily Abundance',
        'category': 'Wealth',
        'colorTheme': 'Warm Amber',
        'isPinned': false,
        'syncStatus': 'pending',
      },
      {
        'id': 'aff_sample_3',
        'localId': 'aff_sample_3',
        'text': 'I feed my body with nourishing food, deep sleep, and energizing workouts.',
        'author': 'Daily Health',
        'category': 'Health',
        'colorTheme': 'Emerald Green',
        'isPinned': false,
        'syncStatus': 'pending',
      },
      {
        'id': 'aff_sample_4',
        'localId': 'aff_sample_4',
        'text': 'Every challenge I face is a launching pad for my growth and adaptability.',
        'author': 'Daily Growth',
        'category': 'Growth',
        'colorTheme': 'Minimal White',
        'isPinned': true,
        'syncStatus': 'pending',
      },
      {
        'id': 'aff_sample_5',
        'localId': 'aff_sample_5',
        'text': 'I choose happiness, peace, and gratitude in this present moment.',
        'author': 'Daily Peace',
        'category': 'Gratitude',
        'colorTheme': 'Rose Quartz',
        'isPinned': false,
        'syncStatus': 'pending',
      },
      {
        'id': 'aff_sample_6',
        'localId': 'aff_sample_6',
        'text': 'I am fully centered, calm, and capable of achieving my daily goals.',
        'author': 'Daily Calm',
        'category': 'Self-Care',
        'colorTheme': 'Minimal White',
        'isPinned': false,
        'syncStatus': 'pending',
      }
    ]);

    // 9. Vision Board Items - Curated layout with all card types used
    final visionMeta = {
      'isOnShelf': false,
      'createdAt': now.toIso8601String(),
      'scale': 1.0,
      'opacity': 1.0,
    };

    await hiveDb.saveVisionItems([
      // Column 1 (Left side)
      {
        'id': 'vis_item_1',
        'type': 'stickyNote',
        'content': 'Focus on daily consistency. Tiny steps lead to massive gains over time. ✨',
        'x': -340.0,
        'y': -220.0,
        'width': 180.0,
        'height': 160.0,
        'rotation': -0.05,
        'colorValue': 0xFF1D4ED8, // Rich Blue
        'isPinned': true,
        'zIndex': 1,
        'attachmentType': 'pin',
        'attachmentStyle': 'redPin',
        'materialStyle': 'default',
        'metadata': visionMeta,
      },
      {
        'id': 'vis_item_2',
        'type': 'countdown',
        'content': 'MVP Product Launch',
        'x': -340.0,
        'y': 20.0,
        'width': 180.0,
        'height': 110.0,
        'rotation': 0.02,
        'colorValue': 0xFF7C2D12, // Warm Terracotta
        'isPinned': false,
        'zIndex': 2,
        'attachmentType': 'pin',
        'attachmentStyle': 'redPin',
        'materialStyle': 'default',
        'countdownDate': now.add(const Duration(days: 30)).toIso8601String(),
        'metadata': visionMeta,
      },

      // Column 2 (Center side)
      {
        'id': 'vis_item_3',
        'type': 'image',
        'content': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&q=80',
        'x': -100.0,
        'y': -240.0,
        'width': 220.0,
        'height': 170.0,
        'rotation': 0.03,
        'colorValue': 0xFF1E1B4B,
        'isPinned': false,
        'zIndex': 3,
        'attachmentType': 'tape',
        'attachmentStyle': 'beige',
        'materialStyle': 'polaroid',
        'metadata': visionMeta,
      },
      {
        'id': 'vis_item_4',
        'type': 'quote',
        'content': '"The secret of your future is hidden in your daily routine."',
        'x': -100.0,
        'y': -10.0,
        'width': 220.0,
        'height': 130.0,
        'rotation': -0.02,
        'colorValue': 0xFF0F172A,
        'isPinned': true,
        'zIndex': 4,
        'attachmentType': 'pin',
        'attachmentStyle': 'redPin',
        'materialStyle': 'kraft',
        'metadata': {
          ...visionMeta,
          'author': 'Mike Murdock',
        },
      },
      {
        'id': 'vis_item_5',
        'type': 'financeGoal',
        'content': 'Emergency Fund Goal',
        'x': -100.0,
        'y': 170.0,
        'width': 220.0,
        'height': 100.0,
        'rotation': 0.04,
        'colorValue': 0xFF065F46, // Deep Emerald
        'isPinned': false,
        'zIndex': 5,
        'attachmentType': 'tape',
        'attachmentStyle': 'beige',
        'materialStyle': 'default',
        'metadata': {
          ...visionMeta,
          'monthlyAmount': '1500',
          'targetAmount': '10000',
        },
      },

      // Column 3 (Right side)
      {
        'id': 'vis_item_6',
        'type': 'goal',
        'content': 'Launch Side Hustle MVP',
        'x': 180.0,
        'y': -220.0,
        'width': 200.0,
        'height': 130.0,
        'rotation': -0.04,
        'colorValue': 0xFF0F172A,
        'isPinned': false,
        'zIndex': 6,
        'attachmentType': 'pin',
        'attachmentStyle': 'redPin',
        'materialStyle': 'default',
        'secondaryContent': 'Productivity',
        'metadata': {
          ...visionMeta,
          'targetDate': now.add(const Duration(days: 30)).toIso8601String(),
          'category': 'Productivity',
        },
      },
      {
        'id': 'vis_item_7',
        'type': 'affirmation',
        'content': 'I build the future I deserve through bold execution today.',
        'x': 180.0,
        'y': -40.0,
        'width': 200.0,
        'height': 120.0,
        'rotation': 0.02,
        'colorValue': 0xFF5B21B6, // Deep Royal Purple
        'isPinned': false,
        'zIndex': 7,
        'attachmentType': 'tape',
        'attachmentStyle': 'beige',
        'materialStyle': 'default',
        'metadata': {
          ...visionMeta,
          'category': 'Growth',
        },
      },
      {
        'id': 'vis_item_8',
        'type': 'task',
        'content': 'Write Landing Page Script',
        'x': 180.0,
        'y': 130.0,
        'width': 200.0,
        'height': 140.0,
        'rotation': -0.03,
        'colorValue': 0xFF0F172A,
        'isPinned': true,
        'zIndex': 8,
        'attachmentType': 'pin',
        'attachmentStyle': 'redPin',
        'materialStyle': 'default',
        'metadata': visionMeta,
      }
    ]);

    // 10. Premium Demo Tasks — Interactive product tour for guest experience
    // ~70% appear in Today (no dueDate), ~30% in Upcoming (future dueDate)
    await hiveDb.saveTasks([
      // ── Showcases Vision Room / Image Board / Custom Layout ──
      {
        'id': 'task_demo_1',
        'title': '🎯 Build Your Dream Vision Room',
        'description':
            'Explore every feature with these sample tasks. Showcases Vision Room, Image Board, and Custom Layout.',
        'category': 'Vision Room',
        'priority': 'high',
        'status': 'in_progress',
        'progress': 40.0,
        'manualProgress': 40.0,
        'completed': false,
        'pinned': true,
        'dueTime': '09:00 AM',
        'reminder': true,
        'reminderStyle': 'balanced',
        'syncStatus': 'pending',
        'createdAt': now.subtract(const Duration(days: 2)).toIso8601String(),
        'subtasks': [
          {'id': 'st_1_1', 'title': 'Add a dream home image', 'completed': true, 'sortOrder': 0, 'createdAt': now.subtract(const Duration(days: 2)).toIso8601String(), 'completedAt': now.subtract(const Duration(days: 1)).toIso8601String()},
          {'id': 'st_1_2', 'title': 'Pin your dream car', 'completed': false, 'sortOrder': 1, 'createdAt': now.subtract(const Duration(days: 1)).toIso8601String()},
          {'id': 'st_1_3', 'title': 'Add travel destinations', 'completed': false, 'sortOrder': 2, 'createdAt': now.subtract(const Duration(days: 1)).toIso8601String()},
          {'id': 'st_1_4', 'title': 'Organize your vision wall', 'completed': false, 'sortOrder': 3, 'createdAt': now.subtract(const Duration(days: 1)).toIso8601String()},
          {'id': 'st_1_5', 'title': 'Customize room theme', 'completed': false, 'sortOrder': 4, 'createdAt': now.subtract(const Duration(days: 1)).toIso8601String()},
        ],
      },
      // ── Showcases Daily Spark / Categories / Favorites / Custom Affirmations ──
      {
        'id': 'task_demo_2',
        'title': '✨ Create Daily Affirmations',
        'description':
            'Showcases Daily Spark, Categories, Favorites, and Custom Affirmations.',
        'category': 'Affirmations',
        'priority': 'medium',
        'status': 'in_progress',
        'progress': 20.0,
        'manualProgress': 20.0,
        'completed': false,
        'pinned': false,
        'dueTime': '08:00 AM',
        'reminder': true,
        'reminderStyle': 'minimal',
        'syncStatus': 'pending',
        'createdAt': now.subtract(const Duration(days: 3)).toIso8601String(),
        'subtasks': [
          {'id': 'st_2_1', 'title': 'Create your first affirmation', 'completed': true, 'sortOrder': 0, 'createdAt': now.subtract(const Duration(days: 3)).toIso8601String(), 'completedAt': now.subtract(const Duration(days: 2)).toIso8601String()},
          {'id': 'st_2_2', 'title': 'Pin today\'s favorite', 'completed': false, 'sortOrder': 1, 'createdAt': now.subtract(const Duration(days: 2)).toIso8601String()},
          {'id': 'st_2_3', 'title': 'Open Daily Spark board', 'completed': false, 'sortOrder': 2, 'createdAt': now.subtract(const Duration(days: 2)).toIso8601String()},
          {'id': 'st_2_4', 'title': 'Read today\'s motivation', 'completed': false, 'sortOrder': 3, 'createdAt': now.subtract(const Duration(days: 2)).toIso8601String()},
          {'id': 'st_2_5', 'title': 'Save your own affirmation', 'completed': false, 'sortOrder': 4, 'createdAt': now.subtract(const Duration(days: 2)).toIso8601String()},
        ],
      },
      // ── Showcases Goal Planner / Roadmap / Progress Tracking ──
      {
        'id': 'task_demo_3',
        'title': '🏆 Plan Your Biggest Goal',
        'description':
            'Showcases Goal Planner, Roadmap, and Progress Tracking.',
        'category': 'Goals',
        'priority': 'high',
        'status': 'in_progress',
        'progress': 20.0,
        'manualProgress': 20.0,
        'completed': false,
        'pinned': true,
        'dueTime': '10:00 AM',
        'reminder': true,
        'reminderStyle': 'balanced',
        'syncStatus': 'pending',
        'createdAt': now.subtract(const Duration(days: 4)).toIso8601String(),
        'subtasks': [
          {'id': 'st_3_1', 'title': 'Create a goal', 'completed': true, 'sortOrder': 0, 'createdAt': now.subtract(const Duration(days: 4)).toIso8601String(), 'completedAt': now.subtract(const Duration(days: 3)).toIso8601String()},
          {'id': 'st_3_2', 'title': 'Add milestones', 'completed': false, 'sortOrder': 1, 'dueDate': now.add(const Duration(days: 2)).toIso8601String(), 'createdAt': now.subtract(const Duration(days: 3)).toIso8601String()},
          {'id': 'st_3_3', 'title': 'Add subtasks', 'completed': false, 'sortOrder': 2, 'dueDate': now.add(const Duration(days: 3)).toIso8601String(), 'createdAt': now.subtract(const Duration(days: 3)).toIso8601String()},
          {'id': 'st_3_4', 'title': 'Track progress', 'completed': false, 'sortOrder': 3, 'dueDate': now.add(const Duration(days: 5)).toIso8601String(), 'createdAt': now.subtract(const Duration(days: 3)).toIso8601String()},
          {'id': 'st_3_5', 'title': 'Complete first milestone', 'completed': false, 'sortOrder': 4, 'dueDate': now.add(const Duration(days: 7)).toIso8601String(), 'createdAt': now.subtract(const Duration(days: 3)).toIso8601String()},
        ],
      },
      // ── Showcases Tasks / Subtasks / Priority / Reminders ──
      {
        'id': 'task_demo_4',
        'title': '📌 Organize Today\'s Targets',
        'description':
            'Showcases Tasks, Subtasks, Priority, and Reminders.',
        'category': 'Productivity',
        'priority': 'high',
        'status': 'in_progress',
        'progress': 20.0,
        'manualProgress': 20.0,
        'completed': false,
        'pinned': false,
        'dueTime': '09:30 AM',
        'reminder': true,
        'reminderStyle': 'balanced',
        'syncStatus': 'pending',
        'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
        'subtasks': [
          {'id': 'st_4_1', 'title': 'Create a task', 'completed': true, 'sortOrder': 0, 'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(), 'completedAt': now.subtract(const Duration(days: 1)).toIso8601String()},
          {'id': 'st_4_2', 'title': 'Add three subtasks', 'completed': false, 'sortOrder': 1, 'createdAt': now.subtract(const Duration(days: 1)).toIso8601String()},
          {'id': 'st_4_3', 'title': 'Set reminder time', 'completed': false, 'sortOrder': 2, 'createdAt': now.subtract(const Duration(days: 1)).toIso8601String()},
          {'id': 'st_4_4', 'title': 'Assign priority', 'completed': false, 'sortOrder': 3, 'createdAt': now.subtract(const Duration(days: 1)).toIso8601String()},
          {'id': 'st_4_5', 'title': 'Complete today\'s target', 'completed': false, 'sortOrder': 4, 'createdAt': now.subtract(const Duration(days: 1)).toIso8601String()},
        ],
      },
      // ── Showcases Savings Goals / Progress / Target Date ──
      {
        'id': 'task_demo_5',
        'title': '💰 Create a Finance Goal',
        'description':
            'Showcases Savings Goals, Progress, and Target Date tracking.',
        'category': 'Finance',
        'priority': 'medium',
        'status': 'in_progress',
        'progress': 0.0,
        'manualProgress': 0.0,
        'completed': false,
        'pinned': false,
        'dueDate': now.add(const Duration(days: 30)).toIso8601String(),
        'dueTime': '06:00 PM',
        'reminder': true,
        'reminderStyle': 'minimal',
        'syncStatus': 'pending',
        'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
        'subtasks': [
          {'id': 'st_5_1', 'title': 'Set target amount', 'completed': true, 'sortOrder': 0, 'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(), 'completedAt': now.toIso8601String()},
          {'id': 'st_5_2', 'title': 'Monthly savings plan', 'completed': false, 'sortOrder': 1, 'dueDate': now.add(const Duration(days: 7)).toIso8601String(), 'createdAt': now.subtract(const Duration(days: 1)).toIso8601String()},
          {'id': 'st_5_3', 'title': 'Add motivation', 'completed': false, 'sortOrder': 2, 'createdAt': now.subtract(const Duration(days: 1)).toIso8601String()},
          {'id': 'st_5_4', 'title': 'Track savings progress', 'completed': false, 'sortOrder': 3, 'dueDate': now.add(const Duration(days: 14)).toIso8601String(), 'createdAt': now.subtract(const Duration(days: 1)).toIso8601String()},
          {'id': 'st_5_5', 'title': 'Reach first milestone', 'completed': false, 'sortOrder': 4, 'dueDate': now.add(const Duration(days: 30)).toIso8601String(), 'createdAt': now.subtract(const Duration(days: 1)).toIso8601String()},
        ],
      },
      // ── Showcases Notifications / Countdown / Due Time ──
      {
        'id': 'task_demo_6',
        'title': '⏰ Smart Reminder Setup',
        'description':
            'Showcases Notifications, Countdown, and Due Time scheduling.',
        'category': 'Productivity',
        'priority': 'medium',
        'status': 'in_progress',
        'progress': 0.0,
        'manualProgress': 0.0,
        'completed': false,
        'pinned': false,
        'dueDate': now.add(const Duration(days: 3)).toIso8601String(),
        'dueTime': '02:00 PM',
        'reminder': true,
        'reminderStyle': 'balanced',
        'syncStatus': 'pending',
        'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
        'subtasks': [
          {'id': 'st_6_1', 'title': 'Select due date', 'completed': false, 'sortOrder': 0, 'createdAt': now.subtract(const Duration(days: 1)).toIso8601String()},
          {'id': 'st_6_2', 'title': 'Set due time', 'completed': false, 'sortOrder': 1, 'createdAt': now.subtract(const Duration(days: 1)).toIso8601String()},
          {'id': 'st_6_3', 'title': 'Enable reminders', 'completed': false, 'sortOrder': 2, 'createdAt': now.subtract(const Duration(days: 1)).toIso8601String()},
          {'id': 'st_6_4', 'title': 'Receive notification', 'completed': false, 'sortOrder': 3, 'createdAt': now.subtract(const Duration(days: 1)).toIso8601String()},
          {'id': 'st_6_5', 'title': 'Mark task complete', 'completed': false, 'sortOrder': 4, 'createdAt': now.subtract(const Duration(days: 1)).toIso8601String()},
        ],
      },
      // ── Showcases Sticky Notes / Quotes / Polaroids ──
      {
        'id': 'task_demo_7',
        'title': '🖼️ Design Your Vision Board',
        'description':
            'Showcases Sticky Notes, Quotes, and Polaroid-style photos.',
        'category': 'Vision Room',
        'priority': 'medium',
        'status': 'in_progress',
        'progress': 0.0,
        'manualProgress': 0.0,
        'completed': false,
        'pinned': false,
        'dueDate': now.add(const Duration(days: 14)).toIso8601String(),
        'dueTime': '12:00 PM',
        'reminder': true,
        'reminderStyle': 'minimal',
        'syncStatus': 'pending',
        'createdAt': now.subtract(const Duration(days: 2)).toIso8601String(),
        'subtasks': [
          {'id': 'st_7_1', 'title': 'Add Polaroid photo', 'completed': false, 'sortOrder': 0, 'dueDate': now.add(const Duration(days: 3)).toIso8601String(), 'createdAt': now.subtract(const Duration(days: 2)).toIso8601String()},
          {'id': 'st_7_2', 'title': 'Create sticky note', 'completed': false, 'sortOrder': 1, 'dueDate': now.add(const Duration(days: 5)).toIso8601String(), 'createdAt': now.subtract(const Duration(days: 2)).toIso8601String()},
          {'id': 'st_7_3', 'title': 'Add motivational quote', 'completed': false, 'sortOrder': 2, 'dueDate': now.add(const Duration(days: 7)).toIso8601String(), 'createdAt': now.subtract(const Duration(days: 2)).toIso8601String()},
          {'id': 'st_7_4', 'title': 'Arrange cards', 'completed': false, 'sortOrder': 3, 'dueDate': now.add(const Duration(days: 10)).toIso8601String(), 'createdAt': now.subtract(const Duration(days: 2)).toIso8601String()},
          {'id': 'st_7_5', 'title': 'Save workspace', 'completed': false, 'sortOrder': 4, 'dueDate': now.add(const Duration(days: 14)).toIso8601String(), 'createdAt': now.subtract(const Duration(days: 2)).toIso8601String()},
        ],
      },
      // ── Showcases Finance Tracking / Long-term Goals ──
      {
        'id': 'task_demo_8',
        'title': '🚗 Save for BMW S1000RR',
        'description':
            'Showcases Finance Tracking and Long-term Goal milestones.',
        'category': 'Finance',
        'priority': 'high',
        'status': 'in_progress',
        'progress': 0.0,
        'manualProgress': 0.0,
        'completed': false,
        'pinned': false,
        'dueTime': '07:00 PM',
        'reminder': true,
        'reminderStyle': 'minimal',
        'syncStatus': 'pending',
        'createdAt': now.subtract(const Duration(days: 3)).toIso8601String(),
        'subtasks': [
          {'id': 'st_8_1', 'title': 'Save ₹10,000', 'completed': false, 'sortOrder': 0, 'dueDate': now.add(const Duration(days: 30)).toIso8601String(), 'createdAt': now.subtract(const Duration(days: 3)).toIso8601String()},
          {'id': 'st_8_2', 'title': 'Skip unnecessary purchases', 'completed': false, 'sortOrder': 1, 'createdAt': now.subtract(const Duration(days: 3)).toIso8601String()},
          {'id': 'st_8_3', 'title': 'Update savings progress', 'completed': false, 'sortOrder': 2, 'dueDate': now.add(const Duration(days: 7)).toIso8601String(), 'createdAt': now.subtract(const Duration(days: 3)).toIso8601String()},
          {'id': 'st_8_4', 'title': 'Review monthly goal', 'completed': false, 'sortOrder': 3, 'dueDate': now.add(const Duration(days: 14)).toIso8601String(), 'createdAt': now.subtract(const Duration(days: 3)).toIso8601String()},
        ],
      },
      // ── Real-life example: Personal ──
      {
        'id': 'task_demo_9',
        'title': '✈️ Plan Your Dream Vacation',
        'description':
            'A realistic personal goal to plan and save for your next big trip.',
        'category': 'Personal',
        'priority': 'medium',
        'status': 'in_progress',
        'progress': 25.0,
        'manualProgress': 25.0,
        'completed': false,
        'pinned': false,
        'dueTime': '08:00 PM',
        'reminder': false,
        'reminderStyle': 'none',
        'syncStatus': 'pending',
        'createdAt': now.subtract(const Duration(days: 7)).toIso8601String(),
        'subtasks': [
          {'id': 'st_9_1', 'title': 'Choose destination', 'completed': true, 'sortOrder': 0, 'createdAt': now.subtract(const Duration(days: 7)).toIso8601String(), 'completedAt': now.subtract(const Duration(days: 5)).toIso8601String()},
          {'id': 'st_9_2', 'title': 'Save travel budget', 'completed': false, 'sortOrder': 1, 'dueDate': now.add(const Duration(days: 30)).toIso8601String(), 'createdAt': now.subtract(const Duration(days: 5)).toIso8601String()},
          {'id': 'st_9_3', 'title': 'Book flights', 'completed': false, 'sortOrder': 2, 'dueDate': now.add(const Duration(days: 60)).toIso8601String(), 'createdAt': now.subtract(const Duration(days: 5)).toIso8601String()},
          {'id': 'st_9_4', 'title': 'Create packing checklist', 'completed': false, 'sortOrder': 3, 'dueDate': now.add(const Duration(days: 65)).toIso8601String(), 'createdAt': now.subtract(const Duration(days: 5)).toIso8601String()},
        ],
      },
      // ── Real-life example: Health ──
      {
        'id': 'task_demo_10',
        'title': '💪 Build Better Habits',
        'description':
            'A realistic health routine to build consistency with daily habits.',
        'category': 'Health',
        'priority': 'low',
        'status': 'in_progress',
        'progress': 50.0,
        'manualProgress': 50.0,
        'completed': false,
        'pinned': false,
        'dueTime': '06:00 AM',
        'reminder': true,
        'reminderStyle': 'minimal',
        'syncStatus': 'pending',
        'createdAt': now.subtract(const Duration(days: 14)).toIso8601String(),
        'subtasks': [
          {'id': 'st_10_1', 'title': 'Morning workout', 'completed': true, 'sortOrder': 0, 'createdAt': now.subtract(const Duration(days: 14)).toIso8601String(), 'completedAt': now.subtract(const Duration(days: 1)).toIso8601String()},
          {'id': 'st_10_2', 'title': 'Drink 2L water', 'completed': true, 'sortOrder': 1, 'createdAt': now.subtract(const Duration(days: 14)).toIso8601String(), 'completedAt': now.subtract(const Duration(days: 1)).toIso8601String()},
          {'id': 'st_10_3', 'title': 'Sleep before 11 PM', 'completed': false, 'sortOrder': 2, 'dueDate': now.add(const Duration(days: 1)).toIso8601String(), 'dueTime': '11:00 PM', 'createdAt': now.subtract(const Duration(days: 7)).toIso8601String()},
          {'id': 'st_10_4', 'title': 'Read for 20 minutes', 'completed': false, 'sortOrder': 3, 'dueDate': now.add(const Duration(days: 1)).toIso8601String(), 'dueTime': '09:00 PM', 'createdAt': now.subtract(const Duration(days: 7)).toIso8601String()},
        ],
      },
    ]);

    // 11. Enhanced Goals with Roadmaps
    await hiveDb.saveSelectedGoals([
      {
        'id': 'goal_demo_1',
        'localId': 'goal_demo_1',
        'title': 'BMW S1000RR',
        'category': 'Finance',
        'target': 100,
        'currentProgress': 25,
        'status': 'in-progress',
        'priority': 'high',
        'deadline': DateTime(2026, 9, 30).toIso8601String(),
        'syncStatus': 'pending',
        'milestones': [
          {
            'id': 'm_demo_1_1',
            'title': 'Save First ₹5,00,000',
            'isCompleted': true,
            'order': 0,
            'subtasks': [
              {'id': 'sub_d_1_1_1', 'title': 'Open dedicated savings account', 'isCompleted': true},
              {'id': 'sub_d_1_1_2', 'title': 'Set up monthly auto-transfer ₹50,000', 'isCompleted': true},
            ]
          },
          {
            'id': 'm_demo_1_2',
            'title': 'Reach ₹15,00,000 Mark',
            'isCompleted': false,
            'order': 1,
            'subtasks': [
              {'id': 'sub_d_1_2_1', 'title': 'Increase monthly savings to ₹75,000', 'isCompleted': false},
              {'id': 'sub_d_1_2_2', 'title': 'Review investment returns quarterly', 'isCompleted': false},
            ]
          },
          {
            'id': 'm_demo_1_3',
            'title': 'Purchase & Registration',
            'isCompleted': false,
            'order': 2,
            'subtasks': [
              {'id': 'sub_d_1_3_1', 'title': 'Visit BMW showroom for test ride', 'isCompleted': false},
              {'id': 'sub_d_1_3_2', 'title': 'Complete loan documentation', 'isCompleted': false},
            ]
          }
        ]
      },
      {
        'id': 'goal_demo_2',
        'localId': 'goal_demo_2',
        'title': 'Dream Home',
        'category': 'Finance',
        'target': 100,
        'currentProgress': 45,
        'status': 'in-progress',
        'priority': 'high',
        'deadline': DateTime(2028, 12, 31).toIso8601String(),
        'syncStatus': 'pending',
        'milestones': [
          {
            'id': 'm_demo_2_1',
            'title': 'Save Down Payment',
            'isCompleted': true,
            'order': 0,
            'subtasks': [
              {'id': 'sub_d_2_1_1', 'title': 'Research property rates in preferred area', 'isCompleted': true},
              {'id': 'sub_d_2_1_2', 'title': 'Start SIP for down payment fund', 'isCompleted': true},
            ]
          },
          {
            'id': 'm_demo_2_2',
            'title': 'Get Loan Pre-Approval',
            'isCompleted': false,
            'order': 1,
            'subtasks': [
              {'id': 'sub_d_2_2_1', 'title': 'Improve credit score to 750+', 'isCompleted': false},
              {'id': 'sub_d_2_2_2', 'title': 'Compare bank loan offers', 'isCompleted': false},
            ]
          },
        ]
      },
      {
        'id': 'goal_demo_3',
        'localId': 'goal_demo_3',
        'title': 'Travel Japan',
        'category': 'Lifestyle',
        'target': 100,
        'currentProgress': 15,
        'status': 'in-progress',
        'priority': 'medium',
        'deadline': DateTime(2027, 3, 15).toIso8601String(),
        'syncStatus': 'pending',
        'milestones': [
          {
            'id': 'm_demo_3_1',
            'title': 'Plan Itinerary',
            'isCompleted': true,
            'order': 0,
            'subtasks': [
              {'id': 'sub_d_3_1_1', 'title': 'Research Tokyo, Kyoto, Osaka routes', 'isCompleted': true},
              {'id': 'sub_d_3_1_2', 'title': 'Book Japan Rail Pass', 'isCompleted': false},
            ]
          },
          {
            'id': 'm_demo_3_2',
            'title': 'Save ₹3,00,000 Travel Fund',
            'isCompleted': false,
            'order': 1,
            'subtasks': [
              {'id': 'sub_d_3_2_1', 'title': 'Set aside ₹25,000/month', 'isCompleted': false},
            ]
          },
        ]
      },
    ]);

    // 12. Enhanced Affirmations — More categories and richer content
    await hiveDb.saveSelectedAffirmations([
      {
        'id': 'aff_demo_1', 'localId': 'aff_demo_1',
        'text': 'My mind is sharp, focused, and ready for greatness today.',
        'author': 'Getzio', 'category': 'Mindset', 'colorTheme': 'Deep Indigo',
        'isPinned': true, 'syncStatus': 'pending',
      },
      {
        'id': 'aff_demo_2', 'localId': 'aff_demo_2',
        'text': 'I nourish my body with movement, rest, and whole foods every single day.',
        'author': 'Getzio', 'category': 'Health', 'colorTheme': 'Emerald Green',
        'isPinned': false, 'syncStatus': 'pending',
      },
      {
        'id': 'aff_demo_3', 'localId': 'aff_demo_3',
        'text': 'Success is inevitable when I show up daily and give my absolute best.',
        'author': 'Getzio', 'category': 'Success', 'colorTheme': 'Warm Amber',
        'isPinned': true, 'syncStatus': 'pending',
      },
      {
        'id': 'aff_demo_4', 'localId': 'aff_demo_4',
        'text': 'Every challenge I face is a launching pad for my personal evolution.',
        'author': 'Getzio', 'category': 'Growth', 'colorTheme': 'Minimal White',
        'isPinned': false, 'syncStatus': 'pending',
      },
      {
        'id': 'aff_demo_5', 'localId': 'aff_demo_5',
        'text': 'Discipline today creates the freedom I crave tomorrow.',
        'author': 'Getzio', 'category': 'Discipline', 'colorTheme': 'Deep Indigo',
        'isPinned': true, 'syncStatus': 'pending',
      },
      {
        'id': 'aff_demo_6', 'localId': 'aff_demo_6',
        'text': 'I trust the process, move forward with conviction, and let faith guide me.',
        'author': 'Getzio', 'category': 'Faith', 'colorTheme': 'Rose Quartz',
        'isPinned': false, 'syncStatus': 'pending',
      },
      {
        'id': 'aff_demo_7', 'localId': 'aff_demo_7',
        'text': 'I am grateful for this moment and the infinite opportunities it holds.',
        'author': 'Getzio', 'category': 'Gratitude', 'colorTheme': 'Emerald Green',
        'isPinned': false, 'syncStatus': 'pending',
      },
    ]);

    // 13. Enhanced Vision Room Items — More variety
    await hiveDb.saveVisionItems([
      // Column 1 (Left)
      {
        'id': 'vis_demo_1', 'type': 'stickyNote',
        'content': 'Focus on daily consistency. Tiny steps lead to massive gains. ✨',
        'x': -340.0, 'y': -220.0, 'width': 180.0, 'height': 160.0, 'rotation': -0.05,
        'colorValue': 0xFF1D4ED8, 'isPinned': true, 'zIndex': 1,
        'attachmentType': 'pin', 'attachmentStyle': 'redPin', 'materialStyle': 'default',
        'metadata': visionMeta,
      },
      {
        'id': 'vis_demo_2', 'type': 'countdown',
        'content': 'Launch Startup', 'countdownDate': now.add(const Duration(days: 29)).toIso8601String(),
        'x': -340.0, 'y': 20.0, 'width': 180.0, 'height': 110.0, 'rotation': 0.02,
        'colorValue': 0xFF7C2D12, 'isPinned': false, 'zIndex': 2,
        'attachmentType': 'pin', 'attachmentStyle': 'redPin', 'materialStyle': 'default',
        'metadata': visionMeta,
      },
      {
        'id': 'vis_demo_countdown_2', 'type': 'countdown',
        'content': 'Japan Trip', 'countdownDate': now.add(const Duration(days: 250)).toIso8601String(),
        'x': -340.0, 'y': 180.0, 'width': 180.0, 'height': 110.0, 'rotation': -0.01,
        'colorValue': 0xFF1E3A5F, 'isPinned': false, 'zIndex': 12,
        'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default',
        'metadata': visionMeta,
      },
      // Column 2 (Center)
      {
        'id': 'vis_demo_3', 'type': 'image',
        'content': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&q=80',
        'x': -100.0, 'y': -240.0, 'width': 220.0, 'height': 170.0, 'rotation': 0.03,
        'colorValue': 0xFF1E1B4B, 'isPinned': false, 'zIndex': 3,
        'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'polaroid',
        'metadata': visionMeta,
      },
      {
        'id': 'vis_demo_4', 'type': 'quote',
        'content': '"The secret of your future is hidden in your daily routine."',
        'x': -100.0, 'y': -10.0, 'width': 220.0, 'height': 130.0, 'rotation': -0.02,
        'colorValue': 0xFF0F172A, 'isPinned': true, 'zIndex': 4,
        'attachmentType': 'pin', 'attachmentStyle': 'redPin', 'materialStyle': 'kraft',
        'metadata': {...visionMeta, 'author': 'Mike Murdock'},
      },
      {
        'id': 'vis_demo_5', 'type': 'financeGoal',
        'content': 'Emergency Fund',
        'x': -100.0, 'y': 170.0, 'width': 220.0, 'height': 100.0, 'rotation': 0.04,
        'colorValue': 0xFF065F46, 'isPinned': false, 'zIndex': 5,
        'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default',
        'metadata': {...visionMeta, 'monthlyAmount': '15000', 'targetAmount': '200000'},
      },
      {
        'id': 'vis_demo_finance_2', 'type': 'financeGoal',
        'content': 'MacBook Pro Fund',
        'x': -100.0, 'y': 320.0, 'width': 220.0, 'height': 100.0, 'rotation': -0.01,
        'colorValue': 0xFF374151, 'isPinned': false, 'zIndex': 13,
        'attachmentType': 'pin', 'attachmentStyle': 'redPin', 'materialStyle': 'default',
        'metadata': {...visionMeta, 'monthlyAmount': '10000', 'targetAmount': '150000'},
      },
      // Column 3 (Right)
      {
        'id': 'vis_demo_6', 'type': 'goal',
        'content': 'Launch Side Hustle MVP', 'secondaryContent': 'Productivity',
        'x': 180.0, 'y': -220.0, 'width': 200.0, 'height': 130.0, 'rotation': -0.04,
        'colorValue': 0xFF0F172A, 'isPinned': false, 'zIndex': 6,
        'attachmentType': 'pin', 'attachmentStyle': 'redPin', 'materialStyle': 'default',
        'metadata': {...visionMeta, 'targetDate': now.add(const Duration(days: 30)).toIso8601String(), 'category': 'Productivity'},
      },
      {
        'id': 'vis_demo_7', 'type': 'quote',
        'content': '"Stay hungry. Stay foolish."',
        'x': 180.0, 'y': -40.0, 'width': 200.0, 'height': 120.0, 'rotation': 0.02,
        'colorValue': 0xFF5B21B6, 'isPinned': false, 'zIndex': 7,
        'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default',
        'metadata': {...visionMeta, 'author': 'Steve Jobs'},
      },
      {
        'id': 'vis_demo_8', 'type': 'task',
        'content': 'Write Landing Page Script',
        'x': 180.0, 'y': 130.0, 'width': 200.0, 'height': 140.0, 'rotation': -0.03,
        'colorValue': 0xFF0F172A, 'isPinned': true, 'zIndex': 8,
        'attachmentType': 'pin', 'attachmentStyle': 'redPin', 'materialStyle': 'default',
        'metadata': visionMeta,
      },
      {
        'id': 'vis_demo_countdown_3', 'type': 'countdown',
        'content': 'Birthday', 'countdownDate': now.add(const Duration(days: 110)).toIso8601String(),
        'x': 180.0, 'y': 310.0, 'width': 200.0, 'height': 110.0, 'rotation': 0.01,
        'colorValue': 0xFF831843, 'isPinned': false, 'zIndex': 14,
        'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default',
        'metadata': visionMeta,
      },
    ]);

    await hiveDb.saveSampleDataSeeded(true);
    await hiveDb.saveSampleDataVersion(currentVersion);
    dev.log('$_logTag Seeding completed successfully!');
  }
}
