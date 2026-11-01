// ============================================================================
// File: lib/models/promotion_model.dart
// Mục đích: Định nghĩa cấu trúc dữ liệu mã giảm giá & giờ vàng (promotion_model).
// Kết cấu:
//  - Lớp mô hình (Model) bao gồm các thuộc tính và phương thức kiểm tra hợp lệ.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// Loại giảm giá: theo phần trăm (%) hoặc số tiền cố định (đ)
enum PromotionType { percentage, fixedAmount }

/// Mô hình mã giảm giá / Giờ vàng Happy Hour (promotions/{promoId})
class PromotionModel {
  final String id;
  final String code; // Ví dụ: "HAPPYHOUR20", "HAIRFIT30"
  final String title; // "Giờ Vàng Khung Sáng Giảm 20%"
  final String description; // "Áp dụng khung 08:30 - 11:30 các ngày T2 - T5"
  final PromotionType type;
  final int discountValue; // 20 (%) hoặc 20000 (đ)
  final int minOrderPrice; // Giá tối thiểu áp dụng (vd: 80000đ)
  final int maxDiscountAmount; // Mức giảm tối đa (vd: 50000đ)
  final String? applicableHoursStart; // "08:30"
  final String? applicableHoursEnd; // "11:30"
  final List<String> applicableDays; // ["mon", "tue", "wed", "thu"]
  final DateTime? validFrom;
  final DateTime? validUntil;
  final int usageLimit;
  final int usedCount;
  final bool active;

  const PromotionModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    this.type = PromotionType.percentage,
    required this.discountValue,
    this.minOrderPrice = 0,
    this.maxDiscountAmount = 100000,
    this.applicableHoursStart,
    this.applicableHoursEnd,
    this.applicableDays = const [],
    this.validFrom,
    this.validUntil,
    this.usageLimit = 1000,
    this.usedCount = 0,
    this.active = true,
  });

  /// Tính số tiền giảm giá cho một đơn hàng có giá gốc [orderPrice]
  int calculateDiscount(int orderPrice) {
    if (orderPrice < minOrderPrice) return 0;

    int calculated = 0;
    if (type == PromotionType.percentage) {
      calculated = (orderPrice * discountValue / 100).round();
    } else {
      calculated = discountValue;
    }

    if (maxDiscountAmount > 0 && calculated > maxDiscountAmount) {
      return maxDiscountAmount;
    }
    return calculated.clamp(0, orderPrice);
  }

  /// Kiểm tra xem mã giảm giá có áp dụng được cho khung giờ và ngày này không
  bool isApplicableForSlot({
    required int orderPrice,
    required String time, // "09:30"
    required String dateIso, // "2026-10-15"
    required DateTime now,
  }) {
    if (!active) return false;
    if (usedCount >= usageLimit) return false;
    if (orderPrice < minOrderPrice) return false;

    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;

    // Kiểm tra ngày trong tuần nếu có cấu hình
    if (applicableDays.isNotEmpty) {
      final parsedDate = DateTime.tryParse(dateIso);
      if (parsedDate != null) {
        final dayKey = _getDayKey(parsedDate.weekday);
        if (!applicableDays.contains(dayKey)) return false;
      }
    }

    // Kiểm tra khung giờ (Happy Hour) nếu có cấu hình
    if (applicableHoursStart != null && applicableHoursEnd != null) {
      final slotMinutes = _timeToMinutes(time);
      final startMinutes = _timeToMinutes(applicableHoursStart!);
      final endMinutes = _timeToMinutes(applicableHoursEnd!);

      if (slotMinutes < startMinutes || slotMinutes > endMinutes) {
        return false;
      }
    }

    return true;
  }

  static String _getDayKey(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'mon';
      case DateTime.tuesday:
        return 'tue';
      case DateTime.wednesday:
        return 'wed';
      case DateTime.thursday:
        return 'thu';
      case DateTime.friday:
        return 'fri';
      case DateTime.saturday:
        return 'sat';
      case DateTime.sunday:
      default:
        return 'sun';
    }
  }

  static int _timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return 0;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return h * 60 + m;
  }

  factory PromotionModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return PromotionModel(
      id: id ?? map['id'] as String? ?? '',
      code: map['code'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      type: map['type'] == 'fixedAmount'
          ? PromotionType.fixedAmount
          : PromotionType.percentage,
      discountValue: (map['discountValue'] as num?)?.toInt() ?? 0,
      minOrderPrice: (map['minOrderPrice'] as num?)?.toInt() ?? 0,
      maxDiscountAmount: (map['maxDiscountAmount'] as num?)?.toInt() ?? 100000,
      applicableHoursStart: map['applicableHoursStart'] as String?,
      applicableHoursEnd: map['applicableHoursEnd'] as String?,
      applicableDays:
          (map['applicableDays'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      validFrom: map['validFrom'] is Timestamp
          ? (map['validFrom'] as Timestamp).toDate()
          : null,
      validUntil: map['validUntil'] is Timestamp
          ? (map['validUntil'] as Timestamp).toDate()
          : null,
      usageLimit: (map['usageLimit'] as num?)?.toInt() ?? 1000,
      usedCount: (map['usedCount'] as num?)?.toInt() ?? 0,
      active: map['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'type': type == PromotionType.fixedAmount ? 'fixedAmount' : 'percentage',
      'discountValue': discountValue,
      'minOrderPrice': minOrderPrice,
      'maxDiscountAmount': maxDiscountAmount,
      if (applicableHoursStart != null)
        'applicableHoursStart': applicableHoursStart,
      if (applicableHoursEnd != null) 'applicableHoursEnd': applicableHoursEnd,
      'applicableDays': applicableDays,
      if (validFrom != null) 'validFrom': Timestamp.fromDate(validFrom!),
      if (validUntil != null) 'validUntil': Timestamp.fromDate(validUntil!),
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'active': active,
    };
  }
}

// CreBy: MenBoyBMN
