// ============================================================================
// File: lib/core/services/auth_service.dart
// Mục đích: Cung cấp dịch vụ hạ tầng (auth).
// Kết cấu:
//  - Xác thực qua Firebase Auth và đồng bộ hồ sơ người dùng qua ASP.NET Core Web API.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../models/user_model.dart';
import 'api_client.dart';

/// Exception khi tài khoản bị khóa
class BlockedAccountException implements Exception {
  final String message;
  const BlockedAccountException([
    this.message =
        'Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên.',
  ]);

  @override
  String toString() => message;
}

/// Exception chung cho Auth với thông báo thân thiện bằng tiếng Việt
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Service xử lý xác thực người dùng bằng Firebase Auth và ASP.NET Core Web API
class AuthService {
  final FirebaseAuth _firebaseAuth;
  final ApiClient _apiClient;

  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    ApiClient? apiClient,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _apiClient = apiClient ?? ApiClient(firebaseAuth: firebaseAuth);

  /// Stream theo dõi trạng thái Authentication của Firebase
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// User hiện tại từ Firebase Auth
  User? get currentAuthUser => _firebaseAuth.currentUser;

  /// Đăng ký tài khoản mới bằng Email/Password (UC-01)
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    try {
      debugPrint(
        '🔑 [AuthService] Bắt đầu đăng ký: $email, role: ${role.toRoleString()}',
      );

      // 1. Tạo tài khoản trong Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException(
          'Đăng ký không thành công. Vui lòng thử lại.',
        );
      }

      // 2. Cập nhật Display Name trong Firebase Auth
      await firebaseUser.updateDisplayName(displayName.trim());

      // 3. Đồng bộ tài khoản lên ASP.NET Core Web API (SQL Server)
      final response = await _apiClient.post(
        '/api/users/sync',
        body: {
          'uid': firebaseUser.uid,
          'email': email.trim(),
          'displayName': displayName.trim(),
          'role': role.toRoleString(),
          'avatarUrl': '',
        },
      );

      if (response is Map) {
        return UserModel.fromMap(
          Map<String, dynamic>.from(response),
          id: firebaseUser.uid,
        );
      }

      final now = DateTime.now();
      return UserModel(
        uid: firebaseUser.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        avatarUrl: '',
        role: role,
        isBlocked: false,
        createdAt: now,
        updatedAt: now,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '❌ [AuthService] FirebaseAuthException: ${e.code} - ${e.message}',
      );
      throw AuthException(_mapFirebaseError(e));
    } on ApiException catch (e) {
      if (e.code == 'BLOCKED_ACCOUNT' || e.statusCode == 403) {
        await _firebaseAuth.signOut();
        throw BlockedAccountException(e.message);
      }
      throw AuthException(e.message);
    } catch (e) {
      debugPrint('❌ [AuthService] Lỗi không xác định: $e');
      if (e is AuthException || e is BlockedAccountException) rethrow;
      throw AuthException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  /// Đăng nhập tài khoản bằng Email/Password (UC-01)
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔑 [AuthService] Đăng nhập: $email');

      // 1. Xác thực qua Firebase Auth
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('Đăng nhập thất bại. Vui lòng thử lại.');
      }

      // 2. Đồng bộ / Lấy dữ liệu user profile từ ASP.NET Core Web API
      final response = await _apiClient.post(
        '/api/users/sync',
        body: {
          'uid': firebaseUser.uid,
          'email': firebaseUser.email ?? email.trim(),
          'displayName':
              firebaseUser.displayName ?? email.trim().split('@').first,
        },
      );

      final userModel = UserModel.fromMap(
        Map<String, dynamic>.from(response as Map),
        id: firebaseUser.uid,
      );

      // 3. Kiểm tra tài khoản có bị khóa không (isBlocked)
      if (userModel.isBlocked) {
        debugPrint(
          '🚫 [AuthService] Tài khoản ${userModel.uid} bị khóa. Buộc đăng xuất.',
        );
        await _firebaseAuth.signOut();
        throw const BlockedAccountException();
      }

      debugPrint(
        '✅ [AuthService] Đăng nhập thành công: ${userModel.displayName} (${userModel.role.toRoleString()})',
      );
      return userModel;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '❌ [AuthService] FirebaseAuthException: ${e.code} - ${e.message}',
      );
      throw AuthException(_mapFirebaseError(e));
    } on ApiException catch (e) {
      if (e.code == 'BLOCKED_ACCOUNT' || e.statusCode == 403) {
        await _firebaseAuth.signOut();
        throw BlockedAccountException(e.message);
      }
      throw AuthException(e.message);
    } on BlockedAccountException {
      rethrow;
    } catch (e) {
      debugPrint('❌ [AuthService] Login error: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Đăng nhập thất bại: ${e.toString()}');
    }
  }

  /// Lấy thông tin UserModel hiện tại từ ASP.NET Core Web API
  Future<UserModel?> getCurrentUserModel() async {
    final authUser = _firebaseAuth.currentUser;
    if (authUser == null) return null;

    try {
      final response = await _apiClient.get('/api/users/${authUser.uid}');
      if (response is! Map) return null;

      final userModel = UserModel.fromMap(
        Map<String, dynamic>.from(response),
        id: authUser.uid,
      );
      if (userModel.isBlocked) {
        await _firebaseAuth.signOut();
        throw const BlockedAccountException();
      }

      return userModel;
    } on ApiException catch (e) {
      if (e.code == 'BLOCKED_ACCOUNT' || e.statusCode == 403) {
        await _firebaseAuth.signOut();
        throw BlockedAccountException(e.message);
      }
      if (e.statusCode == 404) {
        // Tự động đồng bộ nếu user đã có trên Firebase Auth nhưng chưa có trong SQL Server
        try {
          final synced = await _apiClient.post(
            '/api/users/sync',
            body: {
              'uid': authUser.uid,
              'email': authUser.email ?? '',
              'displayName':
                  authUser.displayName ??
                  (authUser.email?.split('@').first ?? 'Người dùng'),
            },
          );
          if (synced is Map) {
            return UserModel.fromMap(
              Map<String, dynamic>.from(synced),
              id: authUser.uid,
            );
          }
        } catch (_) {}
      }
      return null;
    } on BlockedAccountException {
      rethrow;
    } catch (e) {
      debugPrint('⚠️ [AuthService] Lỗi khi lấy thông tin user: $e');
      return null;
    }
  }

  /// Gửi email đặt lại mật khẩu (UC-01)
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('📧 [AuthService] Gửi email reset password tới: $email');
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      debugPrint('✅ [AuthService] Đã gửi email reset password');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [AuthService] sendPasswordResetEmail error: ${e.code}');
      throw AuthException(_mapFirebaseError(e));
    } catch (e) {
      throw AuthException('Không thể gửi yêu cầu đặt lại mật khẩu: $e');
    }
  }

  /// Cập nhật thông tin hồ sơ người dùng (displayName, avatarUrl) qua API
  Future<UserModel> updateUserProfile({
    required String uid,
    required String displayName,
    String? avatarUrl,
  }) async {
    try {
      debugPrint('👤 [AuthService] Cập nhật thông tin hồ sơ: $displayName');

      final authUser = _firebaseAuth.currentUser;
      if (authUser != null && authUser.uid == uid) {
        await authUser.updateDisplayName(displayName.trim());
      }

      final response = await _apiClient.put(
        '/api/users/$uid/profile',
        body: {
          'displayName': displayName.trim(),
          if (avatarUrl != null) 'avatarUrl': avatarUrl.trim(),
        },
      );

      return UserModel.fromMap(
        Map<String, dynamic>.from(response as Map),
        id: uid,
      );
    } catch (e) {
      debugPrint('❌ [AuthService] Lỗi cập nhật profile: $e');
      throw AuthException('Không thể cập nhật thông tin: $e');
    }
  }

  /// Lưu dáng khuôn mặt AI của khách hàng (Task Phase 3 - C2)
  Future<void> saveUserFaceShape(String uid, String faceShape) async {
    try {
      await _apiClient.put(
        '/api/users/$uid/face-shape',
        body: {'faceShape': faceShape},
      );
      debugPrint(
        '🤖 [AuthService] Đã lưu savedFaceShape=$faceShape cho user $uid',
      );
    } catch (e) {
      debugPrint('⚠️ [AuthService] Lỗi lưu savedFaceShape: $e');
    }
  }

  /// Thêm hoặc bỏ thợ cắt tóc khỏi danh sách yêu thích (Task Phase 3 - C3)
  Future<List<String>> toggleFavoriteBarber(String uid, String barberId) async {
    try {
      final response = await _apiClient.post(
        '/api/users/$uid/favorites/toggle',
        body: {'barberId': barberId},
      );
      if (response is Map && response['favoriteBarberIds'] is List) {
        return (response['favoriteBarberIds'] as List)
            .map((e) => e.toString())
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('⚠️ [AuthService] Lỗi toggle favorite barber: $e');
      return [];
    }
  }

  /// Đăng xuất khỏi hệ thống
  Future<void> logout() async {
    debugPrint('👋 [AuthService] Đăng xuất');
    await _firebaseAuth.signOut();
  }

  /// Chuyển đổi mã lỗi Firebase Auth sang thông báo tiếng Việt dễ hiểu
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không chính xác. Vui lòng kiểm tra lại.';
      case 'email-already-in-use':
        return 'Địa chỉ email này đã được đăng ký. Vui lòng đăng nhập hoặc dùng email khác.';
      case 'invalid-email':
        return 'Định dạng email không hợp lệ.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu có ít nhất 6 ký tự.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'too-many-requests':
        return 'Bạn đã thao tác sai quá nhiều lần. Vui lòng đợi trong giây lát và thử lại.';
      case 'network-request-failed':
        return 'Không thể kết nối Internet. Vui lòng kiểm tra kết nối mạng của bạn.';
      case 'operation-not-allowed':
        return 'Tính năng đăng nhập bằng email chưa được bật trên Firebase. Vui lòng bật Email/Password trong Firebase Console.';
      default:
        return e.message ?? 'Đã xảy ra lỗi xác thực. Vui lòng thử lại sau.';
    }
  }
}

// CreBy: MenBoyBMN
