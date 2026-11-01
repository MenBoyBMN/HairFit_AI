// ============================================================================
// File: lib/features/admin/presentation/admin_barbers_screen.dart
// Mục đích: Màn hình quản lý toàn diện đối tác thợ cắt tóc & salon cho Admin.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../models/barber_profile_model.dart';
import '../../../../providers/admin_provider.dart';
import 'approve_barbers_screen.dart';
import 'widgets/admin_status_badge.dart';

class AdminBarbersScreen extends ConsumerStatefulWidget {
  const AdminBarbersScreen({super.key});

  @override
  ConsumerState<AdminBarbersScreen> createState() => _AdminBarbersScreenState();
}

class _AdminBarbersScreenState extends ConsumerState<AdminBarbersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatusFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const Map<String, String> _dayLabels = {
    'mon': 'Thứ Hai',
    'tue': 'Thứ Ba',
    'wed': 'Thứ Tư',
    'thu': 'Thứ Năm',
    'fri': 'Thứ Sáu',
    'sat': 'Thứ Bảy',
    'sun': 'Chủ Nhật',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showEditBarberDialog(BarberProfileModel barber) {
    final messenger = ScaffoldMessenger.of(context);
    final nameCtrl = TextEditingController(text: barber.displayName);
    final addressCtrl = TextEditingController(text: barber.address);
    final phoneCtrl = TextEditingController(text: barber.phone ?? '');
    final bioCtrl = TextEditingController(text: barber.bio);
    final latCtrl = TextEditingController(
      text: barber.location.latitude.toString(),
    );
    final lngCtrl = TextEditingController(
      text: barber.location.longitude.toString(),
    );
    bool isAccepting = barber.isAcceptingBookingsToday;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Chỉnh sửa tiệm: ${barber.displayName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên tiệm / Thợ *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.storefront_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ tiệm *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại liên hệ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bioCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Giới thiệu tiệm',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: latCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Vĩ độ (Lat)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: lngCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Kinh độ (Lng)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Nhận khách đặt lịch hôm nay',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  value: isAccepting,
                  onChanged: (val) {
                    setDialogState(() => isAccepting = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final address = addressCtrl.text.trim();
                final lat = double.tryParse(latCtrl.text.trim());
                final lng = double.tryParse(lngCtrl.text.trim());
                if (name.isEmpty ||
                    address.isEmpty ||
                    lat == null ||
                    lng == null) {
                  return;
                }
                Navigator.pop(ctx);
                await ref
                    .read(adminControllerProvider.notifier)
                    .updateBarberProfileAdmin(
                      barber.uid,
                      displayName: name,
                      address: address,
                      phone: phoneCtrl.text.trim(),
                      bio: bioCtrl.text.trim(),
                      latitude: lat,
                      longitude: lng,
                      isAcceptingBookingsToday: isAccepting,
                    );
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Đã cập nhật thông tin tiệm thành công!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Lưu thay đổi'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteBarber(BarberProfileModel barber) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa hồ sơ tiệm tóc?'),
        content: Text(
          'Hồ sơ tiệm "${barber.displayName}" sẽ bị xóa khỏi danh sách tiệm cắt tóc trên bản đồ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa hồ sơ'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(adminControllerProvider.notifier)
          .deleteBarberProfile(barber.uid);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Đã xóa hồ sơ tiệm ${barber.displayName}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showBarber360Sheet(BarberProfileModel barber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final historyAsync = ref.watch(
            userAppointmentsHistoryProvider((uid: barber.uid, isBarber: true)),
          );

          return DraggableScrollableSheet(
            initialChildSize: 0.78,
            maxChildSize: 0.92,
            minChildSize: 0.5,
            expand: false,
            builder: (_, scrollController) => Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      AppAvatar(
                        imageUrl: barber.avatarUrl,
                        name: barber.displayName,
                        size: 56,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              barber.displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              barber.address,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                AdminStatusBadge(status: barber.approvalStatus),
                                const SizedBox(width: 8),
                                Text(
                                  'UID: ${barber.uid}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (barber.bio.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        barber.bio,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Thông tin vận hành nhanh
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatMiniCard(
                          label: 'Đánh giá',
                          value:
                              '${barber.ratingAvg.toStringAsFixed(1)} ⭐ (${barber.ratingCount})',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatMiniCard(
                          label: 'Nhận khách hôm nay',
                          value: barber.isAcceptingBookingsToday
                              ? 'Đang mở cửa'
                              : 'Tạm ngưng nhận',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Danh sách dịch vụ
                  Text(
                    'Bảng Giá Dịch Vụ (${barber.services.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (barber.services.isEmpty)
                    const Text(
                      'Thợ chưa thiết lập bảng giá dịch vụ.',
                      style: TextStyle(color: AppColors.textSecondary),
                    )
                  else
                    ...barber.services.map(
                      (s) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.cut,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        title: Text(
                          s.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${s.durationMinutes} phút · ${s.active ? "Đang hoạt động" : "Tạm ngưng"}',
                        ),
                        trailing: Text(
                          DateFormatter.formatCurrency(s.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  const Divider(height: 24),

                  // Giờ làm việc trong tuần
                  const Text(
                    'Giờ Làm Việc Định Kỳ',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'].map((d) {
                    final info = barber.workingHours[d];
                    final isClosed = info == null || info.closed;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _dayLabels[d] ?? d,
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            isClosed
                                ? 'Nghỉ / Đóng cửa'
                                : '${info.open} - ${info.close}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isClosed
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 24),

                  // Lịch sử ca hẹn tại tiệm
                  const Text(
                    'Lịch Sử Lịch Hẹn Tại Tiệm',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  historyAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => Text('Lỗi: $err'),
                    data: (apps) {
                      if (apps.isEmpty) {
                        return const Text(
                          'Chưa có lịch hẹn nào tại tiệm này.',
                          style: TextStyle(color: AppColors.textSecondary),
                        );
                      }
                      final completedRevenue = apps
                          .where((a) => a.isCompleted)
                          .fold<int>(0, (sum, a) => sum + a.price);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tổng ${apps.length} lịch hẹn · Doanh thu hoàn tất: ${DateFormatter.formatCurrency(completedRevenue)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...apps
                              .take(5)
                              .map(
                                (a) => ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    '${a.customerName} — ${a.serviceName}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${a.date} · ${a.startTime} (${DateFormatter.formatCurrency(a.price)})',
                                  ),
                                  trailing: AdminStatusBadge(
                                    status: a.status.toStatusString(),
                                  ),
                                ),
                              ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatMiniCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        ref.watch(pendingBarbersProvider).valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Hồ sơ cần duyệt'),
                    if (pendingCount > 0) ...[
                      const SizedBox(width: 8),
                      Badge(label: Text('$pendingCount')),
                    ],
                  ],
                ),
              ),
              const Tab(text: 'Danh bạ tất cả thợ'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const ApproveBarbersScreen(embedded: true),
          _buildAllBarbersTab(),
        ],
      ),
    );
  }

  Widget _buildAllBarbersTab() {
    final barbersAsync = ref.watch(allBarbersProvider(_selectedStatusFilter));

    return Column(
      children: [
        // Thanh tìm kiếm & bộ lọc
        Container(
          padding: const EdgeInsets.all(12),
          color: AppColors.surface,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên tiệm, địa chỉ, SĐT...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim().toLowerCase());
                },
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Tất cả', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Đã duyệt', 'approved'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Chờ duyệt', 'pending'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Tạm ngưng', 'suspended'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Từ chối', 'rejected'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Danh sách thợ
        Expanded(
          child: barbersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Text(
                'Lỗi khi tải danh sách: $err',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
            data: (barbers) {
              final filtered = barbers.where((b) {
                if (_searchQuery.isEmpty) return true;
                return b.displayName.toLowerCase().contains(_searchQuery) ||
                    b.address.toLowerCase().contains(_searchQuery) ||
                    (b.phone?.toLowerCase().contains(_searchQuery) ?? false);
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Không tìm thấy thợ cắt tóc phù hợp.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final b = filtered[idx];
                  final isApproved = b.approvalStatus == 'approved';

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppAvatar(
                              imageUrl: b.avatarUrl,
                              name: b.displayName,
                              size: 48,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          b.displayName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      AdminStatusBadge(
                                        status: b.approvalStatus,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    b.address,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20),
                              onSelected: (val) async {
                                if (val == 'approve') {
                                  await ref
                                      .read(adminControllerProvider.notifier)
                                      .setBarberStatus(b.uid, 'approved');
                                } else if (val == 'pending') {
                                  await ref
                                      .read(adminControllerProvider.notifier)
                                      .setBarberStatus(b.uid, 'pending');
                                } else if (val == 'reject') {
                                  await ref
                                      .read(adminControllerProvider.notifier)
                                      .setBarberStatus(b.uid, 'rejected');
                                } else if (val == 'delete') {
                                  _confirmDeleteBarber(b);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'approve',
                                  child: Text('Đặt trạng thái: Đã duyệt'),
                                ),
                                const PopupMenuItem(
                                  value: 'pending',
                                  child: Text('Đặt trạng thái: Chờ duyệt'),
                                ),
                                const PopupMenuItem(
                                  value: 'reject',
                                  child: Text('Đặt trạng thái: Từ chối'),
                                ),
                                const PopupMenuDivider(),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Xóa hồ sơ tiệm',
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${b.ratingAvg.toStringAsFixed(1)} (${b.ratingCount})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${b.services.length} dịch vụ',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              b.isAcceptingBookingsToday
                                  ? '🟢 Đang nhận khách'
                                  : '🔴 Tạm ngưng nhận khách',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: b.isAcceptingBookingsToday
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 18),
                        Wrap(
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showBarber360Sheet(b),
                              icon: const Icon(
                                Icons.visibility_outlined,
                                size: 16,
                              ),
                              label: const Text(
                                'Hồ sơ 360°',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showEditBarberDialog(b),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text(
                                'Sửa tiệm',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            if (isApproved)
                              FilledButton.tonal(
                                onPressed: () async {
                                  await ref
                                      .read(adminControllerProvider.notifier)
                                      .suspendBarber(b.uid);
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.deepOrange.shade50,
                                  foregroundColor: Colors.deepOrange,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text(
                                  'Tạm ngưng',
                                  style: TextStyle(fontSize: 12),
                                ),
                              )
                            else
                              FilledButton.tonal(
                                onPressed: () async {
                                  await ref
                                      .read(adminControllerProvider.notifier)
                                      .reactivateBarber(b.uid);
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.successLight,
                                  foregroundColor: AppColors.success,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text(
                                  'Kích hoạt / Duyệt',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedStatusFilter = value;
          });
        }
      },
    );
  }
}

// CreBy: MenBoyBMN
