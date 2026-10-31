// ============================================================================
// File: lib/features/admin/presentation/admin_appointments_screen.dart
// Mục đích: Màn hình quản lý & điều phối lịch hẹn toàn hệ thống cho Admin.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../models/appointment_model.dart';
import '../../../../providers/admin_provider.dart';
import '../data/admin_repository.dart';
import 'widgets/admin_status_badge.dart';

class AdminAppointmentsScreen extends ConsumerStatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  ConsumerState<AdminAppointmentsScreen> createState() =>
      _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState
    extends ConsumerState<AdminAppointmentsScreen> {
  String _selectedStatus = 'all';
  String? _selectedDate; // null = tất cả các ngày, hoặc 'yyyy-MM-dd'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickFilterDate() async {
    final now = DateTime.now();
    final initial = _selectedDate != null
        ? (DateFormatter.parseIsoDate(_selectedDate!) ?? now)
        : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _confirmStatusUpdate(AppointmentModel app, String newStatus) async {
    final messenger = ScaffoldMessenger.of(context);
    final isCancel = newStatus == 'cancelled';
    final reasonCtrl = TextEditingController(
      text: isCancel ? 'Admin hủy khẩn cấp' : '',
    );

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isCancel
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline_rounded,
              color: isCancel ? AppColors.error : AppColors.success,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isCancel
                    ? 'Hủy lịch khẩn cấp?'
                    : newStatus == 'confirmed'
                    ? 'Xác nhận lịch hẹn?'
                    : 'Hoàn tất lịch hẹn?',
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Khách: ${app.customerName} ➔ Tiệm: ${app.barberName}\nThời gian: ${app.date} lúc ${app.startTime}',
              style: const TextStyle(fontSize: 13),
            ),
            if (isCancel) ...[
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Lý do hủy (ghi vào lịch hẹn)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Thao tác này dùng Firestore Transaction tự động giải phóng khung giờ (bookedSlots) tương ứng.',
                  style: TextStyle(fontSize: 12, color: AppColors.warning),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Bỏ qua'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: isCancel ? AppColors.error : AppColors.success,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isCancel ? 'Xác nhận hủy' : 'Đồng ý'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(adminControllerProvider.notifier)
          .updateAppointmentStatus(
            app.id,
            newStatus,
            reason: reasonCtrl.text.trim().isNotEmpty
                ? reasonCtrl.text.trim()
                : null,
          );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isCancel
                ? 'Đã hủy lịch hẹn và giải phóng slot thành công!'
                : 'Đã cập nhật trạng thái lịch hẹn thành công!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showAppointmentDetailSheet(AppointmentModel app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chi Tiết Lịch Hẹn & AI Handshake',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  AdminStatusBadge(status: app.status.toStatusString()),
                ],
              ),
              const Divider(height: 24),
              _buildDetailRow('Mã lịch hẹn:', app.id),
              _buildDetailRow(
                'Thời gian:',
                '${app.date} (${app.startTime} - ${app.endTime})',
              ),
              _buildDetailRow(
                'Khách hàng:',
                app.customerPhone != null && app.customerPhone!.isNotEmpty
                    ? '${app.customerName} (${app.customerPhone})'
                    : app.customerName,
              ),
              _buildDetailRow(
                'Tiệm / Thợ:',
                app.barberPhone != null && app.barberPhone!.isNotEmpty
                    ? '${app.barberName} (${app.barberPhone})'
                    : app.barberName,
              ),
              _buildDetailRow(
                'Dịch vụ:',
                '${app.serviceName} (${app.durationMinutes} phút)',
              ),
              _buildDetailRow(
                'Giá dịch vụ:',
                DateFormatter.formatCurrency(app.price),
              ),
              _buildDetailRow(
                'Slot khóa (bookedSlots):',
                app.slotIds.isEmpty ? 'Đã giải phóng' : app.slotIds.join(', '),
              ),
              if (app.hairstyleId.isNotEmpty ||
                  app.customerFaceShape != null ||
                  app.aiStylingTip != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.face_retouching_natural_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Thông Tin Đồng Bộ Tư Vấn AI (AI Handshake)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (app.customerFaceShape != null)
                        Text(
                          '• Dáng mặt AI: ${app.customerFaceShape}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (app.hairstyleId.isNotEmpty)
                        Text(
                          '• Kiểu tóc chọn: ${app.hairstyleId}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (app.aiStylingTip != null &&
                          app.aiStylingTip!.isNotEmpty)
                        Text(
                          '• Gợi ý tạo kiểu: ${app.aiStylingTip}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
              if (app.note.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Ghi chú khách/hệ thống:', app.note),
              ],
              if (app.barberPrivateNote != null &&
                  app.barberPrivateNote!.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildDetailRow(
                  'Ghi chú riêng của thợ:',
                  app.barberPrivateNote!,
                ),
              ],
              if (app.rating != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Đánh giá khách hàng:',
                  '${app.rating} ⭐ — ${app.reviewComment ?? ""}',
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final filter = AdminAppointmentFilter(
      status: _selectedStatus,
      date: _selectedDate,
    );
    final appointmentsAsync = ref.watch(filteredAppointmentsProvider(filter));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Bộ lọc & tìm kiếm
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên khách, tiệm, dịch vụ, mã lịch...',
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
                // Bộ lọc ngày
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Mọi ngày'),
                        selected: _selectedDate == null,
                        onSelected: (sel) {
                          if (sel) setState(() => _selectedDate = null);
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('Hôm nay ($todayStr)'),
                        selected: _selectedDate == todayStr,
                        onSelected: (sel) {
                          if (sel) setState(() => _selectedDate = todayStr);
                        },
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        avatar: const Icon(
                          Icons.calendar_month_rounded,
                          size: 16,
                        ),
                        label: Text(
                          _selectedDate != null && _selectedDate != todayStr
                              ? 'Ngày: $_selectedDate'
                              : 'Chọn ngày...',
                        ),
                        onPressed: _pickFilterDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Bộ lọc trạng thái
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Tất cả trạng thái', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Chờ xác nhận', 'pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Đã xác nhận', 'confirmed'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Hoàn tất', 'completed'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Đã hủy', 'cancelled'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Từ chối', 'rejected'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Danh sách lịch hẹn
          Expanded(
            child: appointmentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text(
                  'Lỗi: $err',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
              data: (appointments) {
                final filtered = appointments.where((a) {
                  if (_searchQuery.isEmpty) return true;
                  return a.customerName.toLowerCase().contains(_searchQuery) ||
                      a.barberName.toLowerCase().contains(_searchQuery) ||
                      a.serviceName.toLowerCase().contains(_searchQuery) ||
                      a.id.toLowerCase().contains(_searchQuery);
                }).toList();

                final completedRev = filtered
                    .where((a) => a.isCompleted)
                    .fold<int>(0, (sum, a) => sum + a.price);
                final totalVal = filtered.fold<int>(
                  0,
                  (sum, a) => sum + a.price,
                );

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy_rounded,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Không có lịch hẹn nào phù hợp.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Thanh tóm tắt số lượng & doanh thu
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: AppColors.primary.withValues(alpha: 0.06),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hiển thị: ${filtered.length} lịch hẹn',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              'Hoàn tất: ${DateFormatter.formatCurrency(completedRev)} / Tổng: ${DateFormatter.formatCurrency(totalVal)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final app = filtered[idx];
                          final isPending =
                              app.status == AppointmentStatus.pending;
                          final isConfirmed =
                              app.status == AppointmentStatus.confirmed;
                          final canCancel = isPending || isConfirmed;

                          return InkWell(
                            onTap: () => _showAppointmentDetailSheet(app),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
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
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          '${app.date} · ${app.startTime}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      if (app.hairstyleId.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.purple.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.auto_awesome,
                                                size: 12,
                                                color: Colors.purple.shade700,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'AI Handshake',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.purple.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const Spacer(),
                                      AdminStatusBadge(
                                        status: app.status.toStatusString(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.swap_horiz_rounded,
                                        color: AppColors.accent,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 14,
                                                ),
                                                children: [
                                                  const TextSpan(
                                                    text: 'Khách: ',
                                                  ),
                                                  TextSpan(
                                                    text: app.customerName,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const TextSpan(
                                                    text: '  ➔  Tiệm: ',
                                                  ),
                                                  TextSpan(
                                                    text: app.barberName,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Dịch vụ: ${app.serviceName} (${app.durationMinutes} phút) — ${DateFormatter.formatCurrency(app.price)}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            if (app.note.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                'Ghi chú: ${app.note}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 18),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () =>
                                            _showAppointmentDetailSheet(app),
                                        icon: const Icon(
                                          Icons.info_outline_rounded,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          'Chi tiết',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      if (isPending)
                                        TextButton.icon(
                                          onPressed: () => _confirmStatusUpdate(
                                            app,
                                            'confirmed',
                                          ),
                                          icon: const Icon(
                                            Icons.check_rounded,
                                            color: AppColors.info,
                                            size: 16,
                                          ),
                                          label: const Text(
                                            'Xác nhận',
                                            style: TextStyle(
                                              color: AppColors.info,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      if (isConfirmed)
                                        TextButton.icon(
                                          onPressed: () => _confirmStatusUpdate(
                                            app,
                                            'completed',
                                          ),
                                          icon: const Icon(
                                            Icons.task_alt_rounded,
                                            color: AppColors.success,
                                            size: 16,
                                          ),
                                          label: const Text(
                                            'Hoàn tất',
                                            style: TextStyle(
                                              color: AppColors.success,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      if (canCancel)
                                        TextButton.icon(
                                          onPressed: () => _confirmStatusUpdate(
                                            app,
                                            'cancelled',
                                          ),
                                          icon: const Icon(
                                            Icons.cancel_outlined,
                                            color: AppColors.error,
                                            size: 16,
                                          ),
                                          label: const Text(
                                            'Hủy khẩn cấp',
                                            style: TextStyle(
                                              color: AppColors.error,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
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
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedStatus = value;
          });
        }
      },
    );
  }
}

// CreBy: MenBoyBMN
