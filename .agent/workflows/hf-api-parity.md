---
description: Kiểm tra độ lệch route/JSON/mã lỗi giữa ASP.NET Controllers và Node routes/api.js.
---

# /hf-api-parity — Đối chiếu 2 backend

1. Liệt kê route .NET: search `\[Http(Get|Post|Put|Patch|Delete)` và `\[Route` trong `backend/HairFit.Api/Controllers/*.cs` → ghép thành `METHOD /api/<controller>/<template>`.
2. Liệt kê route Node: search `router\.(get|post|put|patch|delete)\(` trong `backend/routes/api.js` (lưu ý prefix `/api` được mount ở `server.js`).
3. Liệt kê route Flutter thực sự gọi: search `_apiClient\.(get|post|put|patch|delete)\(` trong `frontend/lib/`.
4. Lập bảng: Route | .NET | Node | Flutter dùng? | Ghi chú. Đánh dấu:
   - ❌ Flutter gọi nhưng backend thiếu
   - ⚠️ Có ở một backend, thiếu ở backend kia
   - 🔀 Khác tên field / mã lỗi (chỉ kiểm tra sâu các route Flutter dùng)
5. Chỉ báo cáo, KHÔNG tự sửa. Đề xuất danh sách sửa theo mức ưu tiên và chờ người dùng chọn.

<!-- CreBy: MenBoyBMN -->

