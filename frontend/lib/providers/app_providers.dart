// ============================================================================
// File: lib/providers/app_providers.dart
// Mục đích: Quản lý trạng thái (State Management) cho app_providers.dart.
// Kết cấu:
//  - Sử dụng Riverpod (Notifier/StateNotifier/Provider) để cung cấp trạng thái và xử lý logic nghiệp vụ.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/api_client.dart';
import '../models/user_model.dart';

/// Provider cung cấp FirebaseAuth instance (dùng cho Auth & lấy JWT Token)
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provider cung cấp FirebaseFirestore instance (giữ cho Chat 1:1 realtime)
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider cung cấp ApiClient kết nối với ASP.NET Core Web API Backend
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provider theo dõi trạng thái Authentication của người dùng
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

/// Provider cung cấp thông tin tài khoản người dùng hiện tại từ ASP.NET Core Web API
final currentUserModelProvider = FutureProvider<UserModel?>((ref) async {
  final authUser = ref.watch(authStateChangesProvider).value;
  if (authUser == null) return null;

  final apiClient = ref.watch(apiClientProvider);
  try {
    final data = await apiClient.get('/api/users/${authUser.uid}');
    if (data is Map) {
      return UserModel.fromMap(
        Map<String, dynamic>.from(data),
        id: authUser.uid,
      );
    }
  } catch (_) {}
  return null;
});

// CreBy: MenBoyBMN
