// ============================================================================
// File: lib/features/admin/data/admin_repository.dart
// Mục đích: Repository cho các tác vụ quản trị hệ thống (Admin Portal 360°).
// Kết cấu:
//  - Giao tiếp với ASP.NET Core Web API để tổng hợp số liệu thống kê (Dashboard Stats),
//    quản lý người dùng (Khách & Thợ), hồ sơ tiệm, lịch hẹn, kiểu tóc AI,
//    đánh giá và cấu hình vận hành hệ thống.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../../../models/appointment_model.dart';
import '../../../models/barber_profile_model.dart';
import '../../../models/hairstyle_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/app_providers.dart';

/// Lớp chứa số liệu thống kê tổng hợp cho Admin Dashboard
class AdminDashboardStats {
  final int totalUsers;
  final int totalCustomers;
  final int totalBarbers;
  final int totalAdmins;
  final int blockedUsers;
  final int pendingBarbers;
  final int approvedBarbers;
  final int suspendedBarbers;
  final int rejectedBarbers;
  final int totalAppointmentsToday;
  final int pendingAppointmentsToday;
  final int confirmedAppointmentsToday;
  final int completedAppointmentsToday;
  final int cancelledAppointmentsToday;
  final int revenueToday;
  final int expectedRevenueToday;
  final int totalRevenue;
  final int totalAppointments;
  final int totalHairstyles;
  final int totalReviews;

  const AdminDashboardStats({
    this.totalUsers = 0,
    this.totalCustomers = 0,
    this.totalBarbers = 0,
    this.totalAdmins = 0,
    this.blockedUsers = 0,
    this.pendingBarbers = 0,
    this.approvedBarbers = 0,
    this.suspendedBarbers = 0,
    this.rejectedBarbers = 0,
    this.totalAppointmentsToday = 0,
    this.pendingAppointmentsToday = 0,
    this.confirmedAppointmentsToday = 0,
    this.completedAppointmentsToday = 0,
    this.cancelledAppointmentsToday = 0,
    this.revenueToday = 0,
    this.expectedRevenueToday = 0,
    this.totalRevenue = 0,
    this.totalAppointments = 0,
    this.totalHairstyles = 0,
    this.totalReviews = 0,
  });

  double get completionRate {
    final finished = completedAppointmentsToday;
    final totalRelevant =
        completedAppointmentsToday + cancelledAppointmentsToday;
    if (totalRelevant == 0) return 0.0;
    return (finished / totalRelevant) * 100;
  }

