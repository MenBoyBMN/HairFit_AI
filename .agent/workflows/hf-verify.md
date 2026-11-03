---
description: Chạy cổng kiểm chứng (analyze/test/build) cho các tầng đã thay đổi và báo cáo kết quả thật.
---

# /hf-verify — Cổng kiểm chứng

1. `git status --short` để xác định tầng đã chạm:
   - `frontend/` → Flutter
   - `backend/HairFit.Api*` → .NET
   - `backend/server.js`, `backend/routes/`, `backend/data/` → Node
   Người dùng yêu cầu "full" → chạy tất cả.
2. Flutter (cwd `frontend/`):
   ```powershell
   flutter analyze
   flutter test
   ```
   Chỉ format file đã sửa: `dart format <files>`.
3. .NET (cwd gốc repo):
   ```powershell
   dotnet build backend/HairFit.Backend.sln
   dotnet test  backend/HairFit.Backend.sln
   ```
4. Node (cwd `backend/`):
   ```powershell
   node --check server.js
   node --check routes/api.js
   ```
5. Báo cáo dạng bảng: Tầng | Lệnh | Kết quả (số issue / số test pass-fail). Có lỗi → liệt kê `file:line` + thông điệp, không tuyên bố "xong".

Ghi chú: lỗi nằm ở file KHÔNG có trong `git status` → coi là "lỗi tồn đọng", báo riêng, không tự sửa nếu ngoài phạm vi. Không dùng `git stash`/`git checkout` để kiểm tra khi chưa được người dùng cho phép.

<!-- CreBy: MenBoyBMN -->
