---
name: hairfit-booking-engine
description: Use when touching booking, slots, reschedule, cancel, barber break blocking, or double-booking protection in HairFit AI (Flutter booking/appointments features + ASP.NET BookingsController/AppointmentsController + Node mirror).
risk: high
source: workspace
---

# HairFit AI — Booking & Scheduling Engine

> Code là nguồn sự thật. Trước khi sửa, mở đúng các file dưới đây và xác minh lại số dòng.

## 1. Bản đồ code
| Tầng | File | Vai trò |
| :--- | :--- | :--- |
| Flutter – tính slot | `frontend/lib/features/booking/data/slot_service.dart` | Parse `workingHours`, sinh slot 30', loại slot đã đặt/khóa |
| Flutter – gọi API | `frontend/lib/features/booking/data/booking_repository.dart` | `countActiveBookings`, `getBookedSlotsForDate`, `createBooking`, `cancelBooking`, `rescheduleBooking`, `blockSlotsByBarber`, `unblockSlotByBarber`; map mã lỗi → exception |
| Flutter – lịch hẹn | `frontend/lib/features/appointments/data/appointment_repository.dart` | confirm/reject/complete/rate/private-note; cancel & reschedule ủy quyền cho `BookingRepository` |
| Flutter – state | `frontend/lib/providers/booking_provider.dart`, `appointment_provider.dart` | |
| .NET – nguyên tử | `backend/HairFit.Api/Controllers/BookingsController.cs` | `POST /api/bookings`, `POST {id}/cancel`, `POST {id}/reschedule`, block-slots |
| .NET – schema | `backend/HairFit.Api/Data/AppDbContext.cs` | Unique index `BookedSlots(BarberId, Date, Time)` |
| Node mirror | `backend/routes/api.js` (mục "BOOKINGS & SLOTS") | In-memory, không có transaction |
| Tests | `frontend/test/slot_service_test.dart`, `booking_provider_test.dart`, `booking_widgets_test.dart`; `backend/HairFit.Api.Tests/ApiIntegrationTests.cs` | |

## 2. Bất biến (không được phá)
1. **Slot id**: `{barberId}_{YYYY-MM-DD}_{HH-mm}`. Backend tách giờ từ phần cuối sau `_`.
2. **Dịch vụ nhiều slot**: `durationMinutes / 30` slot liên tiếp; chỉ cần 1 slot bận → giờ bắt đầu đó không khả dụng.
3. **Tạo / đổi lịch** ở .NET: `BeginTransactionAsync(IsolationLevel.Serializable)` → kiểm tra xung đột → ghi Appointment + BookedSlots → 1 lần `SaveChangesAsync` → `Commit`; `DbUpdateException` → `409 SLOT_ALREADY_BOOKED`.
4. **Hủy**: cùng transaction đổi `Status = "cancelled"` + xóa BookedSlots của appointment.
5. **Luật nghiệp vụ** (hằng số trong controller + `frontend/lib/core/constants/business_constants.dart`): tối đa active booking / khách, lead time, số ngày đặt trước tối đa. Đổi giá trị → đổi cả 2 nơi.
6. **Frontend không bao giờ tự ghi slot** — chỉ gọi API.
7. Mã lỗi Flutter đang map: `SLOT_ALREADY_BOOKED`, `MAX_BOOKINGS_EXCEEDED`, `LEAD_TIME_VIOLATION`, `MAX_DAYS_EXCEEDED`, `BOOKING_ERROR`.

## 3. Lỗ hổng đã biết (đề xuất, chưa sửa — hỏi người dùng trước khi động vào)
- Server chưa kiểm tra lại `IsAcceptingBookingsToday` / `workingHours` / exceptions khi tạo lịch — đang dựa vào client.
- Controller chưa có `[Authorize]`; `CustomerId` lấy từ body.
- Test .NET dùng EF InMemory → không chứng minh được concurrency.

## 4. Checklist khi sửa
- [ ] Đã đọc đúng action trong `BookingsController.cs` và hàm tương ứng trong `booking_repository.dart`.
- [ ] Contract (field camelCase, mã lỗi) không đổi, hoặc đã đổi đồng bộ cả Flutter + .NET + Node.
- [ ] Không tách transaction; không thêm `SaveChangesAsync` ngoài transaction.
- [ ] Thêm/cập nhật test: `slot_service_test.dart` cho logic slot, `ApiIntegrationTests.cs` cho controller.
- [ ] `/hf-verify` (Flutter + .NET) và `/hf-review`.

<!-- CreBy: MenBoyBMN -->
