// ============================================================================
// File: lib/features/ai_consult/presentation/widgets/virtual_hair_try_on_overlay.dart
// Mục đích: Thành phần giao diện (Widget) thử kiểu tóc 2D/AR Overlay trên khuôn mặt vừa quét.
// Kết cấu:
//  - Ghép lớp phủ 2D kiểu tóc (Hair Overlay) lên khuôn mặt người dùng, cho phép tinh chỉnh vị trí, kích thước và màu nhuộm.
// ============================================================================

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/hairstyle_recommendation_engine.dart';

/// Widget Virtual Haircut Try-On 2D Overlay ghép kiểu tóc trực tiếp lên ảnh khuôn mặt
class VirtualHairTryOnOverlay extends StatefulWidget {
  final String? imagePath;
  final List<RecommendedHairstyle> recommendations;

  const VirtualHairTryOnOverlay({
    super.key,
    required this.imagePath,
    required this.recommendations,
  });

  @override
  State<VirtualHairTryOnOverlay> createState() =>
      _VirtualHairTryOnOverlayState();
}

class _VirtualHairTryOnOverlayState extends State<VirtualHairTryOnOverlay> {
  int _selectedIndex = 0;
  double _offsetY = -35.0; // Tinh chỉnh vị trí chân tóc trên/dưới
  double _scale = 1.05; // Co giãn phom tóc
  bool _isFlipped = false; // Đảo chiều phom tóc
  Color _hairColor = Colors.black87; // Màu nhuộm thử nghiệm
  String _colorName = 'Đen tự nhiên';

  final List<Map<String, dynamic>> _hairColorOptions = [
    {'name': 'Đen tự nhiên', 'color': Colors.black87},
    {'name': 'Nâu hạt dẻ', 'color': const Color(0xFF5D4037)},
    {'name': 'Nâu trà sữa', 'color': const Color(0xFF8D6E63)},
    {'name': 'Xám khói', 'color': const Color(0xFF78909C)},
    {'name': 'Bạch kim', 'color': const Color(0xFFCFD8DC)},
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.recommendations.isEmpty) return const SizedBox.shrink();

