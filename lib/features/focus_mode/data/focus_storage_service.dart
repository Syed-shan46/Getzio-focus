import 'package:hive/hive.dart';
import '../domain/models/focus_session_model.dart';

class FocusStorageService {
  static const String boxName = 'focus_sessions';
  late Box<FocusSessionModel> _box;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(FocusSessionModelAdapter());
      }
      _box = await Hive.openBox<FocusSessionModel>(boxName);
      _isInitialized = true;
    } catch (e) {
      print('FocusStorageService init error: $e');
    }
  }

  Future<void> saveSession(FocusSessionModel session) async {
    if (!_isInitialized) await init();
    if (_isInitialized) await _box.put(session.id, session);
  }

  Future<void> updateSession(FocusSessionModel session) async {
    if (!_isInitialized) await init();
    if (_isInitialized) {
      if (session.isInBox) {
        await session.save();
      } else {
        await _box.put(session.id, session);
      }
    }
  }

  Future<void> deleteSession(String id) async {
    if (_isInitialized) await _box.delete(id);
  }

  FocusSessionModel? getActiveSession() {
    if (!_isInitialized) return null;
    try {
      return _box.values.firstWhere((s) => !s.completed && !s.interrupted);
    } catch (e) {
      return null;
    }
  }

  List<FocusSessionModel> getAllSessions() {
    return _box.values.toList()..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  List<FocusSessionModel> getUnsyncedCompletedSessions() {
    // For a real app, you might have a boolean 'isSynced'.
    // Here we just return all completed ones for demo purposes, or handle it via SyncService.
    return _box.values.where((s) => s.completed).toList();
  }
}
