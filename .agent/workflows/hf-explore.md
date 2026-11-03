---
description: Giao cho sub-agent code-explorer khảo sát một luồng nghiệp vụ dài và chỉ trả về bản đồ file:line, giữ ngữ cảnh agent chính sạch.
---

# /hf-explore — Khảo sát luồng bằng sub-agent

Đầu vào: câu hỏi khảo sát (VD: "Luồng đổi lịch từ màn hình khách đến DB đi qua đâu? Muốn thêm lý do đổi lịch thì sửa chỗ nào?").

1. Đọc `.agent/subagents/code-explorer.md`.
2. `define_subagent` tên `code-explorer` (nếu chưa có trong phiên) với nguyên văn **System Prompt**; chỉ cần quyền đọc.
3. `invoke_subagent` với câu hỏi cụ thể + mục tiêu cuối cùng (để nó liệt kê "điểm cần sửa").
   Có thể chạy song song 2 explorer cho 2 câu hỏi độc lập (VD: frontend và backend).
4. Nhận kết quả → kiểm tra ngẫu nhiên 1-2 trích dẫn `file:line` để chắc chắn không ảo giác.
5. Dùng kết quả làm đầu vào cho Plan Gate. Không đọc lại toàn bộ file mà explorer đã tóm tắt, chỉ đọc đúng đoạn sẽ sửa.

<!-- CreBy: MenBoyBMN -->

