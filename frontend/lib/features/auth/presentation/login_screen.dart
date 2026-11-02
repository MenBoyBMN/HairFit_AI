// ============================================================================
// File: lib/features/auth/presentation/login_screen.dart
// Mục đích: Màn hình giao diện (Screen) chính của tính năng auth.
// Kết cấu:
//  - Sử dụng ConsumerWidget/StatefulWidget, kết nối UI với Provider để hiển thị trạng thái và xử lý sự kiện người dùng.
//  - Hỗ trợ giao diện Split-Screen 2 cột theo phong cách Antigravity trên Web/Desktop.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/platform_helper.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/antigravity_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../providers/auth_provider.dart';

/// Màn hình đăng nhập tài khoản HairFit AI (UC-01)
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authStateProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;
      // GoRouter sẽ tự động redirect khi đăng nhập thành công
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformHelper.isDesktopLayout(context);

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            // Cột trái: Antigravity Showcase Hero
            Expanded(flex: 6, child: _buildWebHeroShowcase()),
            // Cột phải: Khung biểu mẫu nổi
            Expanded(
              flex: 5,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.xxl),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: AntigravityCard(
                      enable3DTilt: false,
                      enableHoverLift: false,
                      padding: const EdgeInsets.all(AppDimensions.xl),
                      child: _buildLoginForm(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppDimensions.paddingScreen,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _buildLoginForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebHeroShowcase() {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      decoration: const BoxDecoration(gradient: AppColors.aiBannerGradient),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: AppDimensions.borderRadiusMd,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Icon(
                      Icons.content_cut_rounded,
                      size: 32,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Text(
                    'HairFit AI',
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Text(
                'Nền Tảng Tư Vấn Kiểu Tóc &\nĐặt Lịch Salon Thế Hệ Mới',
                style: AppTextStyles.h1.copyWith(
                  color: Colors.white,
                  fontSize: 34,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              Text(
                'Trải nghiệm đồng bộ trên cả Điện thoại và Trình duyệt Web. Tìm kiếm Barber hàng đầu, gợi ý kiểu tóc theo dáng mặt và đặt lịch hẹn tức thì.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              _buildHeroFeatureTile(
                Icons.auto_awesome_rounded,
                'Studio Tư Vấn Kiểu Tóc Thông Minh',
                'Gợi ý kiểu tóc chuẩn tỉ lệ vàng dựa trên dáng khuôn mặt và chất tóc.',
              ),
              const SizedBox(height: AppDimensions.md),
              _buildHeroFeatureTile(
                Icons.event_available_rounded,
                'Đặt Lịch Hẹn Chuẩn Xác Thời Gian Thực',
                'Kiểm tra khung giờ trống tự động, cam kết không trùng lịch.',
              ),
              const SizedBox(height: AppDimensions.md),
              _buildHeroFeatureTile(
                Icons.forum_rounded,
                'Trao Đổi 1:1 Trực Tiếp Với Barber',
                'Nhắn tin tư vấn trước khi đến tiệm, đồng bộ lịch sử trên mọi thiết bị.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroFeatureTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: AppDimensions.borderRadiusLg,
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.25),
              borderRadius: AppDimensions.borderRadiusSm,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h4.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppDimensions.borderRadiusLg,
              ),
              child: const Icon(
                Icons.content_cut_rounded,
                size: 40,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          const Text(
            'Chào Mừng Trở Lại',
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            'Đăng nhập để đặt lịch và trải nghiệm tư vấn kiểu tóc AI',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.xxl),

          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: AppDimensions.borderRadiusMd,
                border: Border.all(color: AppColors.error),
              ),
              child: Text(
                _errorMessage!,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
          ],

          AppTextField(
            label: 'Email',
            hintText: 'Nhập địa chỉ email của bạn',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            prefixIcon: const Icon(
              Icons.email_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.lg),

          AppTextField(
            label: 'Mật khẩu',
            hintText: 'Nhập mật khẩu (tối thiểu 6 ký tự)',
            controller: _passwordController,
            isPassword: true,
            validator: Validators.password,
            prefixIcon: const Icon(
              Icons.lock_outline,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/forgot-password'),
              child: const Text('Quên mật khẩu?'),
            ),
          ),
          const SizedBox(height: AppDimensions.md),

          AppButton(
            text: 'Đăng nhập',
            isLoading: _isLoading,
            onPressed: _handleLogin,
          ),
          const SizedBox(height: AppDimensions.xl),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Chưa có tài khoản? ',
                style: AppTextStyles.bodyMedium,
              ),
              GestureDetector(
                onTap: () => context.push('/register'),
                child: Text(
                  'Đăng ký ngay',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// CreBy: MenBoyBMN
