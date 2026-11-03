// ============================================================================
// File: lib/features/appointments/presentation/widgets/ai_haircut_handshake_card.dart
// Mục đích: Thẻ "AI Haircut Handshake" hiển thị kết quả phân tích AI & mẹo kỹ thuật
//           dành cho thợ cắt tóc khi tiếp nhận lịch hẹn của khách hàng.
// ============================================================================

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

class AIHaircutHandshakeCard extends StatelessWidget {
  final String faceShape;
  final String? stylingTip;
  final String? hairstyleImageUrl;
  final String? hairstyleName;

  const AIHaircutHandshakeCard({
    super.key,
    required this.faceShape,
    this.stylingTip,
    this.hairstyleImageUrl,
    this.hairstyleName,
  });

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppDimensions.md),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: AppDimensions.borderRadiusMd,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (_, _) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (_, _, _) => Container(
                  color: Colors.black87,
                  padding: const EdgeInsets.all(AppDimensions.xl),
                  child: const Text(
                    'Không thể tải ảnh mẫu tóc',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.sm),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.aiHandshakeLight,
        borderRadius: AppDimensions.borderRadiusMd,
        border: Border.all(
          color: AppColors.aiHandshake.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.aiHandshake.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.aiHandshake.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.aiHandshake,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppDimensions.xs),
              const Expanded(
                child: Text(
                  'YÊU CẦU TƯ VẤN TỪ HAIRFIT AI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.aiHandshake,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.sm),

          // Face Shape info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '• Dáng mặt khách: ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: Text(
                  faceShape.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.aiHandshake,
                  ),
                ),
              ),
            ],
          ),

          // Hairstyle if selected
          if (hairstyleName != null && hairstyleName!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• Kiểu tóc mong muốn: ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: Text(
                    hairstyleName!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Styling Tip
          if (stylingTip != null && stylingTip!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(AppDimensions.sm),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppDimensions.borderRadiusSm,
                border: Border.all(
                  color: AppColors.aiHandshake.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Mẹo cắt AI: $stylingTip',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Hairstyle Image preview button
          if (hairstyleImageUrl != null && hairstyleImageUrl!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  foregroundColor: AppColors.aiHandshake,
                ),
                icon: const Icon(Icons.image_outlined, size: 16),
                label: const Text(
                  'Xem ảnh mẫu tóc khách chọn',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                onPressed: () => _showImageDialog(context, hairstyleImageUrl!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// CreBy: MenBoyBMN
