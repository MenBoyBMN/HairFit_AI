// ============================================================================
// File: lib/features/search_map/data/barber_repository.dart
// Mục đích: Quản lý dữ liệu (Repository) cho tính năng search_map.
// Kết cấu:
//  - Giao tiếp với ASP.NET Core Web API để truy vấn danh sách thợ và đánh giá.
// ============================================================================

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../../../models/barber_profile_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_provider.dart';

/// Provider cung cấp BarberRepository cho tính năng tìm kiếm và bản đồ (Task 3.2)
final barberRepositoryProvider = Provider<BarberRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BarberRepository(apiClient: apiClient);
});

/// FutureProvider lấy danh sách toàn bộ thợ đã được duyệt (approved)
final approvedBarbersProvider = FutureProvider<List<BarberProfileModel>>((
  ref,
) async {
  final repo = ref.watch(barberRepositoryProvider);
  return await repo.getApprovedBarbers();
});

/// StreamProvider theo dõi danh sách thợ approved
final approvedBarbersStreamProvider = StreamProvider<List<BarberProfileModel>>((
  ref,
) {
  final repo = ref.watch(barberRepositoryProvider);
  return repo.streamApprovedBarbers();
});

/// Provider lọc danh sách thợ ruột yêu thích của khách hàng hiện tại (Task Phase 3 - C3)
final favoriteBarbersProvider = Provider<List<BarberProfileModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  final favIds = user?.favoriteBarberIds ?? [];
  if (favIds.isEmpty) return const [];
  final barbers = ref.watch(approvedBarbersStreamProvider).valueOrNull ?? [];
  return barbers.where((b) => favIds.contains(b.uid)).toList();
});

/// FutureProvider.family lấy chi tiết một thợ cắt tóc theo UID
final barberDetailProvider = FutureProvider.family<BarberProfileModel?, String>(
  (ref, barberId) async {
    final repo = ref.watch(barberRepositoryProvider);
    return await repo.getBarberById(barberId);
  },
);

/// StreamProvider lấy danh sách đánh giá của thợ theo barberId
final barberReviewsStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, barberId) {
      final repo = ref.watch(barberRepositoryProvider);
      return repo.streamReviewsForBarber(barberId);
    });

/// Repository quản lý truy vấn thông tin thợ đã duyệt qua ASP.NET Core Web API
class BarberRepository {
  final ApiClient _apiClient;

  BarberRepository({FirebaseFirestore? firestore, ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Truy vấn tất cả các thợ có trạng thái approvalStatus == "approved"
  Future<List<BarberProfileModel>> getApprovedBarbers() async {
    try {
      final response = await _apiClient.get('/api/barbers/approved');
      if (response is List) {
        return response
            .map(
              (item) => BarberProfileModel.fromMap(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('⚠️ [BarberRepository] Lỗi tải danh sách thợ approved: $e');
      rethrow;
    }
  }

  /// Lắng nghe stream các thợ có trạng thái approved
  Stream<List<BarberProfileModel>> streamApprovedBarbers() async* {
    yield await getApprovedBarbers();
    yield* Stream.periodic(const Duration(seconds: 15)).asyncMap((_) async {
      return await getApprovedBarbers();
    });
  }

  /// Lấy thông tin chi tiết một thợ cắt tóc theo UID
  Future<BarberProfileModel?> getBarberById(String uid) async {
    try {
      final response = await _apiClient.get('/api/barbers/$uid');
      if (response is Map) {
        return BarberProfileModel.fromMap(
          Map<String, dynamic>.from(response),
          id: uid,
        );
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ [BarberRepository] Lỗi tải thông tin thợ ($uid): $e');
      return null;
    }
  }

  /// Lấy danh sách thợ nổi bật (sắp xếp theo ratingAvg giảm dần)
  Future<List<BarberProfileModel>> getFeaturedBarbers({int limit = 5}) async {
    try {
      final response = await _apiClient.get(
        '/api/barbers/featured',
        queryParameters: {'limit': limit},
      );
      if (response is List) {
        return response
            .map(
              (item) => BarberProfileModel.fromMap(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('⚠️ [BarberRepository] Lỗi tải thợ nổi bật: $e');
      final all = await getApprovedBarbers();
      all.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
      return all.take(limit).toList();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchReviewsForBarber(
    String barberId,
  ) async {
    try {
      final response = await _apiClient.get('/api/barbers/$barberId/reviews');
      if (response is List) {
        return response
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } catch (e) {
      debugPrint('⚠️ [BarberRepository] Lỗi tải đánh giá thợ ($barberId): $e');
    }
    return [];
  }

  /// Lắng nghe stream danh sách đánh giá của thợ
  Stream<List<Map<String, dynamic>>> streamReviewsForBarber(
    String barberId,
  ) async* {
    yield await _fetchReviewsForBarber(barberId);
    yield* Stream.periodic(const Duration(seconds: 15)).asyncMap((_) async {
      return await _fetchReviewsForBarber(barberId);
    });
  }
}

// CreBy: MenBoyBMN
