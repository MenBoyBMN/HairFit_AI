// ============================================================================
// File: lib/features/admin/presentation/widgets/admin_status_badge.dart
// Mục đích: Widget chip hiển thị trạng thái màu sắc chuẩn cho phân hệ Admin.
// ============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class AdminStatusBadge extends StatelessWidget {
  final String status;
  final String? customLabel;

  const AdminStatusBadge({super.key, required this.status, this.customLabel});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label = customLabel ?? status;

    switch (status.toLowerCase()) {
      case 'approved':
      case 'confirmed':
      case 'completed':
      case 'active':
        bg = AppColors.successLight;
        text = AppColors.success;
        label =
            customLabel ??
            (status == 'approved'
                ? 'Đã duyệt'
                : status == 'completed'
                ? 'Hoàn tất'
                : status == 'confirmed'
                ? 'Đã xác nhận'
                : 'Hoạt động');
        break;

      case 'pending':
        bg = AppColors.warningLight;
        text = AppColors.warning;
        label = customLabel ?? 'Chờ duyệt';
        break;

      case 'rejected':
      case 'cancelled':
      case 'blocked':
        bg = AppColors.errorLight;
        text = AppColors.error;
        label =
            customLabel ??
            (status == 'rejected'
                ? 'Từ chối'
                : status == 'cancelled'
                ? 'Đã hủy'
                : 'Đã khóa');
        break;

      case 'suspended':
        bg = Colors.deepOrange.shade50;
        text = Colors.deepOrange;
        label = customLabel ?? 'Tạm ngưng';
        break;

      default:
        bg = Colors.grey.shade100;
        text = Colors.grey.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: text.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// CreBy: MenBoyBMN
