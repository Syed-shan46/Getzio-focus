import 'dart:convert';
import 'dart:developer' as dev;
import '../../core/storage/hive_database.dart';

class SampleDataSeedingService {
  static const String _logTag = '[SampleDataSeeding]';

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
      'woodTexture': 'Walnut',
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

    await hiveDb.saveSetupCompleted(true);
    dev.log('$_logTag Seeding completed successfully!');
  }
}
