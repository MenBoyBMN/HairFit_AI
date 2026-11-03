---
trigger: always_on
description: Kỷ luật làm việc cốt lõi của agent — chống over-engineering, chống code vội, chống loãng ngữ cảnh, chống ảo giác và tự khen.
---

# Kỷ Luật Cốt Lõi (Always On)

## A. Chống "Nhiệt tình phá hoại" (Scope Creep)
- Trước khi sửa, tự hỏi: *"Dòng này có nằm trong yêu cầu không?"* — Không → không sửa.
- CẤM khi chưa được yêu cầu: đổi tên biến/hàm/file, đổi chữ ký hàm public, tách/gộp file, chạy format toàn repo, nâng version package, thêm package mới, xóa code "có vẻ thừa".
- Sửa bug → sửa đúng nguyên nhân gốc, không viết lại cả hàm.
- Phát hiện vấn đề ngoài phạm vi → ghi vào mục **"💡 Đề xuất"** của báo cáo.

## B. Chống "Nhảy bổ vào code" (Plan Gate)
Bắt buộc dừng lại và trình kế hoạch (rồi CHỜ duyệt) khi:
- Chạm > 2 file, hoặc tạo file mới ngoài test.
- Thay đổi API contract, DTO, Entity/DB schema, route, RBAC.
- Yêu cầu có ≥ 2 cách hiểu hợp lý.

Định dạng kế hoạch (≤ 15 dòng):
```
🎯 Hiểu yêu cầu: ...
📁 File sẽ sửa: path — thay đổi gì
⚠️ Edge cases: ...
🧪 Cách verify: lệnh / test sẽ chạy
❓ Câu hỏi (nếu có): ...
```
Tác vụ nhỏ, rõ ràng (sửa 1 chỗ, 1 file) → được làm ngay nhưng vẫn phải verify.

## C. Chống "Ngộ độc ngữ cảnh"
- Search (tên symbol, chuỗi lỗi, route) TRƯỚC, đọc file SAU. File > 150 dòng → đọc theo đoạn.
- Không đọc lại file vừa đọc trừ khi nó đã bị sửa.
- Khảo sát luồng dài (> 8 file) → dùng sub-agent `code-explorer` (`/hf-explore`), chỉ nhận về danh sách `file:line` + tóm tắt.
- Bỏ qua: `build/`, `.dart_tool/`, `bin/`, `obj/`, `node_modules/`, `*.g.dart`, `pubspec.lock`, `package-lock.json`.
- Phiên chat đã dài / chuyển sang tính năng khác → đề xuất người dùng chạy `/hf-handoff` rồi mở phiên mới.

## D. Chống "Ảo giác"
- Mọi symbol/endpoint/field nhắc tới phải được xác minh bằng search trong phiên này.
- Không chắc → nói "chưa xác minh" thay vì khẳng định.
- Không giả định package có sẵn: kiểm tra `frontend/pubspec.yaml`, `backend/HairFit.Api/HairFit.Api.csproj`, `backend/package.json`.

## E. Chống "Tự viết tự khen"
- "Xong" = đã chạy lệnh verify phù hợp + đọc output + output sạch.
- Test fail → sửa code, KHÔNG sửa/xóa/skip test để cho pass (trừ khi test sai rõ ràng và đã giải thích cho người dùng).
- Thay đổi lớn hoặc chạm booking/auth/admin → chạy `/hf-review` (critic sub-agent độc lập soi `git diff`).

## F. Khi bị kẹt
- Cùng một lỗi sửa 2 lần không được → DỪNG, tóm tắt những gì đã thử, giả thuyết còn lại, và hỏi người dùng. Không thử mò lần thứ 3.

<!-- CreBy: MenBoyBMN -->

