---
description: Gọi sub-agent critic-reviewer độc lập soi git diff hiện tại để bắt lỗi trước khi bàn giao/commit.
---

# /hf-review — Review chéo bằng sub-agent độc lập

1. Chạy `git status --short` và `git diff --stat`. Không có thay đổi → báo người dùng và dừng.
2. Đọc `.agent/subagents/critic-reviewer.md`.
3. `define_subagent` tên `critic-reviewer` (nếu chưa định nghĩa trong phiên), dùng nguyên văn khối **System Prompt** trong file. Cấp quyền chạy lệnh để nó tự chạy `git diff` (không yêu cầu nó sửa file).
4. `invoke_subagent` với prompt gồm:
   - Mục tiêu của thay đổi (1-3 câu, lấy từ yêu cầu người dùng).
   - Danh sách file đã đổi (từ bước 1).
   - Phạm vi đặc biệt cần soi (nếu người dùng nêu).
   KHÔNG gửi kèm lời giải thích/biện hộ cho code — reviewer phải tự đánh giá.
5. Nhận kết quả. Với mỗi mục 🔴/🟠: tự xác minh tại `file:line`. Đúng → sửa (giữ minimal diff). Sai → ghi lý do bác bỏ.
6. Sau khi sửa → `/hf-verify`.
7. Báo cáo: kết luận reviewer, những gì đã sửa, những gì bác bỏ và vì sao.

<!-- CreBy: MenBoyBMN -->

