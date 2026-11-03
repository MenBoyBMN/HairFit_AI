---
trigger: glob
globs: frontend/lib/features/chat/**, frontend/lib/providers/chat_provider.dart, frontend/lib/models/chat_model.dart, frontend/firestore.rules, frontend/lib/core/services/firebase_service.dart
description: Quy tắc Firestore — hiện chỉ dùng cho chat 1:1 realtime, chạy trên gói Spark miễn phí.
---

# Firestore (Chat) Rules

- Phạm vi: chỉ `chats/{chatId}` và `chats/{chatId}/messages/{messageId}`. KHÔNG đưa dữ liệu booking/appointment/barber trở lại Firestore (đã chuyển sang SQL Server — xem `.agent/memory/decisions.md`).
- Spark free tier: ~50K reads / 20K writes / ngày → mọi query `messages` phải có `orderBy` + `limit`; stream dùng `autoDispose`; tránh listener trên collection lớn.
- Denormalize thông tin hiển thị danh sách chat (tên, avatar, lastMessage, lastMessageAt) vào doc `chats`.
- Đổi cấu trúc dữ liệu chat → cập nhật `frontend/firestore.rules` tương ứng: chỉ 2 participant đọc/ghi được chat của họ.

<!-- CreBy: MenBoyBMN -->

