// ============================================================================
// File: lib/features/home/presentation/widgets/upcoming_appointment_card.dart
// Mục đích: Card hiển thị lịch hẹn sắp diễn ra nhất ngay trên Trang chủ khách hàng.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/url_helper.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../models/appointment_model.dart';
import '../../../../models/chat_model.dart';

class UpcomingAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const UpcomingAppointmentCard({super.key, required this.appointment});

  String _calculateCountdown() {
    final now = DateTime.now();
    final start = appointment.startTimestamp;
    final diff = start.difference(now);

    if (diff.isNegative) {
      if (now.isBefore(appointment.endTimestamp)) {
        return 'Đang diễn ra ngay lúc này';
      }
      return 'Vừa mới hoàn tất';
    }

    if (diff.inMinutes < 60) {
      return 'Còn ${diff.inMinutes} phút nữa';
    } else if (diff.inHours < 24 && start.day == now.day) {
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      return 'Còn ${hours}h ${minutes > 0 ? '$minutes'
                'm' : ''} nữa';
    } else if (start.day == now.add(const Duration(days: 1)).day) {
      return 'Ngày mai lúc ${appointment.startTime}';
    } else {
      return 'Lúc ${appointment.startTime} ngày ${DateFormatter.formatShortDate(start)}';
    }
  }

  void _openChat(BuildContext context) {
    final chatId = ChatConversation.buildChatId(
      appointment.customerId,
      appointment.barberId,
    );
    context.push(
      '/chat/$chatId'
      '?otherUserId=${appointment.barberId}'
      '&otherUserName=${Uri.encodeComponent(appointment.barberName)}'
      '&customerId=${appointment.customerId}'
      '&customerName=${Uri.encodeComponent(appointment.customerName)}'
      '&barberId=${appointment.barberId}'
      '&barberName=${Uri.encodeComponent(appointment.barberName)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final countdownText = _calculateCountdown();

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.lg,
        AppDimensions.md,
        AppDimensions.lg,
        AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.borderRadiusLg,
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppDimensions.borderRadiusLg,
        child: InkWell(
          borderRadius: AppDimensions.borderRadiusLg,
          onTap: () => context.push('/customer/appointments'),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Title + Countdown + Status Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.alarm_rounded,
                        color: AppColors.accent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LỊCH HẸN SẮP TỚI',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: AppColors.accent,
                            ),
                          ),
                          Text(
                            countdownText,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: appointment.status.toStatusString()),
                  ],
                ),

                const Divider(height: 20),

                // Barber Info & Service details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppDimensions.borderRadiusMd,
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.barberName,
                            style: AppTextStyles.h4,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${appointment.serviceName} • ${DateFormatter.formatCurrency(appointment.price)}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${appointment.startTime} - ${appointment.endTime} (${DateFormatter.formatFullDate(appointment.startTimestamp)})',
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // AI Handshake mini badge if user selected AI style
                if (appointment.customerFaceShape != null &&
                    appointment.customerFaceShape!.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.aiHandshake.withValues(alpha: 0.1),
                      borderRadius: AppDimensions.borderRadiusSm,
                      border: Border.all(
                        color: AppColors.aiHandshake.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: AppColors.aiHandshake,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'AI Handshake: Dáng mặt ${appointment.customerFaceShape}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.aiHandshake,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppDimensions.md),

                // Action buttons: Chỉ đường, Chat, Gọi điện
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.directions_outlined, size: 16),
                        label: const Text(
                          'Chỉ đường',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.divider),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          UrlHelper.openMapDirections(
                            title: appointment.barberName,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.xs),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.chat_outlined, size: 16),
                        label: const Text(
                          'Nhắn tin',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: BorderSide(
                            color: AppColors.accent.withValues(alpha: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => _openChat(context),
                      ),
                    ),
                    if (appointment.barberPhone != null &&
                        appointment.barberPhone!.isNotEmpty) ...[
                      const SizedBox(width: AppDimensions.xs),
                      IconButton(
                        tooltip: 'Gọi điện',
                        icon: const Icon(
                          Icons.phone_in_talk_rounded,
                          color: AppColors.success,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.success.withValues(
                            alpha: 0.1,
                          ),
                          padding: const EdgeInsets.all(8),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          UrlHelper.makePhoneCall(appointment.barberPhone!);
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// CreBy: MenBoyBMN
