import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../core/storage/hive_database.dart';
import '../../../../core/services/firebase_service.dart';
import '../../domain/models/auth_user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AuthRepositoryImpl(dio);
});

class AuthNotifier extends StateNotifier<AsyncValue<AuthUserModel?>> {
  final AuthRepository _repo;
  final HiveDatabase _hiveDb;
  String? _verificationId;

  AuthNotifier(this._repo, this._hiveDb) : super(const AsyncValue.loading()) {
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

      state = AsyncValue.data(user);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      try {
        await FirebaseService.signOut();
      } catch (_) {}
      
      // Clear all cached boxes to maintain state boundaries
      await _hiveDb.clearAuth();
      await _hiveDb.clearTodos();
      await _hiveDb.clearSyncQueue();
      
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
  return AuthNotifier(repo, hiveDb);
});
