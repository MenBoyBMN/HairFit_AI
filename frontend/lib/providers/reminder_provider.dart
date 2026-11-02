// ============================================================================
// File: lib/providers/reminder_provider.dart
// Mục đích: Quản lý trạng thái (State Management) nhắc lịch tự động.
// Kết cấu:
//  - Sử dụng Riverpod để quản lý cài đặt bật/tắt nhắc nhở và danh sách thông báo nhắc lịch khẩn cấp.
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/notification_service.dart';
import 'appointment_provider.dart';

/// Trạng thái cài đặt & danh sách nhắc lịch tự động
class ReminderState {
  final bool autoRemindersEnabled;
  final Set<String> dismissedReminderIds;

  const ReminderState({
    this.autoRemindersEnabled = true,
    this.dismissedReminderIds = const {},
  });

  ReminderState copyWith({
    bool? autoRemindersEnabled,
    Set<String>? dismissedReminderIds,
  }) {
    return ReminderState(
      autoRemindersEnabled: autoRemindersEnabled ?? this.autoRemindersEnabled,
      dismissedReminderIds: dismissedReminderIds ?? this.dismissedReminderIds,
    );
  }
}

/// Notifier quản lý bật/tắt và tắt tạm thời nhắc lịch
class ReminderNotifier extends StateNotifier<ReminderState> {
  ReminderNotifier() : super(const ReminderState());

  /// Bật / Tắt tính năng nhắc lịch tự động
  void toggleAutoReminders(bool enabled) {
    state = state.copyWith(autoRemindersEnabled: enabled);
  }

  /// Ẩn một thông báo nhắc nhở cụ thể
  void dismissReminder(String reminderId) {
    final updated = Set<String>.from(state.dismissedReminderIds)
      ..add(reminderId);
    state = state.copyWith(dismissedReminderIds: updated);
  }

  /// Xóa toàn bộ nhắc nhở đã ẩn
  void clearDismissed() {
    state = state.copyWith(dismissedReminderIds: const {});
  }
}

/// Provider quản lý cài đặt nhắc lịch
final reminderNotifierProvider =
    StateNotifierProvider<ReminderNotifier, ReminderState>((ref) {
      return ReminderNotifier();
    });

/// Provider tính toán thông báo nhắc lịch hẹn tự động khẩn cấp nhất hiện tại
final activeAutoReminderProvider =
    Provider.autoDispose<AppointmentReminderNotice?>((ref) {
      final reminderState = ref.watch(reminderNotifierProvider);
      if (!reminderState.autoRemindersEnabled) return null;

      final appointmentsAsync = ref.watch(customerAppointmentsProvider);
      final appointments = appointmentsAsync.valueOrNull ?? [];
      if (appointments.isEmpty) return null;

      final service = NotificationService();
      final reminders = service.generateReminders(appointments);

      final activeReminders = reminders
          .where((r) => !reminderState.dismissedReminderIds.contains(r.id))
          .toList();

      if (activeReminders.isEmpty) return null;
      return activeReminders.first;
    });

// CreBy: MenBoyBMN
