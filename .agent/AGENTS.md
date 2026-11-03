# HairFit AI — Hiến Pháp Cho AI Agent (đọc trước mọi tác vụ)

> File này LUÔN được nạp. Giữ ngắn gọn. Chi tiết nằm trong `rules/` (tự kích hoạt theo glob), `skills/` (nạp khi cần), `workflows/` (slash command), `memory/` (bộ nhớ dự án).

---

## 0. Sự Thật Về Dự Án (Source of Truth — cập nhật 2026-11)

| Tầng | Công nghệ thực tế | Thư mục |
| :--- | :--- | :--- |
| Frontend | Flutter 3.x / Dart 3, Riverpod 2, GoRouter 14, `flutter_map` (OSM) | `frontend/` |
| Backend | ASP.NET Core 8 Web API + EF Core + SQL Server LocalDB, port `5000` | `backend/HairFit.Api/` |
| Auth | Firebase Auth → Firebase ID Token (JWT) → ASP.NET JwtBearer | `frontend/lib/core/services/auth_service.dart`, `backend/HairFit.Api/Program.cs` |
| Realtime | Cloud Firestore **CHỈ dùng cho Chat** (`chats/`, `messages/`) | `frontend/lib/features/chat/`, `frontend/firestore.rules` |
| AI | On-device `google_mlkit_face_detection` (contours), KHÔNG dùng Cloud AI | `frontend/lib/features/ai_consult/` |

- Frontend gọi backend qua `ApiClient` (`frontend/lib/core/services/api_client.dart`) — tự dò URL `:5000` → ngrok (đã loại bỏ backend Node.js phụ).
- Đặt lịch chống trùng = **SQL Transaction `Serializable` + unique index `(BarberId, Date, Time)`** trong `BookingsController.cs`. KHÔNG còn là Firestore transaction.
- Bản đồ file chi tiết: `.agent/memory/project-map.md`. Quyết định kiến trúc: `.agent/memory/decisions.md`.

> [!IMPORTANT]
> Nếu code thực tế mâu thuẫn với bất kỳ tài liệu nào (kể cả file này) → **tin code**, báo cho người dùng và đề xuất cập nhật tài liệu. Không bao giờ "bịa" API/field/file dựa trên trí nhớ.

---

## 1. Bảy Luật Vàng (vi phạm = làm lại)

1. **Hiểu trước, code sau (Plan Gate)** — Tác vụ chạm > 2 file, đổi API/DB schema, hoặc yêu cầu mơ hồ → trình kế hoạch ngắn (file sẽ sửa, edge cases, cách verify) và **CHỜ người dùng duyệt**. Nếu mơ hồ → hỏi, không tự suy diễn.
2. **Minimal Diff** — Chỉ sửa đúng phần được yêu cầu. Cấm đổi tên, format lại, refactor, "tiện tay cải thiện" code xung quanh. Thấy vấn đề khác → ghi vào mục "Đề xuất" trong báo cáo, không tự sửa.
3. **Không bịa (Grounding)** — Trước khi dùng một class/hàm/field/endpoint, phải tìm thấy nó trong code (search). Trích dẫn `file:line` khi giải thích.
4. **Giữ ngữ cảnh sạch** — Search trước, đọc có phạm vi (StartLine/EndLine). Cần khảo sát > 8 file → giao cho sub-agent (`/hf-explore`) và chỉ nhận về bản tóm tắt.
5. **Verify bằng bằng chứng** — Không được nói "đã xong/đã chạy được" nếu chưa chạy lệnh kiểm chứng tương ứng ở mục 3 và đọc kết quả. Dán tóm tắt output vào báo cáo.
6. **Không tự khen** — Thay đổi đáng kể (> 50 dòng, hoặc chạm booking/auth/admin) → chạy `/hf-review` (critic sub-agent độc lập) trước khi bàn giao.
7. **Học từ sai lầm** — Khi người dùng sửa lưng / chỉ ra lỗi agent → thêm 1 dòng vào `.agent/memory/known-pitfalls.md`.

---

## 2. Bất Biến Kiến Trúc

- **Zero-Cost**: Không thêm dịch vụ/API trả phí. AI xử lý 100% on-device.
- **Booking Integrity**: Mọi thao tác tạo / đổi / hủy lịch phải atomic ở backend (transaction). Frontend không tự ghi slot.
- **RBAC 3 vai trò**: `customer`, `barber`, `admin` — guard ở GoRouter (`frontend/lib/routing/app_router.dart`) và phải được kiểm tra ở backend.
- **Feature-First** ở frontend: `core/`, `features/<feature>/{data,domain,presentation}`, `models/`, `providers/`, `routing/`.

---

## 3. Cổng Kiểm Chứng (chạy đúng phần bạn đã chạm)

```powershell
# Frontend (chạy trong frontend/)
flutter analyze            # bắt buộc: "No issues found!"
flutter test               # bắt buộc: All tests passed
dart format lib test       # chỉ format file bạn đã sửa nếu có thể

# Backend .NET (chạy ở gốc repo)
dotnet build backend/HairFit.Backend.sln
dotnet test  backend/HairFit.Backend.sln
```
Dùng `/hf-verify` để chạy tự động.

---

## 4. Quy Ước Bắt Buộc

- **Ngôn ngữ**: Trả lời người dùng & chuỗi UI bằng **tiếng Việt** (lịch sự, phong cách salon). Tên biến/hàm/class, comment code, commit message bằng **tiếng Anh**.
- **Credit note**: Mọi file MỚI tạo phải có dòng cuối: `// CreBy: MenBoyBMN` (Dart/C#/JS), `# CreBy: MenBoyBMN` (yaml/py/sh), `<!-- CreBy: MenBoyBMN -->` (md). Không thêm vào file đã tồn tại.
- **Tool**: Ưu tiên tool chuyên dụng (đọc/sửa/tìm file) thay vì shell `cat/sed/echo >`. Shell dành cho `flutter`, `dotnet`, `node`, `git`.
- **Git**: Không tự `commit`/`push`/`reset`/xóa file khi chưa được yêu cầu.

---

## 5. Mẫu Báo Cáo Khi Kết Thúc Tác Vụ

```
✅ Đã làm: <1-3 dòng>
📁 File thay đổi: <danh sách + lý do>
🧪 Kiểm chứng: <lệnh đã chạy → kết quả>
⚠️ Chưa làm / rủi ro: <nếu có>
💡 Đề xuất (không tự làm): <nếu có>
```

<!-- CreBy: MenBoyBMN -->
