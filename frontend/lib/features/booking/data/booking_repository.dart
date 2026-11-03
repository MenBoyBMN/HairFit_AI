// ============================================================================
// File: lib/features/booking/data/booking_repository.dart
// Mục đích: Quản lý dữ liệu (Repository) cho tính năng booking.
// Kết cấu:
//  - Giao tiếp với ASP.NET Core Web API để thực thi giao dịch đặt lịch/hủy lịch ACID.
// ============================================================================

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/business_constants.dart';
import '../../../core/services/api_client.dart';
import '../../../models/booked_slot_model.dart';

/// Ngoại lệ cơ sở cho các lỗi đặt lịch
class BookingException implements Exception {
  final String message;
  const BookingException(this.message);

  @override
  String toString() => message;
}

/// Ngoại lệ khi một hoặc nhiều slot thời gian đã bị người khác đặt trước
class SlotAlreadyBookedException extends BookingException {
  final String slotId;
  SlotAlreadyBookedException(this.slotId)
    : super(
        'Khung giờ này vừa có người khác đặt. Vui lòng chọn khung giờ khác!',
      );
}

/// Ngoại lệ khi khách hàng đã đạt giới hạn tối đa 2 lịch hẹn đang active (pending/confirmed)
class MaxBookingsExceededException extends BookingException {
  MaxBookingsExceededException()
    : super(
        'Bạn đã có ${BusinessConstants.maxActiveBookingsPerCustomer} lịch hẹn chưa hoàn thành. Không thể đặt thêm!',
      );
}

/// Ngoại lệ khi đặt lịch quá sát giờ (dưới 30 phút)
class BookingLeadTimeException extends BookingException {
  BookingLeadTimeException()
    : super(
        'Vui lòng đặt lịch trước ít nhất ${BusinessConstants.leadTimeMinutes} phút!',
      );
}

/// Ngoại lệ khi đặt lịch vượt quá 30 ngày tới
class BookingMaxDaysExceededException extends BookingException {
  BookingMaxDaysExceededException()
    : super(
        'Chỉ được đặt lịch trước tối đa ${BusinessConstants.maxBookingDaysAhead} ngày!',
      );
}

/// Ngoại lệ khi không thể hủy lịch (do quá hạn 30 phút hoặc sai trạng thái)
class CannotCancelException extends BookingException {
  const CannotCancelException(super.message);
}

/// Repository xử lý giao dịch đặt lịch và hủy lịch chống trùng qua ASP.NET Core Web API
class BookingRepository {
  final ApiClient _apiClient;

  BookingRepository({FirebaseFirestore? firestore, ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Never _mapApiException(ApiException e) {
    switch (e.code) {
      case 'MAX_BOOKINGS_EXCEEDED':
        throw MaxBookingsExceededException();
      case 'LEAD_TIME_VIOLATION':
        throw BookingLeadTimeException();
      case 'MAX_DAYS_EXCEEDED':
        throw BookingMaxDaysExceededException();
      case 'SLOT_ALREADY_BOOKED':
        final slotId = e.data['slotId']?.toString() ?? '';
        throw SlotAlreadyBookedException(slotId);
      case 'CANNOT_CANCEL':
        throw CannotCancelException(e.message);
      default:
        throw BookingException(e.message);
    }
  }

  /// Đếm số lượng lịch hẹn đang active (pending hoặc confirmed) của một khách hàng
  Future<int> countActiveBookings(String customerId) async {
    try {
      final response = await _apiClient.get(
        '/api/bookings/active-count/$customerId',
      );
      if (response is Map) {
        return (response['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// Lấy danh sách các slot đã đặt của thợ theo ngày từ ASP.NET Core Web API
  Future<List<BookedSlotModel>> getBookedSlotsForDate(
    String barberId,
    String date,
  ) async {
    try {
      final response = await _apiClient.get(
        '/api/bookings/slots',
        queryParameters: {'barberId': barberId, 'date': date},
      );
      if (response is List) {
        return response
            .map(
              (e) =>
                  BookedSlotModel.fromMap(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Thợ tự khóa slot giờ nghỉ / bận đột xuất (Task 2.2)
  Future<void> blockSlotsByBarber({
    required String barberId,
    required String date,
    required List<String> times,
    String reason = 'Giờ nghỉ / Bận đột xuất',
  }) async {
    await _apiClient.post(
      '/api/bookings/block-slots',
      body: {
        'barberId': barberId,
        'date': date,
        'times': times,
        'reason': reason,
      },
    );
  }

  /// Thợ mở lại slot đã khóa
  Future<void> unblockSlotByBarber(String slotId) async {
    await _apiClient.delete('/api/bookings/block-slots/$slotId');
  }

  /// Thực thi TRANSACTION đặt lịch nguyên tử (Atomic SQL Transaction trên ASP.NET Core)
  Future<String> createBooking({
    required String customerId,
    required String customerName,
    required String barberId,
    required String barberName,
    required String serviceId,
    required String serviceName,
    required int price,
    required int durationMinutes,
    required String date,
    required String startTime,
    required String endTime,
    required List<String> slotIds,
    String hairstyleId = '',
    String? customerFaceShape,
    String? aiStylingTip,
    String? hairstyleImageUrl,
    String? customerPhone,
    String? barberPhone,
    String note = '',
    DateTime? currentTime,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/bookings',
        body: {
          'customerId': customerId,
          'customerName': customerName,
          'barberId': barberId,
          'barberName': barberName,
          'serviceId': serviceId,
          'serviceName': serviceName,
          'price': price,
          'durationMinutes': durationMinutes,
          'date': date,
          'startTime': startTime,
          'endTime': endTime,
          'slotIds': slotIds,
          'hairstyleId': hairstyleId,
          'customerFaceShape': ?customerFaceShape,
          'aiStylingTip': ?aiStylingTip,
          'hairstyleImageUrl': ?hairstyleImageUrl,
          'customerPhone': ?customerPhone,
          'barberPhone': ?barberPhone,
          'note': note.trim(),
          if (currentTime != null) 'currentTime': currentTime.toIso8601String(),
        },
      );
      if (response is Map && response['appointmentId'] != null) {
        return response['appointmentId'].toString();
      }
      return '';
    } on ApiException catch (e) {
      _mapApiException(e);
    }
  }

  /// Thực thi TRANSACTION hủy lịch nguyên tử (Atomic Cancel Transaction)
  Future<void> cancelBooking({
    required String appointmentId,
    required String cancelledByUid,
    DateTime? currentTime,
  }) async {
    try {
      await _apiClient.post(
        '/api/bookings/$appointmentId/cancel',
        body: {
          'cancelledByUid': cancelledByUid,
          if (currentTime != null) 'currentTime': currentTime.toIso8601String(),
        },
      );
    } on ApiException catch (e) {
      _mapApiException(e);
    }
  }

  /// Thực thi TRANSACTION đổi giờ hẹn nguyên tử (Atomic Reschedule Transaction)
  Future<void> rescheduleBooking({
    required String appointmentId,
    required String newDate,
    required String newStartTime,
    required String newEndTime,
    required List<String> newSlotIds,
  }) async {
    try {
      await _apiClient.post(
        '/api/bookings/$appointmentId/reschedule',
        body: {
          'newDate': newDate,
          'newStartTime': newStartTime,
          'newEndTime': newEndTime,
          'newSlotIds': newSlotIds,
        },
      );
    } on ApiException catch (e) {
      _mapApiException(e);
    }
  }
}

// CreBy: MenBoyBMN
