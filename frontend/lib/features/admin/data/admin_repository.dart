// ============================================================================
// File: lib/features/admin/data/admin_repository.dart
// Mục đích: Repository cho các tác vụ quản trị hệ thống (Admin Portal 360°).
// Kết cấu:
//  - Tương tác với Firestore để tổng hợp số liệu thống kê (Dashboard Stats),
//    quản lý người dùng (Khách & Thợ), hồ sơ tiệm, lịch hẹn, kiểu tóc AI,
//    đánh giá và cấu hình vận hành hệ thống.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
  return AdminRepository(ref.watch(firestoreProvider));
});

class AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepository(this._firestore);

  /// Lấy số liệu thống kê tổng quan cho Dashboard
  Future<AdminDashboardStats> getDashboardStats() async {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 1. Lấy dữ liệu Users
    final usersSnapshot = await _firestore.collection('users').get();
    int customers = 0;
    int barbers = 0;
    int admins = 0;
    int blocked = 0;

    for (final doc in usersSnapshot.docs) {
      final data = doc.data();
      final role = (data['role'] as String? ?? '').toLowerCase();
      final isBlocked = data['isBlocked'] as bool? ?? false;
      if (isBlocked) blocked++;

      if (role == 'barber') {
        barbers++;
      } else if (role == 'admin') {
        admins++;
      } else {
        customers++;
      }
    }

    // 2. Lấy dữ liệu Thợ (Barber Profiles)
    final barberProfilesSnapshot = await _firestore
        .collection('barberProfiles')
        .get();
    int pendingBarbers = 0;
    int approvedBarbers = 0;
    int suspendedBarbers = 0;
    int rejectedBarbers = 0;

    for (final doc in barberProfilesSnapshot.docs) {
      final status = (doc.data()['approvalStatus'] as String? ?? 'pending')
          .toLowerCase();
      if (status == 'pending') {
        pendingBarbers++;
      } else if (status == 'approved') {
        approvedBarbers++;
      } else if (status == 'suspended') {
        suspendedBarbers++;
      } else if (status == 'rejected') {
        rejectedBarbers++;
      }
    }

    // 3. Lấy dữ liệu Lịch hẹn (Appointments)
    final allAppointmentsSnapshot = await _firestore
        .collection('appointments')
        .get();

    int totalAppToday = 0;
    int pendingAppToday = 0;
    int confirmedAppToday = 0;
    int completedAppToday = 0;
    int cancelledAppToday = 0;
    int revenueToday = 0;
    int expectedRevenueToday = 0;
    int totalRevenue = 0;

    for (final doc in allAppointmentsSnapshot.docs) {
      final data = doc.data();
      final status = (data['status'] as String? ?? 'pending').toLowerCase();
      final date = data['date'] as String? ?? '';
      final price = (data['price'] as num?)?.toInt() ?? 0;

      if (status == 'completed') {
        totalRevenue += price;
      }

      if (date == todayStr) {
        totalAppToday++;
        if (status == 'pending') {
          pendingAppToday++;
        } else if (status == 'confirmed') {
          confirmedAppToday++;
          expectedRevenueToday += price;
        } else if (status == 'completed') {
          completedAppToday++;
          revenueToday += price;
          expectedRevenueToday += price;
        } else if (status == 'cancelled' || status == 'rejected') {
          cancelledAppToday++;
        }
      }
    }

    // 4. Lấy số lượng Kiểu tóc trong catalog
    final hairstylesCount =
        (await _firestore.collection('hairstyleCatalog').count().get()).count ??
        0;

    // 5. Lấy số lượng đánh giá
    final reviewsCount =
        (await _firestore.collection('reviews').count().get()).count ?? 0;

    return AdminDashboardStats(
      totalUsers: usersSnapshot.size,
      totalCustomers: customers,
      totalBarbers: barbers,
      totalAdmins: admins,
      blockedUsers: blocked,
      pendingBarbers: pendingBarbers,
      approvedBarbers: approvedBarbers,
      suspendedBarbers: suspendedBarbers,
      rejectedBarbers: rejectedBarbers,
      totalAppointmentsToday: totalAppToday,
      pendingAppointmentsToday: pendingAppToday,
      confirmedAppointmentsToday: confirmedAppToday,
      completedAppointmentsToday: completedAppToday,
      cancelledAppointmentsToday: cancelledAppToday,
      revenueToday: revenueToday,
      expectedRevenueToday: expectedRevenueToday,
      totalRevenue: totalRevenue,
      totalAppointments: allAppointmentsSnapshot.size,
      totalHairstyles: hairstylesCount,
      totalReviews: reviewsCount,
    );
  }

  /// Lấy danh sách thợ chờ duyệt gần nhất (giới hạn [limit])
  Future<List<BarberProfileModel>> getRecentPendingBarbers({
    int limit = 5,
  }) async {
    final query = await _firestore
        .collection('barberProfiles')
        .where('approvalStatus', isEqualTo: 'pending')
        .limit(limit)
        .get();

    return query.docs
        .map((doc) => BarberProfileModel.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  /// Lấy danh sách tất cả thợ với bộ lọc trạng thái tùy chọn
  Future<List<BarberProfileModel>> getAllBarbers({String? statusFilter}) async {
    Query<Map<String, dynamic>> query = _firestore.collection('barberProfiles');

    if (statusFilter != null &&
        statusFilter.isNotEmpty &&
        statusFilter != 'all') {
      query = query.where('approvalStatus', isEqualTo: statusFilter);
    }

    final snapshot = await query.get();
    final list = snapshot.docs
        .map((doc) => BarberProfileModel.fromMap(doc.data(), id: doc.id))
        .toList();

    list.sort((a, b) => a.displayName.compareTo(b.displayName));
    return list;
  }

  /// Lấy danh sách người dùng với bộ lọc vai trò tùy chọn
  Future<List<UserModel>> getAllUsers({String? roleFilter}) async {
    Query<Map<String, dynamic>> query = _firestore.collection('users');

    if (roleFilter != null && roleFilter.isNotEmpty && roleFilter != 'all') {
      query = query.where('role', isEqualTo: roleFilter);
    }

    final snapshot = await query.get();
    final list = snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();

    list.sort((a, b) {
      final tA = a.createdAt;
      final tB = b.createdAt;
      if (tA != null && tB != null) return tB.compareTo(tA);
      return a.displayName.compareTo(b.displayName);
    });
    return list;
  }

  /// Khóa hoặc mở khóa tài khoản người dùng (đồng bộ sang barberProfiles nếu là thợ)
  Future<void> setUserBlockStatus(String uid, bool isBlocked) async {
    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(uid);

    batch.update(userRef, {
      'isBlocked': isBlocked,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Nếu tài khoản bị khóa và có hồ sơ thợ, tự động tạm ngưng tiệm để khách không đặt nhầm
    final barberRef = _firestore.collection('barberProfiles').doc(uid);
    final barberDoc = await barberRef.get();
    if (barberDoc.exists) {
      if (isBlocked) {
        batch.update(barberRef, {
          'approvalStatus': 'suspended',
          'isAcceptingBookingsToday': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();
  }

  /// Cập nhật vai trò (Role) người dùng & khởi tạo hồ sơ thợ nếu chuyển sang barber
  Future<void> updateUserRole(String uid, String newRole) async {
    final userRef = _firestore.collection('users').doc(uid);
    await userRef.update({
      'role': newRole,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (newRole == 'barber') {
      final barberRef = _firestore.collection('barberProfiles').doc(uid);
      final barberDoc = await barberRef.get();
      if (!barberDoc.exists) {
        final userDoc = await userRef.get();
        final userData = userDoc.data() ?? {};
        final defaultProfile = BarberProfileModel(
          uid: uid,
          displayName: userData['displayName'] as String? ?? 'Tiệm Tóc Mới',
          avatarUrl: userData['avatarUrl'] as String? ?? '',
          phone: userData['phone'] as String?,
          address: 'Chưa cập nhật địa chỉ',
          location: const GeoLocation(latitude: 16.0544, longitude: 108.2022),
          approvalStatus: 'pending',
        );
        await barberRef.set(defaultProfile.toMap());
      }
    }
  }

  /// Cập nhật thông tin cơ bản của người dùng từ Admin
  Future<void> updateUserInfo(
    String uid, {
    required String displayName,
    String? phone,
  }) async {
    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(uid);
    final cleanPhone = phone?.trim();

    batch.update(userRef, {
      'displayName': displayName.trim(),
      'phone': (cleanPhone != null && cleanPhone.isNotEmpty)
          ? cleanPhone
          : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final barberRef = _firestore.collection('barberProfiles').doc(uid);
    final barberDoc = await barberRef.get();
    if (barberDoc.exists) {
      batch.update(barberRef, {
        if (cleanPhone != null && cleanPhone.isNotEmpty) 'phone': cleanPhone,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Lấy lịch sử đặt lịch của một người dùng (Khách hàng hoặc Thợ)
  Future<List<AppointmentModel>> getUserAppointments(
    String uid, {
    required bool isBarber,
    int limit = 50,
  }) async {
    final field = isBarber ? 'barberId' : 'customerId';
    final snapshot = await _firestore
        .collection('appointments')
        .where(field, isEqualTo: uid)
        .get();

    final list = snapshot.docs
        .map((doc) => AppointmentModel.fromFirestore(doc))
        .toList();

    list.sort((a, b) => b.startTimestamp.compareTo(a.startTimestamp));
    return list.take(limit).toList();
  }

  /// Cập nhật tọa độ bản đồ của tiệm tóc
  Future<void> updateBarberLocation(
    String uid,
    double latitude,
    double longitude,
  ) async {
    await _firestore.collection('barberProfiles').doc(uid).update({
      'location': {'latitude': latitude, 'longitude': longitude},
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
    final cleanPhone = phone?.trim();
    await _firestore.collection('barberProfiles').doc(uid).update({
      'displayName': displayName.trim(),
      'address': address.trim(),
      'phone': (cleanPhone != null && cleanPhone.isNotEmpty)
          ? cleanPhone
          : null,
      'bio': bio.trim(),
      'location': {'latitude': latitude, 'longitude': longitude},
      'isAcceptingBookingsToday': isAcceptingBookingsToday,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cập nhật trạng thái duyệt của thợ
  Future<void> updateBarberStatus(String uid, String status) async {
    await _firestore.collection('barberProfiles').doc(uid).update({
      'approvalStatus': status,
      if (status == 'suspended' || status == 'rejected')
        'isAcceptingBookingsToday': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Xóa hồ sơ thợ cắt tóc
  Future<void> deleteBarberProfile(String uid) async {
    await _firestore.collection('barberProfiles').doc(uid).delete();
  }

  /// Lấy danh sách lịch hẹn theo ngày và trạng thái (sắp xếp an toàn không cần Composite Index)
  Future<List<AppointmentModel>> getAppointments({
    String? date,
    String? status,
    int limit = 100,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection('appointments');

    if (date != null && date.isNotEmpty) {
      query = query.where('date', isEqualTo: date);
    }
    if (status != null && status.isNotEmpty && status != 'all') {
      query = query.where('status', isEqualTo: status);
    }

    final snapshot = await query.get();
    final list = snapshot.docs
        .map((doc) => AppointmentModel.fromFirestore(doc))
        .toList();

    list.sort((a, b) => b.startTimestamp.compareTo(a.startTimestamp));
    return list.take(limit).toList();
  }

  /// Hủy lịch hẹn khẩn cấp từ phía Admin và giải phóng slot bằng Firestore Transaction
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
    await _firestore.runTransaction((transaction) async {
      final appointmentRef = _firestore
          .collection('appointments')
          .doc(appointmentId);
      final doc = await transaction.get(appointmentRef);
      if (!doc.exists) return;

      final appointment = AppointmentModel.fromFirestore(doc);
      final cleanReason = reason?.trim() ?? '';
      String updatedNote = appointment.note;
      if (cleanReason.isNotEmpty && !updatedNote.contains(cleanReason)) {
        updatedNote = updatedNote.isEmpty
            ? '[$cleanReason]'
            : '$updatedNote [$cleanReason]';
      }

      transaction.update(appointmentRef, {
        'status': newStatus,
        'note': updatedNote,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Giải phóng các bookedSlots nếu chuyển sang trạng thái hủy hoặc từ chối
      if (newStatus == 'cancelled' || newStatus == 'rejected') {
        for (final slotId in appointment.slotIds) {
          final slotRef = _firestore.collection('bookedSlots').doc(slotId);
          transaction.delete(slotRef);
        }
      }
    });
  }

  /// Lấy danh sách tất cả kiểu tóc trong catalog
  Future<List<HairstyleModel>> getHairstyles() async {
    final snapshot = await _firestore.collection('hairstyleCatalog').get();
    return snapshot.docs
        .map((doc) => HairstyleModel.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  /// Thêm mới hoặc cập nhật kiểu tóc vào catalog
  Future<void> saveHairstyle(HairstyleModel hairstyle) async {
    final docRef = _firestore.collection('hairstyleCatalog').doc(hairstyle.id);
    await docRef.set(hairstyle.toMap(), SetOptions(merge: true));
  }

  /// Xóa kiểu tóc khỏi catalog
  Future<void> deleteHairstyle(String id) async {
    await _firestore.collection('hairstyleCatalog').doc(id).delete();
  }

  /// Lấy danh sách đánh giá toàn hệ thống (hỗ trợ lọc theo số sao không lỗi Composite Index)
  Future<List<Map<String, dynamic>>> getReviews({
    int? ratingFilter,
    int limit = 100,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection('reviews');

    if (ratingFilter != null) {
      query = query.where('rating', isEqualTo: ratingFilter);
    }

    final snapshot = await query.get();
    final reviews = snapshot.docs
        .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
        .toList();

    // Sắp xếp theo thời gian tạo mới nhất lên đầu trong bộ nhớ (tránh lỗi Composite Index)
    reviews.sort((a, b) {
      final tA = a['createdAt'];
      final tB = b['createdAt'];
      if (tA is Timestamp && tB is Timestamp) {
        return tB.compareTo(tA);
      }
      return 0;
    });

    return reviews.take(limit).toList();
  }

  /// Xóa đánh giá độc hại, gỡ đánh giá khỏi lịch hẹn và tính lại rating của thợ
  Future<void> deleteReview(
    String reviewId,
    String barberId,
    int rating, {
    String? appointmentId,
  }) async {
    final reviewRef = _firestore.collection('reviews').doc(reviewId);
    String? resolvedAppointmentId = appointmentId;

    if (resolvedAppointmentId == null || resolvedAppointmentId.isEmpty) {
      try {
        final reviewDoc = await reviewRef.get();
        if (reviewDoc.exists) {
          resolvedAppointmentId = reviewDoc.data()?['appointmentId'] as String?;
        }
      } catch (_) {}
    }

    final batch = _firestore.batch();
    batch.delete(reviewRef);

    // Gỡ rating và reviewComment trên document appointment tương ứng (nếu có)
    if (resolvedAppointmentId != null && resolvedAppointmentId.isNotEmpty) {
      final appRef = _firestore
          .collection('appointments')
          .doc(resolvedAppointmentId);
      final appDoc = await appRef.get();
      if (appDoc.exists) {
        batch.update(appRef, {
          'rating': FieldValue.delete(),
          'reviewComment': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    // Tính lại ratingAvg và ratingCount của thợ
    if (barberId.isNotEmpty) {
      final barberRef = _firestore.collection('barberProfiles').doc(barberId);
      final barberDoc = await barberRef.get();
      if (barberDoc.exists) {
        final data = barberDoc.data() ?? {};
        final currentAvg = (data['ratingAvg'] as num?)?.toDouble() ?? 5.0;
        final currentCount = (data['ratingCount'] as num?)?.toInt() ?? 1;

        if (currentCount > 1) {
          final newCount = currentCount - 1;
          final newTotalScore = (currentAvg * currentCount) - rating;
          final newAvg = newTotalScore / newCount;
          batch.update(barberRef, {
            'ratingAvg': double.parse(
              newAvg.clamp(1.0, 5.0).toStringAsFixed(1),
            ),
            'ratingCount': newCount,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          batch.update(barberRef, {
            'ratingAvg': 5.0,
            'ratingCount': 0,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }

    await batch.commit();
  }

  /// Đọc cấu hình vận hành hệ thống từ Firestore (systemSettings/global)
  Future<Map<String, dynamic>> getSystemSettings() async {
    try {
      final doc = await _firestore
          .collection('systemSettings')
          .doc('global')
          .get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!;
      }
    } catch (_) {}
    return {
      'searchRadiusKm': 10.0,
      'cancelNoticeHours': 1,
      'maintenanceMode': false,
    };
  }

  /// Lưu cấu hình vận hành hệ thống lên Firestore (systemSettings/global)
  Future<void> saveSystemSettings({
    required double searchRadiusKm,
    required int cancelNoticeHours,
    required bool maintenanceMode,
  }) async {
    await _firestore.collection('systemSettings').doc('global').set({
      'searchRadiusKm': searchRadiusKm,
      'cancelNoticeHours': cancelNoticeHours,
      'maintenanceMode': maintenanceMode,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

// CreBy: MenBoyBMN
