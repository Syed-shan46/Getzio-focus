import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getzio_todo_app/shared/providers/app_providers.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/storage/hive_database.dart';
import '../../domain/models/routine_item.dart';

class RoutineNotifier extends StateNotifier<List<RoutineItem>> {
  final HiveDatabase _hiveDb;

  RoutineNotifier(this._hiveDb) : super([]) {
    _loadRoutines();
  }

  void _loadRoutines() {
    final rawList = _hiveDb.getUserItems('daily_routines');
    // Filter out old auto-seeded sample routines so users start with a clean state
    final loaded = rawList
        .map((e) => RoutineItem.fromMap(e))
        .where((r) => !r.id.startsWith('sample_routine_'))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    state = loaded;
    _saveState();
  }

  void _saveState() {
    final rawList = state.map((e) => e.toMap()).toList();
    _hiveDb.saveUserItems('daily_routines', rawList);
  }

  void toggleRoutineCompletion(String id, String dateStr) {
    state = state.map((item) {
      if (item.id == id) {
        final dates = List<String>.from(item.completedDates);
        if (dates.contains(dateStr)) {
          dates.remove(dateStr);
        } else {
          dates.add(dateStr);
        }
        return item.copyWith(completedDates: dates);
      }
      return item;
    }).toList();
    _saveState();
  }

  void addRoutine(String title, [String? subtitle]) {
    final newItem = RoutineItem(
      id: const Uuid().v4(),
      title: title,
      subtitle: subtitle,
      completedDates: [],
      createdAt: DateTime.now(),
    );
    state = [...state, newItem];
    _saveState();
  }

  void deleteRoutine(String id) {
    state = state.where((item) => item.id != id).toList();
    _saveState();
  }
}

final routineProvider =
    StateNotifierProvider<RoutineNotifier, List<RoutineItem>>((ref) {
      final hiveDb = ref.watch(hiveDatabaseProvider);
      return RoutineNotifier(hiveDb);
    });
