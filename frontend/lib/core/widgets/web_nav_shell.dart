// ============================================================================
// File: lib/core/widgets/web_nav_shell.dart
// Mục đích: Thanh điều hướng Glassmorphic Top Navbar dành cho giao diện Web / Desktop.
// Kết cấu:
//  - Hỗ trợ điều hướng nhanh cho cả Khách hàng (Customer) và Thợ cắt tóc (Barber).
//  - Áp dụng hiệu ứng kính mờ (BackdropFilter) và bóng đổ không trọng lực Antigravity.
// ============================================================================

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import 'app_avatar.dart';

/// Mục điều hướng trên thanh Top Navbar Web
class WebNavItem {
  final String label;
  final IconData icon;
  final String route;

  const WebNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

/// Thanh điều hướng Top Navbar chuẩn Web / Desktop với hiệu ứng Glassmorphism
class WebTopNavBar extends ConsumerWidget implements PreferredSizeWidget {
  final String currentRoute;
  final List<Widget>? extraActions;
  final bool? isBarber;

  const WebTopNavBar({
    super.key,
    required this.currentRoute,
    this.extraActions,
    this.isBarber,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  static const List<WebNavItem> customerItems = [
    WebNavItem(
      label: 'Trang chủ',
      icon: Icons.home_rounded,
      route: '/customer/home',
    ),
    WebNavItem(
      label: 'Bản đồ & Salon',
      icon: Icons.explore_rounded,
      route: '/customer/search',
    ),
    WebNavItem(
      label: 'Tư vấn Kiểu tóc',
      icon: Icons.auto_awesome_rounded,
      route: '/customer/ai-consult',
    ),
    WebNavItem(
      label: 'Lịch hẹn',
      icon: Icons.calendar_month_rounded,
      route: '/customer/appointments',
    ),
    WebNavItem(
      label: 'Tin nhắn',
      icon: Icons.forum_rounded,
      route: '/conversations',
    ),
  ];

  static const List<WebNavItem> barberItems = [
    WebNavItem(
      label: 'Quản lý Lịch hẹn',
      icon: Icons.event_note_rounded,
      route: '/barber/appointments',
    ),
    WebNavItem(
      label: 'Hộp thư Khách',
      icon: Icons.forum_rounded,
      route: '/conversations',
    ),
    WebNavItem(
      label: 'Cấu hình Salon',
      icon: Icons.storefront_rounded,
      route: '/barber/profile-edit',
    ),
    WebNavItem(
      label: 'Tài khoản',
      icon: Icons.person_rounded,
      route: '/barber/profile',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;
    final effectiveIsBarber =
        isBarber ?? (currentUser?.role == UserRole.barber);
    final items = effectiveIsBarber ? barberItems : customerItems;
    final badgeText = effectiveIsBarber ? 'BARBER STUDIO' : 'WEB PORTAL';

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: preferredSize.height,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.88),
            border: const Border(
              bottom: BorderSide(color: AppColors.divider, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1320),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.lg,
                ),
                child: Row(
                  children: [
                    // 1. Brand Logo
                    InkWell(
                      borderRadius: AppDimensions.borderRadiusSm,
                      onTap: () {
                        context.go(
                          effectiveIsBarber
                              ? '/barber/appointments'
                              : '/customer/home',
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: AppDimensions.borderRadiusSm,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.content_cut_rounded,
                              size: 20,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          const Text('HairFit AI', style: AppTextStyles.h3),
                          const SizedBox(width: AppDimensions.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              badgeText,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accent,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.xl),

                    // 2. Navigation Links
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: items.map((item) {
                            final isSelected =
                                currentRoute == item.route ||
                                (item.route != '/customer/home' &&
                                    currentRoute.startsWith(item.route));
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: _NavTabButton(
                                item: item,
                                isSelected: isSelected,
                                onTap: () {
                                  if (currentRoute != item.route) {
                                    context.push(item.route);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // 3. Extra Actions & User Profile Pill
                    ...?extraActions,
                    const SizedBox(width: AppDimensions.sm),
                    if (currentUser != null)
                      InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          context.push(
                            effectiveIsBarber
                                ? '/barber/profile'
                                : '/customer/profile',
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppAvatar(
                                imageUrl: currentUser.avatarUrl,
                                name: currentUser.displayName,
                                size: 28,
                                shape: BoxShape.circle,
                              ),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 130,
                                ),
                                child: Text(
                                  currentUser.displayName.isNotEmpty
                                      ? currentUser.displayName
                                      : currentUser.email,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTabButton extends StatefulWidget {
  final WebNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTabButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavTabButton> createState() => _NavTabButtonState();
}

class _NavTabButtonState extends State<_NavTabButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isSelected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary
                : (_hovered
                      ? AppColors.primary.withValues(alpha: 0.06)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.item.icon,
                size: 18,
                color: active
                    ? AppColors.accent
                    : (_hovered ? AppColors.primary : AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              Text(
                widget.item.label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  color: active
                      ? Colors.white
                      : (_hovered
                            ? AppColors.primary
                            : AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// CreBy: MenBoyBMN
