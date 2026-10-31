import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/url_helper.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../models/appointment_model.dart';
import 'ai_haircut_handshake_card.dart';

/// Card hiển thị thông tin lịch hẹn cắt tóc (Task 4.14)
///
/// Hỗ trợ cả 2 chế độ hiển thị:
/// - Khách hàng (isBarberView = false): Hiển thị tên thợ, cho phép hủy lịch trước 30 phút
/// - Thợ cắt tóc (isBarberView = true): Hiển thị tên khách, nút Tiếp nhận, Từ chối, Hoàn tất
class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final bool isBarberView;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;
  final VoidCallback? onComplete;
  final VoidCallback? onRate;
  final VoidCallback? onChat;
  final VoidCallback? onReschedule;
  final void Function(String note)? onUpdatePrivateNote;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.isBarberView = false,
    this.onCancel,
    this.onConfirm,
    this.onReject,
    this.onComplete,
    this.onRate,
    this.onChat,
    this.onReschedule,
    this.onUpdatePrivateNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.borderRadiusMd,
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Thời gian & Status Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusMd),
                topRight: Radius.circular(AppDimensions.radiusMd),
              ),
              border: const Border(
                bottom: BorderSide(color: AppColors.divider, width: 0.8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: AppDimensions.xs),
                      Expanded(
                        child: Text(
                          '${appointment.startTime} - ${appointment.endTime}, ${DateFormatter.formatShortDate(appointment.startTimestamp)}',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.xs),
                StatusBadge.appointment(
                  status: appointment.status.toStatusString(),
                ),
              ],
            ),
          ),

          // Body: Thông tin đối tác, dịch vụ và giá
          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isBarberView
                            ? Icons.person_outline_rounded
                            : Icons.storefront_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBarberView
                                ? 'Khách hàng: ${appointment.customerName.isEmpty ? 'Khách hàng' : appointment.customerName}'
                                : (appointment.barberName.isEmpty
                                      ? 'Thợ cắt tóc'
                                      : appointment.barberName),
                            style: AppTextStyles.h4,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Dịch vụ: ${appointment.serviceName.isEmpty ? 'Dịch vụ cắt tóc' : appointment.serviceName} (${appointment.durationMinutes} phút)',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.xs),
                    Text(
                      DateFormatter.formatCurrency(appointment.price),
                      style: AppTextStyles.h4.copyWith(color: AppColors.accent),
                    ),
                  ],
                ),

                // Lý do từ chối nếu có
                if (appointment.isRejected &&
                    appointment.rejectReason != null &&
                    appointment.rejectReason!.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimensions.sm),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: AppDimensions.borderRadiusSm,
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.cancel_outlined,
                          size: 16,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Lý do từ chối: ${appointment.rejectReason}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Ghi chú nếu có
                if (appointment.note.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimensions.sm),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppDimensions.borderRadiusSm,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.sticky_note_2_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Ghi chú: ${appointment.note}',
                            style: AppTextStyles.caption.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // AI Handshake Card (Nếu có thông tin tư vấn AI)
                if (appointment.customerFaceShape != null &&
                    appointment.customerFaceShape!.isNotEmpty) ...[
                  AIHaircutHandshakeCard(
                    faceShape: appointment.customerFaceShape!,
                    stylingTip: appointment.aiStylingTip,
                    hairstyleImageUrl: appointment.hairstyleImageUrl,
                  ),
                ],

                // Ghi chú riêng của thợ về khách quen (Client Notes / Mini CRM - Phase 5)
                if (isBarberView) ...[
                  const SizedBox(height: AppDimensions.sm),
                  _buildBarberPrivateNoteSection(context),
                ],

                // Action Buttons cho Customer hoặc Barber
                const SizedBox(height: AppDimensions.sm),
                _buildActionButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (!isBarberView) {
      // Giao diện Khách hàng: Có thể hủy nếu status là pending/confirmed và >= 30m trước giờ hẹn
      if (appointment.isPending || appointment.isConfirmed) {
        final canCancel = appointment.canCustomerCancel();
        return Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppDimensions.sm,
            runSpacing: AppDimensions.xs,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: BorderSide(
                    color: AppColors.accent.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.xs,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusSm,
                  ),
                ),
                icon: const Icon(Icons.directions_outlined, size: 15),
                label: const Text('Chỉ đường', style: TextStyle(fontSize: 13)),
                onPressed: () {
                  UrlHelper.openMapDirections(title: appointment.barberName);
                },
              ),
              if (appointment.barberPhone != null &&
                  appointment.barberPhone!.isNotEmpty)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: const BorderSide(color: AppColors.success),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                      vertical: AppDimensions.xs,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusSm,
                    ),
                  ),
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 15),
                  label: const Text('Gọi tiệm', style: TextStyle(fontSize: 13)),
                  onPressed: () =>
                      UrlHelper.makePhoneCall(appointment.barberPhone!),
                ),
              if (onChat != null)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                      vertical: AppDimensions.xs,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusSm,
                    ),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                  label: const Text('Nhắn tin', style: TextStyle(fontSize: 13)),
                  onPressed: onChat,
                ),
              if (onReschedule != null && canCancel)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                      vertical: AppDimensions.xs,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusSm,
                    ),
                  ),
                  icon: const Icon(Icons.event_repeat_rounded, size: 16),
                  label: const Text(
                    'Đổi giờ hẹn',
                    style: TextStyle(fontSize: 13),
                  ),
                  onPressed: onReschedule,
                ),
              if (canCancel)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                      vertical: AppDimensions.xs,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusSm,
                    ),
                  ),
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text(
                    'Hủy lịch hẹn',
                    style: TextStyle(fontSize: 13),
                  ),
                  onPressed: onCancel,
                )
              else
                const Text(
                  'Không thể hủy (quá sát giờ hẹn < 30 phút)',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        );
      } else if (appointment.isCompleted) {
        return Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppDimensions.sm,
            runSpacing: AppDimensions.xs,
            children: [
              if (onChat != null)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                      vertical: AppDimensions.xs,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusSm,
                    ),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                  label: const Text('Nhắn tin', style: TextStyle(fontSize: 13)),
                  onPressed: onChat,
                ),
              if (appointment.rating == null && onRate != null)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                      vertical: AppDimensions.xs,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusSm,
                    ),
                  ),
                  icon: const Icon(Icons.star_outline_rounded, size: 16),
                  label: const Text('Đánh giá', style: TextStyle(fontSize: 13)),
                  onPressed: onRate,
                ),
            ],
          ),
        );
      }
      return onChat != null
          ? Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.xs,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusSm,
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                label: const Text('Nhắn tin', style: TextStyle(fontSize: 13)),
                onPressed: onChat,
              ),
            )
          : const SizedBox.shrink();
    }

    // Giao diện Thợ cắt tóc
    if (appointment.isPending) {
      return Align(
        alignment: Alignment.centerRight,
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppDimensions.sm,
          runSpacing: AppDimensions.xs,
          children: [
            if (appointment.customerPhone != null &&
                appointment.customerPhone!.isNotEmpty)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.success,
                  side: const BorderSide(color: AppColors.success),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.xs,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusSm,
                  ),
                ),
                icon: const Icon(Icons.phone_in_talk_rounded, size: 15),
                label: const Text('Gọi khách', style: TextStyle(fontSize: 13)),
                onPressed: () =>
                    UrlHelper.makePhoneCall(appointment.customerPhone!),
              ),
            if (onChat != null)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.xs,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusSm,
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                label: const Text('Nhắn tin', style: TextStyle(fontSize: 13)),
                onPressed: onChat,
              ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.xs,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.borderRadiusSm,
                ),
              ),
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('Từ chối', style: TextStyle(fontSize: 13)),
              onPressed: onReject,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.xs,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.borderRadiusSm,
                ),
              ),
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text('Tiếp nhận', style: TextStyle(fontSize: 13)),
              onPressed: onConfirm,
            ),
          ],
        ),
      );
    } else if (appointment.isConfirmed) {
      return Align(
        alignment: Alignment.centerRight,
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppDimensions.sm,
          runSpacing: AppDimensions.xs,
          children: [
            if (appointment.customerPhone != null &&
                appointment.customerPhone!.isNotEmpty)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.success,
                  side: const BorderSide(color: AppColors.success),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.xs,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusSm,
                  ),
                ),
                icon: const Icon(Icons.phone_in_talk_rounded, size: 15),
                label: const Text('Gọi khách', style: TextStyle(fontSize: 13)),
                onPressed: () =>
                    UrlHelper.makePhoneCall(appointment.customerPhone!),
              ),
            if (onChat != null)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.xs,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusSm,
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
                label: const Text('Nhắn tin', style: TextStyle(fontSize: 13)),
                onPressed: onChat,
              ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.xs,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.borderRadiusSm,
                ),
              ),
              icon: const Icon(Icons.task_alt_rounded, size: 16),
              label: const Text(
                'Hoàn tất dịch vụ',
                style: TextStyle(fontSize: 13),
              ),
              onPressed: onComplete,
            ),
          ],
        ),
      );
    }

    if (onChat != null) {
      return Align(
        alignment: Alignment.centerRight,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.xs,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.borderRadiusSm,
            ),
          ),
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
          label: const Text('Nhắn tin', style: TextStyle(fontSize: 13)),
          onPressed: onChat,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBarberPrivateNoteSection(BuildContext context) {
    final hasNote =
        appointment.barberPrivateNote != null &&
        appointment.barberPrivateNote!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: AppDimensions.borderRadiusSm,
        border: Border.all(
          color: hasNote
              ? AppColors.primary.withValues(alpha: 0.25)
              : AppColors.divider,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasNote ? Icons.assignment_outlined : Icons.note_add_outlined,
            size: 16,
            color: hasNote ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ghi chú thợ (Bí mật riêng):',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    InkWell(
                      onTap: () => _showEditPrivateNoteDialog(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        child: Text(
                          hasNote ? 'Sửa' : '+ Thêm ghi chú',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: hasNote
                                ? AppColors.accent
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  hasNote
                      ? appointment.barberPrivateNote!
                      : 'Chưa có ghi chú (Lưu sở thích, cữ fade, kiểu vuốt...)',
                  style: TextStyle(
                    fontSize: 12,
                    color: hasNote
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontStyle: hasNote ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPrivateNoteDialog(BuildContext context) {
    final controller = TextEditingController(
      text: appointment.barberPrivateNote ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusMd,
        ),
        title: Row(
          children: [
            const Icon(Icons.edit_note_rounded, color: AppColors.accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ghi chú: ${appointment.customerName}',
                style: AppTextStyles.h4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ghi chú riêng tư chỉ thợ nhìn thấy. Giúp bạn nhớ thói quen, cữ tông đơ hoặc sở thích tạo kiểu của khách.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.md),
            TextField(
              controller: controller,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'VD: Da đầu nhạy cảm, thích cạo sát mai, dùng sáp mùi gỗ...',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: AppDimensions.borderRadiusSm,
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              if (onUpdatePrivateNote != null) {
                onUpdatePrivateNote!(controller.text);
              }
            },
            child: const Text('Lưu ghi chú'),
          ),
        ],
      ),
    );
  }
}

// CreBy: MenBoyBMN
