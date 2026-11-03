// ============================================================================
// File: lib/features/admin/presentation/admin_dashboard_screen.dart
// Mục đích: Màn hình Tổng quan Dashboard quản trị hệ thống HairFit AI.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../providers/admin_stats_provider.dart';
import 'widgets/admin_kpi_card.dart';
import 'widgets/admin_status_badge.dart';

class AdminDashboardScreen extends ConsumerWidget {
  final Function(int tabIndex)? onNavigateTab;

  const AdminDashboardScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);
    final recentPendingAsync = ref.watch(adminRecentPendingBarbersProvider);
    final appointmentsTodayAsync = ref.watch(adminAppointmentsTodayProvider);

    final todayFormatted = DateFormatter.formatFullDate(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminDashboardStatsProvider);
          ref.invalidate(adminRecentPendingBarbersProvider);
          ref.invalidate(adminAppointmentsTodayProvider);
          ref.invalidate(pendingBarbersProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header chào mừng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tổng Quan Vận Hành',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              todayFormatted,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () {
                          ref.invalidate(adminDashboardStatsProvider);
                          ref.invalidate(adminRecentPendingBarbersProvider);
                          ref.invalidate(adminAppointmentsTodayProvider);
                          ref.invalidate(pendingBarbersProvider);
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        tooltip: 'Làm mới số liệu',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // KPI CARDS GRID
                  statsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Không thể tải số liệu thống kê: $err',
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                    data: (stats) {
                      return Column(
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 600;
                              final crossAxisCount = isWide ? 4 : 2;
                              final childAspectRatio = isWide ? 1.4 : 1.25;

                              return GridView.count(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: childAspectRatio,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  AdminKpiCard(
                                    title: 'Hồ sơ chờ duyệt',
                                    value: '${stats.pendingBarbers}',
                                    subtitle: stats.pendingBarbers > 0
                                        ? 'Cần xử lý ngay'
                                        : '${stats.approvedBarbers} tiệm hoạt động',
                                    icon: Icons.pending_actions_rounded,
                                    color: stats.pendingBarbers > 0
                                        ? AppColors.warning
                                        : AppColors.success,
                                    onTap: () => onNavigateTab?.call(1),
                                  ),
                                  AdminKpiCard(
                                    title: 'Lịch hẹn hôm nay',
                                    value: '${stats.totalAppointmentsToday}',
                                    subtitle:
                                        '${stats.confirmedAppointmentsToday} xác nhận · ${stats.pendingAppointmentsToday} chờ',
                                    icon: Icons.calendar_today_rounded,
                                    color: AppColors.info,
                                    onTap: () => onNavigateTab?.call(3),
                                  ),
                                  AdminKpiCard(
                                    title: 'Tổng người dùng',
                                    value: '${stats.totalUsers}',
                                    subtitle:
                                        '${stats.totalBarbers} thợ · ${stats.totalCustomers} khách',
                                    icon: Icons.people_alt_rounded,
                                    color: AppColors.primary,
                                    onTap: () => onNavigateTab?.call(2),
                                  ),
                                  AdminKpiCard(
                                    title: 'Tỷ lệ hoàn tất',
                                    value:
                                        '${stats.completionRate.toStringAsFixed(1)}%',
                                    subtitle:
                                        '${stats.completedAppointmentsToday} ca hoàn tất hôm nay',
                                    icon: Icons.verified_rounded,
                                    color: AppColors.success,
                                    onTap: () => onNavigateTab?.call(3),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          // Hàng 2: Thống kê Doanh thu (Responsive)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isNarrow = constraints.maxWidth < 460;
                              final revenueTodayCard = AdminKpiCard(
                                title: 'Doanh thu hôm nay',
                                value: DateFormatter.formatCurrency(
                                  stats.revenueToday,
                                ),
                                subtitle:
                                    'Dự kiến: ${DateFormatter.formatCurrency(stats.expectedRevenueToday)}',
                                icon: Icons.payments_rounded,
                                color: Colors.teal.shade700,
                                onTap: () => onNavigateTab?.call(3),
                              );
                              final revenueTotalCard = AdminKpiCard(
                                title: 'Tổng doanh thu hoàn tất',
                                value: DateFormatter.formatCurrency(
                                  stats.totalRevenue,
                                ),
                                subtitle:
                                    'Tổng ${stats.totalAppointments} lịch toàn hệ thống',
                                icon: Icons.account_balance_wallet_rounded,
                                color: AppColors.accent,
                                onTap: () => onNavigateTab?.call(3),
                              );

                              if (isNarrow) {
                                return Column(
                                  children: [
                                    revenueTodayCard,
                                    const SizedBox(height: 12),
                                    revenueTotalCard,
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(child: revenueTodayCard),
                                  const SizedBox(width: 12),
                                  Expanded(child: revenueTotalCard),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          // Hàng 3: Kiểu tóc & Đánh giá (Responsive)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isNarrow = constraints.maxWidth < 460;
                              final hairstylesCard = AdminKpiCard(
                                title: 'Danh mục kiểu tóc',
                                value: '${stats.totalHairstyles}',
                                subtitle: 'Kiểu tóc mẫu AI',
                                icon: Icons.content_cut_rounded,
                                color: Colors.purple.shade700,
                                onTap: () => onNavigateTab?.call(4),
                              );
                              final reviewsCard = AdminKpiCard(
                                title: 'Đánh giá hệ thống',
                                value: '${stats.totalReviews}',
                                subtitle: 'Lượt phản hồi khách hàng',
                                icon: Icons.star_half_rounded,
                                color: Colors.amber.shade800,
                                onTap: () => onNavigateTab?.call(5),
                              );

                              if (isNarrow) {
                                return Column(
                                  children: [
                                    hairstylesCard,
                                    const SizedBox(height: 12),
                                    reviewsCard,
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(child: hairstylesCard),
                                  const SizedBox(width: 12),
                                  Expanded(child: reviewsCard),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // DANH SÁCH THỢ CHỜ DUYỆT GẦN ĐÂY
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Hồ Sơ Thợ Cần Duyệt Gần Đây',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => onNavigateTab?.call(1),
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  recentPendingAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => Text('Lỗi: $err'),
                    data: (pendingBarbers) {
                      if (pendingBarbers.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: AppColors.success,
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Không có hồ sơ thợ nào đang chờ duyệt!',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pendingBarbers.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final barber = pendingBarbers[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Row(
                              children: [
                                AppAvatar(
                                  imageUrl: barber.avatarUrl,
                                  name: barber.displayName,
                                  size: 44,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        barber.displayName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        barber.address,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filledTonal(
                                  onPressed: () async {
                                    await ref
                                        .read(adminControllerProvider.notifier)
                                        .approveBarber(barber.uid);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Đã duyệt nhanh tiệm ${barber.displayName}!',
                                          ),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.check_rounded,
                                    color: AppColors.success,
                                    size: 18,
                                  ),
                                  tooltip: 'Duyệt nhanh',
                                ),
                                const SizedBox(width: 4),
                                FilledButton.tonal(
                                  onPressed: () => onNavigateTab?.call(1),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  child: const Text('Xem xét'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // LỊCH HẸN HÔM NAY
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Lịch Hẹn Hôm Nay',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => onNavigateTab?.call(3),
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  appointmentsTodayAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => Text('Lỗi: $err'),
                    data: (appointments) {
                      if (appointments.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.event_available_rounded,
                                color: AppColors.info,
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Hôm nay chưa có lịch hẹn nào được ghi nhận.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: appointments.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final app = appointments[index];
                          return InkWell(
                            onTap: () => onNavigateTab?.call(3),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.infoLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      app.startTime,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.info,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${app.customerName} ➔ ${app.barberName}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Dịch vụ: ${app.serviceName} (${DateFormatter.formatCurrency(app.price)})',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AdminStatusBadge(
                                    status: app.status.toStatusString(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// CreBy: MenBoyBMN
