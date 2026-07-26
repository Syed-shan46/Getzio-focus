import 'dart:convert';
import 'dart:developer' as dev;
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../../../../core/storage/hive_database.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../vision_room/domain/models/vision_item.dart';
import '../../../vision_room/domain/models/sticky_note.dart';
import '../../../vision_room/data/repositories/vision_room_repository.dart';
import '../../../vision_room/data/services/vision_upload_service.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';
import '../../../affirmations/presentation/providers/affirmations_provider.dart';
import '../../../vision_room/presentation/providers/sticky_note_provider.dart';
import '../../../vision_room/presentation/providers/canvas_providers.dart';
import '../../../todo/presentation/providers/todo_providers.dart';
import '../../../os_dashboard/presentation/providers/os_providers.dart';

class GuestDataMigrationService {
  static const String _logTag = '[Migration]';

  /// Check if local guest data exists to migrate
  static Future<bool> checkGuestDataExists(HiveDatabase hiveDb) async {
    final habits = hiveDb.getSelectedHabits();
    final goals = await hiveDb.getUserItemsForId('goals', 'guest');
    final identity = hiveDb.getSelectedIdentity();
    final areas = hiveDb.getSelectedLifeAreas();
    final vision = await hiveDb.getUserItemsForId('vision_items', 'guest');
    final tasks = await hiveDb.getUserItemsForId('tasks', 'guest');
    final affirmations = await hiveDb.getUserItemsForId('affirmations', 'guest');
    final stickyNotes = Hive.box<StickyNote>('sticky_notes').values.toList();

    final exists = habits.isNotEmpty ||
        goals.isNotEmpty ||
        identity != null ||
        areas.isNotEmpty ||
        vision.isNotEmpty ||
        tasks.isNotEmpty ||
        affirmations.isNotEmpty ||
        stickyNotes.isNotEmpty;
    dev.log('$_logTag Check Guest Data: $exists (Habits: ${habits.length}, Goals: ${goals.length}, Tasks: ${tasks.length}, Affirmations: ${affirmations.length}, StickyNotes: ${stickyNotes.length})');
    return exists;
  }

