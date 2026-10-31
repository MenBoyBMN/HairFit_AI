// ============================================================================
// File: lib/providers/admin_provider.dart
// Mục đích: Quản lý trạng thái (State Management) cho các thao tác quản trị Admin.
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/admin/data/admin_repository.dart';
import '../features/barber_profile/data/barber_profile_repository.dart';
import '../models/appointment_model.dart';
import '../models/barber_profile_model.dart';
import '../models/hairstyle_model.dart';
import '../models/user_model.dart';
import 'admin_stats_provider.dart';

/// Provider danh sách thợ chờ duyệt
final pendingBarbersProvider =
    FutureProvider.autoDispose<List<BarberProfileModel>>((ref) async {
      final repo = ref.watch(barberProfileRepositoryProvider);
      return repo.getPendingBarbers();
    });

/// Provider danh sách tất cả thợ (có lọc trạng thái: all, approved, pending, rejected, suspended)
final allBarbersProvider = FutureProvider.autoDispose
    .family<List<BarberProfileModel>, String>((ref, statusFilter) async {
      final repo = ref.watch(adminRepositoryProvider);
      return repo.getAllBarbers(statusFilter: statusFilter);
    });

/// Provider danh sách tất cả người dùng (có lọc vai trò: all, customer, barber, admin)
final allUsersProvider = FutureProvider.autoDispose
    .family<List<UserModel>, String>((ref, roleFilter) async {
      final repo = ref.watch(adminRepositoryProvider);
      return repo.getAllUsers(roleFilter: roleFilter);
    });

/// Provider danh sách lịch hẹn toàn hệ thống (có lọc trạng thái: all, pending, confirmed, completed, cancelled, rejected)
final allAppointmentsProvider = FutureProvider.autoDispose
    .family<List<AppointmentModel>, String>((ref, statusFilter) async {
      final repo = ref.watch(adminRepositoryProvider);
      return repo.getAppointments(status: statusFilter, limit: 100);
    });

/// Provider danh sách lịch hẹn kết hợp lọc theo ngày và trạng thái
final filteredAppointmentsProvider = FutureProvider.autoDispose
    .family<List<AppointmentModel>, AdminAppointmentFilter>((
      ref,
      filter,
    ) async {
      final repo = ref.watch(adminRepositoryProvider);
      return repo.getAppointments(
        date: filter.date,
        status: filter.status,
        limit: 150,
      );
    });

/// Provider lịch sử đặt lịch của một người dùng cụ thể (Khách hoặc Thợ)
final userAppointmentsHistoryProvider = FutureProvider.autoDispose
    .family<List<AppointmentModel>, ({String uid, bool isBarber})>((
      ref,
      params,
    ) async {
      final repo = ref.watch(adminRepositoryProvider);
      return repo.getUserAppointments(params.uid, isBarber: params.isBarber);
    });

/// Provider danh sách tất cả kiểu tóc trong catalog
final allHairstylesProvider = FutureProvider.autoDispose<List<HairstyleModel>>((
  ref,
) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getHairstyles();
});

/// Provider danh sách đánh giá toàn hệ thống (hỗ trợ lọc theo số sao)
final allReviewsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, int?>((ref, ratingFilter) async {
      final repo = ref.watch(adminRepositoryProvider);
      return repo.getReviews(ratingFilter: ratingFilter);
    });

/// Provider cấu hình hệ thống toàn cục (systemSettings/global)
final systemSettingsProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) async {
    final repo = ref.watch(adminRepositoryProvider);
    return repo.getSystemSettings();
  },
);

/// Controller xử lý các tác vụ can thiệp quản trị
class AdminController extends StateNotifier<AsyncValue<void>> {
  final AdminRepository _adminRepo;
  final BarberProfileRepository _barberRepo;
  final Ref _ref;

  AdminController(this._adminRepo, this._barberRepo, this._ref)
    : super(const AsyncValue.data(null));

  void _invalidateAll() {
    _ref.invalidate(pendingBarbersProvider);
    _ref.invalidate(allBarbersProvider);
    _ref.invalidate(allUsersProvider);
    _ref.invalidate(allAppointmentsProvider);
    _ref.invalidate(filteredAppointmentsProvider);
    _ref.invalidate(userAppointmentsHistoryProvider);
    _ref.invalidate(allHairstylesProvider);
    _ref.invalidate(allReviewsProvider);
    _ref.invalidate(systemSettingsProvider);
    _ref.invalidate(adminDashboardStatsProvider);
    _ref.invalidate(adminRecentPendingBarbersProvider);
    _ref.invalidate(adminAppointmentsTodayProvider);
  }

