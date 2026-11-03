// ============================================================================
// File: lib/features/admin/presentation/admin_settings_screen.dart
// Mục đích: Màn hình Cài đặt hệ thống, Tham số vận hành & Seed Data 1-Click.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../providers/admin_stats_provider.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  bool _isLoading = false;
  bool _initializedFromRemote = false;
  double _searchRadiusKm = 10.0;
  int _cancelNoticeHours = 1;
  bool _maintenanceMode = false;

  Future<void> _runAction(String title, Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);
    try {
      await action();
      ref.invalidate(adminDashboardStatsProvider);
      ref.invalidate(adminRecentPendingBarbersProvider);
      ref.invalidate(adminAppointmentsTodayProvider);
      ref.invalidate(pendingBarbersProvider);
      ref.invalidate(allBarbersProvider);
      ref.invalidate(allAppointmentsProvider);
      ref.invalidate(filteredAppointmentsProvider);
      ref.invalidate(allHairstylesProvider);
      ref.invalidate(systemSettingsProvider);

      messenger.showSnackBar(
        SnackBar(
          content: Text('$title thành công!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(systemSettingsProvider);

    settingsAsync.whenData((data) {
      if (!_initializedFromRemote) {
        _initializedFromRemote = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _searchRadiusKm =
                  (data['searchRadiusKm'] as num?)?.toDouble() ?? 10.0;
              _cancelNoticeHours =
                  (data['cancelNoticeHours'] as num?)?.toInt() ?? 1;
              _maintenanceMode = data['maintenanceMode'] as bool? ?? false;
            });
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Đang xử lý dữ liệu hệ thống...',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSectionHeader(
                  title: 'Tham Số Nghiệp Vụ Hệ Thống',
                  subtitle: 'Tùy chỉnh và lưu trữ các quy tắc vận hành lên Cloud Firestore (systemSettings/global)',
                  icon: Icons.tune_rounded,
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Bán kính tìm kiếm thợ tối đa:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${_searchRadiusKm.toStringAsFixed(0)} km',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _searchRadiusKm.clamp(5.0, 50.0),
                          min: 5,
                          max: 50,
                          divisions: 9,
                          label: '${_searchRadiusKm.toStringAsFixed(0)} km',
                          onChanged: (val) =>
                              setState(() => _searchRadiusKm = val),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Thời gian hủy lịch tối thiểu'),
                          subtitle: const Text(
                            'Khách chỉ được hủy trước giờ hẹn tối thiểu',
                          ),
                          trailing: DropdownButton<int>(
                            value: [1, 2, 4].contains(_cancelNoticeHours)
                                ? _cancelNoticeHours
                                : 1,
                            items: const [
                              DropdownMenuItem(
                                value: 1,
                                child: Text('1 tiếng'),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text('2 tiếng'),
                              ),
                              DropdownMenuItem(
                                value: 4,
                                child: Text('4 tiếng'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _cancelNoticeHours = val);
                              }
                            },
                          ),
                        ),
                        const Divider(),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Chế độ bảo trì (Maintenance Mode)',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Khi bật, hệ thống ghi nhận trạng thái bảo trì nâng cấp trên toàn nền tảng',
                          ),
                          value: _maintenanceMode,
                          onChanged: (val) {
                            setState(() => _maintenanceMode = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => _runAction(
                              'Lưu cấu hình hệ thống',
                              () => ref
                                  .read(adminControllerProvider.notifier)
                                  .saveSystemSettings(
                                    searchRadiusKm: _searchRadiusKm,
                                    cancelNoticeHours: _cancelNoticeHours,
                                    maintenanceMode: _maintenanceMode,
                                  ),
                            ),
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Lưu cấu hình hệ thống'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // SECTION 3: SYSTEM INFO
                _buildSectionHeader(
                  title: 'Thông Tin Nền Tảng HairFit AI',
                  subtitle: 'Kiến trúc & Hạ tầng kỹ thuật',
                  icon: Icons.info_outline_rounded,
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 0,
                  color: AppColors.primary.withValues(alpha: 0.04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'Phiên bản ứng dụng',
                          value: 'v2.2 (Admin 360°)',
                        ),
                        Divider(),
                        _InfoRow(
                          label: 'AI Engine',
                          value: '100% On-Device ML Kit Face Mesh',
                        ),
                        Divider(),
                        _InfoRow(
                          label: 'Cơ sở dữ liệu',
                          value: 'ASP.NET Core 8 Web API + SQL Server',
                        ),
                        Divider(),
                        _InfoRow(
                          label: 'Xác thực tài khoản',
                          value: 'Firebase Auth (Email/Password)',
                        ),
                        Divider(),
                        _InfoRow(
                          label: 'Nền tảng bản đồ',
                          value: 'OpenStreetMap (Zero-Cost Map)',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// CreBy: MenBoyBMN