  factory AdminDashboardStats.fromMap(Map<String, dynamic> map) {
    return AdminDashboardStats(
      totalUsers: (map['totalUsers'] as num?)?.toInt() ?? 0,
      totalCustomers: (map['totalCustomers'] as num?)?.toInt() ?? 0,
      totalBarbers: (map['totalBarbers'] as num?)?.toInt() ?? 0,
      totalAdmins: (map['totalAdmins'] as num?)?.toInt() ?? 0,
      blockedUsers: (map['blockedUsers'] as num?)?.toInt() ?? 0,
      pendingBarbers: (map['pendingBarbers'] as num?)?.toInt() ?? 0,
      approvedBarbers: (map['approvedBarbers'] as num?)?.toInt() ?? 0,
      suspendedBarbers: (map['suspendedBarbers'] as num?)?.toInt() ?? 0,
      rejectedBarbers: (map['rejectedBarbers'] as num?)?.toInt() ?? 0,
      totalAppointmentsToday:
          (map['totalAppointmentsToday'] as num?)?.toInt() ?? 0,
      pendingAppointmentsToday:
          (map['pendingAppointmentsToday'] as num?)?.toInt() ?? 0,
      confirmedAppointmentsToday:
          (map['confirmedAppointmentsToday'] as num?)?.toInt() ?? 0,
      completedAppointmentsToday:
          (map['completedAppointmentsToday'] as num?)?.toInt() ?? 0,
      cancelledAppointmentsToday:
          (map['cancelledAppointmentsToday'] as num?)?.toInt() ?? 0,
      revenueToday: (map['revenueToday'] as num?)?.toInt() ?? 0,
      expectedRevenueToday: (map['expectedRevenueToday'] as num?)?.toInt() ?? 0,
      totalRevenue: (map['totalRevenue'] as num?)?.toInt() ?? 0,
      totalAppointments: (map['totalAppointments'] as num?)?.toInt() ?? 0,
      totalHairstyles: (map['totalHairstyles'] as num?)?.toInt() ?? 0,
      totalReviews: (map['totalReviews'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Bộ lọc truy vấn lịch hẹn cho Admin
class AdminAppointmentFilter {
  final String status;
  final String? date;

  const AdminAppointmentFilter({this.status = 'all', this.date});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminAppointmentFilter &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          date == other.date;

  @override
  int get hashCode => Object.hash(status, date);
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(null, ref.watch(apiClientProvider));
});

class AdminRepository {
  final ApiClient _apiClient;

  AdminRepository([FirebaseFirestore? firestore, ApiClient? apiClient])
    : _apiClient = apiClient ?? ApiClient();

  /// Lấy số liệu thống kê tổng quan cho Dashboard
  Future<AdminDashboardStats> getDashboardStats() async {
    final response = await _apiClient.get('/api/admin/stats');
    if (response is Map) {
      return AdminDashboardStats.fromMap(Map<String, dynamic>.from(response));
    }
    return const AdminDashboardStats();
  }

  /// Lấy danh sách thợ chờ duyệt gần nhất (giới hạn [limit])
  Future<List<BarberProfileModel>> getRecentPendingBarbers({
    int limit = 5,
  }) async {
    final response = await _apiClient.get(
      '/api/admin/barbers/recent-pending',
      queryParameters: {'limit': limit},
    );
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

  /// Lấy danh sách tất cả thợ với bộ lọc trạng thái tùy chọn
  Future<List<BarberProfileModel>> getAllBarbers({String? statusFilter}) async {
    final response = await _apiClient.get(
      '/api/admin/barbers',
      queryParameters: {
        if (statusFilter != null && statusFilter.isNotEmpty)
          'statusFilter': statusFilter,
      },
    );
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

  /// Lấy danh sách người dùng với bộ lọc vai trò tùy chọn
  Future<List<UserModel>> getAllUsers({String? roleFilter}) async {
    final response = await _apiClient.get(
      '/api/admin/users',
      queryParameters: {
        if (roleFilter != null && roleFilter.isNotEmpty)
          'roleFilter': roleFilter,
      },
    );
    if (response is List) {
      return response
          .map((e) => UserModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return [];
  }

  /// Khóa hoặc mở khóa tài khoản người dùng (đồng bộ sang barberProfiles nếu là thợ)
  Future<void> setUserBlockStatus(String uid, bool isBlocked) async {
    await _apiClient.patch(
      '/api/admin/users/$uid/block',
      body: {'isBlocked': isBlocked},
    );
  }

  /// Cập nhật vai trò (Role) người dùng & khởi tạo hồ sơ thợ nếu chuyển sang barber
  Future<void> updateUserRole(String uid, String newRole) async {
    await _apiClient.patch(
      '/api/admin/users/$uid/role',
      body: {'newRole': newRole},
    );
  }

  /// Cập nhật thông tin cơ bản của người dùng từ Admin
  Future<void> updateUserInfo(
    String uid, {
    required String displayName,
    String? phone,
  }) async {
    await _apiClient.put(
      '/api/admin/users/$uid',
      body: {'displayName': displayName.trim(), 'phone': phone?.trim()},
    );
  }

  /// Lấy lịch sử đặt lịch của một người dùng (Khách hàng hoặc Thợ)
  Future<List<AppointmentModel>> getUserAppointments(
    String uid, {
    required bool isBarber,
    int limit = 50,
  }) async {
    final response = await _apiClient.get(
      '/api/admin/users/$uid/appointments',
      queryParameters: {'isBarber': isBarber, 'limit': limit},
    );
    if (response is List) {
      return response
          .map(
            (e) =>
                AppointmentModel.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    }
    return [];
  }

  /// Cập nhật tọa độ bản đồ của tiệm tóc
  Future<void> updateBarberLocation(
    String uid,
    double latitude,
    double longitude,
  ) async {
    await _apiClient.patch(
      '/api/admin/barbers/$uid/location',
      body: {'latitude': latitude, 'longitude': longitude},
    );
  }

  /// Admin chỉnh sửa toàn diện thông tin tiệm cắt tóc
  Future<void> updateBarberProfileAdmin(
    String uid, {
    required String displayName,
    required String address,
    String? phone,
    required String bio,
    required double latitude,
    required double longitude,
    required bool isAcceptingBookingsToday,
  }) async {
    await _apiClient.put(
      '/api/admin/barbers/$uid',
      body: {
        'displayName': displayName.trim(),
        'address': address.trim(),
        'phone': phone?.trim(),
        'bio': bio.trim(),
        'latitude': latitude,
        'longitude': longitude,
        'isAcceptingBookingsToday': isAcceptingBookingsToday,
      },
    );
  }

  /// Cập nhật trạng thái duyệt của thợ
  Future<void> updateBarberStatus(String uid, String status) async {
    await _apiClient.patch(
      '/api/admin/barbers/$uid/status',
      body: {'status': status},
    );
  }

  /// Xóa hồ sơ thợ cắt tóc
  Future<void> deleteBarberProfile(String uid) async {
    await _apiClient.delete('/api/admin/barbers/$uid');
  }

  /// Lấy danh sách lịch hẹn theo ngày và trạng thái
  Future<List<AppointmentModel>> getAppointments({
    String? date,
    String? status,
    int limit = 100,
  }) async {
    final response = await _apiClient.get(
      '/api/admin/appointments',
      queryParameters: {
        if (date != null && date.isNotEmpty) 'date': date,
        if (status != null && status.isNotEmpty) 'status': status,
        'limit': limit,
      },
    );
    if (response is List) {
      return response
          .map(
            (e) =>
                AppointmentModel.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    }
    return [];
  }

  /// Hủy lịch hẹn khẩn cấp từ phía Admin và giải phóng slot
  Future<void> emergencyCancelAppointment(
    String appointmentId, {
    String? reason,
  }) async {
    await updateAppointmentStatusAdmin(
      appointmentId,
      'cancelled',
      reason: reason ?? 'Admin đã hủy khẩn cấp',
    );
  }

  /// Admin cập nhật trạng thái lịch hẹn (Xác nhận / Hoàn tất / Hủy) chuẩn ACID Transaction
  Future<void> updateAppointmentStatusAdmin(
    String appointmentId,
    String newStatus, {
    String? reason,
  }) async {
    await _apiClient.patch(
      '/api/admin/appointments/$appointmentId/status',
      body: {'newStatus': newStatus, 'reason': ?reason},
    );
  }

  /// Lấy danh sách tất cả kiểu tóc trong catalog
  Future<List<HairstyleModel>> getHairstyles() async {
    final response = await _apiClient.get('/api/admin/hairstyles');
    if (response is List) {
      return response
          .map(
            (e) => HairstyleModel.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    }
    return [];
  }

  /// Thêm mới hoặc cập nhật kiểu tóc vào catalog
  Future<void> saveHairstyle(HairstyleModel hairstyle) async {
    await _apiClient.post('/api/admin/hairstyles', body: hairstyle.toMap());
  }

  /// Xóa kiểu tóc khỏi catalog
  Future<void> deleteHairstyle(String id) async {
    await _apiClient.delete('/api/admin/hairstyles/$id');
  }

  /// Lấy danh sách đánh giá toàn hệ thống
  Future<List<Map<String, dynamic>>> getReviews({
    int? ratingFilter,
    int limit = 100,
  }) async {
    final response = await _apiClient.get(
      '/api/admin/reviews',
      queryParameters: {'ratingFilter': ?ratingFilter, 'limit': limit},
    );
    if (response is List) {
      return response.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  /// Xóa đánh giá độc hại, gỡ đánh giá khỏi lịch hẹn và tính lại rating của thợ
  Future<void> deleteReview(
    String reviewId,
    String barberId,
    int rating, {
    String? appointmentId,
  }) async {
    await _apiClient.delete(
      '/api/admin/reviews/$reviewId',
      queryParameters: {
        'barberId': barberId,
        'rating': rating,
        'appointmentId': ?appointmentId,
      },
    );
  }

  /// Đọc cấu hình vận hành hệ thống từ ASP.NET Core Web API
  Future<Map<String, dynamic>> getSystemSettings() async {
    try {
      final response = await _apiClient.get('/api/admin/settings');
      if (response is Map) {
        return Map<String, dynamic>.from(response);
      }
    } catch (_) {}
    return {
      'searchRadiusKm': 10.0,
      'cancelNoticeHours': 1,
      'maintenanceMode': false,
    };
  }

  /// Lưu cấu hình vận hành hệ thống lên ASP.NET Core Web API
  Future<void> saveSystemSettings({
    required double searchRadiusKm,
    required int cancelNoticeHours,
    required bool maintenanceMode,
  }) async {
    await _apiClient.put(
      '/api/admin/settings',
      body: {
        'searchRadiusKm': searchRadiusKm,
        'cancelNoticeHours': cancelNoticeHours,
        'maintenanceMode': maintenanceMode,
      },
    );
  }
}

// CreBy: MenBoyBMN
