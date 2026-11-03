---
trigger: glob
globs: backend/HairFit.Api/**/*.cs, backend/HairFit.Api.Tests/**/*.cs
description: Quy chuẩn ASP.NET Core 8 + EF Core + SQL Server cho backend chính của HairFit AI.
---

# ASP.NET Core Backend Rules

## 1. Cấu trúc
- `Controllers/` — 1 controller / domain (`Users`, `Barbers`, `Bookings`, `Appointments`, `Hairstyles`, `Admin`, `Seed`).
- `Models/Entities.cs` — EF entities. `DTOs/ApiDtos.cs` — request/response. `Data/AppDbContext.cs` — index & cấu hình. `Data/DbInitializer.cs` — tạo DB + seed.
- `Program.cs` — DI, SQL Server, Firebase JwtBearer (`Authority = https://securetoken.google.com/{projectId}`), CORS, Swagger.

## 2. Contract với Flutter
- JSON camelCase. Lỗi nghiệp vụ trả `{ code: "UPPER_SNAKE", message: "<tiếng Việt>" }` với status phù hợp (`400` validate, `404`, `409` xung đột slot).
- Mã lỗi đang được Flutter map: `SLOT_ALREADY_BOOKED`, `MAX_BOOKINGS_EXCEEDED`, `LEAD_TIME_VIOLATION`, `MAX_DAYS_EXCEEDED`, `BOOKING_ERROR`... → không đổi tên khi chưa cập nhật `frontend/lib/features/booking/data/booking_repository.dart`.
- Đổi route/DTO → cập nhật Node (`backend/routes/api.js`) hoặc hỏi người dùng (xem rule parity).

## 3. Toàn vẹn đặt lịch (bất biến)
- Tạo / đổi lịch: `BeginTransactionAsync(IsolationLevel.Serializable)` + unique index `BookedSlots(BarberId, Date, Time)` + bắt `DbUpdateException` → `409 SLOT_ALREADY_BOOKED`.
- Hủy lịch: cùng transaction cập nhật `Appointment.Status = "cancelled"` và xóa `BookedSlots` liên quan.
- Slot id: `{barberId}_{YYYY-MM-DD}_{HH-mm}`. Timezone nghiệp vụ: `Asia/Ho_Chi_Minh`.
- Không bao giờ tách các bước trên ra nhiều `SaveChangesAsync` ngoài transaction.

## 4. EF Core
- Truy vấn chỉ đọc: `.AsNoTracking()`. Tránh N+1 (dùng `Include`/projection `Select`). Danh sách có thể lớn → phân trang/`Take`.
- Thay đổi Entity/Index → nêu rõ trong kế hoạch; kiểm tra `DbInitializer` có cần chỉnh không (dự án dùng tạo DB tự động — xác minh trước khi giả định có Migrations).
- Async toàn bộ (`...Async`), không `.Result`/`.Wait()`.

## 5. Bảo mật
- Endpoint mới phải cân nhắc `[Authorize]` + kiểm tra vai trò/chủ sở hữu từ claims (Firebase `user_id`/`sub`), KHÔNG tin `customerId`/`barberId`/`role` gửi lên trong body.
- Không log token, mật khẩu, số điện thoại đầy đủ. Không commit secret vào `appsettings.json`.

## 6. Kiểm chứng
```powershell
dotnet build backend/HairFit.Backend.sln
dotnet test  backend/HairFit.Backend.sln
```
Test dùng EF InMemory (`HairFit.Api.Tests/ApiIntegrationTests.cs`) — InMemory KHÔNG kiểm chứng được transaction/unique index thật; nêu rõ giới hạn này khi báo cáo về concurrency.

<!-- CreBy: MenBoyBMN -->

