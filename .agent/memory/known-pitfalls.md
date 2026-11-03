# Known Pitfalls — Bài học xương máu (agent PHẢI đọc trước khi code)

> Mỗi khi người dùng sửa lưng agent, hoặc phát hiện cạm bẫy mới → thêm 1 dòng: `- [YYYY-MM-DD] [khu vực] Sai lầm/cạm bẫy → Cách đúng`.
> Giữ ≤ 60 dòng; gộp các mục trùng.

## Tài liệu & kiến trúc
- [2026-11-03] [docs] Tài liệu cũ mô tả booking bằng Firestore transaction & Face Mesh landmarks (10/152/234...) → SAI. Thực tế: SQL transaction ở `BookingsController.cs`; AI dùng `FaceContourType.face` trong `face_shape_analyzer.dart`.
- [2026-11-03] [ui] Token màu card là `AppColors.cardColor` (không phải `AppColors.card`).
- [2026-11-03] [ui] `Size.fromHeight(h)` đặt `width = double.infinity`; dùng trong `ButtonThemeData` gây lỗi `BoxConstraints forces an infinite width` khi đặt `OutlinedButton`/`ElevatedButton` trong `Row` → dùng `Size(0, h)`.
- [2026-11-03] [repo] Code nằm trong `frontend/` và `backend/`, không có `lib/` hay `test/` ở gốc repo. Chạy lệnh Flutter trong `frontend/`.

## Backend parity
- [2026-11-03] [parity] Flutter gọi `PATCH /api/barbers/{uid}/accepting` (.NET có), nhưng Node chỉ có `/barbers/:id/accepting-bookings` → nút tạm ngưng nhận khách hỏng khi chạy Node. Luôn chạy `/hf-api-parity` khi đụng route.

## Testing
- [2026-11-03] [test] `pumpAndSettle()` timeout với Shimmer/animation lặp → dùng `pump(Duration)`.
- [2026-11-03] [test] EF InMemory bỏ qua transaction & unique index → test .NET KHÔNG chứng minh được chống trùng lịch.

## Bảo mật (chưa xử lý — chỉ ghi nhận)
- [2026-11-03] [security] Chưa thấy `[Authorize]` trong Controllers; nhiều endpoint nhận `customerId`/`barberId` từ body/route. Không mở rộng pattern này cho endpoint mới.

<!-- CreBy: MenBoyBMN -->

