// ============================================================================
// File: lib/core/services/notification_service.dart
// Mục đích: Cung cấp dịch vụ hạ tầng nhắc lịch hẹn tự động (Automated Appointment Reminder Service).
// Kết cấu:
//  - Quản lý việc tính toán thời gian nhắc nhở, tạo thông báo nhắc lịch và lưu trữ trạng thái nhắc nhở.
// ============================================================================

import 'package:flutter/foundation.dart';

import '../../models/appointment_model.dart';
import '../utils/date_formatter.dart';

/// Cấu trúc thông báo nhắc lịch hẹn tự động
class AppointmentReminderNotice {
  final String id;
  final String appointmentId;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final String barberName;
  final String serviceName;
  final String barberPhone;
  final String timeText;
  final int minutesRemaining;
  final bool isUrgent; // Dưới 30 phút

  const AppointmentReminderNotice({
    required this.id,
    required this.appointmentId,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.barberName,
    required this.serviceName,
    required this.barberPhone,
    required this.timeText,
    required this.minutesRemaining,
    required this.isUrgent,
  });
}

/// Dịch vụ tính toán và quản lý nhắc lịch hẹn tự động
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  /// Tính toán danh sách nhắc nhở tự động từ danh sách lịch hẹn
  List<AppointmentReminderNotice> generateReminders(
    List<AppointmentModel> appointments, {
    DateTime? nowOverride,
  }) {
    final now = nowOverride ?? DateTime.now();
    final List<AppointmentReminderNotice> notices = [];

    final activeUpcoming = appointments.where((a) {
      if (!a.isPending && !a.isConfirmed) return false;
      // Lịch hẹn chưa kết thúc và diễn ra trong hôm nay hoặc ngày mai
      return a.endTimestamp.isAfter(now);
    }).toList();

    for (final app in activeUpcoming) {
      final diff = app.startTimestamp.difference(now);
      final minutesRemaining = diff.inMinutes;

      // Chỉ sinh nhắc nhở nếu lịch hẹn diễn ra trong vòng 24 giờ tới
      if (minutesRemaining >= -30 && minutesRemaining <= 1440) {
        final isUrgent = minutesRemaining <= 30;
        String title;
        String body;

        if (minutesRemaining <= 0) {
          title = '⏰ ĐÃ TỚI GIỜ CẮT TÓC!';
          body =
              'Ca cắt tóc "${app.serviceName}" tại "${app.barberName}" đang diễn ra!';
        } else if (minutesRemaining <= 30) {
          title = '⏰ NHẮC LỊCH: CÒN $minutesRemaining PHÚT NỮA!';
          body =
              'Lịch hẹn cắt tóc lúc ${app.startTime} tại "${app.barberName}" sắp bắt đầu.';
        } else if (minutesRemaining <= 120) {
          final hours = minutesRemaining ~/ 60;
          final mins = minutesRemaining % 60;
          title = '🔔 NHẮC LỊCH HẸN HÔM NAY';
          body =
              'Bạn có lịch hẹn cắt tóc lúc ${app.startTime} (${hours > 0 ? '$hours giờ ' : ''}$mins phút nữa) tại "${app.barberName}".';
        } else {
          title = '📅 LỊCH HẸN SẮP TỚI';
          body =
              'Lịch hẹn cắt tóc lúc ${app.startTime} ngày ${DateFormatter.formatShortDate(app.startTimestamp)} tại "${app.barberName}".';
        }

        notices.add(
          AppointmentReminderNotice(
            id: 'reminder_${app.id}_$minutesRemaining',
            appointmentId: app.id,
            title: title,
            body: body,
            scheduledTime: app.startTimestamp,
            barberName: app.barberName,
            serviceName: app.serviceName,
            barberPhone: app.barberPhone ?? '',
            timeText: '${app.startTime} - ${app.endTime}',
            minutesRemaining: minutesRemaining,
            isUrgent: isUrgent,
          ),
        );
      }
    }

    // Sắp xếp lịch hẹn gấp nhất lên đầu
    notices.sort((a, b) => a.minutesRemaining.compareTo(b.minutesRemaining));
    return notices;
  }

  /// In log mô phỏng gửi thông báo nhắc lịch tự động
  void triggerAutoReminderLog(AppointmentReminderNotice notice) {
    debugPrint('🔔 [AutomatedReminder] ${notice.title} -> ${notice.body}');
  }
}

// CreBy: MenBoyBMN
