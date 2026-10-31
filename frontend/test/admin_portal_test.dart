// ============================================================================
// File: test/admin_portal_test.dart
// Mục đích: Kiểm thử toàn diện cổng quản trị Admin 360° (AdminDashboardStats,
//           AdminAppointmentFilter, BarberProfileModel.isSuspended,
//           AdminDashboardScreen, AdminShellScreen, AdminUsersScreen,
//           AdminBarbersScreen, AdminAppointmentsScreen).
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairfit_ai/features/admin/data/admin_repository.dart';
import 'package:hairfit_ai/features/admin/presentation/admin_appointments_screen.dart';
import 'package:hairfit_ai/features/admin/presentation/admin_barbers_screen.dart';
import 'package:hairfit_ai/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:hairfit_ai/features/admin/presentation/admin_shell_screen.dart';
import 'package:hairfit_ai/features/admin/presentation/admin_users_screen.dart';
import 'package:hairfit_ai/features/barber_profile/data/barber_profile_repository.dart';
import 'package:hairfit_ai/features/barber_profile/presentation/barber_pending_screen.dart';
import 'package:hairfit_ai/models/appointment_model.dart';
import 'package:hairfit_ai/models/barber_profile_model.dart';
import 'package:hairfit_ai/models/hairstyle_model.dart';
import 'package:hairfit_ai/models/user_model.dart';
import 'package:hairfit_ai/providers/admin_provider.dart';
import 'package:hairfit_ai/providers/admin_stats_provider.dart';
import 'package:hairfit_ai/providers/auth_provider.dart';

class FakeAuthNotifier extends AuthNotifier {
  final UserModel? _mockUser;
  FakeAuthNotifier(this._mockUser);

  @override
  FutureOr<UserModel?> build() => _mockUser;
}

class FakeAdminController extends StateNotifier<AsyncValue<void>>
    implements AdminController {
  FakeAdminController() : super(const AsyncValue.data(null));

  @override
  Future<void> approveBarber(String uid) async {}

  @override
  Future<void> rejectBarber(String uid) async {}

  @override
  Future<void> suspendBarber(String uid) async {}

  @override
  Future<void> reactivateBarber(String uid) async {}

  @override
  Future<void> setBarberStatus(String uid, String status) async {}

  @override
  Future<void> updateBarberProfileAdmin(
    String uid, {
    required String displayName,
    required String address,
    String? phone,
    required String bio,
    required double latitude,
    required double longitude,
    required bool isAcceptingBookingsToday,
  }) async {}

  @override
  Future<void> deleteBarberProfile(String uid) async {}

  @override
  Future<void> setUserBlockStatus(String uid, bool isBlocked) async {}

  @override
  Future<void> updateUserRole(String uid, String newRole) async {}

  @override
  Future<void> updateUserInfo(
    String uid, {
    required String displayName,
    String? phone,
  }) async {}

  @override
  Future<void> updateBarberLocation(
    String uid,
    double latitude,
    double longitude,
  ) async {}

  @override
  Future<void> emergencyCancelAppointment(
    String appointmentId, {
    String? reason,
  }) async {}

  @override
  Future<void> updateAppointmentStatus(
    String appointmentId,
    String newStatus, {
    String? reason,
  }) async {}

  @override
  Future<void> saveHairstyle(HairstyleModel hairstyle) async {}

  @override
  Future<void> deleteHairstyle(String id) async {}

  @override
  Future<void> deleteReview(
    String reviewId,
    String barberId,
    int rating, {
    String? appointmentId,
  }) async {}

  @override
  Future<void> saveSystemSettings({
    required double searchRadiusKm,
    required int cancelNoticeHours,
    required bool maintenanceMode,
  }) async {}
}

