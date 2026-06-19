import '../../../../core/network/dio_client.dart';
import '../../domain/models/auth_user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dio;

  AuthRepositoryImpl(this._dio);

  @override
  Future<bool> sendOtp(String mobile) async {
    try {
      final response = await _dio.post(
        '/user/auth/send-otp',
        data: {'mobile': mobile},
      );
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthUserModel> verifyOtp(String mobile, String otp) async {
    try {
      final response = await _dio.post(
        '/user/auth/verify-otp',
        data: {'mobile': mobile, 'otp': otp},
      );
      
      final dynamic responseData = response.data['data'] ?? response.data;
      final Map<String, dynamic> data = Map<String, dynamic>.from(responseData as Map);
      return AuthUserModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthUserModel> firebaseAuth({
    required String mobile,
    required String firebaseUid,
    String? idToken,
  }) async {
    try {
      final response = await _dio.post(
        '/user/auth/firebase',
        data: {
          'phoneNumber': mobile,
          'firebaseUid': firebaseUid,
          'idToken': idToken,
        },
      );
      
      final dynamic responseData = response.data['data'] ?? response.data;
      final Map<String, dynamic> data = Map<String, dynamic>.from(responseData as Map);
      return AuthUserModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthUserModel> updateProfile(String name) async {
    try {
      final response = await _dio.put(
        '/user/profile/update',
        data: {'name': name},
      );
      final dynamic responseData = response.data['data'] ?? response.data;
      final Map<String, dynamic> data = Map<String, dynamic>.from(responseData as Map);
      return AuthUserModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
