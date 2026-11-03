// ============================================================================
// File: lib/features/ai_consult/data/web_face_detector_web.dart
// Mục đích: Triển khai JS Interop gọi MediaPipe Face Landmarker trên Web.
// ============================================================================

import 'dart:convert';
import 'dart:js_interop';

import 'web_face_detector.dart';

@JS('hairfitAnalyzeFaceImage')
external JSPromise<JSString> _hairfitAnalyzeFaceImage(JSString imageUrl);

Future<WebFaceAnalysisResult> analyzeFaceOnWebImpl(String imageUrl) async {
  try {
    final jsJson = await _hairfitAnalyzeFaceImage(imageUrl.toJS).toDart;
    final decoded = jsonDecode(jsJson.toDart) as Map<String, dynamic>;
    return WebFaceAnalysisResult.fromMap(decoded);
  } catch (e) {
    return WebFaceAnalysisResult(
      isValid: false,
      errorMessage: 'Không thể nhận diện khuôn mặt trong ảnh',
      errorHint:
          'Vui lòng chọn ảnh chân dung chụp rõ khuôn mặt nhìn thẳng ($e).',
    );
  }
}

// CreBy: MenBoyBMN
