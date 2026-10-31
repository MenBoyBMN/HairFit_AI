// ============================================================================
// File: lib/features/appointments/data/appointment_repository.dart
// Mục đích: Quản lý truy vấn và cập nhật trạng thái lịch hẹn qua ASP.NET Core Web API.
// ============================================================================

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/api_client.dart';
import '../../../models/appointment_model.dart';
import '../../booking/data/booking_repository.dart';

/// Repository quản lý truy vấn và cập nhật trạng thái lịch hẹn (Tasks 4.9, 4.10, 4.13)
class AppointmentRepository {
  final ApiClient _apiClient;
  final BookingRepository _bookingRepository;

  AppointmentRepository({
    FirebaseFirestore? firestore,
    BookingRepository? bookingRepository,
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient(),
       _bookingRepository =
           bookingRepository ??
           BookingRepository(apiClient: apiClient ?? ApiClient());

  Future<List<AppointmentModel>> _fetchCustomerAppointments(
    String customerId,
  ) async {
    final response = await _apiClient.get(
      '/api/appointments/customer/$customerId',
    );
    if (response is List) {
      final list = response
          .map(
            (e) =>
                AppointmentModel.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
      list.sort((a, b) => b.startTimestamp.compareTo(a.startTimestamp));
      return list;
    }
    return [];
  }

  /// Lắng nghe danh sách lịch hẹn của một khách hàng
  Stream<List<AppointmentModel>> streamCustomerAppointments(
    String customerId,
  ) async* {
    yield await _fetchCustomerAppointments(customerId);
    yield* Stream.periodic(const Duration(seconds: 10)).asyncMap((_) async {
      return await _fetchCustomerAppointments(customerId);
    });
  }

  Future<List<AppointmentModel>> _fetchBarberAppointments(
    String barberId,
  ) async {
    final response = await _apiClient.get('/api/appointments/barber/$barberId');
    if (response is List) {
      final list = response
          .map(
            (e) =>
                AppointmentModel.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
      list.sort((a, b) => b.startTimestamp.compareTo(a.startTimestamp));
      return list;
    }
    return [];
  }

  /// Lắng nghe danh sách lịch hẹn của một thợ cắt tóc
  Stream<List<AppointmentModel>> streamBarberAppointments(
    String barberId,
  ) async* {
    yield await _fetchBarberAppointments(barberId);
    yield* Stream.periodic(const Duration(seconds: 10)).asyncMap((_) async {
      return await _fetchBarberAppointments(barberId);
    });
  }

  /// Lấy thông tin chi tiết một lịch hẹn bằng ID
  Future<AppointmentModel?> getAppointmentById(String appointmentId) async {
    try {
      final response = await _apiClient.get('/api/appointments/$appointmentId');
      if (response is Map) {
        return AppointmentModel.fromMap(
          Map<String, dynamic>.from(response),
          id: appointmentId,
        );
      }
    } catch (_) {}
    return null;
  }

  /// Thợ xác nhận tiếp nhận lịch hẹn (pending -> confirmed)
  Future<void> confirmAppointment(String appointmentId) async {
    try {
      await _apiClient.post('/api/appointments/$appointmentId/confirm');
    } on ApiException catch (e) {
      throw BookingException(e.message);
    }
  }

  /// Thợ từ chối lịch hẹn (pending -> rejected) và giải phóng khung giờ
  Future<void> rejectAppointment(String appointmentId, {String? reason}) async {
    try {
      await _apiClient.post(
        '/api/appointments/$appointmentId/reject',
        body: {'reason': ?reason},
      );
    } on ApiException catch (e) {
      throw BookingException(e.message);
    }
  }

  /// Thợ hoàn tất dịch vụ cắt tóc (confirmed -> completed)
  Future<void> completeAppointment(String appointmentId) async {
    try {
      await _apiClient.post('/api/appointments/$appointmentId/complete');
    } on ApiException catch (e) {
      throw BookingException(e.message);
    }
  }

  /// Khách hàng hủy lịch hẹn (ủy thác qua BookingRepository transaction)
  Future<void> cancelAppointment({
    required String appointmentId,
    required String cancelledByUid,
    DateTime? currentTime,
  }) async {
    await _bookingRepository.cancelBooking(
      appointmentId: appointmentId,
      cancelledByUid: cancelledByUid,
      currentTime: currentTime,
    );
  }

  /// Khách hàng đổi giờ hẹn (ủy thác qua BookingRepository transaction)
  Future<void> rescheduleAppointment({
    required String appointmentId,
    required String newDate,
    required String newStartTime,
    required String newEndTime,
    required List<String> newSlotIds,
  }) async {
    await _bookingRepository.rescheduleBooking(
      appointmentId: appointmentId,
      newDate: newDate,
      newStartTime: newStartTime,
      newEndTime: newEndTime,
      newSlotIds: newSlotIds,
    );
  }

  /// Đánh giá lịch hẹn và cập nhật điểm trung bình của thợ
  Future<void> rateAppointment({
    required String appointmentId,
    required String barberId,
    required int rating,
    String? customerId,
    String? customerName,
    String? comment,
  }) async {
    try {
      await _apiClient.post(
        '/api/appointments/$appointmentId/rate',
        body: {
          'barberId': barberId,
          'rating': rating,
          'customerId': ?customerId,
          'customerName': ?customerName,
          'comment': ?comment,
        },
      );
    } on ApiException catch (e) {
      throw BookingException(e.message);
    }
  }

  /// Thợ cập nhật ghi chú riêng tư về khách hàng này (Client Notes / Mini CRM)
  Future<void> updateBarberPrivateNote(
    String appointmentId,
    String note,
  ) async {
    try {
      await _apiClient.patch(
        '/api/appointments/$appointmentId/private-note',
        body: {'note': note},
      );
    } on ApiException catch (e) {
      throw BookingException(e.message);
    }
  }
}

// CreBy: MenBoyBMN
