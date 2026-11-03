# Architecture Decision Log (ADR rút gọn)

> Thêm mục mới lên ĐẦU danh sách. Mỗi mục ≤ 6 dòng. Agent phải đọc file này trước khi đề xuất thay đổi kiến trúc.

---

### ADR-004 — Tinh gọn hệ thống về 1 Backend duy nhất (ASP.NET Core 8) & dọn sạch bloatware
- **Bối cảnh**: Hệ thống bị lag, giật trên máy thật do dò mạng qua nhiều port, polling HTTP ngầm 10-15s, dư thừa 2 backend và tàn dư Firestore/seed data.
- **Quyết định**: Xóa hoàn toàn Backend Node.js phụ (server.js, routes, data, port 3000); xóa polling ngầm chuyển sang on-demand fetch; dọn sạch tàn dư Firestore ngoài Chat 1:1; xóa 8 file dead code/spike/seed; tối ưu cache Base64 và query SQL Server.
- **Hệ quả**: Giảm 100% lãng phí CPU/pin chạy ngầm, khởi động app nhanh tức thì, chỉ duy trì 1 backend duy nhất chuẩn nghiệp vụ.

### ADR-003 — [LỖI THỜI - Thay thế bởi ADR-004] Duy trì 2 backend song song
- **Bối cảnh**: Cần backend chạy local hiệu năng cao và bản deploy 0 đồng (Vercel).
- **Quyết định**: Đã bị bãi bỏ theo ADR-004 do người dùng phê duyệt tinh gọn hệ thống.
- **Hệ quả**: Node.js backend và cổng 3000 đã bị xóa hoàn toàn khỏi dự án.

### ADR-002 — Chuyển dữ liệu nghiệp vụ từ Firestore sang ASP.NET + SQL Server
- **Bối cảnh**: Commit `a3dfc4a` "restructure architecture into frontend and backend".
- **Quyết định**: Booking/appointment/barber/user/review/hairstyle lưu SQL Server qua EF Core; chống trùng bằng SQL transaction `Serializable` + unique index.
- **Hệ quả**: Tài liệu cũ nói "Firestore transaction cho booking" là LỖI THỜI. Firestore chỉ còn cho chat.

### ADR-001 — AI tư vấn hoàn toàn on-device
- **Quyết định**: `google_mlkit_face_detection` (face contours) + công thức tỷ lệ hình học; không gửi ảnh lên server/cloud AI.
- **Hệ quả**: Không thêm API AI trả phí. Ngưỡng phân loại nằm trong `face_shape_analyzer.dart` (code là nguồn sự thật).

<!-- CreBy: MenBoyBMN -->

