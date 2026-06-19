import 'dart:developer';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<void> clearAuth() async {
    await _settingsBox.delete('auth_token');
    await _settingsBox.delete('user_id');
    await _settingsBox.delete('user_name');
    await _settingsBox.delete('user_phone');
  }
}
