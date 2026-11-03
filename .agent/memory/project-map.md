# Project Map — "Cái gì nằm ở đâu" (đọc thay vì quét toàn repo)

> Cập nhật lần cuối: 2026-11-03. Nếu phát hiện sai lệch → sửa file này (đây là bộ nhớ dùng chung giữa các phiên).

## 1. Gốc repo
| Đường dẫn | Nội dung |
| :--- | :--- |
| `frontend/` | Ứng dụng Flutter (`pubspec.yaml`, `analysis_options.yaml`, `firestore.rules`, `.env`) |
| `backend/HairFit.Api/` | ASP.NET Core 8 Web API (Backend duy nhất của hệ thống) |
| `backend/HairFit.Api.Tests/` | xUnit + EF InMemory (`ApiIntegrationTests.cs`) |
| `server_setup/` | Script `.bat` cài tool / chạy server ASP.NET / ngrok / adb reverse |
| `About System/` | Tài liệu đặc tả & kế hoạch (có thể lỗi thời — tin code hơn) |

## 2. Frontend (`frontend/lib/`)
| Chủ đề | File chính |
| :--- | :--- |
| Entry / DI | `main.dart`, `providers/app_providers.dart` |
| HTTP client (dò URL, failover, gắn Firebase token) | `core/services/api_client.dart` |
| Auth | `core/services/auth_service.dart`, `features/auth/`, `providers/auth_provider.dart` |
| Routing + RBAC guard | `routing/app_router.dart` (redirect ~L57, role guard ~L99) |
| Design tokens | `core/constants/app_colors.dart`, `app_dimensions.dart`, `app_text_styles.dart`, `business_constants.dart`; theme `core/theme/app_theme.dart` |
| Widget dùng chung | `core/widgets/` (AppButton, AppTextField, EmptyState, ErrorRetry, LoadingShimmer, StatusBadge, AppAvatar, WebNavShell...) |
| Đặt lịch | `features/booking/data/{booking_repository,slot_service}.dart`, `providers/booking_provider.dart`, `features/booking/presentation/` |
| Lịch hẹn | `features/appointments/data/appointment_repository.dart`, `providers/appointment_provider.dart`, widgets `appointment_card`, `reschedule_bottom_sheet`, `quick_break_dialog`, `ai_haircut_handshake_card`, `barber_daily_earnings` |
| AI tư vấn | `features/ai_consult/domain/{face_shape_analyzer,hairstyle_recommendation_engine,ai_consultant_service}.dart`, `data/face_validation_service.dart`, `providers/ai_consult_provider.dart` |
| Hồ sơ thợ | `features/barber_profile/` (edit, registration, pending, working hours, location picker) |
| Tìm kiếm / bản đồ | `features/search_map/`, `providers/search_provider.dart`, `core/services/tile_server_config.dart` |
| Admin | `features/admin/data/admin_repository.dart`, `providers/admin_provider.dart`, `features/admin/presentation/*` |
| Chat (Firestore) | `features/chat/data/chat_repository.dart`, `providers/chat_provider.dart`, `models/chat_model.dart` |
| Models | `models/` (appointment, barber_profile, booked_slot, chat, hairstyle, promotion, service, user) |
| Tests | `frontend/test/*_test.dart` (20 file) |

## 3. Backend ASP.NET — Route map
| Controller | Base | Actions |
| :--- | :--- | :--- |
| `BookingsController` | `/api/bookings` | `GET active-count/{customerId}`, `GET slots`, `POST block-slots`, `DELETE block-slots/{slotId}`, `POST` (tạo lịch), `POST {id}/cancel`, `POST {id}/reschedule` |
| `AppointmentsController` | `/api/appointments` | `GET customer/{id}`, `GET barber/{id}`, `GET {id}`, `POST {id}/confirm|reject|complete|rate`, `PATCH {id}/private-note` |
| `BarbersController` | `/api/barbers` | `GET approved|featured|pending|{uid}|{uid}/reviews`, `PUT {uid}`, `PATCH {uid}/accepting`, `PATCH {uid}/approval` |
| `UsersController` | `/api/users` | `POST sync`, `GET {uid}`, `PUT {uid}/profile`, `PUT {uid}/face-shape`, `POST {uid}/favorites/toggle` |
| `HairstylesController` | `/api/hairstyles` | `GET` |
| `AdminController` | `/api/admin` | stats, users (block/role/update/appointments), barbers (pending/list/location/update/status/delete), appointments, hairstyles CRUD, reviews, settings |
| `SeedController` | `/api/seed` | seed/xóa hairstyles, barbers, appointments |

Entities (`Models/Entities.cs`): User, BarberProfile, Appointment, BookedSlot (unique `BarberId+Date+Time`), Review, Hairstyle, SystemSetting.

## 4. Lệnh chạy nhanh
```powershell
cd backend/HairFit.Api; dotnet run          # http://localhost:5000/swagger
cd frontend; flutter run                    # .env: API_BASE_URL=auto
```

<!-- CreBy: MenBoyBMN -->

