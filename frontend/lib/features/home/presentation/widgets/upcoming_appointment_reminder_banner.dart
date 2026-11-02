// ============================================================================
// File: lib/features/home/presentation/widgets/upcoming_appointment_reminder_banner.dart
// Mục đích: Widget hiển thị banner nhắc lịch hẹn tự động (Automated Appointment Reminder Banner).
// Kết cấu:
//  - Banner nổi bật hiển thị thời gian đếm ngược, thông tin thợ và các nút chỉ đường, gọi điện, nhắn chat.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/url_helper.dart';
import '../../../../providers/reminder_provider.dart';

/// Banner nhắc lịch hẹn tự động nổi bật hiển thị đếm ngược và hành động nhanh
class UpcomingAppointmentReminderBanner extends ConsumerWidget {
  const UpcomingAppointmentReminderBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeNotice = ref.watch(activeAutoReminderProvider);
    if (activeNotice == null) return const SizedBox.shrink();

    final isUrgent = activeNotice.isUrgent;
    final bannerBg = isUrgent
        ? const LinearGradient(
            colors: [
              AppColors.urgentRedGradientStart,
              AppColors.urgentRedGradientEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [AppColors.primary, AppColors.surfaceDarkGradient],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.lg,
        AppDimensions.md,
        AppDimensions.lg,
        AppDimensions.xs,
      ),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        gradient: bannerBg,
        borderRadius: AppDimensions.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: (isUrgent ? AppColors.error : AppColors.primary).withValues(
              alpha: 0.3,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Biểu tượng chuông + Tiêu đề đếm ngược + Nút đóng
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppDimensions.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeNotice.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      activeNotice.body,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.white70,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Tắt nhắc nhở này',
                onPressed: () {
                  ref
                      .read(reminderNotifierProvider.notifier)
                      .dismissReminder(activeNotice.id);
                },
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.sm),

          // Thông tin thợ & thời gian
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: AppDimensions.borderRadiusSm,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeNotice.barberName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Dịch vụ: ${activeNotice.serviceName} • Khung giờ: ${activeNotice.timeText}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.sm),

          // Nút hành động nhanh: Chỉ đường, Gọi điện, Xem lịch hẹn (Wrap chống tràn)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusSm,
                  ),
                ),
                icon: const Icon(Icons.directions_outlined, size: 14),
                label: const Text(
                  'Chỉ đường',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  UrlHelper.openMapDirections(title: activeNotice.barberName);
                },
              ),
              if (activeNotice.barberPhone.isNotEmpty)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusSm,
                    ),
                  ),
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 14),
                  label: const Text(
                    'Gọi tiệm',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    UrlHelper.makePhoneCall(activeNotice.barberPhone);
                  },
                ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusSm,
                  ),
                ),
                icon: const Icon(Icons.calendar_month_outlined, size: 14),
                label: const Text(
                  'Xem lịch',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  context.push('/customer/appointments');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// CreBy: MenBoyBMN
