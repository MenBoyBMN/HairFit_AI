---
description: Làm tính năng mới theo quy trình Explore → Plan Gate → Implement → Verify → Review (chống code vội & over-engineering).
---

# /hf-feature — Quy trình làm tính năng mới

Đầu vào: mô tả tính năng của người dùng.

1. **Làm rõ**: Nếu yêu cầu có ≥ 2 cách hiểu, hỏi tối đa 3 câu ngắn rồi DỪNG chờ trả lời.
2. **Khảo sát**:
   - Đọc `.agent/memory/project-map.md` và `.agent/memory/known-pitfalls.md`.
   - Nếu luồng liên quan > 8 file → chạy `/hf-explore` (sub-agent `code-explorer`) thay vì tự đọc.
   - Đọc skill liên quan: `hairfit-feature-scaffold` (luôn), `hairfit-booking-engine` (đặt lịch), `hairfit-ai-consultation` (AI), `hairfit-admin-portal` (admin).
3. **Plan Gate** — trình kế hoạch theo mẫu trong `rules/00-core-discipline.md` mục B, gồm thứ tự tầng: Entity/DTO → Controller (.NET) → Node route → Flutter model → repository → provider → UI → route → test.
   **DỪNG và chờ người dùng duyệt. Không sửa file nào ở bước này.**
4. **Implement** đúng kế hoạch đã duyệt. Phát sinh thay đổi ngoài kế hoạch → hỏi lại trước.
5. **Verify** — chạy `/hf-verify` cho các tầng đã chạm. Lỗi → sửa → chạy lại (tối đa 2 vòng, sau đó dừng hỏi).
6. **Review** — chạy `/hf-review`. Sửa mọi mục 🔴 Critical, chạy lại verify.
7. **Báo cáo** theo mẫu mục 5 của `AGENTS.md`. Đề xuất người dùng commit và `/hf-handoff` nếu phiên đã dài.

<!-- CreBy: MenBoyBMN -->