final sampleAdminUser = UserModel(
  uid: 'admin_1',
  email: 'admin@hairfit.vn',
  displayName: 'Admin HairFit',
  role: UserRole.admin,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

void main() {
  group('Admin Models & Stats Unit Tests', () {
    test(
      'AdminDashboardStats calculates completionRate and revenue fields',
      () {
        const stats = AdminDashboardStats(
          totalUsers: 30,
          totalCustomers: 24,
          totalBarbers: 5,
          totalAdmins: 1,
          blockedUsers: 2,
          pendingBarbers: 1,
          approvedBarbers: 3,
          suspendedBarbers: 1,
          totalAppointmentsToday: 4,
          completedAppointmentsToday: 2,
          confirmedAppointmentsToday: 0,
          cancelledAppointmentsToday: 2,
          revenueToday: 250000,
          expectedRevenueToday: 380000,
          totalRevenue: 4500000,
        );

        expect(stats.completionRate, 50.0);
        expect(stats.revenueToday, 250000);
        expect(stats.expectedRevenueToday, 380000);
        expect(stats.totalRevenue, 4500000);
        expect(stats.blockedUsers, 2);
        expect(stats.suspendedBarbers, 1);
      },
    );

    test('AdminAppointmentFilter equality and hashCode work properly for Family provider', () {
      const filter1 = AdminAppointmentFilter(date: '2026-10-24', status: 'all');
      const filter2 = AdminAppointmentFilter(date: '2026-10-24', status: 'all');
      const filter3 = AdminAppointmentFilter(
        date: '2026-10-24',
        status: 'confirmed',
      );

      expect(filter1, equals(filter2));
      expect(filter1.hashCode, equals(filter2.hashCode));
      expect(filter1, isNot(equals(filter3)));
    });

    test('BarberProfileModel.isSuspended returns true when approvalStatus is suspended', () {
      const suspendedProfile = BarberProfileModel(
        uid: 'b1',
        displayName: 'Tiệm Tạm Ngưng',
        address: 'Đà Nẵng',
        location: GeoLocation(latitude: 16.0, longitude: 108.0),
        approvalStatus: 'suspended',
      );

      expect(suspendedProfile.isSuspended, isTrue);
      expect(suspendedProfile.isApproved, isFalse);
      expect(suspendedProfile.isPending, isFalse);
      expect(suspendedProfile.isRejected, isFalse);
    });
  });

  group('Admin Portal 360° Widget Tests', () {
    testWidgets(
      'BarberPendingScreen displays suspended message when barber is suspended by Admin',
      (tester) async {
        final barberUser = UserModel(
          uid: 'b_susp',
          email: 'suspended@barber.vn',
          displayName: 'Thợ Tạm Ngưng',
          role: UserRole.barber,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );

        const suspendedBarber = BarberProfileModel(
          uid: 'b_susp',
          displayName: 'Tiệm Bị Khóa',
          approvalStatus: 'suspended',
          address: 'Đà Nẵng',
          location: GeoLocation(latitude: 16.0, longitude: 108.0),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith(
                () => FakeAuthNotifier(barberUser),
              ),
              barberProfileProvider('b_susp')
                  .overrideWith((ref) async => suspendedBarber),
            ],
            child: const MaterialApp(home: BarberPendingScreen()),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Tiệm của bạn đang tạm ngưng hoạt động'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'AdminDashboardScreen renders without LocaleDataException and displays revenue & KPI stats',
      (tester) async {
        const mockStats = AdminDashboardStats(
          totalUsers: 25,
          totalCustomers: 20,
          totalBarbers: 5,
          blockedUsers: 1,
          pendingBarbers: 1,
          approvedBarbers: 4,
          totalAppointments: 10,
          totalAppointmentsToday: 3,
          completedAppointmentsToday: 2,
          cancelledAppointmentsToday: 0,
          pendingAppointmentsToday: 1,
          confirmedAppointmentsToday: 0,
          revenueToday: 300000,
          expectedRevenueToday: 400000,
          totalRevenue: 1500000,
          totalHairstyles: 15,
          totalReviews: 12,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith(
                () => FakeAuthNotifier(sampleAdminUser),
              ),
              adminDashboardStatsProvider.overrideWith(
                (ref) async => mockStats,
              ),
              adminRecentPendingBarbersProvider.overrideWith(
                (ref) async => <BarberProfileModel>[],
              ),
              adminAppointmentsTodayProvider.overrideWith(
                (ref) async => <AppointmentModel>[],
              ),
              adminControllerProvider.overrideWith(
                (ref) => FakeAdminController(),
              ),
            ],
            child: MaterialApp(
              home: Scaffold(body: AdminDashboardScreen(onNavigateTab: (_) {})),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Tổng Quan Vận Hành'), findsOneWidget);
        expect(find.text('Doanh thu hôm nay'), findsOneWidget);
        expect(find.text('Tổng doanh thu hoàn tất'), findsOneWidget);
        expect(find.text('25'), findsOneWidget);
      },
    );

    testWidgets(
      'AdminShellScreen opens Drawer when tapping Xem thêm on bottom NavigationBar',
      (tester) async {
        const mockStats = AdminDashboardStats();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith(
                () => FakeAuthNotifier(sampleAdminUser),
              ),
              adminDashboardStatsProvider.overrideWith(
                (ref) async => mockStats,
              ),
              adminRecentPendingBarbersProvider.overrideWith(
                (ref) async => <BarberProfileModel>[],
              ),
              adminAppointmentsTodayProvider.overrideWith(
                (ref) async => <AppointmentModel>[],
              ),
              adminControllerProvider.overrideWith(
                (ref) => FakeAdminController(),
              ),
            ],
            child: const MaterialApp(home: AdminShellScreen()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Tổng Quan Hệ Thống'), findsOneWidget);
        await tester.tap(find.text('Xem thêm'));
        await tester.pumpAndSettle();

        expect(find.text('Danh mục kiểu tóc AI'), findsOneWidget);
        expect(find.text('Kiểm duyệt đánh giá'), findsOneWidget);
      },
    );

    testWidgets(
      'AdminBarbersScreen displays barber list in Danh bạ tất cả thợ tab',
      (tester) async {
        const sampleBarber = BarberProfileModel(
          uid: 'b_360',
          displayName: 'Tiệm Tóc Hoàng Gia',
          address: '45 Nguyễn Văn Linh, Đà Nẵng',
          phone: '0905111222',
          location: GeoLocation(latitude: 16.06, longitude: 108.21),
          approvalStatus: 'approved',
          ratingAvg: 4.9,
          ratingCount: 25,
          isAcceptingBookingsToday: true,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              pendingBarbersProvider.overrideWith(
                (ref) async => <BarberProfileModel>[],
              ),
              allBarbersProvider('all')
                  .overrideWith((ref) async => [sampleBarber]),
              userAppointmentsHistoryProvider((uid: 'b_360', isBarber: true))
                  .overrideWith((ref) async => <AppointmentModel>[]),
              adminControllerProvider.overrideWith(
                (ref) => FakeAdminController(),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(body: AdminBarbersScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Danh bạ tất cả thợ'));
        await tester.pumpAndSettle();

        expect(find.text('Tiệm Tóc Hoàng Gia'), findsOneWidget);
      },
    );

    testWidgets(
      'AdminUsersScreen displays user list and opens 360 action menu',
      (tester) async {
        final sampleCustomer = UserModel(
          uid: 'cust_360',
          email: 'khachvip@gmail.com',
          displayName: 'Nguyễn Văn Khách',
          phone: '0912345678',
          role: UserRole.customer,
          savedFaceShape: 'oval',
          createdAt: DateTime(2026, 2, 1),
          updatedAt: DateTime(2026, 2, 1),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith(
                () => FakeAuthNotifier(sampleAdminUser),
              ),
              allUsersProvider('all')
                  .overrideWith((ref) async => [sampleCustomer]),
              adminControllerProvider.overrideWith(
                (ref) => FakeAdminController(),
              ),
            ],
            child: const MaterialApp(home: Scaffold(body: AdminUsersScreen())),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Nguyễn Văn Khách'), findsOneWidget);
        expect(find.text('Khách'), findsOneWidget);

        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();

        expect(find.text('Xem hồ sơ 360° & Lịch sử'), findsOneWidget);
        expect(find.text('Sửa tên & SĐT'), findsOneWidget);
      },
    );

    testWidgets(
      'AdminAppointmentsScreen displays date filter bar and appointment card',
      (tester) async {
        final now = DateTime.now();
        final sampleAppt = AppointmentModel(
          id: 'appt_admin_1',
          customerId: 'cust_1',
          barberId: 'barber_1',
          barberName: 'Tiệm Tóc Sài Gòn',
          customerName: 'Trần Văn Nam',
          serviceId: 'svc_1',
          serviceName: 'Combo Cắt Gội',
          price: 120000,
          durationMinutes: 45,
          date: '2026-10-24',
          startTime: '14:00',
          endTime: '14:45',
          startTimestamp: now,
          endTimestamp: now.add(const Duration(minutes: 45)),
          status: AppointmentStatus.confirmed,
          slotIds: const ['barber_1_2026-10-24_14-00'],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              filteredAppointmentsProvider(
                const AdminAppointmentFilter(date: null, status: 'all'),
              ).overrideWith((ref) async => [sampleAppt]),
              adminControllerProvider.overrideWith(
                (ref) => FakeAdminController(),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(body: AdminAppointmentsScreen()),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Mọi ngày'), findsOneWidget);
        expect(find.text('Chọn ngày...'), findsOneWidget);
        expect(find.text('2026-10-24 · 14:00'), findsOneWidget);
        expect(find.text('Hoàn tất'), findsWidgets);
      },
    );
  });
}

// CreBy: MenBoyBMN
