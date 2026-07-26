import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getzio_todo_app/shared/providers/app_providers.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../../core/storage/hive_database.dart';
import '../../domain/models/routine_item.dart';

class RoutineNotifier extends StateNotifier<List<RoutineItem>> {
  final HiveDatabase _hiveDb;

  RoutineNotifier(this._hiveDb) : super([]) {
    _loadRoutines();
  }

  void _loadRoutines() {
    final rawList = _hiveDb.getUserItems('daily_routines');
    if (rawList.isEmpty) {
      // Seed default/sample routines for new users to start with
      state = _getSampleRoutines();
      _saveState();
    } else {
      state = rawList.map((e) => RoutineItem.fromMap(e)).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
  }

  List<RoutineItem> _getSampleRoutines() {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    return [
      RoutineItem(
        id: 'sample_routine_1',
        title: 'Wake up at 6:00 AM',
        subtitle: 'Start the day early',
        completedDates: [todayStr],
        createdAt: now.subtract(const Duration(minutes: 6)),
      ),
      RoutineItem(
        id: 'sample_routine_2',
        title: 'Drink Water',
        subtitle: 'Stay hydrated',
        completedDates: [todayStr],
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
      RoutineItem(
        id: 'sample_routine_3',
        title: 'Learn 5 English Words',
        subtitle: 'Expand vocabulary',
        completedDates: [],
        createdAt: now.subtract(const Duration(minutes: 4)),
      ),
      RoutineItem(
        id: 'sample_routine_4',
        title: 'Read 30 Minutes',
        subtitle: 'Consistent learning',
        completedDates: [todayStr],
        createdAt: now.subtract(const Duration(minutes: 3)),
      ),
      RoutineItem(
        id: 'sample_routine_5',
        title: 'Exercise',
        subtitle: 'Stay active',
        completedDates: [],
        createdAt: now.subtract(const Duration(minutes: 2)),
      ),
      RoutineItem(
        id: 'sample_routine_6',
        title: 'Practice English Speaking',
        subtitle: 'Fluent communication',
        completedDates: [todayStr],
        createdAt: now.subtract(const Duration(minutes: 1)),
      ),
      RoutineItem(
        id: 'sample_routine_7',
        title: 'Sleep Before 10:30 PM',
        subtitle: 'Healthy rest schedule',
        completedDates: [],
        createdAt: now,
      ),
    ];
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
