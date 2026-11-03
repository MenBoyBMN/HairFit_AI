---
name: hairfit-api-contract
description: Use when adding/changing any REST endpoint, DTO, JSON field, or error code shared between the Flutter ApiClient and the ASP.NET / Node backends of HairFit AI, or when debugging "works on one backend but not the other" issues.
risk: medium
source: workspace
---

# HairFit AI — API Contract & Connectivity

## 1. Một contract, ba nơi
```
frontend/lib/features/*/data/*_repository.dart   (caller: _apiClient.<verb>('/api/...'))
backend/HairFit.Api/Controllers/*.cs + DTOs/ApiDtos.cs   (chuẩn)
backend/routes/api.js                                    (mirror)
```
Thay đổi bất kỳ nơi nào → search route string ở 2 nơi còn lại và cập nhật/ghi chú.

## 2. Quy ước
- Prefix `/api/<resource>`; JSON camelCase; ngày `YYYY-MM-DD`, giờ `HH:mm`, timezone nghiệp vụ `Asia/Ho_Chi_Minh`.
- Lỗi: `{ "code": "UPPER_SNAKE", "message": "<tiếng Việt>" }`; `400` validate, `404` không thấy, `409` xung đột.
- Flutter `fromMap` phải chịu được field thiếu/null (backend Node và .NET có thể lệch nhẹ).

## 3. Kết nối (`frontend/lib/core/services/api_client.dart`)
- `.env`: `API_BASE_URL` (`auto` = tự dò), `REMOTE_API_BASE_URL` (ngrok).
- Thứ tự dò: URL trong `.env` → `:5000` (.NET) → `:3000` (Node) → ngrok. Android emulator dùng `10.0.2.2`; máy thật qua USB cần `adb reverse` (`server_setup/3_connect_usb_device.bat`).
- `ApiClient` gắn Firebase ID token vào header và tự failover sang candidate khác khi lỗi mạng.
- Debug "API không gọi được": xác định backend nào đang trả lời (`GET /api/health`) trước khi sửa code.

## 4. Quy trình đổi contract
1. Plan Gate: liệt kê endpoint, field cũ → mới, ai đang gọi (search `'/api/<path>`).
2. Sửa .NET (DTO + action) → Node → Flutter model/repository.
3. Test: `frontend/test/api_client_test.dart` (MockClient) / test repository; `[Fact]` .NET.
4. `/hf-api-parity` để xác nhận không còn lệch, rồi `/hf-verify`.

<!-- CreBy: MenBoyBMN -->

