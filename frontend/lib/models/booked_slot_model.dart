// ============================================================================
// File: lib/models/booked_slot_model.dart
// Mục đích: Định nghĩa cấu trúc dữ liệu (booked_slot_model).
// Kết cấu:
//  - Lớp mô hình (Model) bao gồm các thuộc tính và phương thức chuyển đổi (toMap, fromMap, copyWith).
// ============================================================================

/// Mô hình slot thời gian đã đặt (bookedSlots/{slotId})
/// Dùng để chống trùng lịch bằng Transaction
class BookedSlotModel {
  final String id; // Format: "{barberId}_{yyyy-MM-dd}_{HH-mm}"
  final String barberId;
  final String date; // "yyyy-MM-dd"
  final String time; // "HH:mm"
  final String appointmentId;
  final DateTime startTimestamp;
  final bool isBlockedByBarber;
  final String? blockReason;
  final DateTime? createdAt;

  const BookedSlotModel({
    required this.id,
    required this.barberId,
    required this.date,
    required this.time,
    required this.appointmentId,
    required this.startTimestamp,
    this.isBlockedByBarber = false,
    this.blockReason,
    this.createdAt,
  });

  /// Hàm tạo mã slotId chuẩn theo định dạng quy định
  /// Ví dụ: barberId="barber_456", date="2026-10-10", time="09:00" -> "barber_456_2026-10-10_09-00"
  static String generateSlotId({
    required String barberId,
    required String date,
    required String time,
  }) {
    final sanitizedTime = time.replaceAll(':', '-');
    return '${barberId}_${date}_$sanitizedTime';
  }

  factory BookedSlotModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parseTimestamp(dynamic val) {
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is num) return DateTime.fromMillisecondsSinceEpoch(val.toInt());
      return DateTime.now();
    }

    DateTime? parseNullableTimestamp(dynamic val) {
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      if (val is num) return DateTime.fromMillisecondsSinceEpoch(val.toInt());
      return null;
    }

    return BookedSlotModel(
      id: id ?? map['id'] as String? ?? '',
      barberId: map['barberId'] as String? ?? '',
      date: map['date'] as String? ?? '',
      time: map['time'] as String? ?? '',
      appointmentId: map['appointmentId'] as String? ?? '',
      startTimestamp: parseTimestamp(map['startTimestamp']),
      isBlockedByBarber: map['isBlockedByBarber'] as bool? ?? false,
      blockReason: map['blockReason'] as String?,
      createdAt: parseNullableTimestamp(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barberId': barberId,
      'date': date,
      'time': time,
      'appointmentId': appointmentId,
      'startTimestamp': startTimestamp.toIso8601String(),
      'isBlockedByBarber': isBlockedByBarber,
      if (blockReason != null) 'blockReason': blockReason,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  BookedSlotModel copyWith({
    String? id,
    String? barberId,
    String? date,
    String? time,
    String? appointmentId,
    DateTime? startTimestamp,
    bool? isBlockedByBarber,
    String? blockReason,
    DateTime? createdAt,
  }) {
    return BookedSlotModel(
      id: id ?? this.id,
      barberId: barberId ?? this.barberId,
      date: date ?? this.date,
      time: time ?? this.time,
      appointmentId: appointmentId ?? this.appointmentId,
      startTimestamp: startTimestamp ?? this.startTimestamp,
      isBlockedByBarber: isBlockedByBarber ?? this.isBlockedByBarber,
      blockReason: blockReason ?? this.blockReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// CreBy: MenBoyBMN
