import '../models/auth_user_model.dart';

abstract class AuthRepository {
  Future<bool> sendOtp(String mobile);
  Future<AuthUserModel> verifyOtp(String mobile, String otp);
  Future<AuthUserModel> firebaseAuth({
    required String mobile,
    required String firebaseUid,
    String? idToken,
  });
  Future<AuthUserModel> updateProfile(String name);
}
