import 'dart:developer';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/vision_room/domain/models/sticky_note.dart';

class HiveDatabase {
  static const String _todosBoxName = 'todo_personal_todos';
  static const String _syncBoxName = 'todo_personal_sync';
  static const String _settingsBoxName = 'todo_personal_settings';

  late Box _todosBox;
  late Box _syncBox;
  late Box _settingsBox;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);

    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(StickyNoteAdapter());
    }

    // Open standard Hive boxes requested by user
    await Hive.openBox('tasks');
    await Hive.openBox('subtasks');
    await Hive.openBox('vision_room');
    await Hive.openBox('vision_board');
    await Hive.openBox<StickyNote>('sticky_notes');
    await Hive.openBox('quotes');
    await Hive.openBox('goals');
    await Hive.openBox('finance_goals');
    await Hive.openBox('countdowns');
    await Hive.openBox('affirmations');
    await Hive.openBox('settings');
    await Hive.openBox('theme');
    await Hive.openBox('profile_preferences');
    await Hive.openBox('pending_sync'); // local queue

    // For backwards compatibility and legacy support
    await Hive.openBox<StickyNote>('guest_sticky_notes');
    _todosBox = await Hive.openBox(_todosBoxName);
    _syncBox = await Hive.openBox(_syncBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);

    // Initial user boxes
    await openUserBoxes();
    await migrateLegacyData();

    log('[Hive] Database initialized');
  }

  Future<void> openUserBoxes() async {
    final userId = getUserId() ?? 'guest';
    final goalsBox = await Hive.openBox('goals_$userId');
    final tasksBox = await Hive.openBox('tasks_$userId');
    final visionItemsBox = await Hive.openBox('vision_items_$userId');
    final affirmationsBox = await Hive.openBox('affirmations_$userId');
    await Hive.openBox('pending_sync_$userId');
    await Hive.openBox('daily_routines_$userId');

    // Migrate legacy data if isolated boxes are empty
    if (goalsBox.isEmpty) {
      final oldGoals = _settingsBox.get('focus_selected_goals') as List?;
      if (oldGoals != null) {
        for (var item in oldGoals) {
          final id =
              item['id'] ?? item['_id'] ?? item['localId'] ?? item['itemId'];
          if (id != null)
            goalsBox.put(id.toString(), Map<String, dynamic>.from(item as Map));
        }
      }
    }
    if (tasksBox.isEmpty) {
      final oldTasks = _settingsBox.get('focus_tasks') as List?;
      if (oldTasks != null) {
        for (var item in oldTasks) {
          final id =
              item['id'] ?? item['_id'] ?? item['localId'] ?? item['itemId'];
          if (id != null)
            tasksBox.put(id.toString(), Map<String, dynamic>.from(item as Map));
        }
      }
    }
    if (visionItemsBox.isEmpty) {
      final oldVision = _settingsBox.get('focus_vision_items') as List?;
      if (oldVision != null) {
        for (var item in oldVision) {
          final id =
              item['id'] ?? item['_id'] ?? item['localId'] ?? item['itemId'];
          if (id != null)
            visionItemsBox.put(
              id.toString(),
              Map<String, dynamic>.from(item as Map),
            );
        }
      }
    }
    if (affirmationsBox.isEmpty) {
      final oldAff =
          _settingsBox.get('focus_selected_affirmations_$userId') as List?;
      if (oldAff != null) {
        for (var item in oldAff) {
          final id =
              item['id'] ?? item['_id'] ?? item['localId'] ?? item['itemId'];
          if (id != null)
            affirmationsBox.put(
              id.toString(),
              Map<String, dynamic>.from(item as Map),
            );
        }
      }
    }
    log(
      '[Hive] Opened user-isolated boxes for user: $userId and migrated legacy data if any',
    );
  }

  Future<void> migrateLegacyData() async {
    // Preserve strict per-user box isolation: tasks_$userId, goals_$userId, vision_items_$userId, affirmations_$userId
    log('[Migration] Strict user box isolation active.');
  }

  Future<Box> _getUserBox(String boxPrefix) async {
    final userId = getUserId() ?? 'guest';
    final boxName = '${boxPrefix}_$userId';
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  Future<Box> _getUserBoxWithId(String boxPrefix, String userId) async {
    final boxName = '${boxPrefix}_$userId';
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return await Hive.openBox(boxName);
  }

  // ─── Generic User-Isolated Operations ──────────────────────────────

  Future<void> saveUserItem(
    String boxPrefix,
    String id,
    Map<String, dynamic> data,
  ) async {
    final box = await _getUserBox(boxPrefix);
    await box.put(id, data);
  }

  Future<void> saveUserItems(
    String boxPrefix,
    List<Map<String, dynamic>> items,
  ) async {
    final box = await _getUserBox(boxPrefix);
    await box.clear();
    final Map<String, Map> map = {};
    for (var item in items) {
      final id = item['id'] ?? item['_id'] ?? item['localId'] ?? item['itemId'];
      if (id != null) {
        map[id.toString()] = item;
      }
    }
    if (map.isNotEmpty) {
      await box.putAll(map);
    }
  }
  List<Map<String, dynamic>> getUserItems(String boxPrefix) {
    final userId = getUserId() ?? 'guest';
    final boxName = '${boxPrefix}_$userId';

    if (!Hive.isBoxOpen(boxName)) {
      log('[Hive] getUserItems: box $boxName is NOT open, returning []');
      return [];
    }
    final box = Hive.box(boxName);
    log('[Hive] getUserItems($boxPrefix, $userId): box has ${box.length} items');
    return box.values.map((e) => _deepCast(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getUserItemsForId(String boxPrefix, String userId) async {
    final box = await _getUserBoxWithId(boxPrefix, userId);
    return box.values.map((e) => _deepCast(e)).toList();
  }

  /// Recursively converts Hive internal types to standard Dart types
  Map<String, dynamic> _deepCast(dynamic raw) {
    final map = Map<String, dynamic>.from(raw as Map);
    for (final key in map.keys.toList()) {
      final value = map[key];
      if (value is Map) {
        map[key] = _deepCast(value);
      } else if (value is List) {
        map[key] = value.map((e) => e is Map ? _deepCast(e) : e).toList();
      }
    }
    return map;
  }

  Future<void> deleteUserItem(String boxPrefix, String id) async {
    final box = await _getUserBox(boxPrefix);
    await box.delete(id);
  }

  Future<void> clearUserBox(String boxPrefix) async {
    final box = await _getUserBox(boxPrefix);
    await box.clear();
  }

  // ─── Legacy/Compatibility Getters and Setters ────────────────────────

  Future<void> saveSelectedGoals(List<Map<String, dynamic>> goals) async {
    await saveUserItems('goals', goals);
  }

  List<Map<String, dynamic>> getSelectedGoals() {
    return getUserItems('goals');
  }

  Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    await saveUserItems('tasks', tasks);
  }

  List<Map<String, dynamic>> getTasks() {
    return getUserItems('tasks');
  }

  Future<void> saveVisionItems(List<Map<String, dynamic>> items) async {
    await saveUserItems('vision_items', items);
  }

  List<Map<String, dynamic>> getVisionItems() {
    return getUserItems('vision_items');
  }

  Future<void> saveSelectedAffirmations(
    List<Map<String, dynamic>> affirmations,
  ) async {
    await saveUserItems('affirmations', affirmations);
  }

  List<Map<String, dynamic>> getSelectedAffirmations() {
    return getUserItems('affirmations');
  }

  // ─── Pending Sync Operations (User Isolated) ───────────────────────

  Future<void> addToPendingSync(Map<String, dynamic> action) async {
    final box = await _getUserBox('pending_sync');
    final id = action['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    await box.put(id, action);
  }

  Future<void> removeFromPendingSync(String id) async {
    final box = await _getUserBox('pending_sync');
    await box.delete(id);
  }

  List<Map<String, dynamic>> getPendingSyncQueue() {
    return getUserItems('pending_sync');
  }

  // ─── Todos ──────────────────────────────────────────────────────────────

  Future<void> saveTodos(List<Map<String, dynamic>> todos) async {
    final Map<String, Map<String, dynamic>> map = {};
    for (var todo in todos) {
      final id = todo['id'] ?? todo['_id'];
      if (id != null) map[id.toString()] = todo;
    }
    await _todosBox.putAll(map);
  }

  Future<void> saveTodo(Map<String, dynamic> todo) async {
    final id = todo['id'] ?? todo['_id'];
    if (id != null) await _todosBox.put(id.toString(), todo);
  }

  Future<void> deleteTodo(String id) async {
    await _todosBox.delete(id);
  }

  List<Map<String, dynamic>> getCachedTodos() {
    return _todosBox.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> clearTodos() async {
    await _todosBox.clear();
  }

  // ─── Sync Queue (Legacy Global) ─────────────────────────────────────────

  Future<void> addToSyncQueue(Map<String, dynamic> op) async {
    final id = op['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    await _syncBox.put(id, op);
  }

  Future<void> removeFromSyncQueue(String id) async {
    await _syncBox.delete(id);
  }

  List<Map<String, dynamic>> getSyncQueue() {
    return _syncBox.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> clearSyncQueue() async {
    await _syncBox.clear();
  }

  // ─── Settings / Auth ───────────────────────────────────────────────────

  Future<void> saveAuthToken(String token) async {
    await _settingsBox.put('auth_token', token);
  }

  String? getAuthToken() {
    return _settingsBox.get('auth_token') as String?;
  }

  Future<void> saveUserId(String id) async {
    await _settingsBox.put('user_id', id);
    await openUserBoxes();
  }

  String? getUserId() {
    return _settingsBox.get('user_id') as String?;
  }

  Future<void> saveUserName(String name) async {
    await _settingsBox.put('user_name', name);
  }

  String? getUserName() {
    return _settingsBox.get('user_name') as String?;
  }

  Future<void> saveUserPhone(String phone) async {
    await _settingsBox.put('user_phone', phone);
  }

  String? getUserPhone() {
    return _settingsBox.get('user_phone') as String?;
  }

  Future<void> saveOnboardingCompleted(bool completed) async {
    await _settingsBox.put('onboarding_completed', completed);
  }

  bool isOnboardingCompleted() {
    return _settingsBox.get('onboarding_completed', defaultValue: false)
        as bool;
  }

  Future<void> saveLastQuoteDate(String date) async {
    await _settingsBox.put('motivation_last_quote_date', date);
  }

  String? getLastQuoteDate() {
    return _settingsBox.get('motivation_last_quote_date') as String?;
  }

  Future<void> saveQuoteIndex(int index) async {
    await _settingsBox.put('motivation_quote_index', index);
  }

  int getQuoteIndex() {
    return _settingsBox.get('motivation_quote_index', defaultValue: 0) as int;
  }

  Future<void> saveSetupCompleted(bool completed) async {
    await _settingsBox.put('focus_setup_completed', completed);
  }

  bool isSetupCompleted() {
    return _settingsBox.get('focus_setup_completed', defaultValue: false)
        as bool;
  }

  Future<void> saveThemeMode(String mode) async {
    await _settingsBox.put('app_theme_mode', mode);
  }

  String getThemeMode() {
    return _settingsBox.get('app_theme_mode', defaultValue: 'system') as String;
  }

  Future<void> saveSyncStatus({
    required String userId,
    required String lastSyncTime,
    required bool syncCompleted,
  }) async {
    await _settingsBox.put('sync_user_id', userId);
    await _settingsBox.put('sync_last_time', lastSyncTime);
    await _settingsBox.put('sync_completed', syncCompleted);
  }

  bool isSyncCompleted() {
    return _settingsBox.get('sync_completed', defaultValue: false) as bool;
  }

  String? getLastSyncTime() {
    return _settingsBox.get('sync_last_time') as String?;
  }

  Future<void> saveMigrationStatus({
    required bool migrationCompleted,
    required String lastMigrationTime,
    required String serverUserId,
    required bool migrationPending,
  }) async {
    await _settingsBox.put('migration_completed', migrationCompleted);
    await _settingsBox.put('migration_last_time', lastMigrationTime);
    await _settingsBox.put('migration_server_user_id', serverUserId);
    await _settingsBox.put('migration_pending', migrationPending);
  }

  bool isMigrationCompleted() {
    return _settingsBox.get('migration_completed', defaultValue: false) as bool;
  }

  String? getLastMigrationTime() {
    return _settingsBox.get('migration_last_time') as String?;
  }

  String? getServerUserId() {
    return _settingsBox.get('migration_server_user_id') as String?;
  }

  bool isMigrationPending() {
    return _settingsBox.get('migration_pending', defaultValue: false) as bool;
  }

  Future<void> setMigrationPending(bool pending) async {
    await _settingsBox.put('migration_pending', pending);
  }

  Future<void> clearAuth() async {
    await _settingsBox.delete('auth_token');
    await _settingsBox.delete('user_id');
    await _settingsBox.delete('user_name');
    await _settingsBox.delete('user_phone');
    await openUserBoxes();
  }

  Future<void> clearAll() async {
    final userId = getUserId() ?? 'guest';
    final onboardingCompleted = _settingsBox.get('onboarding_completed');
    final setupCompleted = _settingsBox.get('setup_completed');

    await _todosBox.clear();
    await _syncBox.clear();
    
    // Clear user boxes using the retrieved userId
    await (await _getUserBoxWithId('goals', userId)).clear();
    await (await _getUserBoxWithId('tasks', userId)).clear();
    await (await _getUserBoxWithId('vision_items', userId)).clear();
    await (await _getUserBoxWithId('affirmations', userId)).clear();
    await (await _getUserBoxWithId('pending_sync', userId)).clear();

    await _settingsBox.clear();

    if (onboardingCompleted != null) {
      await _settingsBox.put('onboarding_completed', onboardingCompleted);
    }
    if (setupCompleted != null) {
      await _settingsBox.put('setup_completed', setupCompleted);
    }
  }

  Future<void> clearAllGuestData() async {
    final token = _settingsBox.get('auth_token');
    final userData = _settingsBox.get('user_data');
    final onboardingCompleted = _settingsBox.get('onboarding_completed');
    final setupCompleted = _settingsBox.get('setup_completed');

    await _todosBox.clear();
    await _syncBox.clear();

    // Clear user guest boxes explicitly
    await (await _getUserBoxWithId('goals', 'guest')).clear();
    await (await _getUserBoxWithId('tasks', 'guest')).clear();
    await (await _getUserBoxWithId('vision_items', 'guest')).clear();
    await (await _getUserBoxWithId('affirmations', 'guest')).clear();
    await (await _getUserBoxWithId('pending_sync', 'guest')).clear();

    await _settingsBox.clear();

    // Restore auth info and onboarding/setup progress
    if (token != null) await _settingsBox.put('auth_token', token);
    if (userData != null) await _settingsBox.put('user_data', userData);
    if (onboardingCompleted != null) {
      await _settingsBox.put('onboarding_completed', onboardingCompleted);
    }
    if (setupCompleted != null) {
      await _settingsBox.put('setup_completed', setupCompleted);
    }
  }

  // ─── Getzio Focus Onboarding & Dashboard ──────────────────────────────

  Future<void> saveSelectedIdentity(String identity) async {
    await _settingsBox.put('focus_selected_identity', identity);
  }

  String? getSelectedIdentity() {
    return _settingsBox.get('focus_selected_identity') as String?;
  }

  Future<void> saveIsPreviewMode(bool isPreview) async {
    await _settingsBox.put('is_preview_mode', isPreview);
  }

  bool? getIsPreviewMode() {
    return _settingsBox.get('is_preview_mode') as bool?;
  }

  Future<void> saveSelectedGoal(String goal) async {
    await _settingsBox.put('focus_selected_goal', goal);
  }

  String? getSelectedGoal() {
    return _settingsBox.get('focus_selected_goal') as String?;
  }

  Future<void> saveWakeUpTime(String time) async {
    await _settingsBox.put('focus_wake_up_time', time);
  }

  String? getWakeUpTime() {
    return _settingsBox.get('focus_wake_up_time') as String?;
  }

  Future<void> saveSelectedHabits(List<Map<String, dynamic>> habits) async {
    await _settingsBox.put('focus_selected_habits', habits);
  }

  List<Map<String, dynamic>> getSelectedHabits() {
    final list = _settingsBox.get('focus_selected_habits') as List?;
    if (list == null) return [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> clearUserAffirmationsCache(String userId) async {
    await _settingsBox.delete('focus_selected_affirmations_$userId');
    await _settingsBox.delete('focus_pending_deletions_$userId');
    final boxName = 'affirmations_$userId';
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).clear();
    }
  }

  Future<void> savePendingDeletions(List<String> ids) async {
    final userId = getUserId() ?? 'guest';
    await _settingsBox.put('focus_pending_deletions_$userId', ids);
  }

  List<String> getPendingDeletions() {
    final userId = getUserId() ?? 'guest';
    final list = _settingsBox.get('focus_pending_deletions_$userId') as List?;
    if (list == null) return [];
    return List<String>.from(list);
  }

  Future<void> saveUserStatistics(Map<String, dynamic> stats) async {
    await _settingsBox.put('focus_user_statistics', stats);
  }

  Map<String, dynamic>? getUserStatistics() {
    final map = _settingsBox.get('focus_user_statistics') as Map?;
    if (map == null) return null;
    return Map<String, dynamic>.from(map);
  }

  Future<void> saveHabitLogs(Map<String, dynamic> logs) async {
    await _settingsBox.put('focus_habit_logs', logs);
  }

  Map<String, dynamic> getHabitLogs() {
    final map = _settingsBox.get('focus_habit_logs') as Map?;
    if (map == null) return {};
    return Map<String, dynamic>.from(map);
  }

  Future<void> saveWorkspaceSettings(Map<String, dynamic> settings) async {
    await _settingsBox.put('focus_workspace_settings', settings);
  }

  Map<String, dynamic> getWorkspaceSettings() {
    final map = _settingsBox.get('focus_workspace_settings') as Map?;
    if (map == null) return {};
    return Map<String, dynamic>.from(map);
  }

  // ─── Premium Onboarding v2 ─────────────────────────────────────────────

  Future<void> saveSelectedLifeAreas(List<String> areas) async {
    await _settingsBox.put('focus_life_areas', areas);
  }

  List<String> getSelectedLifeAreas() {
    final list = _settingsBox.get('focus_life_areas') as List?;
    if (list == null) return [];
    return List<String>.from(list);
  }

  Future<void> saveReadingPreferences(Map<String, dynamic> prefs) async {
    await _settingsBox.put('focus_reading_prefs', prefs);
  }

  Map<String, dynamic>? getReadingPreferences() {
    final map = _settingsBox.get('focus_reading_prefs') as Map?;
    if (map == null) return null;
    return Map<String, dynamic>.from(map);
  }

  Future<void> saveHealthPreferences(Map<String, dynamic> prefs) async {
    await _settingsBox.put('focus_health_prefs', prefs);
  }

  Map<String, dynamic>? getHealthPreferences() {
    final map = _settingsBox.get('focus_health_prefs') as Map?;
    if (map == null) return null;
    return Map<String, dynamic>.from(map);
  }

  Future<void> saveFinancePreferences(Map<String, dynamic> prefs) async {
    await _settingsBox.put('focus_finance_prefs', prefs);
  }

  Map<String, dynamic>? getFinancePreferences() {
    final map = _settingsBox.get('focus_finance_prefs') as Map?;
    if (map == null) return null;
    return Map<String, dynamic>.from(map);
  }

  Future<void> saveVisionViewport(List<double> matrix) async {
    await _settingsBox.put('focus_vision_viewport', matrix);
  }

  List<double>? getVisionViewport() {
    final list = _settingsBox.get('focus_vision_viewport') as List?;
    return list?.cast<double>();
  }

  // ─── Vision Customization ──────────────────────────────────────────────

  Future<void> saveVisionCustomization(
    Map<String, dynamic> customization,
  ) async {
    await _settingsBox.put('focus_vision_customization', customization);
  }

  Map<String, dynamic>? getVisionCustomization() {
    final map = _settingsBox.get('focus_vision_customization') as Map?;
    if (map == null) return null;
    return Map<String, dynamic>.from(map);
  }

  bool hasSeenPreview(String feature) {
    return _settingsBox.get('focus_seen_preview_$feature', defaultValue: false)
        as bool;
  }

  Future<void> setSeenPreview(String feature) async {
    await _settingsBox.put('focus_seen_preview_$feature', true);
  }

  // ─── Premium Tasks Module ──────────────────────────────────────────────

  Future<void> savePendingTaskActions(
    List<Map<String, dynamic>> actions,
  ) async {
    final box = await _getUserBox('pending_sync');
    await box.put('pending_tasks_actions', actions);
  }

  List<Map<String, dynamic>> getPendingTaskActions() {
    final userId = getUserId() ?? 'guest';
    final boxName = 'pending_sync_$userId';
    if (!Hive.isBoxOpen(boxName)) return [];
    final box = Hive.box(boxName);
    final list = box.get('pending_tasks_actions') as List?;
    if (list == null) return [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ─── Custom Categories ──────────────────────────────────────────────────

  Future<void> saveCustomCategories(List<String> categories) async {
    final userId = getUserId() ?? 'guest';
    await _settingsBox.put('custom_categories_$userId', categories);
  }

  List<String> getCustomCategories() {
    final userId = getUserId() ?? 'guest';
    final list = _settingsBox.get('custom_categories_$userId') as List?;
    if (list == null) return [];
    return List<String>.from(list);
  }

  // ─── Affirmation Metadata (repeat counts, last viewed, etc.) ──────────

  Future<void> saveSampleDataSeeded(bool seeded) async {
    await _settingsBox.put('sample_data_seeded', seeded);
  }

  bool isSampleDataSeeded() {
    return _settingsBox.get('sample_data_seeded', defaultValue: false) as bool;
  }

  Future<void> saveSampleDataVersion(int version) async {
    await _settingsBox.put('sample_data_version', version);
  }

  int getSampleDataVersion() {
    return _settingsBox.get('sample_data_version', defaultValue: 0) as int;
  }

  Future<void> saveAffirmationMetadata(String key, dynamic value) async {
    await _settingsBox.put('affirmation_meta_$key', value);
  }

  dynamic getAffirmationMetadata(String key) {
    return _settingsBox.get('affirmation_meta_$key');
  }

  Box getSettingsBox() => _settingsBox;
}