  /// Run the Guest -> Account Migration POST request
  static Future<bool> migrate(dynamic ref) async {
    final hiveDb = ref.read(hiveDatabaseProvider);
    final dio = ref.read(dioClientProvider);

    if (!await checkGuestDataExists(hiveDb)) {
      dev.log('$_logTag No guest data exists. Skipping migration. Reloading from backend...');
      await reloadFromBackend(ref);
      return true;
    }

    dev.log('$_logTag Migration Started');
    
    // Read every collection from local storage
    final identity = hiveDb.getSelectedIdentity();
    final lifeAreas = hiveDb.getSelectedLifeAreas();
    final selectedGoals = await hiveDb.getUserItemsForId('goals', 'guest');
    final selectedHabits = hiveDb.getSelectedHabits();
    final selectedAffirmations = await hiveDb.getUserItemsForId('affirmations', 'guest');
    final habitLogs = hiveDb.getHabitLogs();
    final workspaceSettings = hiveDb.getWorkspaceSettings();
    final readingPrefs = hiveDb.getReadingPreferences() ?? {};
    final healthPrefs = hiveDb.getHealthPreferences() ?? {};
    final financePrefs = hiveDb.getFinancePreferences() ?? {};
    final visionItems = await hiveDb.getUserItemsForId('vision_items', 'guest');

    dev.log('$_logTag Profile Loaded');
    dev.log('$_logTag Habits Loaded (count: ${selectedHabits.length})');
    dev.log('$_logTag Goals Loaded (count: ${selectedGoals.length})');

    // Migrate tasks first
    final localTasks = await hiveDb.getUserItemsForId('tasks', 'guest');
    if (localTasks.isNotEmpty) {
      dev.log('$_logTag Uploading ${localTasks.length} guest tasks to server...');
      try {
        final tasksPayload = {
          'modifications': localTasks.map((t) => Map<String, dynamic>.from(t)).toList(),
          'deletedIds': [],
        };
        await dio.post('/tasks/sync', data: tasksPayload);
        dev.log('$_logTag Guest tasks uploaded successfully.');
      } catch (e) {
        dev.log('$_logTag Failed to upload guest tasks: $e');
      }
    }

    // Migrate sticky notes
    final stickyNotesBox = Hive.box<StickyNote>('sticky_notes');
    final localStickyNotes = stickyNotesBox.values.toList();
    if (localStickyNotes.isNotEmpty) {
      dev.log('$_logTag Uploading ${localStickyNotes.length} guest sticky notes to server...');
      for (var note in localStickyNotes) {
        try {
          await dio.post('/sticky-notes', data: note.toJson());
        } catch (e) {
          dev.log('$_logTag Failed to upload sticky note ${note.id}: $e');
        }
      }
    }

    // 1. Structure habitLogs map into array for backend format
    final List<Map<String, dynamic>> logsList = [];
    habitLogs.forEach((dateStr, habitsList) {
      if (habitsList is List) {
        for (var habitId in habitsList) {
          logsList.add({
            'localId': 'log_${dateStr}_$habitId',
            'habitId': habitId,
            'completed': true,
            'date': dateStr,
            'completedTime': DateTime.now().toIso8601String()
          });
        }
      }
    });

    final repo = ref.read(visionRoomRepositoryProvider);
    final uploadService = VisionUploadService(dio: dio.dio);
    final List<Map<String, dynamic>> mappedVisionItems = [];
    for (var v in visionItems) {
      final item = VisionItem.fromJson(Map<String, dynamic>.from(v));
      if (item.type == 'image' && 
          item.content.isNotEmpty && 
          !item.content.startsWith('http://') && 
          !item.content.startsWith('https://')) {
        try {
          dev.log('$_logTag Uploading local vision item image during migration: ${item.content}');
          final remoteUrl = await uploadService.uploadImage(item.content);
          if (remoteUrl != null) {
            final updatedItem = item.copyWith(content: remoteUrl);
            mappedVisionItems.add(repo.mapItemToDbKeys(updatedItem));
            continue;
          }
        } catch (e) {
          dev.log('$_logTag Failed to upload local image ${item.content} during migration: $e');
        }
      }
      mappedVisionItems.add(repo.mapItemToDbKeys(item));
    }

    final mappedAffirmations = selectedAffirmations.map((a) => {
      'id': a['id'],
      'localId': a['localId'] ?? a['id'],
      'title': a['title'] ?? 'Affirmation',
      'text': a['text'] ?? '',
      'author': a['author'] ?? 'Anonymous',
      'category': a['category'] ?? 'General',
      'emoji': a['emoji'] ?? '',
      'favorite': a['isFavorite'] ?? a['favorite'] ?? false,
      'pinned': a['isPinned'] ?? a['pinned'] ?? false,
      'theme': a['colorTheme'] ?? a['theme'] ?? 'Warm Amber',
      'createdAt': a['createdAt'],
    }).toList();

    final payload = {
      'profile': {
        'identity': identity,
        'lifeAreas': lifeAreas,
        'workspaceTheme': workspaceSettings['theme'] ?? 'default',
        'customTaskCategories': hiveDb.getCustomCategories()
      },
      'habits': selectedHabits.map((h) => {
        'localId': h['localId'] ?? h['id'] ?? h['_id'] ?? 'h_${h.hashCode}',
        'habitId': h['id'] ?? h['_id'],
        'title': h['title'],
        'category': h['category'] ?? 'General',
        'enabled': h['enabled'] ?? true,
        'dailyTarget': h['frequency'] == 'Daily' ? '1 time' : '3 times',
        'xpReward': h['xpReward'] ?? 10,
      }).toList(),
      'goals': selectedGoals.map((g) => {
        'localId': g['localId'] ?? g['id'] ?? g['_id'] ?? 'g_${g.hashCode}',
        'title': g['title'] ?? 'Goal',
        'category': g['category'] ?? 'General',
        'target': g['target'] ?? 100,
        'currentProgress': g['currentProgress'] ?? 0,
        'status': (g['status'] == 'completed') ? 'completed' : 'in-progress',
        'priority': g['priority'] ?? 'medium',
        'deadline': g['deadline'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      }).toList(),
      'reading': {
        'dailyTargetPages': readingPrefs['dailyReadingMinutes'] ?? 20,
        'goalBooks': readingPrefs['bookTarget'] ?? 12,
      },
      'finance': {
        'targetAmount': financePrefs['monthlySavings'] ?? 10000,
        'monthlySavingsTarget': financePrefs['monthlySavings'] ?? 10000,
      },
      'health': {
        'waterGoal': healthPrefs['waterTarget'] ?? 2000,
        'sleepGoal': healthPrefs['sleepTarget'] ?? 8,
        'exerciseGoal': healthPrefs['exerciseTarget'] ?? 30,
      },
      'affirmations': mappedAffirmations,
      'visionRoom': {
        'items': mappedVisionItems,
      },
      'habitLogs': logsList,
      'workspaceSettings': jsonEncode(workspaceSettings)
    };

    try {
      dev.log('$_logTag Migration Request Sent');
      final response = await dio.post('/focus/migrate', data: payload);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true) {
          final mapping = data['localIdToServerIdMap'] as Map<String, dynamic>?;

          if (mapping != null) {
            // Apply mapped server IDs back to local models
            if (mapping['goals'] != null) {
              final goalMap = mapping['goals'] as Map<String, dynamic>;
              final goalsToSave = hiveDb.getSelectedGoals();
              final List<Map<String, dynamic>> mapped = goalsToSave.map<Map<String, dynamic>>((g) {
                final map = Map<String, dynamic>.from(g);
                final locId = map['localId'];
                if (locId != null && goalMap.containsKey(locId)) {
                  map['serverId'] = goalMap[locId];
                  map['syncStatus'] = 'synced';
                }
                return map;
              }).toList();
              await hiveDb.saveSelectedGoals(mapped);
            }

            if (mapping['habits'] != null) {
              final habitMap = mapping['habits'] as Map<String, dynamic>;
              final habitsToSave = hiveDb.getSelectedHabits();
              final List<Map<String, dynamic>> mapped = habitsToSave.map<Map<String, dynamic>>((h) {
                final map = Map<String, dynamic>.from(h);
                final locId = map['localId'];
                if (locId != null && habitMap.containsKey(locId)) {
                  map['serverId'] = habitMap[locId];
                  map['syncStatus'] = 'synced';
                }
                return map;
              }).toList();
              await hiveDb.saveSelectedHabits(mapped);
            }

            if (mapping['affirmations'] != null) {
              final affMap = mapping['affirmations'] as Map<String, dynamic>;
              final affirmationsToSave = hiveDb.getSelectedAffirmations();
              final List<Map<String, dynamic>> mapped = affirmationsToSave.map<Map<String, dynamic>>((a) {
                final map = Map<String, dynamic>.from(a);
                final locId = map['localId'];
                if (locId != null && affMap.containsKey(locId)) {
                  map['serverId'] = affMap[locId];
                  map['syncStatus'] = 'synced';
                }
                return map;
              }).toList();
              await hiveDb.saveSelectedAffirmations(mapped);
            }
          }

          // Step 5: Save migration status variables
          await hiveDb.saveMigrationStatus(
            migrationCompleted: true,
            lastMigrationTime: DateTime.now().toIso8601String(),
            serverUserId: hiveDb.getUserId() ?? 'unknown',
            migrationPending: false,
          );
          
          dev.log('$_logTag Migration Success');

          // Step 6: Reload everything from backend
          await reloadFromBackend(ref);
          return true;
        } else {
          final msg = data['message'] ?? 'Migration returned success=false';
          dev.log('$_logTag Migration Failed: $msg');
          throw Exception(msg);
        }
      } else {
        dev.log('$_logTag Migration Failed with status ${response.statusCode}');
        throw Exception('Migration failed with status code ${response.statusCode}');
      }
    } catch (e) {
      await hiveDb.setMigrationPending(true);
      dev.log('$_logTag Migration Failed: $e (Queued for background retry)');
      rethrow;
    }
  }

  /// Reload everything from the backend database to ensure local sync correctness
  static Future<void> reloadFromBackend(dynamic ref) async {
    final hiveDb = ref.read(hiveDatabaseProvider);
    final dio = ref.read(dioClientProvider);

    try {
      dev.log('$_logTag Reloading Profile details from backend...');
      final profileRes = await dio.get('/focus/profile');
      if (profileRes.statusCode == 200 && profileRes.data != null) {
        final profileData = profileRes.data['data'] as Map<String, dynamic>?;
        if (profileData != null) {
          if (profileData['identity'] != null) {
            await hiveDb.saveSelectedIdentity(profileData['identity'] as String);
          }
          if (profileData['lifeAreas'] != null) {
            await hiveDb.saveSelectedLifeAreas(List<String>.from(profileData['lifeAreas'] as List));
          }
          if (profileData['workspaceTheme'] != null) {
            final themeVal = profileData['workspaceTheme'] as String;
            try {
              if (themeVal.startsWith('{')) {
                final Map<String, dynamic> parsedSettings = jsonDecode(themeVal);
                await hiveDb.saveWorkspaceSettings(parsedSettings);
              } else {
                await hiveDb.saveWorkspaceSettings({'theme': themeVal});
              }
            } catch (e) {
              await hiveDb.saveWorkspaceSettings({'theme': themeVal});
            }
          }
          if (profileData['customTaskCategories'] != null) {
            await hiveDb.saveCustomCategories(List<String>.from(profileData['customTaskCategories'] as List));
          }
        }
      }

      dev.log('$_logTag Reloading Habits details from backend...');
      final sessionRes = await dio.get('/focus/habits/today');
      if (sessionRes.statusCode == 200 && sessionRes.data != null) {
        final data = sessionRes.data['data'];
        if (data != null) {
          final session = data['session'] as Map<String, dynamic>?;
          if (session != null) {
            final habitsList = session['habits'] as List?;
            if (habitsList != null) {
              final Map<String, dynamic> logs = hiveDb.getHabitLogs();
              final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
              final List<String> completedToday = [];
              for (var h in habitsList) {
                if (h['completed'] == true) {
                  completedToday.add(h['habitId'].toString());
                }
              }
              logs[todayStr] = completedToday;
              await hiveDb.saveHabitLogs(logs);
            }
          }
        }
      }

      dev.log('$_logTag Reloading Goals details from backend...');
      final goalsRes = await dio.get('/focus/goals');
      if (goalsRes.statusCode == 200 && goalsRes.data != null) {
        final goalsList = goalsRes.data['data'] as List?;
        if (goalsList != null) {
          final List<Map<String, dynamic>> mapped = goalsList.map<Map<String, dynamic>>((g) {
            final map = Map<String, dynamic>.from(g as Map);
            return <String, dynamic>{
              'localId': map['localId'] ?? map['_id'],
              'serverId': map['_id'],
              'title': map['title'],
              'category': map['category'],
              'target': map['target'],
              'currentProgress': map['currentProgress'],
              'status': map['status'],
              'priority': map['priority'],
              'deadline': map['deadline'],
              'syncStatus': 'synced'
            };
          }).toList();
          await hiveDb.saveSelectedGoals(mapped);
        }
      }

      dev.log('$_logTag Reloading Reading Tracker from backend...');
      final readingRes = await dio.get('/focus/reading');
      if (readingRes.statusCode == 200 && readingRes.data != null) {
        final readingData = readingRes.data['data'] as Map<String, dynamic>?;
        if (readingData != null) {
          await hiveDb.saveReadingPreferences({
            'dailyReadingMinutes': readingData['dailyTargetPages'] ?? 20,
            'bookTarget': readingData['goalBooks'] ?? 12,
          });
        }
      }

      dev.log('$_logTag Reloading Finance Tracker from backend...');
      final financeRes = await dio.get('/focus/finance');
      if (financeRes.statusCode == 200 && financeRes.data != null) {
        final financeData = financeRes.data['data'] as Map<String, dynamic>?;
        if (financeData != null) {
          await hiveDb.saveFinancePreferences({
            'monthlySavings': financeData['targetAmount'] ?? 10000,
          });
        }
      }

      dev.log('$_logTag Reloading Health Tracker from backend...');
      final healthRes = await dio.get('/focus/health');
      if (healthRes.statusCode == 200 && healthRes.data != null) {
        final healthData = healthRes.data['data'] as Map<String, dynamic>?;
        if (healthData != null) {
          await hiveDb.saveHealthPreferences({
            'waterTarget': healthData['waterGoal'] ?? 2000,
            'sleepTarget': healthData['sleepGoal'] ?? 8,
            'exerciseTarget': healthData['exerciseGoal'] ?? 30,
          });
        }
      }

      dev.log('$_logTag Reloading Vision Room from backend...');
      final visionRes = await dio.get('/focus/vision-room');
      if (visionRes.statusCode == 200 && visionRes.data != null) {
        final visionData = visionRes.data['data'] as Map<String, dynamic>?;
        if (visionData != null && visionData['items'] != null) {
          final itemsList = visionData['items'] as List;
          final List<Map<String, dynamic>> mappedItems = itemsList.map<Map<String, dynamic>>((itemJson) {
            final typeStr = itemJson['type'] ?? '';
            final contentStr = typeStr == 'image' ? (itemJson['imageUrl'] ?? '') : (itemJson['text'] ?? '');
            final colorHex = itemJson['color'] ?? '';
            final colorVal = colorHex.toString().isNotEmpty 
                ? int.tryParse(colorHex, radix: 16) ?? 0xFF1E1B4B 
                : 0xFF1E1B4B;

            return <String, dynamic>{
              'id': itemJson['itemId'] ?? '',
              'type': typeStr,
              'content': contentStr,
              'x': (itemJson['xPosition'] as num?)?.toDouble() ?? 0.0,
              'y': (itemJson['yPosition'] as num?)?.toDouble() ?? 0.0,
              'width': (itemJson['width'] as num?)?.toDouble() ?? 180.0,
              'height': (itemJson['height'] as num?)?.toDouble() ?? 120.0,
              'rotation': (itemJson['rotation'] as num?)?.toDouble() ?? 0.0,
              'colorValue': colorVal,
              'isPinned': itemJson['locked'] ?? false,
              'zIndex': (itemJson['zIndex'] as num?)?.toInt() ?? 0,
              'attachmentType': 'pin',
              'attachmentStyle': 'redPin',
              'materialStyle': 'default',
              'metadata': <String, dynamic>{
                'scale': (itemJson['scale'] as num?)?.toDouble() ?? 1.0,
                'opacity': (itemJson['opacity'] as num?)?.toDouble() ?? 1.0,
                'font': itemJson['font'] ?? '',
              }
            };
          }).toList();
          await hiveDb.saveVisionItems(mappedItems);
        }
      }

      dev.log('$_logTag Reloading Affirmations from backend...');
      final affirmationsRes = await dio.get('/focus/affirmations');
      if (affirmationsRes.statusCode == 200 && affirmationsRes.data != null) {
        final data = affirmationsRes.data['data'] as List?;
        if (data != null) {
          final List<Map<String, dynamic>> mapped = [];
          for (var groupJson in data) {
            final dynamic rawGroupCat = groupJson['category'] ?? groupJson['name'] ?? groupJson['_id'];
            String groupCategory = 'General';
            if (rawGroupCat is Map) {
              groupCategory = rawGroupCat['name'] as String? ?? rawGroupCat['title'] as String? ?? 'General';
            } else if (rawGroupCat != null) {
              groupCategory = rawGroupCat.toString();
            }

            final affs = groupJson['affirmations'] as List?;
            if (affs != null) {
              for (var affJson in affs) {
                final Map<String, dynamic> mutable = Map<String, dynamic>.from(affJson);
                final String id = mutable['id'] ?? (mutable['_id'] ?? '');
                final String title = mutable['title'] ?? 'Affirmation';
                final String text = mutable['text'] ?? '';
                final String? author = mutable['author'];

                final dynamic rawAffCat = mutable['category'];
                String? affCategory;
                if (rawAffCat is Map) {
                  affCategory = rawAffCat['name'] as String? ?? rawAffCat['title'] as String? ?? 'General';
                } else if (rawAffCat != null) {
                  affCategory = rawAffCat.toString();
                }

                final String category = (affCategory != null && affCategory.trim().isNotEmpty) ? affCategory : groupCategory;
                final String colorTheme = mutable['colorTheme'] ?? 'Minimal White';
                final bool isPinned = mutable['isPinned'] ?? mutable['pinned'] ?? false;
                final bool isFavorite = mutable['isFavorite'] ?? mutable['favorite'] ?? false;
                final String? emoji = mutable['emoji'];

                mapped.add({
                  'id': id,
                  'title': title,
                  'text': text,
                  'author': author,
                  'category': category,
                  'colorTheme': colorTheme,
                  'fontStyle': 'Serif',
                  'backgroundStyle': colorTheme,
                  'isPinned': isPinned,
                  'isFavorite': isFavorite,
                  'schedule': ['Morning'],
                  'woodFinish': 'Oak',
                  'frameStyle': 'Classic Wood',
                  'frameColor': 'Natural Walnut',
                  'glassReflection': 'Slight Gloss',
                  'fontWeight': 'Normal',
                  'quoteAlignment': 'Center',
                  'quoteSize': 15.0,
                  'accentColor': 'Amber',
                  'bgBlur': 5.0,
                  'borderDecoration': 'None',
                  'emoji': emoji,
                  'icon': null,
                  'createdAt': mutable['createdAt'] ?? DateTime.now().toIso8601String(),
                  'updatedAt': mutable['updatedAt'] ?? DateTime.now().toIso8601String(),
                  'syncStatus': 'synced',
                });
              }
            }
          }
          await hiveDb.saveSelectedAffirmations(mapped);
        }
      }

      dev.log('$_logTag Reloading Sticky Notes from backend...');
      final userId = hiveDb.getUserId();
      if (userId != null && userId.isNotEmpty) {
        try {
          final stickyNotesRes = await dio.get('/sticky-notes', queryParameters: {'userId': userId});
          if (stickyNotesRes.statusCode == 200 && stickyNotesRes.data != null) {
            final notesData = stickyNotesRes.data['data'] as List?;
            if (notesData != null) {
              final List<StickyNote> notes = notesData.map((noteJson) {
                return StickyNote.fromJson(Map<String, dynamic>.from(noteJson));
              }).toList();
              
              final stickyNotesBox = Hive.box<StickyNote>('sticky_notes');
              await stickyNotesBox.clear();
              for (var note in notes) {
                await stickyNotesBox.put(note.id, note);
              }
              dev.log('$_logTag Mapped and reloaded ${notes.length} sticky notes successfully.');
            }
          }
        } catch (noteErr) {
          dev.log('$_logTag Failed to reload sticky notes: $noteErr');
        }
      }

      dev.log('$_logTag Reloading Tasks from backend...');
      try {
        final serverTasks = await ref.read(tasksRepositoryProvider).fetchTasksFromServer();
        if (serverTasks != null) {
          await ref.read(tasksRepositoryProvider).saveLocalTasks(serverTasks);
          dev.log('$_logTag Mapped and reloaded ${serverTasks.length} tasks successfully.');
        }
      } catch (tasksErr) {
        dev.log('$_logTag Failed to reload tasks: $tasksErr');
      }

      dev.log('$_logTag All collections populated to Local Database successfully.');
      
      // Invalidate and refresh Riverpod providers to update the UI on iPhone instantly
      ref.invalidate(tasksProvider);
      ref.invalidate(affirmationsProvider);
      ref.invalidate(stickyNotesProvider);
      ref.invalidate(canvasStateProvider);
      ref.invalidate(todosProvider);
      ref.invalidate(osStateProvider);
    } catch (e) {
      dev.log('$_logTag Failed to reload/update server state to Hive: $e');
    }
  }
}