  /// Duyệt hồ sơ thợ
  Future<void> approveBarber(String uid) async {
    state = const AsyncValue.loading();
    try {
      await _barberRepo.updateApprovalStatus(uid, 'approved');
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Từ chối hồ sơ thợ
  Future<void> rejectBarber(String uid) async {
    state = const AsyncValue.loading();
    try {
      await _barberRepo.updateApprovalStatus(uid, 'rejected');
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Tạm ngưng hoạt động thợ (suspended)
  Future<void> suspendBarber(String uid) async {
    state = const AsyncValue.loading();
    try {
      await _adminRepo.updateBarberStatus(uid, 'suspended');
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Mở lại hoạt động cho thợ
  Future<void> reactivateBarber(String uid) async {
    state = const AsyncValue.loading();
    try {
      await _adminRepo.updateBarberStatus(uid, 'approved');
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Cập nhật trạng thái bất kỳ cho thợ (approved, pending, suspended, rejected)
  Future<void> setBarberStatus(String uid, String status) async {
    state = const AsyncValue.loading();
    try {
      await _adminRepo.updateBarberStatus(uid, status);
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Admin chỉnh sửa thông tin tiệm tóc toàn diện
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
    state = const AsyncValue.loading();
    try {
      await _adminRepo.updateBarberProfileAdmin(
        uid,
        displayName: displayName,
        address: address,
        phone: phone,
        bio: bio,
        latitude: latitude,
        longitude: longitude,
        isAcceptingBookingsToday: isAcceptingBookingsToday,
      );
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Xóa hồ sơ tiệm tóc
  Future<void> deleteBarberProfile(String uid) async {
    state = const AsyncValue.loading();
    try {
      await _adminRepo.deleteBarberProfile(uid);
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Khóa hoặc mở khóa tài khoản người dùng
  Future<void> setUserBlockStatus(String uid, bool isBlocked) async {
    state = const AsyncValue.loading();
    try {
      await _adminRepo.setUserBlockStatus(uid, isBlocked);
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Đổi vai trò tài khoản (Role)
  Future<void> updateUserRole(String uid, String newRole) async {
    state = const AsyncValue.loading();
    try {
      await _adminRepo.updateUserRole(uid, newRole);
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Cập nhật tên hiển thị & số điện thoại người dùng
  Future<void> updateUserInfo(
    String uid, {
    required String displayName,
    String? phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _adminRepo.updateUserInfo(
        uid,
        displayName: displayName,
        phone: phone,
      );
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Cập nhật tọa độ bản đồ cho tiệm tóc
  Future<void> updateBarberLocation(
    String uid,
    double latitude,
    double longitude,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _adminRepo.updateBarberLocation(uid, latitude, longitude);
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Hủy lịch hẹn khẩn cấp & giải phóng slot kẹt
  Future<void> emergencyCancelAppointment(
    String appointmentId, {
    String? reason,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _adminRepo.emergencyCancelAppointment(
        appointmentId,
        reason: reason,
      );
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Cập nhật trạng thái lịch hẹn từ Admin (confirmed, completed, cancelled, rejected)
  Future<void> updateAppointmentStatus(
    String appointmentId,
    String newStatus, {
    String? reason,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _adminRepo.updateAppointmentStatusAdmin(
        appointmentId,
        newStatus,
        reason: reason,
      );
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Thêm hoặc cập nhật kiểu tóc vào catalog
  Future<void> saveHairstyle(HairstyleModel hairstyle) async {
    state = const AsyncValue.loading();
    try {
      await _adminRepo.saveHairstyle(hairstyle);
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Xóa kiểu tóc khỏi catalog
  Future<void> deleteHairstyle(String id) async {
    state = const AsyncValue.loading();
    try {
      await _adminRepo.deleteHairstyle(id);
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Xóa đánh giá độc hại (gỡ cả trên appointment và tính lại điểm thợ)
  Future<void> deleteReview(
    String reviewId,
    String barberId,
    int rating, {
    String? appointmentId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _adminRepo.deleteReview(
        reviewId,
        barberId,
        rating,
        appointmentId: appointmentId,
      );
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Lưu cấu hình vận hành hệ thống
  Future<void> saveSystemSettings({
    required double searchRadiusKm,
    required int cancelNoticeHours,
    required bool maintenanceMode,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _adminRepo.saveSystemSettings(
        searchRadiusKm: searchRadiusKm,
        cancelNoticeHours: cancelNoticeHours,
        maintenanceMode: maintenanceMode,
      );
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final adminControllerProvider =
    StateNotifierProvider<AdminController, AsyncValue<void>>((ref) {
      return AdminController(
        ref.watch(adminRepositoryProvider),
        ref.watch(barberProfileRepositoryProvider),
        ref,
      );
    });

// CreBy: MenBoyBMN
