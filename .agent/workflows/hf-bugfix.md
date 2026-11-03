---
description: Sửa bug theo root-cause — tái hiện, tìm nguyên nhân gốc, sửa tối thiểu, thêm regression test, verify.
---

# /hf-bugfix — Quy trình sửa bug

Đầu vào: mô tả lỗi / log / screenshot.

1. **Thu thập bằng chứng**: chuỗi lỗi chính xác, màn hình/endpoint, vai trò người dùng, nền tảng (Android/Web/Windows), backend nào đang chạy (.NET `:5000` hay Node `:3000`). Thiếu thông tin quan trọng → hỏi.
2. **Định vị**: search chuỗi lỗi / mã lỗi / tên symbol. Truy luồng dữ liệu từ UI → provider → repository → API → controller → DB. Luồng dài → `/hf-explore`.
3. **Root cause**: viết 2-4 dòng "Nguyên nhân gốc: ... tại `file:line` vì ...". Không có bằng chứng → ghi rõ là giả thuyết và cách xác minh. KHÔNG sửa dựa trên đoán mò.
4. **Tái hiện bằng test** (nếu khả thi): viết test fail trước (Flutter test hoặc xUnit).
5. **Sửa tối thiểu** đúng chỗ gây lỗi. Không refactor xung quanh. Nếu lỗi nằm ở contract giữa 2 tầng → sửa cả hai phía và kiểm tra Node parity.
6. **Verify**: `/hf-verify` cho tầng đã chạm; test tái hiện phải chuyển sang pass.
7. **Review**: chạm booking/auth/admin hoặc diff > 50 dòng → `/hf-review`.
8. **Báo cáo**: nguyên nhân gốc, file sửa, bằng chứng verify. Nếu agent từng hiểu sai trong quá trình → thêm bài học vào `.agent/memory/known-pitfalls.md`.

Quy tắc dừng: sửa 2 lần chưa hết lỗi → dừng, tóm tắt đã thử gì, hỏi người dùng.

<!-- CreBy: MenBoyBMN -->

