// ============================================================================
// File: lib/core/services/firebase_options.dart
// Mục đích: Cung cấp dịch vụ hạ tầng (firebase_options.dart).
// Kết cấu:
//  - Lớp Service xử lý giao tiếp với các hệ thống bên ngoài hoặc phần cứng (Firebase, Location, API).
// ============================================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

/// Cấu hình mặc định cho Firebase Options
/// Tạo bởi FlutterFire CLI hoặc cấu hình thủ công cho Android
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  /// Cấu hình Firebase cho nền tảng Android (minSdk 26, targetSdk 34)
  /// Cần thay thế các giá trị bên dưới bằng thông tin từ Firebase Console của bạn
  /// hoặc chạy lệnh: flutterfire configure
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDpzCa0ifuszmNpzAhsrDVwNcqRjFvFW14',
    appId: '1:533272743401:android:92647daf12c7b455128f78',
    messagingSenderId: '533272743401',
    projectId: 'hairfitai-c4855',
    storageBucket: 'hairfitai-c4855.firebasestorage.app',
  );
}

// CreBy: MenBoyBMN
