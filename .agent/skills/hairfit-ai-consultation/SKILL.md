---
name: hairfit-ai-consultation
description: Use when working on on-device face analysis, face shape classification, hairstyle recommendation, virtual try-on overlay, or the AI Haircut Handshake in HairFit AI.
risk: medium
source: workspace
---

# HairFit AI — On-device AI Consultation

> Ngưỡng/tỷ lệ thay đổi theo thời gian → LUÔN đọc `face_shape_analyzer.dart` để lấy số thật, không dùng số trong tài liệu.

## 1. Nguyên tắc
- 100% on-device bằng `google_mlkit_face_detection` (KHÔNG phải Face Mesh, KHÔNG cloud AI). Ảnh khuôn mặt không rời thiết bị.
- Không thêm package ML / API trả phí khi chưa được duyệt.

## 2. Bản đồ code (`frontend/lib/features/ai_consult/`)
| File | Vai trò |
| :--- | :--- |
| `data/face_validation_service.dart` | Gọi ML Kit, kiểm tra ảnh hợp lệ (1 khuôn mặt, góc, kích thước) |
| `domain/face_shape_analyzer.dart` | Từ `face.contours[FaceContourType.face]` tính `FaceAnthropometricMetrics`: `aspectRatio` (cao/rộng gò má), `foreheadToJawRatio`, `jawSquareness` (hàm/gò má), `chinTaper` (cằm/hàm) → phân loại `FaceShape` kèm `confidence` & giải thích tiếng Việt; có fallback `oval` khi thiếu điểm |
| `domain/face_shape.dart` | `enum FaceShape` (+ `keyName`) |
| `domain/hairstyle_recommendation_engine.dart` | `FaceShapeStylingRule` → `RecommendationResult`/`RecommendedHairstyle`, tips tạo kiểu |
| `domain/ai_consultant_service.dart`, `ai_consult_result.dart` | Điều phối & kết quả |
| `data/hairstyle_repository.dart` | Lấy danh sách kiểu tóc qua API `/api/hairstyles` |
| `presentation/` | `ai_consult_screen`, `ai_result_screen`, `manual_select_screen`, `ai_spike_test_screen`, widgets camera overlay / result card / virtual try-on |
| `frontend/lib/providers/ai_consult_provider.dart` | `AIConsultNotifier`; cache dáng mặt vào `SharedPreferences` key `saved_face_shape` |

## 3. AI Haircut Handshake
- Khi đặt lịch từ kết quả AI, gửi kèm `hairstyleId`, `customerFaceShape`, `aiStylingTip`, `hairstyleImageUrl` (xem `models/appointment_model.dart` và `CreateBookingRequest` trong `ApiDtos.cs`).
- Thợ xem qua `features/appointments/presentation/widgets/ai_haircut_handshake_card.dart`.
- Lưu dáng mặt lên server: `PUT /api/users/{uid}/face-shape`.

## 4. Checklist khi sửa
- [ ] Đổi ngưỡng phân loại → cập nhật/viết test trong `frontend/test/ai_domain_test.dart` cho từng `FaceShape` bị ảnh hưởng.
- [ ] Không gọi ML Kit trong widget test — dùng fake (mẫu `FakeFaceValidationService` trong `test/ai_consult_provider_test.dart`).
- [ ] Giải thích kết quả cho người dùng bằng tiếng Việt, tránh khẳng định tuyệt đối (có `confidence`).
- [ ] `/hf-verify`.

<!-- CreBy: MenBoyBMN -->
