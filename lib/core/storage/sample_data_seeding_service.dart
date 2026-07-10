import 'dart:convert';
import 'dart:developer' as dev;
import '../../core/storage/hive_database.dart';

class SampleDataSeedingService {
  static const String _logTag = '[SampleDataSeeding]';
  static const int currentVersion = 3;

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
{'id': '14393812-96a0-467f-ac72-715425daa015', 'type': 'quote', 'content': 'Dream boldly, act consistently, and let your progress tell the story', 'x': 15.125000000000036, 'y': 444.4583333333335, 'width': 105.12311336904096, 'height': 60.07035049659484, 'rotation': -0.016384742596967747, 'colorValue': 4280163147, 'isPinned': false, 'emoji': null, 'countdownDate': null, 'secondaryContent': null, 'zIndex': 19, 'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default', 'metadata': {'isOnShelf': false, 'createdAt': '2026-07-05T18:12:25.751856', 'scale': 1.0, 'opacity': 1.0, 'quote': 'Dream boldly, act consistently, and let your progress tell the story', 'author': 'Getzio', 'style': 'Dark Luxury', 'font': '{"isOnShelf":false,"createdAt":"2026-07-05T18:12:25.751856","scale":1.0,"opacity":1.0,"quote":"Dream boldly, act consistently, and let your progress tell the story","author":"Getzio","style":"Dark Luxury","font":"{\\"isOnShelf\\":false,\\"createdAt\\":\\"2026-07-05T18:12:25.751856\\",\\"scale\\":1.0,\\"opacity\\":1.0,\\"quote\\":\\"Dream boldly, act consistently, and let your progress tell the story\\",\\"author\\":\\"Getzio\\",\\"style\\":\\"Dark Luxury\\"}","monthlyAmount":"","description":"","motivation":"","syncStatus":"synced","lastSyncedAt":"2026-07-05T18:55:12.330716"}', 'monthlyAmount': '', 'description': '', 'motivation': '', 'syncStatus': 'synced', 'lastSyncedAt': '2026-07-05T19:45:03.217929'}},
{'id': '3459e2dc-41c2-46c8-b612-cf6d803e27e8', 'type': 'task', 'content': 'Plan My Next Adventure', 'x': 211.6666666666667, 'y': 661.375, 'width': 72.12176994553303, 'height': 93.75830092919294, 'rotation': 0.013641484964018735, 'colorValue': 4280163147, 'isPinned': false, 'emoji': null, 'countdownDate': null, 'secondaryContent': null, 'zIndex': 21, 'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default', 'metadata': {'isOnShelf': false, 'createdAt': '2026-07-05T18:12:25.751918', 'scale': 1.0, 'opacity': 1.0, 'title': 'Plan My Next Adventure', 'priority': 'Medium', 'progress': 10.0, 'dueDate': '2026-07-31T00:00:00.000', 'checklist': [{'id': '1783252653138_0', 'title': 'Choose destination', 'isCompleted': false}, {'id': '1783252653138_1', 'title': 'Estimate budget', 'isCompleted': false}, {'id': '1783252653138_2', 'title': 'Create countdown', 'isCompleted': false}, {'id': '1783252653138_3', 'title': 'Save inspiration photos', 'isCompleted': false}], 'font': '{"isOnShelf":false,"createdAt":"2026-07-05T18:12:25.751918","scale":1.0,"opacity":1.0,"title":"Plan My Next Adventure","priority":"Medium","progress":10.0,"dueDate":"2026-07-31T00:00:00.000","checklist":[{"id":"1783252653138_0","title":"Choose destination","isCompleted":false},{"id":"1783252653138_1","title":"Estimate budget","isCompleted":false},{"id":"1783252653138_2","title":"Create countdown","isCompleted":false},{"id":"1783252653138_3","title":"Save inspiration photos","isCompleted":false}],"font":"{\\"isOnShelf\\":false,\\"createdAt\\":\\"2026-07-05T18:12:25.751918\\",\\"scale\\":1.0,\\"opacity\\":1.0,\\"title\\":\\"Plan My Next Adventure\\",\\"priority\\":\\"Medium\\",\\"progress\\":10.0,\\"dueDate\\":\\"2026-07-31T00:00:00.000\\",\\"checklist\\":[{\\"id\\":\\"1783252653138_0\\",\\"title\\":\\"Choose destination\\",\\"isCompleted\\":false},{\\"id\\":\\"1783252653138_1\\",\\"title\\":\\"Estimate budget\\",\\"isCompleted\\":false},{\\"id\\":\\"1783252653138_2\\",\\"title\\":\\"Create countdown\\",\\"isCompleted\\":false},{\\"id\\":\\"1783252653138_3\\",\\"title\\":\\"Save inspiration photos\\",\\"isCompleted\\":false}]}","monthlyAmount":"","description":"","motivation":"","syncStatus":"synced","lastSyncedAt":"2026-07-05T18:55:12.331022"}', 'monthlyAmount': '', 'description': '', 'motivation': '', 'syncStatus': 'synced', 'lastSyncedAt': '2026-07-05T19:45:03.218184'}},
{'id': '55dbfe5e-b561-4699-bce0-daed4c52dfd5', 'type': 'goal', 'content': 'Turn Dreams Into Goals', 'x': 120.83333333333312, 'y': 45.06250000000064, 'width': 155.72724154240066, 'height': 103.8181610282671, 'rotation': -6.297387864790242, 'colorValue': 4280163147, 'isPinned': false, 'emoji': null, 'countdownDate': null, 'secondaryContent': null, 'zIndex': 7, 'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default', 'metadata': {'isOnShelf': false, 'createdAt': '2026-07-04T15:50:01.643429', 'scale': 1.0, 'opacity': 1.0, 'title': 'Turn Dreams Into Goals', 'description': 'Create meaningful goals with milestones, priorities, due dates, and visual progress—all in one inspiring workspace.', 'progress': 40.0, 'dueDate': '2026-07-31T00:00:00.000', 'priority': 'High', 'color': 4285132974, 'font': '{"isOnShelf":false,"createdAt":"2026-07-04T15:50:01.643429","scale":1.0,"opacity":1.0,"title":"Turn Dreams Into Goals","description":"Create meaningful goals with milestones, priorities, due dates, and visual progress—all in one inspiring workspace.","progress":40.0,"dueDate":"2026-07-31T00:00:00.000","priority":"High","color":4285132974}', 'monthlyAmount': '', 'motivation': '', 'syncStatus': 'synced', 'lastSyncedAt': '2026-07-05T19:45:03.214765'}},
{'id': '55f235b3-23e8-4af1-87ac-16273e5650b5', 'type': 'image', 'content': 'https://res.cloudinary.com/dkiizrpqr/image/upload/v1783158787/focus_vision_board/dnxjsudr1pzfjpnhhz9j.jpg', 'x': 8.354166666666671, 'y': 334.7187499999999, 'width': 100.18467135636304, 'height': 100.18467135636304, 'rotation': -0.0102799161016967, 'colorValue': 4280163147, 'isPinned': false, 'emoji': null, 'countdownDate': '2026-07-31T00:00:00.000Z', 'secondaryContent': null, 'zIndex': 1, 'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default', 'metadata': {'isOnShelf': false, 'createdAt': '2026-07-04T15:50:01.643249', 'scale': 1.0, 'opacity': 1.0, 'progress': 52.0, 'caption': 'Dream House', 'emoji': 'heart', 'font': '{"isOnShelf":false,"createdAt":"2026-07-04T15:50:01.643249","scale":1.0,"opacity":1.0,"progress":52.0,"caption":"Dream House","emoji":"heart"}', 'monthlyAmount': '', 'description': '', 'motivation': '', 'syncStatus': 'synced', 'lastSyncedAt': '2026-07-05T19:45:03.213778'}},
{'id': '632d6e85-e82e-48f4-9701-ad6fdfaa1d02', 'type': 'quote', 'content': 'Every completed task is another promise you\'ve kept to yourself."', 'x': 126.25000000000003, 'y': 569.0625, 'width': 129.39061025139188, 'height': 73.93749157222392, 'rotation': -0.006838806977499057, 'colorValue': 4280163147, 'isPinned': false, 'emoji': null, 'countdownDate': null, 'secondaryContent': null, 'zIndex': 20, 'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default', 'metadata': {'isOnShelf': false, 'createdAt': '2026-07-05T18:12:25.751886', 'scale': 1.0, 'opacity': 1.0, 'quote': 'Every completed task is another promise you\'ve kept to yourself."', 'author': 'Getzio', 'style': 'Neon', 'font': '{"isOnShelf":false,"createdAt":"2026-07-05T18:12:25.751886","scale":1.0,"opacity":1.0,"quote":"Every completed task is another promise you\'ve kept to yourself.\\"","author":"Getzio","style":"Neon"}', 'monthlyAmount': '', 'description': '', 'motivation': '', 'syncStatus': 'synced', 'lastSyncedAt': '2026-07-05T19:45:03.217989'}},
{'id': '8338a5e3-6999-4b2c-98bd-43d9b358b479', 'type': 'task', 'content': 'Build My Vision Room', 'x': 17.416666666666607, 'y': 41.45833333333344, 'width': 83.60374480329399, 'height': 108.6848682442822, 'rotation': -0.027139915851516302, 'colorValue': 4280163147, 'isPinned': false, 'emoji': null, 'countdownDate': null, 'secondaryContent': null, 'zIndex': 17, 'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default', 'metadata': {'isOnShelf': false, 'createdAt': '2026-07-05T18:12:25.751745', 'scale': 1.0, 'opacity': 1.0, 'title': 'Build My Vision Room', 'priority': 'Medium', 'progress': 40.0, 'dueDate': null, 'checklist': [{'id': '1783250139636_0', 'title': 'Add dream house', 'isCompleted': false}, {'id': '1783250139636_1', 'title': 'Pin dream car', 'isCompleted': false}, {'id': '1783250139636_2', 'title': 'Add travel destination', 'isCompleted': false}, {'id': '1783250139636_3', 'title': 'Create motivationalquote', 'isCompleted': false}, {'id': '1783250139636_4', 'title': 'Arrange board layout', 'isCompleted': false}], 'font': '{"isOnShelf":false,"createdAt":"2026-07-05T18:12:25.751745","scale":1.0,"opacity":1.0,"title":"Build My Vision Room","priority":"Medium","progress":40.0,"dueDate":null,"checklist":[{"id":"1783250139636_0","title":"Add dream house","isCompleted":false},{"id":"1783250139636_1","title":"Pin dream car","isCompleted":false},{"id":"1783250139636_2","title":"Add travel destination","isCompleted":false},{"id":"1783250139636_3","title":"Create motivational quote","isCompleted":false},{"id":"1783250139636_4","title":"Arrange board layout","isCompleted":false}]}', 'monthlyAmount': '', 'description': '', 'motivation': '', 'syncStatus': 'synced', 'lastSyncedAt': '2026-07-05T19:45:03.217668'}},
{'id': '8aff44e5-37b7-443d-9127-b64f6c6a8be2', 'type': 'quote', 'content': 'Thank you for not giving up on the days when progress was invisible. That\'s why I\'m here', 'x': 224.6249999999999, 'y': 161.32291666666643, 'width': 135.78073513858376, 'height': 83.60902093533825, 'rotation': -0.029614621408659947, 'colorValue': 4280163147, 'isPinned': false, 'emoji': null, 'countdownDate': null, 'secondaryContent': null, 'zIndex': 6, 'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default', 'metadata': {'isOnShelf': false, 'createdAt': '2026-07-04T15:50:01.643373', 'scale': 1.0, 'opacity': 1.0, 'quote': 'Thank you for not giving up on the days when progress was invisible. That\'s why I\'m here', 'author': 'Future you', 'style': 'Typewriter', 'font': '{"isOnShelf":false,"createdAt":"2026-07-04T15:50:01.643373","scale":1.0,"opacity":1.0,"quote":"Thank you for not giving up on the days when progress was invisible. That\'s why I\'m here","author":"Future you","style":"Typewriter"}', 'monthlyAmount': '', 'description': '', 'motivation': '', 'syncStatus': 'synced', 'lastSyncedAt': '2026-07-05T19:45:03.214084'}},
{'id': '8d645e44-03bb-414d-a11a-a91681ed12a8', 'type': 'image', 'content': 'https://res.cloudinary.com/dkiizrpqr/image/upload/v1783254589/focus_vision_board/o7mimjbhpfjeaahvo1vy.jpg', 'x': 260.91666666666663, 'y': 510.2499999999998, 'width': 93.13380471269619, 'height': 93.13380471269619, 'rotation': -0.00997683274794714, 'colorValue': 4280163147, 'isPinned': false, 'emoji': null, 'countdownDate': null, 'secondaryContent': null, 'zIndex': 24, 'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default', 'metadata': {'isOnShelf': false, 'createdAt': '2026-07-05T18:12:25.752084', 'scale': 1.0, 'opacity': 1.0, 'progress': 38.0, 'caption': 'Keep growing', 'emoji': 'heart', 'font': '{"isOnShelf":false,"createdAt":"2026-07-05T18:12:25.752084","scale":1.0,"opacity":1.0,"progress":38.0,"caption":"Keep growing","emoji":"heart","font":"{\\"isOnShelf\\":false,\\"createdAt\\":\\"2026-07-05T18:12:25.752084\\",\\"scale\\":1.0,\\"opacity\\":1.0,\\"progress\\":38.0,\\"caption\\":\\"Keep growing\\",\\"emoji\\":\\"heart\\"}","monthlyAmount":"","description":"","motivation":"","syncStatus":"synced","lastSyncedAt":"2026-07-05T18:55:12.331263"}', 'monthlyAmount': '', 'description': '', 'motivation': '', 'syncStatus': 'synced', 'lastSyncedAt': '2026-07-05T19:45:03.218471'}},
{'id': '8f3aa04a-225a-4817-ba66-080e8414a078', 'type': 'countdown', 'content': '🏠 Move Into My Dream Home', 'x': 5.374999999999822, 'y': 339.29166666666646, 'width': 50.0, 'height': 50.0, 'rotation': 6.209836392180381, 'colorValue': 4280163147, 'isPinned': false, 'emoji': null, 'countdownDate': '2027-08-03T00:00:00.000Z', 'secondaryContent': null, 'zIndex': 11, 'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default', 'metadata': {'isOnShelf': false, 'createdAt': '2026-07-04T16:54:18.608130', 'scale': 1.0, 'opacity': 1.0, 'title': '🏠 Move Into My Dream Home', 'days': 395, 'targetDate': '2027-08-03T00:00:00.000', 'font': '{"isOnShelf":false,"createdAt":"2026-07-04T16:54:18.608130","scale":1.0,"opacity":1.0,"title":"🏠 Move Into My Dream Home","days":395,"targetDate":"2027-08-03T00:00:00.000"}', 'monthlyAmount': '', 'description': '', 'motivation': '', 'syncStatus': 'synced', 'lastSyncedAt': '2026-07-05T19:45:03.217081'}},
{'id': '989225ce-2374-4387-b79e-4c0ea1d0b1b0', 'type': 'image', 'content': 'https://res.cloudinary.com/dkiizrpqr/image/upload/v1783247472/focus_vision_board/xofnow3a6mwep0wsuzcw.jpg', 'x': 125.3541666666666, 'y': 163.39583333333297, 'width': 88.38603443114066, 'height': 88.38603443114066, 'rotation': -0.02761907251743506, 'colorValue': 4280163147, 'isPinned': false, 'emoji': null, 'countdownDate': '2027-07-12T00:00:00.000Z', 'secondaryContent': null, 'zIndex': 13, 'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default', 'metadata': {'isOnShelf': false, 'createdAt': '2026-07-05T16:04:17.665222', 'scale': 1.0, 'opacity': 1.0, 'progress': 30.0, 'caption': 'Drive your dream', 'emoji': 'heart', 'font': '{"isOnShelf":false,"createdAt":"2026-07-05T16:04:17.665222","scale":1.0,"opacity":1.0,"progress":30.0,"caption":"Drive your dream","emoji":"heart"}', 'monthlyAmount': '', 'description': '', 'motivation': '', 'syncStatus': 'synced', 'lastSyncedAt': '2026-07-05T19:45:03.217258'}},
{'id': '9f146ed7-c2a2-4409-9d78-c2f2d50cdfe0', 'type': 'image', 'content': 'https://res.cloudinary.com/dkiizrpqr/image/upload/v1783249606/focus_vision_board/eb8u4ojzyctsht4mbphw.jpg', 'x': 19.79166666666664, 'y': 238.53124999999994, 'width': 86.84498545017958, 'height': 86.84498545017958, 'rotation': -0.0258641309669001, 'colorValue': 4280163147, 'isPinned': false, 'emoji': null, 'countdownDate': '2026-09-30T00:00:00.000Z', 'secondaryContent': null, 'zIndex': 15, 'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default', 'metadata': {'isOnShelf': false, 'createdAt': '2026-07-05T18:12:25.751656', 'scale': 1.0, 'opacity': 1.0, 'progress': 18.0, 'caption': 'Explore the word', 'emoji': 'globe', 'font': '{"isOnShelf":false,"createdAt":"2026-07-05T18:12:25.751656","scale":1.0,"opacity":1.0,"progress":18.0,"caption":"Explore the word","emoji":"globe"}', 'monthlyAmount': '', 'description': '', 'motivation': '', 'syncStatus': 'synced', 'lastSyncedAt': '2026-07-05T19:45:03.217437'}},
{'id': 'ae7eb588-3ba3-42cf-a327-49a50884cd42', 'type': 'quote', 'content': 'Create beautiful quote cards with your favorite words, personal reflections, and memorable authors to inspire you every day.', 'x': 8.541666666666615, 'y': 166.00000000000003, 'width': 105.41664140557741, 'height': 60.238080803187096, 'rotation': -0.010914234486148422, 'colorValue': 4280163147, 'isPinned': false, 'emoji': null, 'countdownDate': null, 'secondaryContent': null, 'zIndex': 2, 'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default', 'metadata': {'isOnShelf': false, 'createdAt': '2026-07-04T15:50:01.643334', 'scale': 1.0, 'opacity': 1.0, 'quote': 'Create beautiful quote cards with your favorite words, personal reflections, and memorable authors to inspire you every day.', 'author': 'Getzio', 'style': 'Elegant Minimal', 'font': '{"isOnShelf":false,"createdAt":"2026-07-04T15:50:01.643334","scale":1.0,"opacity":1.0,"quote":"Create beautiful quote cards with your favorite words, personal reflections, and memorable authors to inspire you every day.","author":"Getzio","style":"Elegant Minimal"}', 'monthlyAmount': '', 'description': '', 'motivation': '', 'syncStatus': 'synced', 'lastSyncedAt': '2026-07-05T19:45:03.213989'}},
{'id': 'af2c4b64-e7ca-4c76-8f83-2dd62324d903', 'type': 'image', 'content': 'https://res.cloudinary.com/dkiizrpqr/image/upload/v1783254490/focus_vision_board/nvlq148mgecnafwhfjzm.jpg', 'x': 125.35416666666671, 'y': 358.34374999999994, 'width': 137.65599917169124, 'height': 137.65599917169124, 'rotation': -0.007444767843179739, 'colorValue': 4280163147, 'isPinned': false, 'emoji': null, 'countdownDate': null, 'secondaryContent': null, 'zIndex': 22, 'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default', 'metadata': {'isOnShelf': false, 'createdAt': '2026-07-05T18:12:25.751961', 'scale': 1.0, 'opacity': 1.0, 'progress': 26.0, 'caption': 'Adventures await', 'emoji': 'globe', 'font': '{"isOnShelf":false,"createdAt":"2026-07-05T18:12:25.751961","scale":1.0,"opacity":1.0,"progress":26.0,"caption":"Adventures await","emoji":"globe","font":"{\\"isOnShelf\\":false,\\"createdAt\\":\\"2026-07-05T18:12:25.751961\\",\\"scale\\":1.0,\\"opacity\\":1.0,\\"progress\\":26.0,\\"caption\\":\\"Adventures await\\",\\"emoji\\":\\"globe\\"}","monthlyAmount":"","description":"","motivation":"","syncStatus":"synced","lastSyncedAt":"2026-07-05T18:55:12.331104"}', 'monthlyAmount': '', 'description': '', 'motivation': '', 'syncStatus': 'synced', 'lastSyncedAt': '2026-07-05T19:45:03.218285'}},
{'id': 'c3bdc2cd-a083-4991-8c06-135fd2706855', 'type': 'financeGoal', 'content': 'Buy BMW S1000RR', 'x': 116.04166666666663, 'y': 261.2604166666664, 'width': 153.25278139451999, 'height': 87.5730179397257, 'rotation': -0.01127379734401501, 'colorValue': 4280163147, 'isPinned': false, 'emoji': null, 'countdownDate': null, 'secondaryContent': null, 'zIndex': 16, 'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default', 'metadata': {'isOnShelf': false, 'createdAt': '2026-07-05T18:12:25.751707', 'scale': 1.0, 'opacity': 1.0, 'title': 'Buy BMW S1000RR', 'amount': '2850000', 'targetAmount': 2850000.0, 'currentAmount': 712500.0, 'progress': 25.0, 'description': 'Every small investment today brings me closer to my dream ride', 'motivation': 'Owning the BMW S1000RR is a reward for my years of hard work and consistency. Every rupee I save reminds me that big dreams are achieved through disciplined daily actions.', 'monthlyAmount': '50,000', 'targetDate': '2027-12-31T00:00:00.000', 'font': '{"isOnShelf":false,"createdAt":"2026-07-05T18:12:25.751707","scale":1.0,"opacity":1.0,"title":"Buy BMW S1000RR","amount":"2850000","targetAmount":2850000.0,"currentAmount":712500.0,"progress":25.0,"description":"Every small investment today brings me closer to my dream ride","motivation":"Owning the BMW S1000RR is a reward for my years of hard work and consistency. Every rupee I save reminds me that big dreams are achieved through disciplined daily actions.","monthlyAmount":"50,000","targetDate":"2027-12-31T00:00:00.000"}', 'syncStatus': 'synced', 'lastSyncedAt': '2026-07-05T19:45:03.217554'}},
{'id': 'c479449a-befe-4dc3-9274-55a6b69e6a55', 'type': 'quote', 'content': 'Your future is quietly built by the choices you make today.', 'x': 137.4375, 'y': 503.6458333333335, 'width': 92.15863205266469, 'height': 52.66207545866554, 'rotation': -0.007537309442717625, 'colorValue': 4280163147, 'isPinned': false, 'emoji': null, 'countdownDate': null, 'secondaryContent': null, 'zIndex': 18, 'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default', 'metadata': {'isOnShelf': false, 'createdAt': '2026-07-05T18:12:25.751820', 'scale': 1.0, 'opacity': 1.0, 'quote': 'Your future is quietly built by the choices you make today.', 'author': 'Future you', 'style': 'Elegant Minimal', 'font': '{"isOnShelf":false,"createdAt":"2026-07-05T18:12:25.751820","scale":1.0,"opacity":1.0,"quote":"Your future is quietly built by the choices you make today.","author":"Future you","style":"Elegant Minimal","font":"{\\"isOnShelf\\":false,\\"createdAt\\":\\"2026-07-05T18:12:25.751820\\",\\"scale\\":1.0,\\"opacity\\":1.0,\\"quote\\":\\"Your future is quietly built by the choices you make today.\\",\\"author\\":\\"Future you\\",\\"style\\":\\"Elegant Minimal\\"}","monthlyAmount":"","description":"","motivation":"","syncStatus":"synced","lastSyncedAt":"2026-07-05T18:55:12.330646"}', 'monthlyAmount': '', 'description': '', 'motivation': '', 'syncStatus': 'synced', 'lastSyncedAt': '2026-07-05T19:45:03.217822'}},
{'id': 'c7c65057-a887-41af-b486-13265e270303', 'type': 'countdown', 'content': 'But A new Car', 'x': 212.08333333333343, 'y': 56.958333333333655, 'width': 50.0, 'height': 50.0, 'rotation': -0.02326271627596968, 'colorValue': 4280163147, 'isPinned': false, 'emoji': null, 'countdownDate': '2027-04-01T00:00:00.000Z', 'secondaryContent': null, 'zIndex': 14, 'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default', 'metadata': {'isOnShelf': false, 'createdAt': '2026-07-05T16:04:17.665276', 'scale': 1.0, 'opacity': 1.0, 'title': 'But A new Car', 'days': 270, 'targetDate': '2027-04-01T00:00:00.000', 'font': '{"isOnShelf":false,"createdAt":"2026-07-05T16:04:17.665276","scale":1.0,"opacity":1.0,"title":"But A new Car","days":270,"targetDate":"2027-04-01T00:00:00.000"}', 'monthlyAmount': '', 'description': '', 'motivation': '', 'syncStatus': 'synced', 'lastSyncedAt': '2026-07-05T19:45:03.217358'}},
{'id': 'c8bef7fa-163b-47eb-80e7-9fceeb4a6a82', 'type': 'image', 'content': 'https://res.cloudinary.com/dkiizrpqr/image/upload/v1783254559/focus_vision_board/c87cunuitcrtqn7ifwmi.jpg', 'x': 80.68749999999997, 'y': 661.2291666666671, 'width': 101.77350182623931, 'height': 101.77350182623931, 'rotation': -0.07485255767957213, 'colorValue': 4280163147, 'isPinned': false, 'emoji': null, 'countdownDate': null, 'secondaryContent': null, 'zIndex': 23, 'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default', 'metadata': {'isOnShelf': false, 'createdAt': '2026-07-05T18:12:25.751991', 'scale': 1.0, 'opacity': 1.0, 'progress': 24.0, 'caption': 'plan, Focus, Succeed', 'emoji': 'camera', 'font': '{"isOnShelf":false,"createdAt":"2026-07-05T18:12:25.751991","scale":1.0,"opacity":1.0,"progress":24.0,"caption":"plan, Focus, Succeed","emoji":"camera","font":"{\\"isOnShelf\\":false,\\"createdAt\\":\\"2026-07-05T18:12:25.751991\\",\\"scale\\":1.0,\\"opacity\\":1.0,\\"progress\\":24.0,\\"caption\\":\\"plan, Focus, Succeed\\",\\"emoji\\":\\"camera\\"}","monthlyAmount":"","description":"","motivation":"","syncStatus":"synced","lastSyncedAt":"2026-07-05T18:55:12.331177"}', 'monthlyAmount': '', 'description': '', 'motivation': '', 'syncStatus': 'synced', 'lastSyncedAt': '2026-07-05T19:45:03.218380'}},
{'id': 'f758e47b-6c8d-44a7-8fa0-d7645e00ea78', 'type': 'task', 'content': 'Get Fit', 'x': 272.93750000000006, 'y': 334.6666666666665, 'width': 70.12787375220138, 'height': 91.1662358778618, 'rotation': -0.01762598472543836, 'colorValue': 4280163147, 'isPinned': false, 'emoji': null, 'countdownDate': null, 'secondaryContent': null, 'zIndex': 8, 'attachmentType': 'tape', 'attachmentStyle': 'beige', 'materialStyle': 'default', 'metadata': {'isOnShelf': false, 'createdAt': '2026-07-04T15:50:01.643481', 'scale': 1.0, 'opacity': 1.0, 'title': 'Get Fit', 'priority': 'High', 'progress': 38.0, 'dueDate': null, 'checklist': [{'id': '1783159822515_0', 'title': '✓ Morning Workout', 'isCompleted': true, 'completionDate': null}, {'id': '1783159822515_1', 'title': '⏳ Healthy Meal Plan', 'isCompleted': true, 'completionDate': null}, {'id': '1783159822515_2', 'title': '☐ Track Weekly Progress', 'isCompleted': false, 'completionDate': null}], 'font': '{"isOnShelf":false,"createdAt":"2026-07-04T15:50:01.643481","scale":1.0,"opacity":1.0,"title":"Get Fit","priority":"High","progress":38.0,"dueDate":null,"checklist":[{"id":"1783159822515_0","title":"✓ Morning Workout","isCompleted":true,"completionDate":null},{"id":"1783159822515_1","title":"⏳ Healthy Meal Plan","isCompleted":true,"completionDate":null},{"id":"1783159822515_2","title":"☐ Track Weekly Progress","isCompleted":false,"completionDate":null}],"font":"{\\"isOnShelf\\":false,\\"createdAt\\":\\"2026-07-04T15:50:01.643481\\",\\"scale\\":1.0,\\"opacity\\":1.0,\\"title\\":\\"Get Fit\\",\\"priority\\":\\"High\\",\\"progress\\":38.0,\\"dueDate\\":null,\\"checklist\\":[{\\"id\\":\\"1783159822515_0\\",\\"title\\":\\"✓ Morning Workout\\",\\"isCompleted\\":true,\\"completionDate\\":null},{\\"id\\":\\"1783159822515_1\\",\\"title\\":\\"⏳ Healthy Meal Plan\\",\\"isCompleted\\":true,\\"completionDate\\":null},{\\"id\\":\\"1783159822515_2\\",\\"title\\":\\"☐ Track Weekly Progress\\",\\"isCompleted\\":false,\\"completionDate\\":null}],\\"font\\":\\"{\\\\\\"isOnShelf\\\\\\":false,\\\\\\"createdAt\\\\\\":\\\\\\"2026-07-04T15:50:01.643481\\\\\\",\\\\\\"scale\\\\\\":1.0,\\\\\\"opacity\\\\\\":1.0,\\\\\\"title\\\\\\":\\\\\\"Get Fit\\\\\\",\\\\\\"priority\\\\\\":\\\\\\"High\\\\\\",\\\\\\"progress\\\\\\":38.0,\\\\\\"dueDate\\\\\\":null,\\\\\\"checklist\\\\\\":[{\\\\\\"id\\\\\\":\\\\\\"1783159822515_0\\\\\\",\\\\\\"title\\\\\\":\\\\\\"✓ Morning Workout\\\\\\",\\\\\\"isCompleted\\\\\\":false},{\\\\\\"id\\\\\\":\\\\\\"1783159822515_1\\\\\\",\\\\\\"title\\\\\\":\\\\\\"⏳ Healthy Meal Plan\\\\\\",\\\\\\"isCompleted\\\\\\":false},{\\\\\\"id\\\\\\":\\\\\\"1783159822515_2\\\\\\",\\\\\\"title\\\\\\":\\\\\\"☐ Track Weekly Progress\\\\\\",\\\\\\"isCompleted\\\\\\":false}]}\\",\\"monthlyAmount\\":\\"\\",\\"description\\":\\"\\",\\"motivation\\":\\"\\",\\"syncStatus\\":\\"synced\\",\\"lastSyncedAt\\":\\"2026-07-04T16:21:45.151816\\"}","monthlyAmount":"","description":"","motivation":"","syncStatus":"synced","lastSyncedAt":"2026-07-05T18:55:12.329695"}', 'monthlyAmount': '', 'description': '', 'motivation': '', 'syncStatus': 'synced', 'lastSyncedAt': '2026-07-05T19:45:03.216895'}},
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

    await hiveDb.saveSetupCompleted(true);
    dev.log('$_logTag Seeding completed successfully!');
  }
}
