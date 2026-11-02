// ============================================================================
// File: lib/features/barber_profile/presentation/barber_edit_screen.dart
// Mục đích: Màn hình giao diện (Screen) chính của tính năng barber_profile.
// Kết cấu:
//  - Sử dụng ConsumerWidget/StatefulWidget, kết nối UI với Provider để hiển thị trạng thái và xử lý sự kiện người dùng.
// ============================================================================

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/platform_helper.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_retry.dart';
import '../../../../core/widgets/web_nav_shell.dart';
import '../../../../models/barber_profile_model.dart';
import '../../../../models/service_model.dart';
import '../../../../providers/auth_provider.dart';
import '../data/barber_profile_repository.dart';
import 'widgets/hairstyle_picker.dart';
import 'widgets/location_picker.dart';
import 'widgets/service_editor.dart';
import 'widgets/working_hours_editor.dart';

/// Màn hình chỉnh sửa hồ sơ thợ cắt tóc đã tạo (Task 6.5)
class BarberEditScreen extends ConsumerStatefulWidget {
  const BarberEditScreen({super.key});

  @override
  ConsumerState<BarberEditScreen> createState() => _BarberEditScreenState();
}

class _BarberEditScreenState extends ConsumerState<BarberEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isInitialized = false;
  bool _isSaving = false;

  late final TextEditingController _nameController;
  late final TextEditingController _bioController;

  String _avatarUrl = '';
  Uint8List? _pickedAvatarBytes;

  String _coverUrl = '';
  Uint8List? _pickedCoverBytes;

  String _address = '';
  GeoLocation _location = const GeoLocation(latitude: 0, longitude: 0);
  List<ServiceModel> _services = [];
  List<String> _hairstyleIds = [];
  List<String> _portfolioUrls = [];
  Map<String, DayWorkingHours> _workingHours = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _populateData(BarberProfileModel profile) {
    if (_isInitialized) return;
    final currentUser = ref.read(authStateProvider).value;
    _nameController.text = profile.displayName;
    _bioController.text = profile.bio;
    _avatarUrl = profile.avatarUrl.isNotEmpty
        ? profile.avatarUrl
        : (currentUser?.avatarUrl ?? '');
    _coverUrl = profile.coverUrl;
    _address = profile.address;
    _location = profile.location;
    _services = List.from(profile.services);
    _hairstyleIds = List.from(profile.hairstyleIds);
    _portfolioUrls = List.from(profile.portfolioUrls);
    _workingHours = Map.from(profile.workingHours);
    _isInitialized = true;
  }

  Future<void> _pickAvatarImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _pickedAvatarBytes = bytes;
          _avatarUrl = base64String;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể chọn ảnh đại diện: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showAvatarImageSourceModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                const Text(
                  'Chọn ảnh đại diện thợ cắt tóc',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: AppDimensions.sm),
                if (!kIsWeb)
                  ListTile(
                    leading: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.accent,
                    ),
                    title: const Text(
                      'Chụp ảnh từ máy ảnh',
                      style: AppTextStyles.bodyMedium,
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _pickAvatarImage(ImageSource.camera);
                    },
                  ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.accent,
                  ),
                  title: const Text(
                    'Chọn ảnh từ thư viện',
                    style: AppTextStyles.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickAvatarImage(ImageSource.gallery);
                  },
                ),
                if (_avatarUrl.isNotEmpty || _pickedAvatarBytes != null)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                    title: const Text(
                      'Xóa ảnh đại diện',
                      style: TextStyle(color: AppColors.error),
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      setState(() {
                        _avatarUrl = '';
                        _pickedAvatarBytes = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickCoverImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 700,
        imageQuality: 80,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _pickedCoverBytes = bytes;
          _coverUrl = base64String;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể chọn ảnh bìa: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showCoverImageSourceModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                const Text('Chọn ảnh bìa tiệm tóc', style: AppTextStyles.h4),
                const SizedBox(height: AppDimensions.sm),
                if (!kIsWeb)
                  ListTile(
                    leading: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.accent,
                    ),
                    title: const Text(
                      'Chụp ảnh từ máy ảnh',
                      style: AppTextStyles.bodyMedium,
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _pickCoverImage(ImageSource.camera);
                    },
                  ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.accent,
                  ),
                  title: const Text(
                    'Chọn ảnh từ thư viện',
                    style: AppTextStyles.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickCoverImage(ImageSource.gallery);
                  },
                ),
                if (_coverUrl.isNotEmpty || _pickedCoverBytes != null)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                    title: const Text(
                      'Xóa ảnh bìa',
                      style: TextStyle(color: AppColors.error),
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      setState(() {
                        _coverUrl = '';
                        _pickedCoverBytes = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave(BarberProfileModel originalProfile) async {
    if (!_formKey.currentState!.validate()) return;

    if (_address.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập địa chỉ tiệm tóc'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tiệm cần có ít nhất 1 dịch vụ'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_hairstyleIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất 1 kiểu tóc tiệm hỗ trợ'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) throw Exception('Người dùng chưa đăng nhập');

      // Tự động tính lại priceMin và priceMax từ danh sách dịch vụ
      final activePrices = _services
          .where((s) => s.active)
          .map((s) => s.price)
          .toList();
      final allPrices = _services.map((s) => s.price).toList();
      final pricesToUse = activePrices.isNotEmpty ? activePrices : allPrices;
      final priceMin = pricesToUse.reduce(min);
      final priceMax = pricesToUse.reduce(max);

      final updatedProfile = originalProfile.copyWith(
        displayName: _nameController.text.trim(),
        avatarUrl: _avatarUrl.trim(),
        bio: _bioController.text.trim(),
        coverUrl: _coverUrl.trim(),
        address: _address.trim(),
        location: _location,
        services: _services,
        hairstyleIds: _hairstyleIds,
        workingHours: _workingHours,
        portfolioUrls: _portfolioUrls,
        priceMin: priceMin,
        priceMax: priceMax,
        updatedAt: DateTime.now(),
      );

      final repo = ref.read(barberProfileRepositoryProvider);
      await repo.createOrUpdateProfile(updatedProfile);

      // Cập nhật tên và avatar trong tài khoản người dùng nếu có thay đổi
      final nameChanged = _nameController.text.trim() != user.displayName;
      final avatarChanged =
          _avatarUrl.trim().isNotEmpty && _avatarUrl.trim() != user.avatarUrl;
      if (nameChanged || avatarChanged) {
        await ref
            .read(authStateProvider.notifier)
            .updateProfile(
              displayName: _nameController.text.trim(),
              avatarUrl: _avatarUrl.trim(),
            );
      }

      ref.invalidate(barberProfileProvider(user.uid));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật hồ sơ tiệm tóc thành công!'),
          backgroundColor: AppColors.success,
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi cập nhật hồ sơ: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chỉnh Sửa Hồ Sơ')),
        body: Center(
          child: EmptyState(
            icon: Icons.person_off_outlined,
            title: 'Chưa đăng nhập',
            message: 'Vui lòng đăng nhập với vai trò thợ cắt tóc.',
            actionText: 'Đăng nhập',
            onAction: () => context.go('/login'),
          ),
        ),
      );
    }

    final profileAsync = ref.watch(barberProfileProvider(user.uid));
    final isDesktop = PlatformHelper.isDesktopLayout(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isDesktop
          ? const WebTopNavBar(
              currentRoute: '/barber/profile-edit',
              isBarber: true,
            )
          : AppBar(
              title: const Text(
                'Chỉnh Sửa Hồ Sơ Tiệm Tóc',
                style: AppTextStyles.h3,
              ),
              centerTitle: true,
            ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (err, _) => Center(
          child: ErrorRetry(
            errorMessage: 'Không thể tải hồ sơ thợ: $err',
            onRetry: () => ref.refresh(barberProfileProvider(user.uid)),
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: EmptyState(
                icon: Icons.storefront_outlined,
                title: 'Chưa có hồ sơ thợ',
                message: 'Bạn chưa tạo hồ sơ tiệm tóc. Hãy tiến hành tạo mới.',
                actionText: 'Tạo hồ sơ ngay',
                onAction: () =>
                    context.pushReplacement('/barber/profile-setup'),
              ),
            );
          }

          _populateData(profile);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thông tin cơ bản
                      _buildSectionHeader('1. Thông tin tiệm tóc'),
                      const SizedBox(height: AppDimensions.sm),
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppDimensions.borderRadiusMd,
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAvatarPicker(),
                            const SizedBox(height: AppDimensions.lg),
                            AppTextField(
                              controller: _nameController,
                              label: 'Tên tiệm tóc / Nghệ danh',
                              hintText: 'Ví dụ: HairFit Barber Studio',
                              prefixIcon: const Icon(Icons.storefront_outlined),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Vui lòng nhập tên tiệm';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppDimensions.md),
                            AppTextField(
                              controller: _bioController,
                              label: 'Giới thiệu ngắn (Bio)',
                              hintText: 'Kinh nghiệm, phong cách tạo mẫu...',
                              prefixIcon: const Icon(
                                Icons.description_outlined,
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: AppDimensions.lg),
                            _buildCoverImagePicker(),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xl),

                      // Địa chỉ & Vị trí bản đồ
                      _buildSectionHeader('2. Địa chỉ & Vị trí bản đồ'),
                      const SizedBox(height: AppDimensions.sm),
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppDimensions.borderRadiusMd,
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: LocationPicker(
                          initialAddress: _address,
                          initialLocation: _location,
                          onChanged: (addr, loc) {
                            _address = addr;
                            _location = loc;
                          },
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xl),

                      // Dịch vụ cung cấp
                      _buildSectionHeader('3. Danh sách dịch vụ & Bảng giá'),
                      const SizedBox(height: AppDimensions.sm),
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppDimensions.borderRadiusMd,
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: ServiceEditor(
                          initialServices: _services,
                          onChanged: (services) {
                            _services = services;
                          },
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xl),

                      // Kiểu tóc hỗ trợ
                      _buildSectionHeader('4. Kiểu tóc chuyên môn'),
                      const SizedBox(height: AppDimensions.sm),
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppDimensions.borderRadiusMd,
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: HairstylePicker(
                          initialSelectedIds: _hairstyleIds,
                          onChanged: (ids) {
                            _hairstyleIds = ids;
                          },
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xl),

                      // Giờ làm việc
                      _buildSectionHeader('5. Giờ làm việc trong tuần'),
                      const SizedBox(height: AppDimensions.sm),
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppDimensions.borderRadiusMd,
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: WorkingHoursEditor(
                          initialHours: _workingHours,
                          onChanged: (hours) {
                            _workingHours = hours;
                          },
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xl),

                      // Album tác phẩm nổi bật (Portfolio) (Phase 5 - Task B4)
                      _buildPortfolioSection(),
                      const SizedBox(height: AppDimensions.xxl),

                      // Nút Lưu thay đổi
                      AppButton(
                        text: 'Lưu Cập Nhật Hồ Sơ',
                        icon: const Icon(Icons.save_outlined, size: 18),
                        isLoading: _isSaving,
                        onPressed: () => _handleSave(profile),
                      ),
                      const SizedBox(height: AppDimensions.md),
                      AppButton(
                        text: 'Hủy Bỏ',
                        variant: AppButtonVariant.secondary,
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(height: AppDimensions.xl),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoverImagePicker() {
    final imageProvider = _getCoverImageProvider();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ảnh bìa tiệm (Cover Image)',
              style: AppTextStyles.labelMedium,
            ),
            if (imageProvider != null)
              TextButton.icon(
                onPressed: _showCoverImageSourceModal,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppColors.accent,
                ),
                label: const Text(
                  'Thay đổi',
                  style: TextStyle(color: AppColors.accent, fontSize: 13),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.xs),
        GestureDetector(
          onTap: _showCoverImageSourceModal,
          child: Container(
            width: double.infinity,
            height: 170,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppDimensions.borderRadiusMd,
              border: Border.all(
                color: imageProvider != null
                    ? AppColors.accent.withValues(alpha: 0.5)
                    : AppColors.divider,
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: AppDimensions.borderRadiusMd,
              child: imageProvider != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 40,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _coverUrl = '';
                                _pickedCoverBytes = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.sm),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 32,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        const Text(
                          'Tải lên ảnh bìa không gian tiệm',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Khách hàng sẽ nhìn thấy ảnh này đầu tiên khi xem tiệm',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ảnh đại diện thợ (Avatar)',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: AppDimensions.sm),
        Row(
          children: [
            GestureDetector(
              onTap: _showAvatarImageSourceModal,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (_pickedAvatarBytes != null)
                    ClipRRect(
                      borderRadius: AppDimensions.borderRadiusMd,
                      child: Image.memory(
                        _pickedAvatarBytes!,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    AppAvatar(
                      imageUrl: _avatarUrl,
                      fallbackUrl: _coverUrl,
                      name: _nameController.text.isNotEmpty
                          ? _nameController.text
                          : 'Thợ',
                      width: 76,
                      height: 76,
                      borderRadius: AppDimensions.borderRadiusMd,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.person_rounded,
                    ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: _showAvatarImageSourceModal,
                    icon: const Icon(Icons.photo_camera_outlined, size: 16),
                    label: Text(
                      _avatarUrl.isNotEmpty || _pickedAvatarBytes != null
                          ? 'Đổi ảnh đại diện'
                          : 'Tải ảnh đại diện',
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ảnh đại diện sẽ hiển thị ở thẻ Thợ nổi bật, Tìm kiếm và Bản đồ.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  ImageProvider? _getCoverImageProvider() {
    if (_pickedCoverBytes != null) {
      return MemoryImage(_pickedCoverBytes!);
    }
    final url = _coverUrl.trim();
    if (url.isEmpty) return null;
    if (url.startsWith('data:image')) {
      try {
        final commaIdx = url.indexOf(',');
        final base64Str = commaIdx != -1 ? url.substring(commaIdx + 1) : url;
        return MemoryImage(base64Decode(base64Str));
      } catch (_) {
        return null;
      }
    }
    return NetworkImage(url);
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.h4.copyWith(color: AppColors.primary),
    );
  }

  Future<void> _pickPortfolioImage(ImageSource source) async {
    if (_portfolioUrls.length >= 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tối đa 8 ảnh trong Album tác phẩm'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 75,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _portfolioUrls.add(base64String);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể chọn ảnh: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showAddPortfolioImageModal() {
    if (_portfolioUrls.length >= 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Album đã đạt giới hạn tối đa 8 ảnh'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              const Text('Thêm ảnh mẫu tóc đã cắt', style: AppTextStyles.h4),
              const SizedBox(height: AppDimensions.sm),
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.accent,
                  ),
                  title: const Text(
                    'Chụp ảnh mới',
                    style: AppTextStyles.bodyMedium,
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickPortfolioImage(ImageSource.camera);
                  },
                ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.accent,
                ),
                title: const Text(
                  'Chọn ảnh từ thư viện',
                  style: AppTextStyles.bodyMedium,
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickPortfolioImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('6. Album tác phẩm thực tế (Lookbook)'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_portfolioUrls.length}/8 ảnh',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.xs),
        const Text(
          'Đăng tải các mẫu tóc đẹp nhất bạn từng tạo kiểu để khách hàng tự tin đặt lịch',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
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
              if (_portfolioUrls.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.md,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.collections_outlined,
                          size: 40,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AppDimensions.xs),
                        const Text(
                          'Chưa có ảnh tác phẩm nào',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: _portfolioUrls.length,
                  itemBuilder: (context, index) {
                    final imgUrl = _portfolioUrls[index];
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildPortfolioImageWidget(imgUrl),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _portfolioUrls.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: AppDimensions.sm),
              if (_portfolioUrls.length < 8)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimensions.borderRadiusSm,
                      ),
                    ),
                    icon: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      'Thêm ảnh tác phẩm (+)',
                      style: TextStyle(fontSize: 13),
                    ),
                    onPressed: _showAddPortfolioImageModal,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioImageWidget(String target) {
    if (target.startsWith('data:image')) {
      try {
        final commaIdx = target.indexOf(',');
        final base64Str = commaIdx != -1
            ? target.substring(commaIdx + 1)
            : target;
        return Image.memory(base64Decode(base64Str), fit: BoxFit.cover);
      } catch (_) {
        return Container(color: AppColors.inputBackground);
      }
    }
    return Image.network(
      target,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(color: AppColors.inputBackground),
    );
  }
}

// CreBy: MenBoyBMN
