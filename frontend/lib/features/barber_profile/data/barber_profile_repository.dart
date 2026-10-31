// ============================================================================
// File: lib/features/barber_profile/data/barber_profile_repository.dart
// Mục đích: Quản lý dữ liệu (Repository) cho tính năng barber_profile.
// Kết cấu:
//  - Giao tiếp với ASP.NET Core Web API để quản lý hồ sơ thợ cắt tóc.
// ============================================================================

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../../../models/barber_profile_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_provider.dart';

final barberProfileRepositoryProvider = Provider<BarberProfileRepository>((
  ref,
) {
  return BarberProfileRepository(null, ref.watch(apiClientProvider));
});

final barberProfileProvider =
    FutureProvider.family<BarberProfileModel?, String>((ref, uid) async {
      return ref.watch(barberProfileRepositoryProvider).getBarberProfile(uid);
    });

/// StreamProvider lắng nghe hồ sơ của thợ cắt tóc đang đăng nhập
final currentBarberProfileStreamProvider =
    StreamProvider.autoDispose<BarberProfileModel?>((ref) {
      final authUser = ref.watch(authStateProvider).value;
      final uid =
          authUser?.uid ??
          ref.watch(currentUserModelProvider).value?.uid ??
          ref.watch(firebaseAuthProvider).currentUser?.uid;
      if (uid == null) return const Stream.empty();
      return ref
          .watch(barberProfileRepositoryProvider)
          .streamBarberProfile(uid);
    });

class BarberProfileRepository {
  final ApiClient _apiClient;

  BarberProfileRepository([FirebaseFirestore? firestore, ApiClient? apiClient])
    : _apiClient = apiClient ?? ApiClient();

  /// Lắng nghe hồ sơ thợ cắt tóc
  Stream<BarberProfileModel?> streamBarberProfile(String uid) async* {
    yield await getBarberProfile(uid);
    yield* Stream.periodic(const Duration(seconds: 15)).asyncMap((_) async {
      return await getBarberProfile(uid);
    });
  }

  /// Cập nhật trạng thái nhận khách đặt lịch hôm nay (Task 2.3)
  Future<void> updateAcceptingBookingsToday(
    String uid,
    bool isAccepting,
  ) async {
    await _apiClient.patch(
      '/api/barbers/$uid/accepting',
      body: {'isAccepting': isAccepting},
    );
  }

  Future<BarberProfileModel?> getBarberProfile(String uid) async {
    try {
      final response = await _apiClient.get('/api/barbers/$uid');
      if (response is Map) {
        return BarberProfileModel.fromMap(
          Map<String, dynamic>.from(response),
          id: uid,
        );
      }
    } catch (_) {}
    return null;
  }

  Future<void> createOrUpdateProfile(BarberProfileModel profile) async {
    await _apiClient.put(
      '/api/barbers/${profile.uid}',
      body: profile.toJsonMap(),
    );
  }

  Future<List<BarberProfileModel>> getPendingBarbers() async {
    final response = await _apiClient.get('/api/barbers/pending');
    if (response is List) {
      return response
          .map(
            (e) =>
                BarberProfileModel.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    }
    return [];
  }

  Future<void> updateApprovalStatus(String uid, String status) async {
    await _apiClient.patch(
      '/api/barbers/$uid/approval',
      body: {'status': status},
    );
  }
}

// CreBy: MenBoyBMN
