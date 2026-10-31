// ============================================================================
// File: lib/features/home/presentation/customer_home_screen.dart
// Mục đích: Màn hình giao diện (Screen) chính của tính năng home.
// Kết cấu:
//  - Sử dụng ConsumerWidget/StatefulWidget, kết nối UI với Provider để hiển thị trạng thái và xử lý sự kiện người dùng.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/seed_data_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/barber_profile_model.dart';
import '../../../providers/appointment_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../search_map/data/barber_repository.dart';
import 'widgets/my_ai_hair_profile_card.dart';
import 'widgets/upcoming_appointment_card.dart';

/// Màn hình chính dành cho khách hàng (Customer Home)
class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final upcomingAppointment = ref.watch(upcomingCustomerAppointmentProvider);
    final currentUser = ref.watch(authStateProvider).value;
    final favoriteBarbers = ref.watch(favoriteBarbersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.xs),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppDimensions.borderRadiusSm,
              ),
              child: const Icon(
                Icons.content_cut_rounded,
                size: 20,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            const Text('HairFit AI', style: AppTextStyles.h3),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Tin nhắn',
            icon: const Icon(Icons.chat_outlined, color: AppColors.accent),
            onPressed: () => context.push('/conversations'),
          ),
          IconButton(
            tooltip: 'Lịch hẹn của tôi',
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.push('/customer/appointments'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (upcomingAppointment != null)
                  UpcomingAppointmentCard(appointment: upcomingAppointment),
                MyAIHairProfileCard(
                  savedFaceShape: currentUser?.savedFaceShape,
                ),
                const SizedBox(height: AppDimensions.md),
                if (favoriteBarbers.isNotEmpty) ...[
                  _buildFavoriteBarbersSection(favoriteBarbers),
                  const SizedBox(height: AppDimensions.lg),
                ],
                _buildQuickActions(),
                const SizedBox(height: AppDimensions.xl),
                _buildHairstyleSection(),
                const SizedBox(height: AppDimensions.xl),
                _buildFeaturedBarbersSection(),
                const SizedBox(height: AppDimensions.xxxl),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 1) {
            context.push('/customer/search');
          } else if (index == 2) {
            context.push('/customer/appointments');
          } else if (index == 3) {
            context.push('/customer/profile');
          } else {
            setState(() {
              _currentNavIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Bản đồ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Lịch hẹn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteBarbersSection(List<BarberProfileModel> barbers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('Thợ Ruột Của Bạn', style: AppTextStyles.h3),
                  SizedBox(width: 6),
                  Icon(
                    Icons.favorite_rounded,
                    size: 18,
                    color: AppColors.error,
                  ),
                ],
              ),
              Text(
                '${barbers.length} thợ',
                style: AppTextStyles.caption.copyWith(color: AppColors.accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        SizedBox(
          height: 155,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
            scrollDirection: Axis.horizontal,
            itemCount: barbers.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.md),
            itemBuilder: (context, index) {
              final barber = barbers[index];
              return InkWell(
                borderRadius: AppDimensions.borderRadiusMd,
                onTap: () => context.push('/customer/barber/${barber.uid}'),
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppDimensions.borderRadiusMd,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          AppAvatar(
                            imageUrl: barber.avatarUrl,
                            name: barber.displayName,
                            size: 44,
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  barber.displayName,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  barber.address,
                                  style: AppTextStyles.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: AppColors.warning,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      barber.ratingAvg.toStringAsFixed(1),
                                      style: AppTextStyles.caption.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppDimensions.borderRadiusSm,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () =>
                              context.push('/customer/barber/${barber.uid}'),
                          child: const Text(
                            'Đặt lịch lại',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      child: Row(
        children: [
          Expanded(
            child: _ActionCard(
              title: 'AI Tư Vấn',
              subtitle: '100% On-Device',
              icon: Icons.face_retouching_natural_rounded,
              iconColor: AppColors.accent,
              onTap: () => context.push('/customer/ai-consult'),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: _ActionCard(
              title: 'Tìm Thợ Quanh Đây',
              subtitle: 'Đà Nẵng & GPS',
              icon: Icons.place_outlined,
              iconColor: AppColors.tertiary,
              onTap: () => context.push('/customer/search'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHairstyleSection() {
    final hairstyles = SeedDataService.sampleHairstyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kiểu Tóc Phổ Biến', style: AppTextStyles.h3),
              Text(
                '${hairstyles.length} kiểu',
                style: AppTextStyles.caption.copyWith(color: AppColors.accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        SizedBox(
          height: 190,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
            scrollDirection: Axis.horizontal,
            itemCount: hairstyles.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppDimensions.md),
            itemBuilder: (context, index) {
              final item = hairstyles[index];
              return InkWell(
                borderRadius: AppDimensions.borderRadiusMd,
                onTap: () =>
                    context.push('/customer/search?hairstyleId=${item.id}'),
                child: Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppDimensions.borderRadiusMd,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppDimensions.radiusMd),
                        ),
                        child: Image.network(
                          item.imageUrl,
                          height: 100,
                          width: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 100,
                                color: AppColors.inputBackground,
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppDimensions.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: AppTextStyles.labelMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.tags.take(2).join(', '),
                              style: AppTextStyles.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedBarbersSection() {
    final barbersAsync = ref.watch(approvedBarbersStreamProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Thợ Cắt Tóc Nổi Bật', style: AppTextStyles.h3),
              InkWell(
                onTap: () => context.push('/customer/search'),
                child: Text(
                  'Xem tất cả',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          barbersAsync.when(
            loading: () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
              child: Column(
                children: [
                  LoadingShimmer.card(height: 120),
                  const SizedBox(height: AppDimensions.md),
                  LoadingShimmer.card(height: 120),
                ],
              ),
            ),
            error: (err, _) => Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppDimensions.borderRadiusMd,
                border: Border.all(color: AppColors.divider),
              ),
              child: Text(
                'Không thể tải danh sách thợ: $err',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              ),
            ),
            data: (barbers) {
              if (barbers.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppDimensions.borderRadiusMd,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Chưa có salon nào được duyệt',
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Các tiệm tóc mới sau khi đăng ký và được Admin duyệt sẽ xuất hiện tại đây.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: barbers.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppDimensions.md),
                itemBuilder: (context, index) {
                  final barber = barbers[index];
                  return InkWell(
                    borderRadius: AppDimensions.borderRadiusMd,
                    onTap: () => context.push('/customer/barber/${barber.uid}'),
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppDimensions.borderRadiusMd,
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          AppAvatar(
                            imageUrl: barber.avatarUrl,
                            fallbackUrl: barber.coverUrl,
                            name: barber.displayName,
                            width: 72,
                            height: 72,
                            borderRadius: AppDimensions.borderRadiusSm,
                            fit: BoxFit.cover,
                            fallbackIcon: Icons.person,
                          ),
                          const SizedBox(width: AppDimensions.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        barber.displayName,
                                        style: AppTextStyles.h4,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const StatusBadge.approval(
                                      status: 'approved',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDimensions.xxs),
                                Text(
                                  barber.address,
                                  style: AppTextStyles.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppDimensions.xs),
                                Row(
                                  children: [
                                    RatingStars(
                                      rating: barber.ratingAvg,
                                      reviewCount: barber.ratingCount,
                                    ),
                                    const Spacer(),
                                    Text(
                                      DateFormatter.formatPriceRange(
                                        barber.priceMin,
                                        barber.priceMax,
                                      ),
                                      style: AppTextStyles.badgeText.copyWith(
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimensions.borderRadiusMd,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDimensions.borderRadiusMd,
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.sm),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CreBy: MenBoyBMN
