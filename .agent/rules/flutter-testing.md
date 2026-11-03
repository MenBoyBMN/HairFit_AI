---
trigger: glob
globs: frontend/test/**/*.dart
description: Quy chuẩn viết và sửa test Flutter (unit + widget) cho HairFit AI.
---

# Flutter Testing Rules

## 1. Cổng chất lượng
- `flutter analyze` → `No issues found!`; `flutter test` → all passed (chạy trong `frontend/`).
- Chạy nhanh 1 file khi đang lặp: `flutter test test/<file>_test.dart`; trước khi bàn giao chạy toàn bộ.

## 2. Cô lập phụ thuộc
- Widget test KHÔNG được khởi tạo Firebase/Firestore/Camera/HTTP thật.
- Override provider qua `ProviderScope(overrides: [...])`.
- Repository/ApiClient: dùng `MockClient` từ `package:http/testing.dart` (xem `test/api_client_test.dart`).
- Notifier giả: kế thừa và override (mẫu có sẵn: `FakeAuthNotifier` trong `test/admin_portal_test.dart`, `MockSearchNotifier` trong `test/barber_detail_test.dart`). Tìm và tái sử dụng mẫu có sẵn trước khi viết fake mới.

## 3. Viewport & animation
- Màn hình dài: đặt `tester.view.physicalSize = const Size(1200, 1600); tester.view.devicePixelRatio = 1.0;` + `addTearDown(tester.view.reset...)`, hoặc `scrollUntilVisible`.
- Có `Shimmer`/animation lặp vô hạn → dùng `tester.pump(const Duration(milliseconds: 300))`, KHÔNG `pumpAndSettle()` (sẽ timeout).

## 4. Nguyên tắc
- Sửa bug → thêm test tái hiện bug (fail trước, pass sau) nếu khả thi.
- Không xóa/skip/nới lỏng assert để test pass. Nếu test sai → giải thích lý do trong báo cáo.
- Đặt tên test mô tả hành vi: `'shows SLOT_ALREADY_BOOKED message when slot is taken'`.

<!-- CreBy: MenBoyBMN -->

