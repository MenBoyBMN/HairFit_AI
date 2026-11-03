// ============================================================================
// File: lib/core/utils/platform_helper.dart
// Mục đích: Tiện ích kiểm tra nền tảng (Web/Mobile) và kích thước màn hình (Responsive Breakpoints).
// Kết cấu:
//  - Các thuộc tính và phương thức tĩnh phục vụ giao diện đa nền tảng (Adaptive UI).
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Tiện ích kiểm tra nền tảng và khung nhìn Responsive cho Web & Mobile
class PlatformHelper {
  PlatformHelper._();

  /// Ngưỡng chiều rộng màn hình Desktop / Web chuẩn
  static const double desktopBreakpoint = 900.0;

  /// Ngưỡng chiều rộng màn hình Tablet
  static const double tabletBreakpoint = 600.0;

  /// Chiều rộng tối đa của vùng nội dung chính trên Web Desktop
  static const double maxWebContentWidth = 1240.0;

  /// Đang chạy trên trình duyệt Web
  static bool get isWeb => kIsWeb;

  /// Hỗ trợ quét khuôn mặt trực tiếp bằng Camera và Google ML Kit On-Device (chỉ Android/iOS)
  static bool get supportsOnDeviceCameraAI =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Kiểm tra màn hình hiện tại có đủ rộng cho giao diện Desktop / Web đa cột không
  static bool isDesktopLayout(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= desktopBreakpoint;
  }

  /// Kiểm tra màn hình hiện tại có phải kích thước Tablet không
  static bool isTabletLayout(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  /// Tính toán số cột lưới (Grid) tối ưu theo chiều rộng màn hình
  static int getResponsiveGridColumns(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktopBreakpoint) return desktop;
    if (width >= tabletBreakpoint) return tablet;
    return mobile;
  }
}

// CreBy: MenBoyBMN
