// ============================================================================
// File: lib/features/ai_consult/presentation/widgets/hair_info_selector.dart
// Mục đích: Thành phần giao diện (Widget) con thuộc tính năng ai_consult.
// Kết cấu:
//  - Widget nhận dữ liệu và hiển thị UI, đóng gói giao diện cho gọn gàng.
// ============================================================================

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Widget chọn thông tin sở thích tóc & đánh giá tình trạng trán/tóc (Task 5.9, 5.10 & AI Enhancements)
class HairInfoSelector extends StatelessWidget {
  final String? selectedGender;
  final String? selectedLength;
  final String? selectedTexture;
  final String? selectedForeheadType;
  final String? selectedHairDensity;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<String?> onLengthChanged;
  final ValueChanged<String?> onTextureChanged;
  final ValueChanged<String?>? onForeheadTypeChanged;
  final ValueChanged<String?>? onHairDensityChanged;

  const HairInfoSelector({
    super.key,
    this.selectedGender,
    this.selectedLength,
    this.selectedTexture,
    this.selectedForeheadType,
    this.selectedHairDensity,
    required this.onGenderChanged,
    required this.onLengthChanged,
    required this.onTextureChanged,
    this.onForeheadTypeChanged,
    this.onHairDensityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.borderRadiusLg,
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.accent, size: 20),
              const SizedBox(width: AppDimensions.xs),
              Text(
                'Sở thích tạo kiểu (Tùy chọn)',
                style: AppTextStyles.h4.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'Độ dày chất tóc và kiểu vầng trán (Trán chữ M, tóc mỏng...) sẽ giúp AI tư vấn chính xác phom tóc che khuyết điểm.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Divider(height: AppDimensions.lg),

          // 1. Đường chân tóc & Vầng trán (Forehead Assessment)
          if (onForeheadTypeChanged != null) ...[
            _buildSectionHeader('Đường chân tóc / Vầng trán:'),
            Wrap(
              spacing: AppDimensions.xs,
              children: [
                _buildChoiceChip(
                  label: 'Trán chuẩn',
                  isSelected:
                      selectedForeheadType == null ||
                      selectedForeheadType == 'standard',
                  onSelected: (_) => onForeheadTypeChanged!('standard'),
                ),
                _buildChoiceChip(
                  label: 'Trán chữ M',
                  icon: Icons.face_retouching_natural_rounded,
                  isSelected: selectedForeheadType == 'mShaped',
                  onSelected: (selected) =>
                      onForeheadTypeChanged!(selected ? 'mShaped' : null),
                ),
                _buildChoiceChip(
                  label: 'Trán cao/Hói M',
                  isSelected: selectedForeheadType == 'high',
                  onSelected: (selected) =>
                      onForeheadTypeChanged!(selected ? 'high' : null),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
          ],

          // 2. Mật độ & Độ dày tóc (Hair Density)
          if (onHairDensityChanged != null) ...[
            _buildSectionHeader('Mật độ & Độ dày chất tóc:'),
            Wrap(
              spacing: AppDimensions.xs,
              children: [
                _buildChoiceChip(
                  label: 'Bình thường',
                  isSelected:
                      selectedHairDensity == null ||
                      selectedHairDensity == 'normal',
                  onSelected: (_) => onHairDensityChanged!('normal'),
                ),
                _buildChoiceChip(
                  label: 'Tóc thưa / Mỏng',
                  isSelected: selectedHairDensity == 'thin',
                  onSelected: (selected) =>
                      onHairDensityChanged!(selected ? 'thin' : null),
                ),
                _buildChoiceChip(
                  label: 'Tóc rễ tre / Dày',
                  isSelected: selectedHairDensity == 'thick',
                  onSelected: (selected) =>
                      onHairDensityChanged!(selected ? 'thick' : null),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
          ],

          // 3. Giới tính
          _buildSectionHeader('Giới tính mục tiêu:'),
          Wrap(
            spacing: AppDimensions.xs,
            children: [
              _buildChoiceChip(
                label: 'Nam',
                icon: Icons.male_rounded,
                isSelected: selectedGender == 'male',
                onSelected: (selected) =>
                    onGenderChanged(selected ? 'male' : null),
              ),
              _buildChoiceChip(
                label: 'Nữ',
                icon: Icons.female_rounded,
                isSelected: selectedGender == 'female',
                onSelected: (selected) =>
                    onGenderChanged(selected ? 'female' : null),
              ),
              _buildChoiceChip(
                label: 'Tất cả (Unisex)',
                icon: Icons.all_inclusive_rounded,
                isSelected:
                    selectedGender == null || selectedGender == 'unisex',
                onSelected: (_) => onGenderChanged('unisex'),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),

          // 4. Độ dài tóc mong muốn
          _buildSectionHeader('Độ dài tóc mong muốn:'),
          Wrap(
            spacing: AppDimensions.xs,
            children: [
              _buildChoiceChip(
                label: 'Tóc ngắn',
                isSelected: selectedLength == 'short',
                onSelected: (selected) =>
                    onLengthChanged(selected ? 'short' : null),
              ),
              _buildChoiceChip(
                label: 'Trung bình',
                isSelected: selectedLength == 'medium',
                onSelected: (selected) =>
                    onLengthChanged(selected ? 'medium' : null),
              ),
              _buildChoiceChip(
                label: 'Tóc dài',
                isSelected: selectedLength == 'long',
                onSelected: (selected) =>
                    onLengthChanged(selected ? 'long' : null),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),

          // 5. Chất tóc hiện tại
          _buildSectionHeader('Chất tóc hiện tại:'),
          Wrap(
            spacing: AppDimensions.xs,
            children: [
              _buildChoiceChip(
                label: 'Tóc thẳng',
                isSelected: selectedTexture == 'straight',
                onSelected: (selected) =>
                    onTextureChanged(selected ? 'straight' : null),
              ),
              _buildChoiceChip(
                label: 'Gợn sóng',
                isSelected: selectedTexture == 'wavy',
                onSelected: (selected) =>
                    onTextureChanged(selected ? 'wavy' : null),
              ),
              _buildChoiceChip(
                label: 'Tóc xoăn',
                isSelected: selectedTexture == 'curly',
                onSelected: (selected) =>
                    onTextureChanged(selected ? 'curly' : null),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.xs),
      child: Text(
        title,
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      selectedColor: AppColors.accent,
      backgroundColor: AppColors.background,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusSm,
        side: BorderSide(
          color: isSelected ? AppColors.accent : AppColors.divider,
        ),
      ),
      onSelected: onSelected,
    );
  }
}

// CreBy: MenBoyBMN
