// ============================================================================
// File: lib/features/ai_consult/data/web_face_detector.dart
// Mục đích: Cầu nối đa nền tảng cho tính năng nhận diện và đo đạc khuôn mặt
//           trên trình duyệt Web (MediaPipe Face Landmarker On-Device WASM).
// ============================================================================

import 'web_face_detector_stub.dart'
    if (dart.library.js_interop) 'web_face_detector_web.dart';

/// Kết quả kiểm tra và đo đạc nhân trắc học khuôn mặt trên trình duyệt Web
class WebFaceAnalysisResult {
  final bool isValid;
  final String? errorMessage;
  final String? errorHint;
  final double faceHeight;
  final double cheekboneWidth;
  final double foreheadWidth;
  final double jawlineWidth;
  final double chinWidth;
  final int contourPointsCount;

  const WebFaceAnalysisResult({
    required this.isValid,
    this.errorMessage,
    this.errorHint,
    this.faceHeight = 0,
    this.cheekboneWidth = 0,
    this.foreheadWidth = 0,
    this.jawlineWidth = 0,
    this.chinWidth = 0,
    this.contourPointsCount = 36,
  });

  factory WebFaceAnalysisResult.fromMap(Map<String, dynamic> map) {
    return WebFaceAnalysisResult(
      isValid: map['isValid'] == true,
      errorMessage: map['errorMessage']?.toString(),
      errorHint: map['errorHint']?.toString(),
      faceHeight: (map['faceHeight'] as num?)?.toDouble() ?? 0,
      cheekboneWidth: (map['cheekboneWidth'] as num?)?.toDouble() ?? 0,
      foreheadWidth: (map['foreheadWidth'] as num?)?.toDouble() ?? 0,
      jawlineWidth: (map['jawlineWidth'] as num?)?.toDouble() ?? 0,
      chinWidth: (map['chinWidth'] as num?)?.toDouble() ?? 0,
      contourPointsCount: (map['contourPointsCount'] as num?)?.toInt() ?? 36,
    );
  }
}

/// Phân tích khuôn mặt từ URL/Blob ảnh trên trình duyệt Web
Future<WebFaceAnalysisResult> analyzeFaceOnWeb(String imageUrl) =>
    analyzeFaceOnWebImpl(imageUrl);

// CreBy: MenBoyBMN
