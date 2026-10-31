// ============================================================================
// File: lib/features/ai_consult/data/hairstyle_repository.dart
// Mục đích: Quản lý dữ liệu (Repository) cho tính năng ai_consult.
// Kết cấu:
//  - Giao tiếp với ASP.NET Core Web API để tải danh mục kiểu tóc.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/api_client.dart';
import '../../../../models/hairstyle_model.dart';
import '../../../../providers/app_providers.dart';

final hairstyleRepositoryProvider = Provider<HairstyleRepository>((ref) {
  return HairstyleRepository(null, ref.watch(apiClientProvider));
});

final hairstylesProvider = FutureProvider<List<HairstyleModel>>((ref) {
  return ref.watch(hairstyleRepositoryProvider).getAllHairstyles();
});

class HairstyleRepository {
  final ApiClient _apiClient;

  HairstyleRepository([FirebaseFirestore? firestore, ApiClient? apiClient])
    : _apiClient = apiClient ?? ApiClient();

  Future<List<HairstyleModel>> getAllHairstyles() async {
    final response = await _apiClient.get('/api/hairstyles');
    if (response is List) {
      return response
          .map(
            (e) => HairstyleModel.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    }
    return [];
  }
}

// CreBy: MenBoyBMN
