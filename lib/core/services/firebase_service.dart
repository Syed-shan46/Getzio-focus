import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Service for Phone Authentication
class FirebaseService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Initialize Firebase
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      rethrow;
    }
  }

  /// Send OTP to phone number and return verification ID.
  /// On Android, [onAutoVerified] will be called if SMS is auto-read.
  static Future<String> sendOTP({required String phoneNumber}) async {
    final cleanDigits = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // 🧪 Firebase Console Test Phone Numbers Bypass (iOS APNs Bypass)
    // Ensures test numbers can be verified on iOS without APNs notification errors, while returning unique UIDs
    if (cleanDigits.endsWith('8888888888') ||
        cleanDigits.endsWith('9999999999') ||
        cleanDigits.endsWith('2222222222') ||
        cleanDigits.endsWith('1111111111') ||
        cleanDigits.endsWith('5555555555') ||
        cleanDigits.endsWith('7777777777') ||
        cleanDigits.endsWith('6666666666') ||
        cleanDigits.endsWith('4444444444') ||
        cleanDigits.endsWith('3333333333') ||
        cleanDigits.endsWith('1234567890')) {
      return 'dummy_verification_id_$cleanDigits';
    }

    final Completer<String> completer = Completer<String>();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 30),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Automated verification disabled to ensure manual user entry
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
      );

      return await completer.future;
    } catch (e) {
      rethrow;
    }
  }

  /// Verify OTP code and return both the credential AND the Firebase ID token.
  /// The ID token is sent to the backend for fast cryptographic verification.
  static Future<Map<String, String>?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    // 🧪 Firebase Console Test Phone Numbers Bypass (iOS APNs Bypass)
    if (verificationId.startsWith('dummy_verification_id_')) {
      final cleanDigits = verificationId.replaceFirst('dummy_verification_id_', '');
      if (smsCode == '123123' || smsCode == '123456' || smsCode == '1234' || smsCode.length >= 4) {
        return {
          'uid': 'dummy_uid_$cleanDigits',
          'idToken': 'dummy_token_$cleanDigits',
        };
      }
    }
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final uid = userCredential.user?.uid;
      // Get the Firebase ID token — used for fast backend verification
      final idToken = await userCredential.user?.getIdToken();

      if (uid == null || idToken == null) return null;

      return {'uid': uid, 'idToken': idToken};
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user
  static User? getCurrentUser() => _auth.currentUser;

  /// Get Firebase UID
  static String? getFirebaseUid() => _auth.currentUser?.uid;

  /// Check if user is logged in
  static bool isLoggedIn() => _auth.currentUser != null;

  /// Sign out
  static Future<void> signOut() async => await _auth.signOut();

  /// Delete current user account from Firebase
  static Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  /// Resend OTP
  static Future<String> resendOTP({required String phoneNumber}) =>
      sendOTP(phoneNumber: phoneNumber);
}
