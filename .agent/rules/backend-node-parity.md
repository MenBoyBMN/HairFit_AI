---
trigger: glob
globs: backend/server.js, backend/routes/**/*.js, backend/data/**/*.js, backend/package.json, backend/vercel.json
description: Quy tắc cho backend Node.js Express phụ và giữ tương thích route với ASP.NET.
---

# Node.js Backend & Parity Rules

## 1. Vai trò
- Backend phụ, nhẹ, deploy Vercel (`vercel.json` rewrite mọi request → `server.js`), port `3000`.
- Dữ liệu **in-memory** từ `backend/data/*.js` → mất khi restart, KHÔNG có transaction thật. Không dùng làm chuẩn cho logic chống trùng lịch.
- `ApiClient` của Flutter ưu tiên `:5000` (.NET) rồi mới tới `:3000` (Node) → mặc định coi ASP.NET là chuẩn.

## 2. Parity (bắt buộc)
- Khi thêm/đổi route, query param, body hoặc shape JSON ở một backend:
  1. Search route tương ứng ở backend còn lại (`backend/routes/api.js` ↔ `backend/HairFit.Api/Controllers/*.cs`).
  2. Cập nhật cả hai, hoặc ghi rõ trong báo cáo "Node chưa được cập nhật" và hỏi người dùng.
- Mã lỗi `{ code, message }` giống hệt ASP.NET.
- Kiểm tra nhanh: `/hf-api-parity`.

## 3. Code style
- CommonJS (`require`), Express router. Không thêm dependency khi chưa được duyệt.
- Kiểm chứng cú pháp: `node --check server.js` và `node --check routes/api.js` (chạy trong `backend/`).

<!-- CreBy: MenBoyBMN -->