    final currentStyle = widget.recommendations[_selectedIndex].style;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.borderRadiusLg,
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Tên tính năng Virtual Try-On
          Row(
            children: [
              const Icon(
                Icons.face_retouching_natural_rounded,
                color: AppColors.accent,
                size: 22,
              ),
              const SizedBox(width: AppDimensions.xs),
              Expanded(
                child: Text(
                  'AI Virtual Try-On (Thử Tóc Trực Tiếp)',
                  style: AppTextStyles.h4.copyWith(color: AppColors.primary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '2D Overlay',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Lớp phủ 2D tự động canh chỉnh kiểu tóc thử nghiệm lên khuôn mặt vừa quét của bạn.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.md),

          // Khung Xem Trước Ảnh Mặt + Lớp Phủ Tóc
          Center(
            child: Container(
              width: 260,
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black12,
                border: Border.all(color: AppColors.divider, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Ảnh khuôn mặt người dùng
                  if (!kIsWeb &&
                      widget.imagePath != null &&
                      widget.imagePath!.isNotEmpty &&
                      File(widget.imagePath!).existsSync())
                    Image.file(
                      File(widget.imagePath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  else
                    Container(
                      color: AppColors.background,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.person_rounded,
                            size: 100,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Khuôn mặt phân tích',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 2. Lớp phủ tóc 2D (Hair Silhouette / Overlay)
                  Positioned(
                    top: 20 + _offsetY,
                    child: Transform.scale(
                      scale: _scale,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(_isFlipped ? 3.14159 : 0),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            _hairColor,
                            BlendMode.srcIn,
                          ),
                          child: CustomPaint(
                            size: const Size(200, 140),
                            painter: _HairStylePainter(
                              styleId: currentStyle.id,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Label Tên kiểu tóc đang thử ở góc dưới
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              currentStyle.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _colorName,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.md),

          // Thanh chọn màu nhuộm thử nghiệm
          const Text(
            'Thử màu nhuộm tóc:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _hairColorOptions.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final item = _hairColorOptions[idx];
                final isSelected = _colorName == item['name'];
                return ChoiceChip(
                  avatar: CircleAvatar(
                    backgroundColor: item['color'] as Color,
                    radius: 8,
                  ),
                  label: Text(
                    item['name'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.accent,
                  backgroundColor: AppColors.background,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _colorName = item['name'] as String;
                        _hairColor = item['color'] as Color;
                      });
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppDimensions.sm),

          // Thanh cuộn chọn kiểu tóc thử nghiệm (Horizontal Hair Selector)
          const Text(
            'Lướt chọn kiểu tóc thử lên mặt:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.recommendations.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final rec = widget.recommendations[idx];
                final isSelected = _selectedIndex == idx;
                return ChoiceChip(
                  label: Text(
                    rec.style.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.accent,
                  backgroundColor: AppColors.background,
                  side: const BorderSide(color: AppColors.divider),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedIndex = idx;
                      });
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppDimensions.sm),

          // Thanh tinh chỉnh vị trí & độ co giãn & Lật phom
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tinh chỉnh góc canh phom tóc:',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              InkWell(
                onTap: () => setState(() => _isFlipped = !_isFlipped),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.flip_rounded,
                        size: 14,
                        color: _isFlipped
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Đảo chiều',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _isFlipped
                              ? AppColors.accent
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Vị trí:', style: TextStyle(fontSize: 11)),
              Expanded(
                child: Slider(
                  value: _offsetY,
                  min: -70.0,
                  max: 10.0,
                  activeColor: AppColors.accent,
                  onChanged: (val) => setState(() => _offsetY = val),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Kích thước:', style: TextStyle(fontSize: 11)),
              Expanded(
                child: Slider(
                  value: _scale,
                  min: 0.8,
                  max: 1.3,
                  activeColor: AppColors.accent,
                  onChanged: (val) => setState(() => _scale = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),

          // Nút hành động: Tìm thợ cắt kiểu này ngay
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
                elevation: 0,
              ),
              icon: const Icon(Icons.content_cut_rounded, size: 16),
              label: Text(
                'Tìm Thợ Cắt Kiểu "${currentStyle.name}" Ngay ✂️',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                context.push('/customer/search?hairstyleId=${currentStyle.id}');
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter vẽ Silhouette hình học đại diện cho phom các kiểu tóc nam
class _HairStylePainter extends CustomPainter {
  final String styleId;

  _HairStylePainter({required this.styleId});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    final w = size.width;
    final h = size.height;

    if (styleId == 'undercut' || styleId == 'pompadour') {
      // Phom tóc sấy phồng nhô cao đỉnh đầu, cạo sát hai bên
      path.moveTo(w * 0.20, h * 0.55);
      path.quadraticBezierTo(w * 0.15, h * 0.20, w * 0.35, h * 0.05);
      path.quadraticBezierTo(w * 0.50, -h * 0.15, w * 0.65, h * 0.05);
      path.quadraticBezierTo(w * 0.85, h * 0.20, w * 0.80, h * 0.55);
      path.quadraticBezierTo(w * 0.70, h * 0.40, w * 0.50, h * 0.35);
      path.quadraticBezierTo(w * 0.30, h * 0.40, w * 0.20, h * 0.55);
    } else if (styleId == 'layer_male' || styleId == 'two_block') {
      // Phom tóc layer mái phủ trán rủ tự nhiên
      path.moveTo(w * 0.12, h * 0.60);
      path.quadraticBezierTo(w * 0.10, h * 0.15, w * 0.40, h * 0.05);
      path.quadraticBezierTo(w * 0.50, h * 0.02, w * 0.60, h * 0.05);
      path.quadraticBezierTo(w * 0.90, h * 0.15, w * 0.88, h * 0.60);
      path.quadraticBezierTo(w * 0.75, h * 0.75, w * 0.50, h * 0.80);
      path.quadraticBezierTo(w * 0.25, h * 0.75, w * 0.12, h * 0.60);
    } else if (styleId == 'french_crop' || styleId == 'buzz_cut') {
      // Phom mái bằng ngắn gọt sát
      path.moveTo(w * 0.18, h * 0.50);
      path.quadraticBezierTo(w * 0.18, h * 0.10, w * 0.50, h * 0.08);
      path.quadraticBezierTo(w * 0.82, h * 0.10, w * 0.82, h * 0.50);
      path.lineTo(w * 0.18, h * 0.50);
    } else {
      // Phom tóc ngắn cổ điển vút nhẹ
      path.moveTo(w * 0.15, h * 0.55);
      path.quadraticBezierTo(w * 0.15, h * 0.10, w * 0.50, h * 0.05);
      path.quadraticBezierTo(w * 0.85, h * 0.10, w * 0.85, h * 0.55);
      path.quadraticBezierTo(w * 0.50, h * 0.40, w * 0.15, h * 0.55);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HairStylePainter oldDelegate) {
    return oldDelegate.styleId != styleId;
  }
}

// CreBy: MenBoyBMN
