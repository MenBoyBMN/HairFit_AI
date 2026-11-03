// ============================================================================
// File: lib/features/appointments/presentation/widgets/barber_daily_earnings.dart
// Mục đích: Thẻ thống kê doanh thu và năng suất làm việc trong ngày của thợ cắt tóc.
// ============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../models/appointment_model.dart';

class BarberDailyEarnings extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final bool isAcceptingBookingsToday;
  final ValueChanged<bool> onToggleAcceptingBookings;
  final VoidCallback onQuickBreak;

  const BarberDailyEarnings({
    super.key,
    required this.appointments,
    required this.isAcceptingBookingsToday,
    required this.onToggleAcceptingBookings,
    required this.onQuickBreak,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStr = DateFormatter.toIsoDateString(now);

    final todayAppointments = appointments
        .where((a) => a.date == todayStr)
        .toList();

    final estimatedEarnings = todayAppointments
        .where((a) => a.isCompleted || a.isConfirmed)
        .fold<int>(0, (sum, a) => sum + a.price);

    final completedCount = todayAppointments.where((a) => a.isCompleted).length;
    final activeWaitingCount = todayAppointments
        .where((a) => a.isPending || a.isConfirmed)
        .length;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.lg,
        AppDimensions.md,
        AppDimensions.lg,
        AppDimensions.sm,
      ),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.surfaceDarkGradient],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppDimensions.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Date & Pause Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: AppDimensions.xs),
                    Expanded(
                      child: Text(
                        'TỔNG KẾT HÔM NAY (${DateFormatter.formatShortDate(now)})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: AppColors.accent,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.xs),
              // Switch Tạm ngưng nhận khách hôm nay
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isAcceptingBookingsToday ? 'Mở nhận khách' : 'Tạm ngưng',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isAcceptingBookingsToday
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Transform.scale(
                    scale: 0.75,
                    child: Switch(
                      value: isAcceptingBookingsToday,
                      activeThumbColor: AppColors.success,
                      inactiveThumbColor: AppColors.error,
                      onChanged: onToggleAcceptingBookings,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.sm),

          // Main revenue KPI display
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormatter.formatCurrency(estimatedEarnings),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'doanh thu ước tính',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.md),

          // 2 mini KPI boxes + Quick Break button (Responsive layout)
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 360;

              final kpiBoxes = Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: AppDimensions.borderRadiusSm,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.success,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$completedCount ca',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Text(
                                  'Đã hoàn tất',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 10,
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
                  ),
                  const SizedBox(width: AppDimensions.xs),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: AppDimensions.borderRadiusSm,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: AppColors.accent,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$activeWaitingCount ca',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Text(
                                  'Chờ phục vụ',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 10,
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
                  ),
                ],
              );

              final quickBreakButton = ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusSm,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.block_rounded, size: 14),
                label: const Text(
                  'Khóa giờ nghỉ',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                onPressed: onQuickBreak,
              );

              if (isCompact) {
                return Column(
                  children: [
                    kpiBoxes,
                    const SizedBox(height: AppDimensions.xs),
                    SizedBox(width: double.infinity, child: quickBreakButton),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: kpiBoxes),
                  const SizedBox(width: AppDimensions.xs),
                  quickBreakButton,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// CreBy: MenBoyBMN
