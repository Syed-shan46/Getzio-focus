import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../core/storage/hive_database.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../todo/presentation/providers/todo_providers.dart';
import '../../domain/models/auth_user_model.dart';
import '../../domain/services/guest_migration_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'dart:developer';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AuthRepositoryImpl(dio);
});

final syncLoadingProvider = StateProvider<bool>((ref) => false);

class AuthNotifier extends StateNotifier<AsyncValue<AuthUserModel?>> {
  final AuthRepository _repo;
  final HiveDatabase _hiveDb;
  final Ref _ref;
  String? _verificationId;

  AuthNotifier(this._repo, this._hiveDb, this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    try {
      final token = _hiveDb.getAuthToken();
      final id = _hiveDb.getUserId();
      final mobile = _hiveDb.getUserPhone();
      final name = _hiveDb.getUserName();

      if (token != null && token.isNotEmpty && id != null && mobile != null) {
        final user = AuthUserModel(
          id: id,
          mobile: mobile,
          name: name ?? '',
          role: 'customer',
          token: token,
        );
        state = AsyncValue.data(user);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> sendOtp(String mobile) async {
    try {
      final verificationId = await FirebaseService.sendOTP(phoneNumber: mobile);
      _verificationId = verificationId;
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _syncLocalDataToServer() async {
    log('[Sync] Preparing to synchronize local preferences...');
    final dio = _ref.read(dioClientProvider);
    
    // Gather all local data from Hive
    final lifeAreas = _hiveDb.getSelectedLifeAreas();
    final selectedGoals = _hiveDb.getSelectedGoals();
    final wakeUpTime = _hiveDb.getWakeUpTime() ?? '6:00 AM';
    final selectedHabits = _hiveDb.getSelectedHabits();
    final selectedAffirmations = _hiveDb.getSelectedAffirmations();
    final userStatistics = _hiveDb.getUserStatistics() ?? {};
    final habitLogs = _hiveDb.getHabitLogs();
    final workspaceSettings = _hiveDb.getWorkspaceSettings();
    final readingPrefs = _hiveDb.getReadingPreferences() ?? {};
    final healthPrefs = _hiveDb.getHealthPreferences() ?? {};
    final financePrefs = _hiveDb.getFinancePreferences() ?? {};
    final visionItems = _hiveDb.getVisionItems();

    // Ensure all items have a localId and a default syncStatus
    final updatedGoals = selectedGoals.map((g) {
      final map = Map<String, dynamic>.from(g);
      map['localId'] ??= map['id'] ?? map['_id'] ?? 'goal_${DateTime.now().microsecondsSinceEpoch}_${g.hashCode}';
      map['syncStatus'] ??= 'pending';
      return map;
    }).toList();
    await _hiveDb.saveSelectedGoals(updatedGoals);

    final updatedHabits = selectedHabits.map((h) {
      final map = Map<String, dynamic>.from(h);
      map['localId'] ??= map['id'] ?? map['_id'] ?? 'habit_${DateTime.now().microsecondsSinceEpoch}_${h.hashCode}';
      map['syncStatus'] ??= 'pending';
      return map;
    }).toList();
    await _hiveDb.saveSelectedHabits(updatedHabits);

    final updatedAffirmations = selectedAffirmations.map((a) {
      final map = Map<String, dynamic>.from(a);
      map['localId'] ??= map['id'] ?? map['_id'] ?? 'affirmation_${DateTime.now().microsecondsSinceEpoch}_${a.hashCode}';
      map['syncStatus'] ??= 'pending';
      return map;
    }).toList();
    await _hiveDb.saveSelectedAffirmations(updatedAffirmations);

    final updatedVisionItems = visionItems.map((v) {
      final map = Map<String, dynamic>.from(v);
      map['localId'] ??= map['id'] ?? map['_id'] ?? 'vision_${DateTime.now().microsecondsSinceEpoch}_${v.hashCode}';
      map['syncStatus'] ??= 'pending';
      return map;
    }).toList();
    await _hiveDb.saveVisionItems(updatedVisionItems);

    // 1. Sync onboarding preferences to /api/focus/onboarding
    try {
      final onboardingPayload = {
        'identity': _hiveDb.getSelectedIdentity() ?? '🚀 Entrepreneur',
        'lifeAreas': lifeAreas,
        'selectedHabits': updatedHabits.map((h) => {
          'localId': h['localId'],
          'id': h['id'] ?? h['_id'],
          'title': h['title'],
          'category': h['category'] ?? 'General',
        }).toList(),
        'readingPreferences': {
          'categories': readingPrefs['categories'] ?? [],
          'targetBooks': readingPrefs['bookTarget'] ?? 10,
          'pagesPerDay': readingPrefs['dailyReadingMinutes'] ?? 20,
        },
        'financePreferences': {
          'targetAmount': financePrefs['monthlySavings'] ?? 0,
          'monthlySavingsTarget': financePrefs['monthlySavings'] ?? 0,
        },
        'healthPreferences': {
          'waterTarget': healthPrefs['waterTarget'] ?? 2000,
          'sleepTarget': healthPrefs['sleepTarget'] ?? 8,
          'exerciseTarget': healthPrefs['exerciseTarget'] ?? 30,
        },
        'affirmations': updatedAffirmations.map((a) => a['text'] as String).toList(),
        'workspaceTheme': workspaceSettings['theme'] ?? 'default',
      };
      
      final response = await dio.post('/api/focus/onboarding', data: onboardingPayload);
      log('[Sync] Onboarding sync completed successfully: ${response.statusCode}');
    } catch (e) {
      log('[Sync] Onboarding sync failed: $e');
    }

    // 2. Sync progress and vision board items to /api/focus/sync
    try {
      // Structure habitLogs map into array for backend format
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

      final syncPayload = {
        'profile': {
          'identity': _hiveDb.getSelectedIdentity(),
          'lifeAreas': lifeAreas,
          'workspaceTheme': workspaceSettings['theme'] ?? 'default'
        },
        'habits': updatedHabits.map((h) => {
          'localId': h['localId'],
          'habitId': h['id'] ?? h['_id'],
          'title': h['title'],
          'category': h['category'] ?? 'General',
          'enabled': h['enabled'] ?? true,
          'dailyTarget': h['frequency'] == 'Daily' ? '1 time' : '3 times',
          'xpReward': h['xpReward'] ?? 10,
        }).toList(),
        'goals': updatedGoals.map((g) => {
          'localId': g['localId'],
          'title': g['title'] ?? 'Goal',
          'category': g['category'] ?? 'General',
          'target': g['target'] ?? 100,
          'currentProgress': g['currentProgress'] ?? 0,
          'status': (g['status'] == 'completed') ? 'completed' : 'in-progress',
          'deadline': g['deadline'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          'priority': g['priority'] ?? 'medium',
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
        'affirmations': updatedAffirmations.map((a) => {
          'localId': a['localId'],
          'title': a['text'] ?? 'Affirmation',
          'author': a['author'] ?? 'Anonymous',
          'category': a['category'] ?? 'General',
          'favorite': a['isPinned'] ?? false,
        }).toList(),
        'visionRoom': {
          'items': updatedVisionItems,
        },
        'habitLogs': logsList,
        'workspaceSettings': workspaceSettings['theme'] ?? 'default'
      };

      final response = await dio.post('/api/focus/sync', data: syncPayload);
      log('[Sync] Core progress and vision room items sync completed: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['localIdToServerIdMap'] != null) {
          final mapping = data['localIdToServerIdMap'] as Map<String, dynamic>;

          // Sync local ID goals mapping
          if (mapping['goals'] != null) {
            final goalMap = mapping['goals'] as Map<String, dynamic>;
            final goalsToSave = _hiveDb.getSelectedGoals();
            final mapped = goalsToSave.map((g) {
              final map = Map<String, dynamic>.from(g);
              final locId = map['localId'];
              if (locId != null && goalMap.containsKey(locId)) {
                map['serverId'] = goalMap[locId];
                map['syncStatus'] = 'synced';
              }
              return map;
            }).toList();
            await _hiveDb.saveSelectedGoals(mapped);
          }

          // Sync local ID habits mapping
          if (mapping['habits'] != null) {
            final habitMap = mapping['habits'] as Map<String, dynamic>;
            final habitsToSave = _hiveDb.getSelectedHabits();
            final mapped = habitsToSave.map((h) {
              final map = Map<String, dynamic>.from(h);
              final locId = map['localId'];
              if (locId != null && habitMap.containsKey(locId)) {
                map['serverId'] = habitMap[locId];
                map['syncStatus'] = 'synced';
              }
              return map;
            }).toList();
            await _hiveDb.saveSelectedHabits(mapped);
          }

          // Sync local ID affirmations mapping
          if (mapping['affirmations'] != null) {
            final affMap = mapping['affirmations'] as Map<String, dynamic>;
            final affirmationsToSave = _hiveDb.getSelectedAffirmations();
            final mapped = affirmationsToSave.map((a) {
              final map = Map<String, dynamic>.from(a);
              final locId = map['localId'];
              if (locId != null && affMap.containsKey(locId)) {
                map['serverId'] = affMap[locId];
                map['syncStatus'] = 'synced';
              }
              return map;
            }).toList();
            await _hiveDb.saveSelectedAffirmations(mapped);
          }

          // Save final sync status parameters
          await _hiveDb.saveSyncStatus(
            userId: _hiveDb.getUserId() ?? 'unknown',
            lastSyncTime: DateTime.now().toIso8601String(),
            syncCompleted: true,
          );
          log('[Sync] All local collections marked as synced.');
        }
      }
    } catch (e) {
      log('[Sync] Core sync failed: $e');
    }

    // 3. Trigger real sync of offline todo queue
    try {
      await _ref.read(todoRepositoryProvider).syncOfflineData();
      log('[Sync] Offline todos sync completed successfully.');
    } catch (e) {
      log('[Sync] Offline todos sync failed: $e');
    }
  }

  Future<void> simulateSocialLogin(String provider) async {
    state = const AsyncValue.loading();
    _ref.read(syncLoadingProvider.notifier).state = true;
    
    // Simulate loading for realistic UX
    await Future.delayed(const Duration(milliseconds: 1500));
    
    final mockUser = AuthUserModel(
      id: 'mock_social_${provider.toLowerCase()}_id',
      mobile: '+919999999999',
      name: '$provider User',
      role: 'customer',
      token: 'mock_jwt_token_for_${provider.toLowerCase()}',
    );

    await _hiveDb.saveAuthToken(mockUser.token);
    await _hiveDb.saveUserId(mockUser.id);
    await _hiveDb.saveUserPhone(mockUser.mobile);
    await _hiveDb.saveUserName(mockUser.name);

    // Guest -> Account Migration / Reload from Backend
    final hasGuestData = GuestDataMigrationService.checkGuestDataExists(_hiveDb);
    if (hasGuestData) {
      log('[Auth] Guest data detected, migrating to server...');
      await GuestDataMigrationService.migrate(_ref);
    } else {
      log('[Auth] No guest data, reloading from server...');
      await GuestDataMigrationService.reloadFromBackend(_ref);
    }

    state = AsyncValue.data(mockUser);
    _ref.read(syncLoadingProvider.notifier).state = false;
  }

  Future<void> verifyOtp(String mobile, String otp) async {
    try {
      if (_verificationId == null) {
        throw Exception("Verification session expired. Please request a new OTP.");
      }

      // 1. Verify OTP with Firebase to get UID and ID Token
      final result = await FirebaseService.verifyOTP(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      if (result == null) {
        throw Exception("Verification failed. Please try again.");
      }

      final uid = result['uid']!;
      final idToken = result['idToken'];

      // Enable sync loading overlay
      _ref.read(syncLoadingProvider.notifier).state = true;

      // 2. Handshake with backend to login/register and retrieve JWT token
      final user = await _repo.firebaseAuth(
        mobile: mobile,
        firebaseUid: uid,
        idToken: idToken,
      );
      
      // 3. Cache details in Hive Database
      await _hiveDb.saveAuthToken(user.token);
      await _hiveDb.saveUserId(user.id);
      await _hiveDb.saveUserPhone(user.mobile);
      await _hiveDb.saveUserName(user.name);

      // Guest -> Account Migration / Reload from Backend
      final hasGuestData = GuestDataMigrationService.checkGuestDataExists(_hiveDb);
      if (hasGuestData) {
        log('[Auth] Guest data detected, migrating to server...');
        await GuestDataMigrationService.migrate(_ref);
      } else {
        log('[Auth] No guest data, reloading from server...');
        await GuestDataMigrationService.reloadFromBackend(_ref);
      }

      state = AsyncValue.data(user);
    } catch (e) {
      rethrow;
    } finally {
      _ref.read(syncLoadingProvider.notifier).state = false;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      try {
        await FirebaseService.signOut();
      } catch (_) {}
      
      // Only clear cached auth boxes to maintain synced focus data
      await _hiveDb.clearAuth();
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    state = const AsyncValue.loading();
    try {
      // 1. Call backend to delete profile
      await _repo.deleteAccount();

      // 2. Call Firebase to delete user profile
      try {
        await FirebaseService.deleteAccount();
      } catch (_) {}

      // 3. Clear local storage cache
      await _hiveDb.clearAuth();
      await _hiveDb.clearTodos();
      await _hiveDb.clearSyncQueue();

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updateName(String name) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      final updatedUser = await _repo.updateProfile(name);
      
      // Save name to settings cache
      await _hiveDb.saveUserName(updatedUser.name);
      
      // Re-emit auth state with updated details
      state = AsyncValue.data(updatedUser);
    } catch (e) {
      rethrow;
    }
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthUserModel?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final hiveDb = ref.watch(hiveDatabaseProvider);
  return AuthNotifier(repo, hiveDb, ref);
});
