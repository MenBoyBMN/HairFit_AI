---
description: Ghi bàn giao phiên làm việc vào .agent/memory/session-handoff.md để mở phiên chat mới mà không mất ngữ cảnh.
---

# /hf-handoff — Bàn giao phiên

Dùng khi: xong 1 tính năng/bug lớn, phiên chat đã dài, hoặc chuẩn bị chuyển việc khác.

1. Chạy `git status --short` và `git diff --stat`.
2. GHI ĐÈ `.agent/memory/session-handoff.md` theo mẫu (≤ 40 dòng, chỉ sự thật đã xác minh):
   ```markdown
   # Session Handoff — <YYYY-MM-DD HH:mm>
   ## Mục tiêu phiên
   ## Đã hoàn thành (file:line chính)
   ## Đang dở / bước tiếp theo (cụ thể, có thể thực thi ngay)
   ## Trạng thái kiểm chứng (lệnh → kết quả)
   ## Quyết định đã chốt với người dùng
   ## Cạm bẫy phát hiện (cũng thêm vào known-pitfalls.md nếu có giá trị lâu dài)
   ```
3. Quyết định kiến trúc mới → thêm 1 mục vào `.agent/memory/decisions.md`.
4. Cấu trúc thư mục / file quan trọng thay đổi → cập nhật `.agent/memory/project-map.md`.
5. Gợi ý người dùng: commit (nếu muốn) rồi mở phiên mới với câu: *"Đọc .agent/memory/session-handoff.md và tiếp tục."*

<!-- CreBy: MenBoyBMN -->

