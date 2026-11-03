---
trigger: glob
globs: frontend/lib/**/*.dart
description: Quy chuẩn Flutter frontend — kiến trúc feature-first, Riverpod, model, gọi API, UI tokens.
---

# Flutter Frontend Rules

## 1. Luồng dữ liệu chuẩn
```
Screen/Widget ──ref.watch──▶ Provider (lib/providers/) ──▶ Repository (features/<f>/data/) ──▶ ApiClient ──▶ ASP.NET / Node
                                                                                      └──▶ Firestore (CHỈ chat)
```
- Repository nhận `ApiClient` qua constructor (`ApiClient? apiClient`) để test được với `MockClient`.
- Không gọi `http` / `ApiClient` / `FirebaseFirestore` trực tiếp trong Widget.
- Endpoint mới: kiểm tra route tồn tại trong `backend/HairFit.Api/Controllers/*.cs` (và `backend/routes/api.js`) trước khi gọi.
- Lỗi backend trả `{ code, message }` → map sang exception có kiểu (xem `booking_repository.dart`: `SlotAlreadyBookedException`, `MaxBookingsExceededException`...), hiển thị `message` tiếng Việt.

## 2. Riverpod 2.x
- Dự án hiện dùng: `StreamProvider`, `FutureProvider`, `StateNotifierProvider` (chủ yếu), một ít `AsyncNotifierProvider`. **Theo đúng style của file đang sửa**, không migrate sang codegen/`Notifier` mới.
- `ref.watch` trong `build()`; `ref.read` trong callback; `ref.listen` cho side effect (SnackBar, điều hướng).
- Ưu tiên `.autoDispose` cho provider theo màn hình; `.family` cho provider theo id.
- Không tạo singleton tĩnh bỏ qua Riverpod (ngoại lệ có sẵn: state dò URL tĩnh trong `ApiClient`).

## 3. Models (`frontend/lib/models/`)
- Immutable, `final` fields, có `copyWith()`, `fromMap(Map<String, dynamic> map, String id)` (fallback an toàn khi thiếu field/null/sai kiểu), `toMap()`.
- Enum serialize bằng `.name`, parse có default.
- Thêm field vào model → kiểm tra DTO tương ứng trong `backend/HairFit.Api/DTOs/ApiDtos.cs` + JSON của Node; JSON key là camelCase.

## 4. UI / Design System
- Dark mode. Dùng token, cấm hardcode màu/khoảng cách:
  - `AppColors`: `background`, `surface`, `cardColor`, `inputBackground`, `primary` (#FF6B00), `accent`, `secondary`, `textPrimary`, `textSecondary`, `textMuted`, `success`, `warning`, `error`, `info`, `border`, `divider`, `aiHandshake`, gradients...
  - `AppDimensions`: spacing `xxs/xs/sm/md/lg/xl/xxl/xxxl`, `radiusXs..radiusFull`, `borderRadiusXs..`, `buttonHeight*`, `icon*`.
  - `AppTextStyles` cho typography.
  - Token chưa có → hỏi trước khi thêm vào `core/constants/`.
- Tái sử dụng widget trong `lib/core/widgets/` (`AppButton`, `AppTextField`, `EmptyState`, `ErrorRetry`, `LoadingShimmer`, `StatusBadge`, `AppAvatar`...) trước khi tạo mới.
- Mỗi màn hình dữ liệu có đủ 3 trạng thái: loading (shimmer) / error (retry) / data (+ empty).
- Chống overflow: text trong `Row` bọc `Expanded/Flexible` + `overflow: TextOverflow.ellipsis`; nội dung dài bọc scroll. Có hỗ trợ web (`web_nav_shell.dart`) → kiểm tra layout rộng.
- File màn hình > 600 dòng → widget mới đặt trong `presentation/widgets/`, không nhồi thêm vào file lớn.

## 5. Ngôn ngữ
- Chuỗi UI tiếng Việt tự nhiên, lịch sự ("Đặt lịch ngay", "Xác nhận ca hẹn"). Không hiển thị stack trace/thông điệp kỹ thuật cho người dùng.

<!-- CreBy: MenBoyBMN -->

