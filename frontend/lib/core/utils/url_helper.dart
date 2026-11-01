// ============================================================================
// File: lib/core/utils/url_helper.dart
// Mục đích: Hỗ trợ mở liên kết ngoài an toàn (Bản đồ, Gọi điện thoại, Web).
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlHelper {
  const UrlHelper._();

  /// Mở ứng dụng gọi điện thoại với số điện thoại được truyền vào
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) return false;

    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      return false;
    } catch (e) {
      debugPrint('Error launching phone call: $e');
      return false;
    }
  }

  /// Mở ứng dụng bản đồ chỉ đường tới địa chỉ hoặc toạ độ
  static Future<bool> openMapDirections({
    double? latitude,
    double? longitude,
    String? address,
    String? title,
  }) async {
    Uri uri;

    if (latitude != null &&
        longitude != null &&
        latitude != 0 &&
        longitude != 0) {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
      );
    } else if (address != null && address.trim().isNotEmpty) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address.trim())}',
      );
    } else if (title != null && title.trim().isNotEmpty) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(title.trim())}',
      );
    } else {
      return false;
    }

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error opening map: $e');
      return false;
    }
  }
}

// CreBy: MenBoyBMN
