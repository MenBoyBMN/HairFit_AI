// ============================================================================
// File: lib/features/home/presentation/widgets/my_ai_hair_profile_card.dart
// Mục đích: Thẻ hiển thị hồ sơ dáng mặt AI và gợi ý kiểu tóc cá nhân hóa (Task Phase 3 - C2).
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/services/seed_data_service.dart';
import '../../../ai_consult/domain/face_shape.dart';
import '../../../ai_consult/domain/hairstyle_recommendation_engine.dart';

class MyAIHairProfileCard extends StatelessWidget {
  final String? savedFaceShape;

  const MyAIHairProfileCard({super.key, required this.savedFaceShape});

  @override
  Widget build(BuildContext context) {
    if (savedFaceShape == null || savedFaceShape!.trim().isEmpty) {
      return _buildEmptyPromptCard(context);
    }

    final shape = FaceShape.fromString(savedFaceShape);
    const engine = HairstyleRecommendationEngine();
    final rec = engine.recommend(
      faceShape: shape,
      catalog: SeedDataService.sampleHairstyles,
    );
    final topStyles = rec.primaryRecommendations.take(3).toList();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.lg,
        vertical: AppDimensions.sm,
      ),
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C1654), Color(0xFF131A35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppDimensions.borderRadiusLg,
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.aiHandshake.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: AI Badge & Re-scan button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.accent,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.xs),
                    const Expanded(
                      child: Text(
                        'HỒ SƠ DÁNG MẶT AI CỦA BẠN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: AppColors.accent,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.xs),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: Colors.white70,
                ),
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: Text(
                  kIsWeb ? 'Đổi dáng mặt' : 'Quét lại',
                  style: const TextStyle(fontSize: 11),
                ),
                onPressed: () => context.push('/customer/ai-consult'),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.sm),

          // Face Shape Highlight
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.6),
                  ),
                ),
                child: Text(
                  shape.displayNameVi,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '• Đã phân loại on-device',
                style: TextStyle(fontSize: 11, color: Colors.white60),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.sm),

          // Advice Text
          Text(
            rec.generalAdviceVi,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppDimensions.md),

          // Recommended Hairstyles Chips
          const Text(
            'Kiểu tóc chuẩn tỉ lệ khuôn mặt:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: topStyles.map((item) {
              return ActionChip(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                label: Text(
                  item.style.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                avatar: const Icon(
                  Icons.content_cut_rounded,
                  size: 13,
                  color: AppColors.accent,
                ),
                onPressed: () {
                  context.push(
                    '/customer/search?query=${Uri.encodeComponent(item.style.name)}',
                  );
                },
              );
            }).toList(),
          ),

          const SizedBox(height: AppDimensions.md),

          // Action Button: Search Barbers with this Style
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.borderRadiusSm,
                ),
              ),
              icon: const Icon(Icons.search_rounded, size: 16),
              label: const Text(
                'Tìm tiệm cắt kiểu hợp mặt bạn ngay',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                final firstStyleName = topStyles.isNotEmpty
                    ? topStyles.first.style.name
                    : '';
                context.push(
                  '/customer/search?query=${Uri.encodeComponent(firstStyleName)}',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPromptCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.lg,
        vertical: AppDimensions.sm,
      ),
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        gradient: AppColors.aiBannerGradient,
        borderRadius: AppDimensions.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: AppColors.accent,
                      size: 16,
                    ),
                    const SizedBox(width: AppDimensions.xs),
                    const Text(
                      'AI TƯ VẤN KIỂU TÓC',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bạn chưa biết mặt mình hợp kiểu nào?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  kIsWeb
                      ? 'Chọn dáng khuôn mặt và chất tóc trên Web Studio để nhận gợi ý chuẩn xác.'
                      : 'Quét mặt với AI on-device bảo mật để lưu dáng mặt và nhận gợi ý chuẩn xác.',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderRadiusSm,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.face_retouching_natural, size: 15),
                  label: const Text(
                    'Khám phá ngay',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => context.push('/customer/ai-consult'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.face, size: 40, color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

// CreBy: MenBoyBMN
