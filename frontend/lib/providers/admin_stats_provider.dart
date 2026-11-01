// ============================================================================
// File: lib/providers/admin_stats_provider.dart
// Mục đích: Quản lý trạng thái thống kê & số liệu tổng quan cho Admin.
// Kết cấu:
//  - Sử dụng Riverpod cung cấp dữ liệu bất đồng bộ từ AdminRepository.
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../features/admin/data/admin_repository.dart';
import '../models/appointment_model.dart';
import '../models/barber_profile_model.dart';

/// Provider cung cấp số liệu tổng quan cho Admin Dashboard
final adminDashboardStatsProvider =
    FutureProvider.autoDispose<AdminDashboardStats>((ref) async {
      final repo = ref.watch(adminRepositoryProvider);
      return repo.getDashboardStats();
    });

/// Provider cung cấp danh sách thợ chờ duyệt gần nhất (tối đa 5 hồ sơ)
final adminRecentPendingBarbersProvider =
    FutureProvider.autoDispose<List<BarberProfileModel>>((ref) async {
      final repo = ref.watch(adminRepositoryProvider);
      return repo.getRecentPendingBarbers(limit: 5);
    });

/// Provider cung cấp danh sách lịch hẹn hôm nay
final adminAppointmentsTodayProvider =
    FutureProvider.autoDispose<List<AppointmentModel>>((ref) async {
      final repo = ref.watch(adminRepositoryProvider);
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      return repo.getAppointments(date: todayStr, limit: 10);
    });

// CreBy: MenBoyBMN
