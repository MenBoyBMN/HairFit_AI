# `.agent/` — Bộ điều phối AI Agent cho HairFit AI

> Dành cho NGƯỜI dùng agent. Agent đọc `AGENTS.md` (luôn nạp) + rules/skills/workflows theo ngữ cảnh.

## 1. Cấu trúc & cơ chế nạp

```
.agent/
├── AGENTS.md                 # Hiến pháp: sự thật dự án + 7 luật vàng + cổng verify (LUÔN nạp — giữ ngắn)
├── rules/                    # Tự kích hoạt theo frontmatter `trigger`
│   ├── 00-core-discipline.md     always_on  — chống scope creep, plan gate, context, ảo giác, tự khen
│   ├── flutter-frontend.md       glob frontend/lib/**/*.dart
│   ├── flutter-testing.md        glob frontend/test/**/*.dart
│   ├── backend-dotnet.md         glob backend/HairFit.Api/**/*.cs
│   ├── backend-node-parity.md    glob backend/server.js, routes, data
│   └── firestore-chat.md         glob chat + firestore.rules
├── skills/                   # Kiến thức chuyên sâu, agent nạp khi mô tả khớp tác vụ
│   ├── hairfit-feature-scaffold/   quy trình full-stack 11 bước
│   ├── hairfit-booking-engine/     đặt lịch, slot, transaction
│   ├── hairfit-api-contract/       contract Flutter ↔ .NET ↔ Node, ApiClient
│   ├── hairfit-ai-consultation/    ML Kit on-device, phân loại dáng mặt
│   └── hairfit-admin-portal/       admin + seed
├── workflows/                # Slash command: gõ /tên-file trong chat
│   ├── hf-feature.md   /hf-feature     Explore → Plan Gate → Code → Verify → Review
│   ├── hf-bugfix.md    /hf-bugfix      Root cause → fix tối thiểu → regression test
│   ├── hf-explore.md   /hf-explore     Sub-agent khảo sát, trả về file:line
│   ├── hf-review.md    /hf-review      Sub-agent critic soi git diff
│   ├── hf-verify.md    /hf-verify      analyze/test/build theo tầng đã sửa
│   ├── hf-api-parity.md /hf-api-parity Đối chiếu route .NET ↔ Node ↔ Flutter
│   └── hf-handoff.md   /hf-handoff     Ghi bàn giao để mở phiên mới
├── subagents/                # System prompt cho sub-agent (workflow đọc và define_subagent)
│   ├── critic-reviewer.md
│   └── code-explorer.md
└── memory/                   # Bộ nhớ dài hạn giữa các phiên
    ├── project-map.md        "cái gì ở đâu" + route map
    ├── decisions.md          ADR rút gọn
    ├── known-pitfalls.md     bài học khi agent sai
    └── session-handoff.md    bàn giao phiên gần nhất
```

> [!NOTE]
> Rules dùng frontmatter `trigger: always_on | glob | model_decision | manual` của Antigravity. Nếu phiên bản Antigravity của bạn không nhận frontmatter, vào **Customizations → Rules** và đặt chế độ kích hoạt thủ công tương ứng.

## 2. Ánh xạ điểm yếu → cơ chế khắc phục

| Điểm yếu AGY | Cơ chế trong bộ này |
| :--- | :--- |
| Over-engineering / scope creep | Luật vàng #2 + `00-core-discipline` mục A + reviewer bắt lỗi "scope creep" |
| Ngộ độc ngữ cảnh | `memory/project-map.md` thay cho quét repo; rules theo glob (chỉ nạp khi chạm file); `/hf-explore`; `/hf-handoff` + phiên mới |
| Code vội khi chưa hiểu | Plan Gate có tiêu chí cụ thể (>2 file, đổi API/schema, mơ hồ) + mẫu kế hoạch; `/hf-feature` bước 3 DỪNG chờ duyệt |
| Tự viết tự khen | `/hf-review` với `critic-reviewer` độc lập, không nhận lời biện hộ, bắt buộc trích `file:line` |
| Ảo giác UI/tích hợp | Luật "Grounding" + `/hf-verify` theo tầng + `/hf-api-parity`; tài liệu trỏ tới file thật thay vì chép số liệu |
| Lặp lại sai lầm cũ | `memory/known-pitfalls.md` — agent tự ghi khi bị sửa lưng |

## 3. Mẫu prompt ngắn (đã có workflow lo phần còn lại)

```text
/hf-feature Thêm "lý do đổi lịch" khi khách reschedule, thợ xem được trên thẻ lịch hẹn.
/hf-bugfix  Nút "Tạm ngưng nhận khách" không có tác dụng khi chạy backend Node. Log: <dán log>
/hf-explore Luồng duyệt thợ của admin từ màn hình tới DB đi qua những đâu?
/hf-review
/hf-handoff
```
Tác vụ nhỏ, khóa phạm vi rõ: *"Chỉ sửa hàm X trong file Y. Không đổi chữ ký/hàm khác. Chạy flutter analyze sau khi sửa."*

## 4. Bảo trì bộ này
- Kiến trúc đổi → cập nhật mục 0 của `AGENTS.md`, `memory/project-map.md`, thêm ADR.
- `AGENTS.md` nên < 150 dòng; chi tiết đẩy xuống rules/skills.
- Mỗi tháng: dọn `known-pitfalls.md`, xóa mục đã được sửa tận gốc.
- Bản `.agent` cũ đã được backup ngoài repo trước khi viết lại.

<!-- CreBy: MenBoyBMN -->

