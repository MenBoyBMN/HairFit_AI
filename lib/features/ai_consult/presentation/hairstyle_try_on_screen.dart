// ============================================================================
// File: lib/features/ai_consult/presentation/hairstyle_try_on_screen.dart
// Purpose: Virtual Hairstyle Try-On Filter AR Screen (Bộ lọc thử tóc ảo).
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/seed_data_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/hairstyle_model.dart';

class HairstyleTryOnScreen extends ConsumerStatefulWidget {
  final String? initialHairstyleId;

  const HairstyleTryOnScreen({
    super.key,
    this.initialHairstyleId,
  });

  @override
  ConsumerState<HairstyleTryOnScreen> createState() => _HairstyleTryOnScreenState();
}

class _HairstyleTryOnScreenState extends ConsumerState<HairstyleTryOnScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  late List<HairstyleModel> _hairstyles;
  late HairstyleModel _currentStyle;

  // Transform controls for overlay filter image
  double _scale = 1.0;
  double _offsetX = 0.0;
  double _offsetY = -50.0;
  double _rotation = 0.0;
  double _opacity = 0.9;

  @override
  void initState() {
    super.initState();
    _hairstyles = SeedDataService.sampleHairstyles;
    if (widget.initialHairstyleId != null) {
      _currentStyle = _hairstyles.firstWhere(
        (h) => h.id == widget.initialHairstyleId,
        orElse: () => _hairstyles.first,
      );
    } else {
      _currentStyle = _hairstyles.first;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );
      if (file != null) {
        setState(() {
          _selectedImage = file;
          _offsetX = 0.0;
          _offsetY = -50.0;
          _scale = 1.0;
          _rotation = 0.0;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể chọn ảnh: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bộ Lọc Thử Tóc Ảo (AR Filter)'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Đặt lại vị trí',
            onPressed: () {
              setState(() {
                _scale = 1.0;
                _offsetX = 0.0;
                _offsetY = -50.0;
                _rotation = 0.0;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Main Preview Area with Face Overlay Filter
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(AppDimensions.lg),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: AppDimensions.borderRadiusLg,
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: AppDimensions.borderRadiusLg,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_selectedImage != null)
                      Image.file(
                        File(_selectedImage!.path),
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.lg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.face_retouching_natural, size: 64, color: AppColors.textSecondary),
                              const SizedBox(height: AppDimensions.md),
                              const Text(
                                'Vui lòng chọn ảnh chân dung để bắt đầu thử tóc ảo',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppDimensions.lg),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                                    onPressed: () => _pickImage(ImageSource.camera),
                                    icon: const Icon(Icons.camera_alt),
                                    label: const Text('Chụp ảnh'),
                                  ),
                                  const SizedBox(width: AppDimensions.md),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
                                    onPressed: () => _pickImage(ImageSource.gallery),
                                    icon: const Icon(Icons.photo_library),
                                    label: const Text('Thư viện'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Hairstyle Overlay Filter
                    if (_selectedImage != null)
                      Positioned(
                        left: MediaQuery.of(context).size.width / 2 - 120 + _offsetX,
                        top: MediaQuery.of(context).size.height * 0.22 + _offsetY,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              _offsetX += details.delta.dx;
                              _offsetY += details.delta.dy;
                            });
                          },
                          child: Transform(
                            transform: Matrix4.identity()
                              ..scale(_scale)
                              ..rotateZ(_rotation),
                            alignment: Alignment.center,
                            child: Opacity(
                              opacity: _opacity,
                              child: Image.network(
                                _currentStyle.imageUrl,
                                width: 240,
                                height: 240,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 240,
                                  height: 240,
                                  color: Colors.orange.withValues(alpha: 0.3),
                                  child: const Center(child: Text('Lỗi tải ảnh tóc', style: TextStyle(color: Colors.white))),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Controls & Sliders (Scale, Rotation, Opacity)
          if (_selectedImage != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppDimensions.borderRadiusMd,
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Kích thước:', style: AppTextStyles.caption),
                        Expanded(
                          child: Slider(
                            value: _scale,
                            min: 0.5,
                            max: 2.0,
                            activeColor: AppColors.accent,
                            onChanged: (val) => setState(() => _scale = val),
                          ),
                        ),
                        Text('${(_scale * 100).toStringAsFixed(0)}%', style: AppTextStyles.caption),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Độ mờ/thật:', style: AppTextStyles.caption),
                        Expanded(
                          child: Slider(
                            value: _opacity,
                            min: 0.3,
                            max: 1.0,
                            activeColor: AppColors.primary,
                            onChanged: (val) => setState(() => _opacity = val),
                          ),
                        ),
                        Text('${(_opacity * 100).toStringAsFixed(0)}%', style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
          ],

          // Hairstyle Catalog Selector (Horizontal Carousel)
          SizedBox(
            height: 105,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
              scrollDirection: Axis.horizontal,
              itemCount: _hairstyles.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.sm),
              itemBuilder: (context, index) {
                final style = _hairstyles[index];
                final isSelected = style.id == _currentStyle.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentStyle = style;
                    });
                  },
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: AppDimensions.borderRadiusMd,
                      border: Border.all(
                        color: isSelected ? AppColors.accent : AppColors.divider,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusMd)),
                          child: Image.network(
                            style.imageUrl,
                            width: 80,
                            height: 65,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 65,
                              color: AppColors.inputBackground,
                              child: const Icon(Icons.image),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            style.name,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppDimensions.md),

          // Bottom Action Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
            child: Row(
              children: [
                Expanded(
                  child: AppButton.outline(
                    text: 'Đổi ảnh',
                    icon: const Icon(Icons.camera_alt_outlined, size: 16),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: AppButton(
                    text: 'Đặt Lịch Kiểu Này',
                    icon: const Icon(Icons.calendar_month_rounded, size: 16, color: Colors.white),
                    onPressed: () {
                      context.push('/customer/search?hairstyleId=${_currentStyle.id}');
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.xl),
        ],
      ),
    );
  }
}

// CreBy: MenBoyBMN
