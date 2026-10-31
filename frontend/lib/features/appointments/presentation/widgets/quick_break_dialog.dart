// ============================================================================
// File: lib/features/appointments/presentation/widgets/quick_break_dialog.dart
// Mục đích: Hộp thoại cho phép thợ cắt tóc khóa slot giờ nghỉ hoặc bận đột xuất.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../providers/booking_provider.dart';

class QuickBreakDialog extends ConsumerStatefulWidget {
  final String barberId;

  const QuickBreakDialog({super.key, required this.barberId});

  static Future<bool?> show(BuildContext context, {required String barberId}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => QuickBreakDialog(barberId: barberId),
    );
  }

  @override
  ConsumerState<QuickBreakDialog> createState() => _QuickBreakDialogState();
}

class _QuickBreakDialogState extends ConsumerState<QuickBreakDialog> {
  DateTime _selectedDate = DateTime.now();
  final Set<String> _selectedTimes = {};
  final TextEditingController _reasonController = TextEditingController(
    text: 'Nghỉ trưa / Việc cá nhân',
  );
  bool _isSubmitting = false;

  final List<String> _allSlots = const [
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
  ];

  final List<String> _quickReasons = const [
    'Nghỉ trưa',
    'Việc cá nhân',
    'Đông khách vãng lai',
    'Mất điện / Bảo trì ghế',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (_selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất 1 khung giờ cần khóa!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dateStr = DateFormatter.toIsoDateString(_selectedDate);
      final bookingRepo = ref.read(bookingRepositoryProvider);

      await bookingRepo.blockSlotsByBarber(
        barberId: widget.barberId,
        date: dateStr,
        times: _selectedTimes.toList(),
        reason: _reasonController.text.trim().isEmpty
            ? 'Bận đột xuất'
            : _reasonController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi khóa khung giờ: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormatter.formatFullDate(_selectedDate);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLg),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_clock_rounded,
              color: AppColors.accent,
              size: 22,
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          const Expanded(
            child: Text('Khóa Giờ Nghỉ / Đột Xuất', style: AppTextStyles.h4),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chọn ngày
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ngày: $dateStr',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                    label: const Text('Đổi ngày'),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),

              const Divider(height: 16),

              const Text(
                'Chọn các khung giờ muốn tạm khóa:',
                style: AppTextStyles.labelMedium,
              ),
              const SizedBox(height: AppDimensions.xs),
              const Text(
                'Khách hàng sẽ thấy các slot này ở trạng thái "Thợ bận" và không thể đặt lịch.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),

              const SizedBox(height: AppDimensions.sm),

              // Danh sách chips giờ
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _allSlots.map((time) {
                  final isSelected = _selectedTimes.contains(time);
                  return FilterChip(
                    label: Text(time),
                    selected: isSelected,
                    selectedColor: AppColors.accent.withValues(alpha: 0.25),
                    checkmarkColor: AppColors.accent,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.textPrimary,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTimes.add(time);
                        } else {
                          _selectedTimes.remove(time);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: AppDimensions.md),

              // Lý do khóa
              const Text(
                'Lý do khóa khung giờ:',
                style: AppTextStyles.labelMedium,
              ),
              const SizedBox(height: AppDimensions.xs),
              Wrap(
                spacing: 6,
                children: _quickReasons.map((r) {
                  return ActionChip(
                    label: Text(r, style: const TextStyle(fontSize: 11)),
                    onPressed: () {
                      _reasonController.text = r;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimensions.xs),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  hintText: 'Nhập lý do hiển thị cho khách...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text(
            'Hủy bỏ',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
          ),
          onPressed: _isSubmitting ? null : _handleConfirm,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_rounded, size: 18),
          label: Text(_isSubmitting ? 'Đang lưu...' : 'Xác Nhận Khóa'),
        ),
      ],
    );
  }
}

// CreBy: MenBoyBMN
