// ============================================================================
// File: lib/features/ai_consult/data/web_face_detector_stub.dart
// Mục đích: Stub implementation cho nền tảng Mobile/Desktop/VM Test.
// ============================================================================

import 'web_face_detector.dart';

Future<WebFaceAnalysisResult> analyzeFaceOnWebImpl(String imageUrl) async {
  return const WebFaceAnalysisResult(
    isValid: false,
    errorMessage: 'Chỉ khả dụng trên trình duyệt Web',
    errorHint: 'Trên thiết bị di động sử dụng Google ML Kit trực tiếp',
  );
}

// CreBy: MenBoyBMN
