// ============================================================================
// File: test/profile_and_features_test.dart
// Mục đích: Chứa các kịch bản kiểm thử (Test) cho profile_and_features.
// Kết cấu:
//  - Sử dụng flutter_test, bao gồm các nhóm test (group) và các trường hợp test (test/testWidgets) cụ thể.
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairfit_ai/features/admin/presentation/approve_barbers_screen.dart';
import 'package:hairfit_ai/features/barber_profile/data/barber_profile_repository.dart';
import 'package:hairfit_ai/features/barber_profile/presentation/barber_pending_screen.dart';
import 'package:hairfit_ai/models/appointment_model.dart';
import 'package:hairfit_ai/models/barber_profile_model.dart';
import 'package:hairfit_ai/models/hairstyle_model.dart';
import 'package:hairfit_ai/models/service_model.dart';
import 'package:hairfit_ai/models/user_model.dart';
import 'package:hairfit_ai/providers/admin_provider.dart';
import 'package:hairfit_ai/providers/appointment_provider.dart';
import 'package:hairfit_ai/providers/auth_provider.dart';
import 'package:hairfit_ai/providers/search_provider.dart';
import 'package:latlong2/latlong.dart';

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

void main() {
  group('Week 6 & 7 Features Unit Tests', () {
    test('BarberProfileModel copyWith updates fields correctly', () {
      final original = const BarberProfileModel(
        uid: '123',
        displayName: 'Test Barber',
        coverUrl: 'https://example.com/cover.jpg',
        bio: 'Old Bio',
        address: 'Old Address',
        location: GeoLocation(latitude: 0, longitude: 0),
        approvalStatus: 'approved',
        ratingAvg: 4.8,
        ratingCount: 10,
        priceMin: 50000,
        priceMax: 100000,
      );

      final updated = original.copyWith(
        bio: 'New Bio',
        priceMin: 60000,
        coverUrl: 'data:image/jpeg;base64,samplebase64',
      );

      expect(updated.uid, '123');
      expect(updated.displayName, 'Test Barber');
      expect(updated.coverUrl, 'data:image/jpeg;base64,samplebase64');
      expect(updated.bio, 'New Bio');
      expect(updated.address, 'Old Address');
      expect(updated.approvalStatus, 'approved');
      expect(updated.ratingAvg, 4.8);
      expect(updated.ratingCount, 10);
      expect(updated.priceMin, 60000);
      expect(updated.priceMax, 100000);

      // Test toMap & fromMap
      final map = updated.toMap();
      expect(map['coverUrl'], 'data:image/jpeg;base64,samplebase64');
      final fromMap = BarberProfileModel.fromMap(map);
      expect(fromMap.coverUrl, 'data:image/jpeg;base64,samplebase64');
    });

    test('SearchMapState copyWith handles maxPriceFilter correctly', () {
      final initialState = SearchMapState(
        referenceLocation: const LatLng(0, 0),
      );

      expect(initialState.maxPriceFilter, isNull);

      final stateWithPrice = initialState.copyWith(maxPriceFilter: 150000);
      expect(stateWithPrice.maxPriceFilter, 150000);

      final stateClearedPrice = stateWithPrice.copyWith(clearPriceFilter: true);
      expect(stateClearedPrice.maxPriceFilter, isNull);
    });

    test('AppointmentActionState handles loading and messages', () {
      const initialState = AppointmentActionState();

      expect(initialState.isLoading, false);
      expect(initialState.successMessage, isNull);
      expect(initialState.errorMessage, isNull);

      final loadingState = initialState.copyWith(
        isLoading: true,
        clearMessages: true,
      );
      expect(loadingState.isLoading, true);
      expect(loadingState.successMessage, isNull);
      expect(loadingState.errorMessage, isNull);

      final successState = loadingState.copyWith(
        isLoading: false,
        successMessage: 'Thành công',
      );
      expect(successState.isLoading, false);
      expect(successState.successMessage, 'Thành công');
      expect(successState.errorMessage, isNull);
    });

    test(
      'BarberProfileModel handles portfolioUrls and isAcceptingBookingsToday',
      () {
        const barber = BarberProfileModel(
          uid: 'b_lookbook',
          displayName: 'Master Barber',
          address: 'Đà Nẵng',
          location: GeoLocation(latitude: 16.0, longitude: 108.0),
          portfolioUrls: ['img1.jpg', 'img2.jpg'],
          isAcceptingBookingsToday: true,
        );

        expect(barber.portfolioUrls.length, 2);
        expect(barber.isAcceptingBookingsToday, true);

        final updated = barber.copyWith(
          portfolioUrls: ['img1.jpg', 'img2.jpg', 'img3.jpg'],
          isAcceptingBookingsToday: false,
        );

        expect(updated.portfolioUrls.length, 3);
        expect(updated.isAcceptingBookingsToday, false);

        final map = updated.toMap();
        expect((map['portfolioUrls'] as List).length, 3);
        expect(map['isAcceptingBookingsToday'], false);
      },
    );

    test('AppointmentModel handles AI Handshake and Barber Private Notes', () {
      final now = DateTime.now();
      final appt = AppointmentModel(
        id: 'appt_1',
        customerId: 'cust_1',
        barberId: 'barber_1',
        barberName: 'Thợ Tâm',
        customerName: 'Khách Minh',
        serviceId: 's1',
        serviceName: 'Cắt Fade',
        price: 100000,
        durationMinutes: 30,
        date: '2026-10-10',
        startTime: '10:00',
        endTime: '10:30',
        startTimestamp: now,
        endTimestamp: now.add(const Duration(minutes: 30)),
        slotIds: ['slot_1'],
        customerFaceShape: 'round',
        aiStylingTip: 'Nên cạo High Fade để mặt thanh thoát hơn',
        hairstyleImageUrl: 'https://example.com/fade.jpg',
        barberPrivateNote: 'Khách da đầu nhạy cảm, thích dùng sáp nhẹ',
      );

      expect(appt.customerFaceShape, 'round');
      expect(appt.aiStylingTip, contains('High Fade'));
      expect(appt.barberPrivateNote, contains('da đầu nhạy cảm'));

      final updated = appt.copyWith(
        barberPrivateNote: 'Khách đổi ý thích chải Side Part',
      );
      expect(updated.barberPrivateNote, 'Khách đổi ý thích chải Side Part');
    });

    test('SearchMapState handles minRatingFilter and onlyOpenNow', () {
      final initialState = SearchMapState(
        referenceLocation: const LatLng(16.0, 108.0),
      );

      expect(initialState.minRatingFilter, isNull);
      expect(initialState.onlyOpenNow, false);

      final updated = initialState.copyWith(
        minRatingFilter: 4.5,
        onlyOpenNow: true,
      );

      expect(updated.minRatingFilter, 4.5);
      expect(updated.onlyOpenNow, true);

      final cleared = updated.copyWith(
        clearRatingFilter: true,
        onlyOpenNow: false,
      );

      expect(cleared.minRatingFilter, isNull);
      expect(cleared.onlyOpenNow, false);
    });

    testWidgets(
      'BarberPendingScreen shows (Bạn có thể cập nhật lại thông tin trong Trang Thợ)',
      (tester) async {
        final sampleUser = UserModel(
          uid: 'barber_123',
          email: 'barber@test.com',
          displayName: 'Thợ Test',
          avatarUrl: '',
          role: UserRole.barber,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final samplePendingBarber = const BarberProfileModel(
          uid: 'barber_123',
          displayName: 'Thợ Test',
          approvalStatus: 'pending',
          address: '100 Nguyễn Văn Linh, Đà Nẵng',
          location: GeoLocation(latitude: 16.05, longitude: 108.20),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authStateProvider.overrideWith(
                () => FakeAuthNotifier(sampleUser),
              ),
              barberProfileProvider('barber_123')
                  .overrideWith((ref) => Future.value(samplePendingBarber)),
            ],
            child: const MaterialApp(home: BarberPendingScreen()),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('(Bạn có thể cập nhật lại thông tin trong Trang Thợ)'),
          findsOneWidget,
        );
        expect(find.text('Xem lại / Cập nhật hồ sơ'), findsNothing);
      },
    );

    testWidgets('ApproveBarbersScreen renders detail button and opens modal', (
      tester,
    ) async {
      final samplePendingBarber = const BarberProfileModel(
        uid: 'barber_test_admin',
        displayName: 'Tiệm Tóc Minh Nhật',
        bio: '5 năm kinh nghiệm cắt tóc nam',
        address: '123 Lê Duẩn, Đà Nẵng',
        location: GeoLocation(latitude: 16.068, longitude: 108.216),
        priceMin: 70000,
        priceMax: 150000,
        approvalStatus: 'pending',
        services: [
          ServiceModel(
            id: 'svc1',
            name: 'Cắt tạo kiểu',
            price: 80000,
            durationMinutes: 30,
          ),
        ],
        hairstyleIds: ['undercut', 'side_part'],
        workingHours: {
          'mon': DayWorkingHours(closed: false, open: '08:00', close: '20:00'),
          'sun': DayWorkingHours(closed: true, open: '00:00', close: '00:00'),
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pendingBarbersProvider.overrideWith(
              (ref) => Future.value([samplePendingBarber]),
            ),
            adminControllerProvider.overrideWith(
              (ref) => FakeAdminController(),
            ),
          ],
          child: const MaterialApp(home: ApproveBarbersScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify card summary
      expect(find.text('Tiệm Tóc Minh Nhật'), findsOneWidget);
      expect(find.text('Xem chi tiết hồ sơ đầy đủ'), findsOneWidget);

      // Tap on details button
      await tester.tap(find.text('Xem chi tiết hồ sơ đầy đủ'));
      await tester.pumpAndSettle();

      // Verify details modal opened
      expect(find.text('Chi tiết hồ sơ thợ cắt tóc'), findsOneWidget);
      expect(find.text('Giới thiệu tiệm / thợ'), findsOneWidget);
      expect(find.text('5 năm kinh nghiệm cắt tóc nam'), findsWidgets);
      expect(find.text('Dịch vụ & Bảng giá (1 dịch vụ)'), findsOneWidget);
      expect(find.text('Giờ làm việc chi tiết trong tuần'), findsOneWidget);
      expect(find.text('Cắt tạo kiểu'), findsOneWidget);
      expect(find.text('30 phút'), findsOneWidget);
      expect(find.text('08:00 - 20:00'), findsOneWidget);
      expect(find.text('Duyệt hồ sơ'), findsWidgets);
      expect(find.text('Đóng cửa / Nghỉ'), findsWidgets);
    });
  });
}

// CreBy: MenBoyBMN
