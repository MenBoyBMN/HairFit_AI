// ============================================================================
// File: lib/features/admin/presentation/admin_shell_screen.dart
// Mục đích: Khung giao diện trung tâm (Admin Shell) cho toàn bộ phân hệ quản trị.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../providers/admin_stats_provider.dart';
import '../../../../providers/auth_provider.dart';
import 'admin_appointments_screen.dart';
import 'admin_barbers_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_hairstyles_screen.dart';
import 'admin_reviews_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_users_screen.dart';

class AdminShellScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const AdminShellScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends ConsumerState<AdminShellScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _onSelectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _refreshAllData() {
    ref.invalidate(adminDashboardStatsProvider);
    ref.invalidate(adminRecentPendingBarbersProvider);
    ref.invalidate(adminAppointmentsTodayProvider);
    ref.invalidate(pendingBarbersProvider);
    ref.invalidate(allBarbersProvider);
    ref.invalidate(allUsersProvider);
    ref.invalidate(allAppointmentsProvider);
    ref.invalidate(filteredAppointmentsProvider);
    ref.invalidate(allHairstylesProvider);
    ref.invalidate(allReviewsProvider);
    ref.invalidate(systemSettingsProvider);
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return 'Tổng Quan Hệ Thống';
      case 1:
        return 'Quản Lý Thợ & Salon';
      case 2:
        return 'Quản Lý Người Dùng';
      case 3:
        return 'Quản Lý Lịch Hẹn';
      case 4:
        return 'Danh Mục Kiểu Tóc AI';
      case 5:
        return 'Kiểm Duyệt Đánh Giá';
      case 6:
        return 'Cài Đặt & Seed Data';
      default:
        return 'Admin Portal';
    }
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return AdminDashboardScreen(
          onNavigateTab: (tabIdx) => _onSelectTab(tabIdx),
        );
      case 1:
        return const AdminBarbersScreen();
      case 2:
        return const AdminUsersScreen();
      case 3:
        return const AdminAppointmentsScreen();
      case 4:
        return const AdminHairstylesScreen();
      case 5:
        return const AdminReviewsScreen();
      case 6:
        return const AdminSettingsScreen();
      default:
        return const Center(child: Text('Trang không tồn tại'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;
    final pendingCount =
        ref.watch(pendingBarbersProvider).valueOrNull?.length ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              _getTabTitle(_currentIndex),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            scrolledUnderElevation: 1,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Làm mới toàn bộ dữ liệu',
                onPressed: _refreshAllData,
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Đăng xuất',
                onPressed: () => ref.read(authStateProvider.notifier).logout(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          drawer: isDesktop
              ? null
              : _buildDrawer(
                  currentUser?.displayName,
                  currentUser?.email,
                  pendingCount,
                ),
          body: Row(
            children: [
              if (isDesktop)
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onSelectTab,
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.primary,
                          radius: 22,
                          child: Icon(
                            Icons.admin_panel_settings,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'HairFit Admin',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  destinations: [
                    const NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard_rounded),
                      label: Text('Tổng quan'),
                    ),
                    NavigationRailDestination(
                      icon: Badge(
                        isLabelVisible: pendingCount > 0,
                        label: Text('$pendingCount'),
                        child: const Icon(Icons.content_cut_outlined),
                      ),
                      selectedIcon: Badge(
                        isLabelVisible: pendingCount > 0,
                        label: Text('$pendingCount'),
                        child: const Icon(Icons.content_cut_rounded),
                      ),
                      label: const Text('Thợ & Tiệm'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.people_outline_rounded),
                      selectedIcon: Icon(Icons.people_alt_rounded),
                      label: Text('Người dùng'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month_rounded),
                      label: Text('Lịch hẹn'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.face_retouching_natural_outlined),
                      selectedIcon: Icon(Icons.face_retouching_natural_rounded),
                      label: Text('Kiểu tóc AI'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.star_outline_rounded),
                      selectedIcon: Icon(Icons.star_rate_rounded),
                      label: Text('Đánh giá'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings_suggest_rounded),
                      label: Text('Cài đặt'),
                    ),
                  ],
                ),
              Expanded(child: _buildBody(_currentIndex)),
            ],
          ),
          bottomNavigationBar: isDesktop
              ? null
              : NavigationBar(
                  selectedIndex: _currentIndex > 2 ? 3 : _currentIndex,
                  onDestinationSelected: (idx) {
                    if (idx == 3) {
                      _scaffoldKey.currentState?.openDrawer();
                    } else {
                      _onSelectTab(idx);
                    }
                  },
                  destinations: [
                    const NavigationRequestDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard_rounded),
                      label: 'Tổng quan',
                    ),
                    NavigationRequestDestination(
                      icon: Badge(
                        isLabelVisible: pendingCount > 0,
                        label: Text('$pendingCount'),
                        child: const Icon(Icons.content_cut_outlined),
                      ),
                      selectedIcon: Badge(
                        isLabelVisible: pendingCount > 0,
                        label: Text('$pendingCount'),
                        child: const Icon(Icons.content_cut_rounded),
                      ),
                      label: 'Thợ & Tiệm',
                    ),
                    const NavigationRequestDestination(
                      icon: Icon(Icons.people_outline_rounded),
                      selectedIcon: Icon(Icons.people_alt_rounded),
                      label: 'Người dùng',
                    ),
                    const NavigationRequestDestination(
                      icon: Icon(Icons.menu_rounded),
                      selectedIcon: Icon(Icons.menu_open_rounded),
                      label: 'Xem thêm',
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildDrawer(String? name, String? email, int pendingCount) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.admin_panel_settings,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            accountName: Text(
              name ?? 'Quản Trị Viên',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(email ?? 'admin@hairfit.ai'),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  index: 0,
                  icon: Icons.dashboard_rounded,
                  title: 'Tổng quan hệ thống',
                ),
                _buildDrawerItem(
                  index: 1,
                  icon: Icons.content_cut_rounded,
                  title: 'Quản lý thợ cắt tóc',
                  badgeCount: pendingCount,
                ),
                _buildDrawerItem(
                  index: 2,
                  icon: Icons.people_alt_rounded,
                  title: 'Quản lý người dùng',
                ),
                _buildDrawerItem(
                  index: 3,
                  icon: Icons.calendar_month_rounded,
                  title: 'Quản lý lịch hẹn',
                ),
                const Divider(),
                _buildDrawerItem(
                  index: 4,
                  icon: Icons.face_retouching_natural_rounded,
                  title: 'Danh mục kiểu tóc AI',
                ),
                _buildDrawerItem(
                  index: 5,
                  icon: Icons.star_rate_rounded,
                  title: 'Kiểm duyệt đánh giá',
                ),
                _buildDrawerItem(
                  index: 6,
                  icon: Icons.settings_suggest_rounded,
                  title: 'Cài đặt & Seed Data',
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              ref.read(authStateProvider.notifier).logout();
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required int index,
    required IconData icon,
    required String title,
    int badgeCount = 0,
  }) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.accent : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.accent : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: badgeCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      selected: isSelected,
      onTap: () {
        Navigator.pop(context);
        _onSelectTab(index);
      },
    );
  }
}

class NavigationRequestDestination extends NavigationDestination {
  const NavigationRequestDestination({
    super.key,
    required super.icon,
    super.selectedIcon,
    required super.label,
  });
}

// CreBy: MenBoyBMN
