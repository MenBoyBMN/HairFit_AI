// ============================================================================
// File: lib/features/admin/presentation/admin_users_screen.dart
// Mục đích: Màn hình quản lý người dùng (Khách hàng & Thợ) 360° cho Admin.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/admin_provider.dart';
import 'widgets/admin_status_badge.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String _selectedRoleFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const Map<String, String> _faceShapeLabels = {
    'round': 'Mặt tròn',
    'oval': 'Trái xoan',
    'square': 'Mặt vuông',
    'heart': 'Trái tim',
    'oblong': 'Mặt dài',
    'diamond': 'Kim cương',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditUserInfoDialog(UserModel user) {
    final messenger = ScaffoldMessenger.of(context);
    final nameCtrl = TextEditingController(text: user.displayName);
    final phoneCtrl = TextEditingController(text: user.phone ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sửa thông tin: ${user.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên hiển thị *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              await ref
                  .read(adminControllerProvider.notifier)
                  .updateUserInfo(
                    user.uid,
                    displayName: name,
                    phone: phoneCtrl.text.trim(),
                  );
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Đã cập nhật thông tin cho $name!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(UserModel user) {
    String selectedRole = user.role.toRoleString();
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Phân quyền: ${user.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn vai trò mới cho tài khoản (nếu chuyển sang Thợ cắt tóc, hệ thống sẽ tự động khởi tạo hồ sơ tiệm):',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedRole,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'customer',
                  child: Text('Khách hàng (Customer)'),
                ),
                DropdownMenuItem(
                  value: 'barber',
                  child: Text('Thợ cắt tóc (Barber)'),
                ),
                DropdownMenuItem(
                  value: 'admin',
                  child: Text('Quản trị viên (Admin)'),
                ),
              ],
              onChanged: (val) {
                if (val != null) selectedRole = val;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(adminControllerProvider.notifier)
                  .updateUserRole(user.uid, selectedRole);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'Đã cập nhật vai trò của ${user.displayName} thành $selectedRole!',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
  }

  void _confirmToggleBlock(UserModel user) async {
    final messenger = ScaffoldMessenger.of(context);
    final willBlock = !user.isBlocked;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(willBlock ? 'Khóa tài khoản?' : 'Mở khóa tài khoản?'),
        content: Text(
          willBlock
              ? 'Tài khoản ${user.displayName} (${user.email}) sẽ bị thu hồi quyền truy cập ngay lập tức.${user.isBarber ? "\n\nLưu ý: Tiệm cắt tóc của thợ này cũng sẽ tự động chuyển sang trạng thái Tạm ngưng để khách không đặt lịch nhầm." : ""}'
              : 'Cho phép người dùng ${user.displayName} đăng nhập và sử dụng hệ thống bình thường.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: willBlock ? AppColors.error : AppColors.success,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(willBlock ? 'Xác nhận khóa' : 'Mở khóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(adminControllerProvider.notifier)
          .setUserBlockStatus(user.uid, willBlock);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            willBlock
                ? 'Đã khóa tài khoản ${user.displayName}'
                : 'Đã mở khóa tài khoản ${user.displayName}',
          ),
          backgroundColor: willBlock ? AppColors.error : AppColors.success,
        ),
      );
    }
  }

  void _showUser360Modal(UserModel user) {
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
            userAppointmentsHistoryProvider((
              uid: user.uid,
              isBarber: user.isBarber,
            )),
          );
          final faceLabel = user.savedFaceShape != null
              ? (_faceShapeLabels[user.savedFaceShape!.toLowerCase()] ??
                    user.savedFaceShape!)
              : 'Chưa phân tích AI';

          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            maxChildSize: 0.92,
            minChildSize: 0.5,
            expand: false,
            builder: (_, scrollController) => Padding(
              padding: const EdgeInsets.all(20),
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
                        imageUrl: user.avatarUrl,
                        name: user.displayName,
                        size: 56,
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
                                    user.displayName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _buildRoleBadge(user.role),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (user.phone != null && user.phone!.isNotEmpty)
                              Text(
                                'SĐT: ${user.phone}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Hồ sơ AI & Tương tác của Khách hàng
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hồ Sơ Cá Nhân & Tư Vấn AI',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Dáng khuôn mặt AI:',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              faceLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tiệm cắt tóc yêu thích:',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${user.favoriteBarberIds.length} tiệm',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Mã định danh (UID):',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                user.uid,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nút thao tác nhanh
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showEditUserInfoDialog(user);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Sửa thông tin'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showChangeRoleDialog(user);
                        },
                        icon: const Icon(
                          Icons.manage_accounts_rounded,
                          size: 16,
                        ),
                        label: const Text('Đổi vai trò'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _confirmToggleBlock(user);
                        },
                        icon: Icon(
                          user.isBlocked
                              ? Icons.lock_open_rounded
                              : Icons.lock_outline_rounded,
                          size: 16,
                        ),
                        label: Text(
                          user.isBlocked ? 'Mở khóa' : 'Khóa tài khoản',
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Lịch sử đặt lịch của người dùng
                  Text(
                    user.isBarber
                        ? 'Lịch Sử Nhận Khách Của Thợ'
                        : 'Lịch Sử Đặt Lịch Của Khách Hàng',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  historyAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => Text('Lỗi: $err'),
                    data: (apps) {
                      if (apps.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Người dùng này chưa có lịch hẹn nào trên hệ thống.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        );
                      }
                      final completedCount = apps
                          .where((a) => a.isCompleted)
                          .length;
                      final cancelledCount = apps
                          .where((a) => a.isCancelled || a.isRejected)
                          .length;
                      final totalSpent = apps
                          .where((a) => a.isCompleted)
                          .fold<int>(0, (sum, a) => sum + a.price);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.infoLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Tổng: ${apps.length} lịch · Hoàn tất: $completedCount · Hủy: $cancelledCount · Giá trị hoàn tất: ${DateFormatter.formatCurrency(totalSpent)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.info,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...apps
                              .take(10)
                              .map(
                                (a) => ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    user.isBarber
                                        ? 'Khách: ${a.customerName} — ${a.serviceName}'
                                        : 'Tiệm: ${a.barberName} — ${a.serviceName}',
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

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider(_selectedRoleFilter));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Thanh tìm kiếm và bộ lọc vai trò
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên, email, SĐT người dùng...',
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
                      _buildFilterChip('Khách hàng', 'customer'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Thợ cắt tóc', 'barber'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Quản trị viên', 'admin'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Danh sách User
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text(
                  'Lỗi: $err',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
              data: (users) {
                final filtered = users.where((u) {
                  if (_searchQuery.isEmpty) return true;
                  return u.displayName.toLowerCase().contains(_searchQuery) ||
                      u.email.toLowerCase().contains(_searchQuery) ||
                      (u.phone?.toLowerCase().contains(_searchQuery) ?? false);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_rounded,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Không tìm thấy người dùng phù hợp.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final u = filtered[idx];
                    final dateCreated = u.createdAt != null
                        ? DateFormat('dd/MM/yyyy').format(u.createdAt!)
                        : 'Không rõ';

                    return InkWell(
                      onTap: () => _showUser360Modal(u),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: u.isBlocked
                                ? AppColors.errorLight
                                : AppColors.divider,
                            width: u.isBlocked ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            AppAvatar(
                              imageUrl: u.avatarUrl,
                              name: u.displayName,
                              size: 46,
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
                                          u.displayName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            decoration: u.isBlocked
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      _buildRoleBadge(u.role),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    u.phone != null && u.phone!.isNotEmpty
                                        ? '${u.email} · ${u.phone}'
                                        : u.email,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        'Tham gia: $dateCreated',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      if (u.savedFaceShape != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.08,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            'AI: ${_faceShapeLabels[u.savedFaceShape!] ?? u.savedFaceShape}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const Spacer(),
                                      AdminStatusBadge(
                                        status: u.isBlocked
                                            ? 'blocked'
                                            : 'active',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (val) {
                                if (val == 'detail') {
                                  _showUser360Modal(u);
                                } else if (val == 'edit') {
                                  _showEditUserInfoDialog(u);
                                } else if (val == 'role') {
                                  _showChangeRoleDialog(u);
                                } else if (val == 'block') {
                                  _confirmToggleBlock(u);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(
                                  value: 'detail',
                                  child: Row(
                                    children: [
                                      Icon(Icons.visibility_outlined, size: 20),
                                      SizedBox(width: 8),
                                      Flexible(
                                        child: Text('Xem hồ sơ 360° & Lịch sử'),
                                      ),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 20),
                                      SizedBox(width: 8),
                                      Flexible(child: Text('Sửa tên & SĐT')),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'role',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.manage_accounts_rounded,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Flexible(child: Text('Đổi vai trò')),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'block',
                                  child: Row(
                                    children: [
                                      Icon(
                                        u.isBlocked
                                            ? Icons.lock_open_rounded
                                            : Icons.lock_outline_rounded,
                                        size: 20,
                                        color: u.isBlocked
                                            ? AppColors.success
                                            : AppColors.error,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          u.isBlocked
                                              ? 'Mở khóa'
                                              : 'Khóa tài khoản',
                                          style: TextStyle(
                                            color: u.isBlocked
                                                ? AppColors.success
                                                : AppColors.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    Color bg;
    Color text;
    String label;

    switch (role) {
      case UserRole.admin:
        bg = Colors.purple.shade50;
        text = Colors.purple.shade700;
        label = 'Admin';
        break;
      case UserRole.barber:
        bg = AppColors.infoLight;
        text = AppColors.info;
        label = 'Thợ tóc';
        break;
      case UserRole.customer:
        bg = Colors.grey.shade100;
        text = Colors.grey.shade700;
        label = 'Khách';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: text.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedRoleFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedRoleFilter = value;
          });
        }
      },
    );
  }
}

// CreBy: MenBoyBMN
