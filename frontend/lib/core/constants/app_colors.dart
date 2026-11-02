// ============================================================================
// File: lib/core/constants/app_colors.dart
// Mục đích: Lưu trữ các hằng số dùng chung toàn ứng dụng.
// Kết cấu:
//  - Các biến static const như màu sắc, kích thước, text style hoặc business rules.
// ============================================================================

import 'package:flutter/material.dart';

/// Bảng màu chuẩn của ứng dụng HairFit AI theo Design System
class AppColors {
  AppColors._();

  // Primary & Accent Brand Colors
  static const Color primary = Color(0xFF1A1A2E); // Dark Navy - Màu chủ đạo
  static const Color accent = Color(0xFFE94560); // Coral Red - CTA, điểm nhấn
  static const Color secondary = Color(
    0xFF16213E,
  ); // Deep Blue - Màu phụ, thanh header
  static const Color tertiary = Color(0xFF0F3460); // Dark Blue Navy

  // Surface & Backgrounds
  static const Color surface = Color(0xFFFFFFFF); // Card, Dialog, BottomSheet
  static const Color background = Color(0xFFF5F6FA); // Scaffold background
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF8F9FD);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A2E); // Chữ đậm, tiêu đề
  static const Color textSecondary = Color(0xFF8E8E93); // Chữ phụ, caption
  static const Color textMuted = Color(0xFFA0A0AB); // Chữ placeholder
  static const Color textOnPrimary = Color(
    0xFFFFFFFF,
  ); // Chữ trên nền tối/accent

  // Status & Feedback Colors
  static const Color success = Color(
    0xFF34C759,
  ); // Xanh lá (Approved, Confirmed, Completed)
  static const Color successLight = Color(0xFFE8F9ED);
  static const Color successBorder = Color(0xFFC7EBD1);
  static const Color warning = Color(0xFFFF9500); // Cam (Pending)
  static const Color warningLight = Color(0xFFFFF4E5);
  static const Color warningBorder = Color(0xFFFFE0B2);
  static const Color error = Color(0xFFFF3B30); // Đỏ (Rejected, Cancelled, Lỗi)
  static const Color errorLight = Color(0xFFFFEBEA);
  static const Color errorBorder = Color(0xFFFFD1CF);
  static const Color info = Color(0xFF007AFF); // Xanh dương thông tin
  static const Color infoLight = Color(0xFFE5F1FF);

  // Status Badge Auxiliary Colors
  static const Color statusCompletedBg = Color(0xFFE8EEF8);
  static const Color statusCompletedBorder = Color(0xFFC4D5F0);
  static const Color statusCancelledBg = Color(0xFFF0F0F2);

  // Star & Rating
  static const Color starRating = Color(0xFFFFB800);

  // AI Handshake & Smart Features
  static const Color aiHandshake = Color(
    0xFF6C5CE7,
  ); // Tím AI Handshake & AI Profile
  static const Color aiHandshakeLight = Color(0xFFF7F5FF);

  // Dark Gradients Auxiliaries
  static const Color surfaceDarkGradient = Color(0xFF1E272E);
  static const Color urgentRedGradientStart = Color(0xFFEA2027);
  static const Color urgentRedGradientEnd = Color(0xFFC0392B);

  // UI Borders & Dividers
  static const Color divider = Color(0xFFE5E5EA);
  static const Color border = Color(0xFFE0E0E6);
  static const Color borderFocused = Color(0xFF1A1A2E);
  static const Color shadow = Color(0x0D000000); // 5% black shadow

  // Shimmer Effect Colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE94560), Color(0xFFFF6B81)],
  );

  static const LinearGradient aiBannerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF0F3460), Color(0xFFE94560)],
  );
}

// CreBy: MenBoyBMN
