// ============================================================================
// File: lib/features/booking/presentation/widgets/booking_summary.dart
// Mục đích: Thành phần giao diện (Widget) con thuộc tính năng booking.
// Kết cấu:
//  - Widget nhận dữ liệu và hiển thị UI, đóng gói giao diện cho gọn gàng.
// ============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/seed_data_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../models/barber_profile_model.dart';
import '../../../../models/promotion_model.dart';
import '../../../../models/service_model.dart';
import '../../data/slot_service.dart';

/// Widget tóm tắt chi tiết lịch hẹn & áp dụng mã giảm giá Giờ Vàng (Task 4.7 & Feature 7)
class BookingSummary extends StatefulWidget {
  final BarberProfileModel barber;
  final ServiceModel? service;
  final DateTime selectedDate;
  final AvailableSlot? selectedSlot;
  final String note;
  final ValueChanged<String> onNoteChanged;
  final String? customerFaceShape;
  final String? aiStylingTip;
  final String? hairstyleName;
  final PromotionModel? appliedPromotion;
  final int discountAmount;
  final Function(PromotionModel promo)? onApplyPromo;
  final VoidCallback? onRemovePromo;

  const BookingSummary({
    super.key,
    required this.barber,
    required this.service,
    required this.selectedDate,
    required this.selectedSlot,
    required this.note,
    required this.onNoteChanged,
    this.customerFaceShape,
    this.aiStylingTip,
    this.hairstyleName,
    this.appliedPromotion,
    this.discountAmount = 0,
    this.onApplyPromo,
    this.onRemovePromo,
  });

  @override
  State<BookingSummary> createState() => _BookingSummaryState();
}

class _BookingSummaryState extends State<BookingSummary> {
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _handleApplyCode(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return;

    final found = SeedDataService.samplePromotions.where(
      (p) => p.code.toUpperCase() == cleanCode,
    );

    if (found.isNotEmpty && widget.onApplyPromo != null) {
      widget.onApplyPromo!(found.first);
      _promoController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã giảm giá không hợp lệ hoặc đã hết hạn!'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final originalPrice = widget.service?.price ?? 0;
    final finalPrice = (originalPrice - widget.discountAmount).clamp(
      0,
      originalPrice,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('4. Thông tin tóm tắt & ghi chú', style: AppTextStyles.h4),
        const SizedBox(height: AppDimensions.sm),
        Container(
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppDimensions.borderRadiusMd,
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              _buildRow(
                icon: Icons.storefront_rounded,
                label: 'Tiệm cắt tóc',
                value: widget.barber.displayName,
              ),
              const Divider(height: 16),
              _buildRow(
                icon: Icons.content_cut_rounded,
                label: 'Dịch vụ',
                value: widget.service != null
                    ? '${widget.service!.name} (${widget.service!.durationMinutes}p)'
                    : 'Chưa chọn',
              ),
              const Divider(height: 16),
              _buildRow(
                icon: Icons.calendar_today_rounded,
                label: 'Ngày hẹn',
                value: DateFormatter.formatFullDate(widget.selectedDate),
              ),
              const Divider(height: 16),
              _buildRow(
                icon: Icons.access_time_rounded,
                label: 'Thời gian',
                value: widget.selectedSlot != null
                    ? '${widget.selectedSlot!.startTime} - ${widget.selectedSlot!.endTime}'
                    : 'Chưa chọn khung giờ',
                highlightValue: widget.selectedSlot != null,
              ),
              if (widget.customerFaceShape != null &&
                  widget.customerFaceShape!.isNotEmpty) ...[
                const Divider(height: 16),
                _buildRow(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Dáng mặt AI',
                  value: widget.customerFaceShape!,
                  highlightValue: true,
                ),
              ],
              if (widget.hairstyleName != null &&
                  widget.hairstyleName!.isNotEmpty) ...[
                const Divider(height: 16),
                _buildRow(
                  icon: Icons.face_retouching_natural_rounded,
                  label: 'Kiểu tóc mẫu AI',
                  value: widget.hairstyleName!,
                  highlightValue: true,
                ),
              ],

              // Khối Khuyến Mãi / Happy Hour
              const Divider(height: 16),
              _buildPromotionSection(),

              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'Tổng thanh toán (tại tiệm)',
                      style: AppTextStyles.labelMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.xs),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (widget.discountAmount > 0)
                        Text(
                          DateFormatter.formatCurrency(originalPrice),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Text(
                        DateFormatter.formatCurrency(finalPrice),
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        AppTextField(
          label: 'Ghi chú cho thợ (không bắt buộc)',
          hintText: 'Ví dụ: Cắt ngắn gọn gàng, sấy phồng chân tóc...',
          initialValue: widget.note,
          maxLines: 2,
          onChanged: widget.onNoteChanged,
        ),
      ],
    );
  }

  Widget _buildPromotionSection() {
    if (widget.appliedPromotion != null) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.discount_rounded,
              color: AppColors.success,
              size: 20,
            ),
            const SizedBox(width: AppDimensions.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mã ${widget.appliedPromotion!.code}: ${widget.appliedPromotion!.title}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    'Giảm giá: -${DateFormatter.formatCurrency(widget.discountAmount)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              onPressed: widget.onRemovePromo,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.local_offer_outlined, size: 18, color: AppColors.accent),
            SizedBox(width: AppDimensions.xs),
            Text(
              'Ưu đãi & Giờ Vàng Happy Hour',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.xs),

        // Danh sách các mã Happy Hour mẫu gợi ý
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: SeedDataService.samplePromotions.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppDimensions.xs),
            itemBuilder: (context, index) {
              final promo = SeedDataService.samplePromotions[index];
              return ChoiceChip(
                label: Text(
                  '${promo.code} (-${promo.discountValue}${promo.type == PromotionType.percentage ? '%' : 'k'})',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                  ),
                ),
                selected: false,
                backgroundColor: AppColors.background,
                side: const BorderSide(color: AppColors.divider),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                onSelected: (_) {
                  if (widget.onApplyPromo != null) {
                    widget.onApplyPromo!(promo);
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.xs),

        // Ô nhập mã thủ công
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: _promoController,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Nhập mã giảm giá...',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.xs),
            ElevatedButton(
              onPressed: () => _handleApplyCode(_promoController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Áp dụng', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required String value,
    bool highlightValue = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppDimensions.sm),
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(width: AppDimensions.sm),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelMedium.copyWith(
              color: highlightValue ? AppColors.accent : AppColors.textPrimary,
              fontWeight: highlightValue ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// CreBy: MenBoyBMN
