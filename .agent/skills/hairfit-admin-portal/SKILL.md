---
name: hairfit-admin-portal
description: Use when working on the HairFit AI admin portal (dashboard, barber approval, users, appointments, hairstyles, reviews, settings) or seed data (frontend admin feature + ASP.NET AdminController/SeedController).
risk: medium
source: workspace
---

# HairFit AI — Admin Portal

## 1. Bảo mật 2 tầng
1. **Route guard**: `/admin/*` trong `frontend/lib/routing/app_router.dart` chỉ cho `role == admin`.
2. **Backend**: `backend/HairFit.Api/Controllers/AdminController.cs` (`/api/admin`). ⚠️ Hiện chưa có `[Authorize]` → bất kỳ ai biết URL đều gọi được. Không thêm endpoint admin mới mà thiếu kiểm tra; đề xuất người dùng bổ sung policy admin.

## 2. Bản đồ code
| Màn hình (`frontend/lib/features/admin/presentation/`) | API chính (`/api/admin/...`) |
| :--- | :--- |
| `admin_shell_screen.dart` — điều hướng (rail/bottom bar) | — |
| `admin_dashboard_screen.dart` — KPI | `GET stats`, `GET barbers/recent-pending` |
| `approve_barbers_screen.dart` — duyệt thợ | `GET barbers`, `PATCH barbers/{uid}/status` |
| `admin_barbers_screen.dart` — danh bạ thợ | `GET barbers`, `PUT/DELETE barbers/{uid}`, `PATCH barbers/{uid}/location` |
| `admin_users_screen.dart` — người dùng | `GET users`, `PATCH users/{uid}/block|role`, `PUT users/{uid}`, `GET users/{uid}/appointments` |
| `admin_appointments_screen.dart` — giám sát lịch | `GET appointments`, `PATCH appointments/{id}/status` |
| `admin_hairstyles_screen.dart` — kiểu tóc | `GET/POST hairstyles`, `DELETE hairstyles/{id}` |
| `admin_reviews_screen.dart` — kiểm duyệt đánh giá | `GET reviews`, `DELETE reviews/{id}` |
| `admin_settings_screen.dart` — cấu hình & seed | `GET/PUT settings`, `/api/seed/*` |

- Data: `features/admin/data/admin_repository.dart`; state: `providers/admin_provider.dart`, `admin_stats_provider.dart`; widgets: `admin_kpi_card.dart`, `admin_status_badge.dart`.
- Test: `frontend/test/admin_portal_test.dart` (có `FakeAuthNotifier`).

## 3. Seed data
- Server: `SeedController` (`/api/seed/hairstyles|barbers|all|appointments`) + `Data/DbInitializer.cs` (seed lần đầu).
- Client: `frontend/lib/core/services/seed_data_service.dart`.
- Thợ seed phải có `workingHours` hợp lệ và tọa độ thật ở thành phố Việt Nam (Đà Nẵng, Hà Nội, TP.HCM).

## 4. Lưu ý
- Các màn hình admin rất dài (700–900 dòng) → đọc theo đoạn; widget mới tách vào `presentation/widgets/`.
- Bảng/list có thể lớn → phân trang/lọc ở server, không tải toàn bộ.

<!-- CreBy: MenBoyBMN -->
