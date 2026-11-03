---
name: hairfit-feature-scaffold
description: Use when adding a new end-to-end feature or extending one across layers in HairFit AI (EF entity/DTO/controller, Node mirror route, Flutter model/repository/provider/screen/route, tests).
risk: medium
source: workspace
---

# HairFit AI — Full-stack Feature Scaffold

> Bắt buộc qua Plan Gate trước khi tạo file. Chỉ làm các bước tính năng thực sự cần — không tạo tầng thừa.
> Tìm 1 tính năng tương tự có sẵn và **bắt chước cấu trúc của nó** (VD: hairstyles = CRUD đơn giản, bookings = nghiệp vụ phức tạp).

## Thứ tự triển khai (backend → frontend)

### 1. Entity & DB (`backend/HairFit.Api/Models/Entities.cs`, `Data/AppDbContext.cs`)
- Thêm entity/field; index cho cột hay lọc. Kiểm tra `Data/DbInitializer.cs` (tạo DB + seed) có cần cập nhật.
- Đổi schema = thay đổi rủi ro → nêu rõ trong kế hoạch.

### 2. DTO (`backend/HairFit.Api/DTOs/ApiDtos.cs`)
- Request/response tách khỏi entity. JSON camelCase.

### 3. Controller (`backend/HairFit.Api/Controllers/<X>Controller.cs`)
- `[ApiController]`, `[Route("api/<x>")]`. Async, `AsNoTracking` cho đọc, transaction cho ghi nhiều bảng.
- Lỗi nghiệp vụ: `{ code, message }` (message tiếng Việt).
- Cân nhắc `[Authorize]` + kiểm tra vai trò từ claims.

### 4. Node mirror (`backend/routes/api.js` + `backend/data/*.js` nếu cần)
- Cùng method/path/shape JSON/mã lỗi. Hoặc ghi rõ "Node chưa cập nhật" và hỏi người dùng.

### 5. Flutter model (`frontend/lib/models/<x>_model.dart`)
- Immutable, `copyWith`, `fromMap(map, id)` có fallback, `toMap`, enum `.name`.

### 6. Repository (`frontend/lib/features/<feature>/data/<x>_repository.dart`)
- Constructor nhận `ApiClient? apiClient`; gọi `_apiClient.get/post/put/patch/delete('/api/...')`; map lỗi sang exception có kiểu.

### 7. Provider (`frontend/lib/providers/<feature>_provider.dart`)
- `Provider<Repo>` cho repository; `FutureProvider/StreamProvider(.autoDispose/.family)` cho đọc; `StateNotifierProvider` cho hành động. Theo style file lân cận.

### 8. UI (`frontend/lib/features/<feature>/presentation/` + `widgets/`)
- Token `AppColors/AppDimensions/AppTextStyles`, widget `core/widgets/`, đủ loading/error/empty/data, chuỗi tiếng Việt.

### 9. Route (`frontend/lib/routing/app_router.dart`)
- Thêm `GoRoute` vào nhánh đúng vai trò; kiểm tra role guard trong `redirect`.

### 10. Tests
- Flutter: `frontend/test/<feature>_test.dart` — model (fromMap/toMap/copyWith), repository với `MockClient`, notifier, widget với `ProviderScope(overrides:)`.
- .NET: thêm `[Fact]` vào `backend/HairFit.Api.Tests/ApiIntegrationTests.cs` cho action mới.

### 11. Hoàn tất
- Credit `CreBy: MenBoyBMN` ở cuối mọi file MỚI.
- `/hf-verify` → `/hf-review` → cập nhật `.agent/memory/project-map.md` nếu thêm controller/feature mới.

<!-- CreBy: MenBoyBMN -->
