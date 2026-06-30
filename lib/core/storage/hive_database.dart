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

    await Hive.openBox<StickyNote>('guest_sticky_notes');

    _todosBox = await Hive.openBox(_todosBoxName);
    _syncBox = await Hive.openBox(_syncBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);

    log('[Hive] Database initialized');
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

  // ─── Sync Queue ─────────────────────────────────────────────────────────

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
    return _settingsBox.get('onboarding_completed', defaultValue: false) as bool;
  }

  Future<void> saveSetupCompleted(bool completed) async {
    await _settingsBox.put('focus_setup_completed', completed);
  }

  bool isSetupCompleted() {
    return _settingsBox.get('focus_setup_completed', defaultValue: false) as bool;
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
  }

  Future<void> clearAll() async {
    await _todosBox.clear();
    await _syncBox.clear();
    await _settingsBox.clear();
  }

  Future<void> clearAllGuestData() async {
    // Wait, the guest data is in _todosBox and _syncBox? Actually, guest data is just data without an auth_token.
    // So clearing the boxes except for auth info would be best. 
    // Wait, GuestDataMigrationService.clearGuestData() is a better place for this.
    // Let's implement it here for simplicity.
    final token = _settingsBox.get('auth_token');
    final userData = _settingsBox.get('user_data');
    
    await _todosBox.clear();
    await _syncBox.clear();
    await _settingsBox.clear();
    
    // Restore auth info
    if (token != null) await _settingsBox.put('auth_token', token);
    if (userData != null) await _settingsBox.put('user_data', userData);
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

  Future<void> saveSelectedAffirmations(List<Map<String, dynamic>> affirmations) async {
    final userId = getUserId() ?? 'guest';
    await _settingsBox.put('focus_selected_affirmations_$userId', affirmations);
  }

  List<Map<String, dynamic>> getSelectedAffirmations() {
    final userId = getUserId() ?? 'guest';
    final list = _settingsBox.get('focus_selected_affirmations_$userId') as List?;
    if (list == null) return [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> clearUserAffirmationsCache(String userId) async {
    await _settingsBox.delete('focus_selected_affirmations_$userId');
    await _settingsBox.delete('focus_pending_deletions_$userId');
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

  // Habit completion logs formatted as: { "yyyy-MM-dd": [ "habitId1", "habitId2" ] }
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

  Future<void> saveSelectedGoals(List<Map<String, dynamic>> goals) async {
    await _settingsBox.put('focus_selected_goals', goals);
  }

  List<Map<String, dynamic>> getSelectedGoals() {
    final list = _settingsBox.get('focus_selected_goals') as List?;
    if (list == null) return [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
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

  // ─── Vision Items Persistence ──────────────────────────────────────────

  Future<void> saveVisionItems(List<Map<String, dynamic>> items) async {
    await _settingsBox.put('focus_vision_items', items);
  }

  List<Map<String, dynamic>> getVisionItems() {
    final list = _settingsBox.get('focus_vision_items') as List?;
    if (list == null) return [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> saveVisionViewport(List<double> matrix) async {
    await _settingsBox.put('focus_vision_viewport', matrix);
  }

  List<double>? getVisionViewport() {
    final list = _settingsBox.get('focus_vision_viewport') as List?;
    return list?.cast<double>();
  }

  // ─── Vision Customization ──────────────────────────────────────────────

  Future<void> saveVisionCustomization(Map<String, dynamic> customization) async {
    await _settingsBox.put('focus_vision_customization', customization);
  }

  Map<String, dynamic>? getVisionCustomization() {
    final map = _settingsBox.get('focus_vision_customization') as Map?;
    if (map == null) return null;
    return Map<String, dynamic>.from(map);
  }

  bool hasSeenPreview(String feature) {
    return _settingsBox.get('focus_seen_preview_$feature', defaultValue: false) as bool;
  }

  Future<void> setSeenPreview(String feature) async {
    await _settingsBox.put('focus_seen_preview_$feature', true);
  }
}
