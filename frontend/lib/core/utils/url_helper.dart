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

  /// Mở ứng dụng bản đồ chỉ đường tới toạ độ hoặc địa chỉ cụ thể
  static Future<bool> openMapDirections({
    double? latitude,
    double? longitude,
    String? address,
    String? title,
  }) async {
    final hasValidCoords = latitude != null &&
        longitude != null &&
        latitude != 0 &&
        longitude != 0;

    // 1. Thử mở qua Native Map Scheme trên thiết bị di động nếu có toạ độ
    if (hasValidCoords && !kIsWeb) {
      final safeTitle = title?.trim().isNotEmpty == true ? title!.trim() : 'Tiệm cắt tóc';
      final geoUri = Uri.parse(
        'geo:$latitude,$longitude?q=$latitude,$longitude(${Uri.encodeComponent(safeTitle)})',
      );
      try {
        if (await canLaunchUrl(geoUri)) {
          final launched = await launchUrl(
            geoUri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) return true;
        }
      } catch (e) {
        debugPrint('Không thể mở native geo URI: $e');
      }
    }

    // 2. Mở qua Google Maps Directions Navigation chuẩn
    Uri webUri;
    if (hasValidCoords) {
      webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
      );
    } else {
      final queryParts = <String>[];
      if (title != null && title.trim().isNotEmpty) {
        queryParts.add(title.trim());
      }
      if (address != null && address.trim().isNotEmpty) {
        queryParts.add(address.trim());
      }

      if (queryParts.isNotEmpty) {
        webUri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(queryParts.join(', '))}',
        );
      } else {
        return false;
      }
    }

    try {
      return await launchUrl(
        webUri,
        mode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Error opening map directions: $e');
      return false;
    }
  }
}

// CreBy: MenBoyBMN
