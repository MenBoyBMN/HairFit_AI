# HairFit AI — Hướng Dẫn Cấu Hình Máy Chủ Server & Tunnel

Tài liệu này hướng dẫn cách biến một máy tính cá nhân (laptop/PC) thành **Máy chủ Backend cố định** để phục vụ cho các thiết bị di động chạy app từ xa qua mạng 4G/Wi-Fi khắp thành phố.

---

## 1. Chuẩn Bị Máy Server (Trước Khi Khởi Động)

1. **Cắm nguồn sạc cố định** (nếu là laptop).
2. **Tắt chế độ Sleep (Ngủ)** để server không bị ngắt kết nối:
   - Mở **Windows Settings** -> **System** -> **Power & battery** (hoặc **Power & sleep**).
   - Đặt mục **When plugged in, put my device to sleep after** thành **Never**.
3. **Cài đặt SQL Server LocalDB** (nếu chạy ASP.NET Core trên máy mới):
   - Tải gói cài đặt nhẹ [SQL Server Express LocalDB](https://learn.microsoft.com/vi-vn/sql/database-engine/configure-windows/sql-server-express-localdb).

---

## 2. Lựa Chọn Khởi Động Server

Trong thư mục `server_setup/`, bạn có các kịch bản sẵn sàng:

### Lựa Chọn A: ASP.NET Core 8 Web API + Ngrok (Khuyên Dùng cho 10 máy Demo)
1. Chạy `1_setup_new_machine.bat` để cài đặt .NET SDK, Ngrok và nhập Authtoken an toàn.
2. Kiểm tra tên miền tĩnh của bạn trong `ngrok_domain.txt` (mặc định: `clothing-similarly-delicacy.ngrok-free.dev`).
3. Chạy `2_start_server_ngrok.bat`:
   - Backend ASP.NET Core tự động khởi chạy trên Port 5000 (tự tạo DB và seed data).
   - Ngrok mở đường hầm HTTPS cố định trỏ về Port 5000.

### Lựa Chọn B: ASP.NET Core 8 Web API + Cloudflare Tunnel
1. Chạy `1_install_tools.bat` để cài đặt .NET SDK & `cloudflared`.
2. Chạy `2_start_server.bat`:
   - Backend ASP.NET Core tự chạy trên Port 5000.
   - Cloudflare Tunnel cấp URL ngẫu nhiên dạng `https://xxxx.trycloudflare.com`.

### Lựa Chọn C: Node.js Express Web API + Ngrok (Port 3000)
1. Chạy `2_start_server_nodejs.bat`:
   - Tự động chạy Node.js Express trên Port 3000.
   - Ngrok mở đường hầm trỏ về Port 3000.

---

## 3. Cơ Chế Auto-Discovery "Cắm Là Chạy" (Zero-Config Plug & Play)

Ứng dụng Flutter đã được tích hợp công nghệ **Tự động nhận diện nền tảng & endpoint (Auto-Discovery Probe)** trong `api_client.dart`:
- **Web (Chrome/Edge) & Windows Desktop**: Tự động nhận diện và kết nối `http://localhost:5000` (hoặc `http://localhost:3000`).
- **Máy ảo Android (Android Emulator)**: Tự động chuyển đổi sang loopback `http://10.0.2.2:5000`.
- **Điện thoại thật cắm cáp USB**: Tự động kích hoạt `adb reverse` để kết nối thẳng `http://localhost:5000` (tốc độ tối đa, 0 ping, offline 100%).
- **Điện thoại thật chạy 4G/Wi-Fi từ xa**: Khi không tìm thấy server local, app tự động chuyển sang đường hầm Ngrok tĩnh (`https://clothing-similarly-delicacy.ngrok-free.dev`).

👉 **Bạn hoàn toàn KHÔNG CẦN sửa file `.env` khi đổi qua lại giữa các thiết bị!**

---

## 4. Build File APK Cho 10 Điện Thoại Cài App

1. File `frontend/.env` đã được cấu hình mặc định sẵn sàng:
   ```env
   REMOTE_API_BASE_URL=https://clothing-similarly-delicacy.ngrok-free.dev
   API_BASE_URL=auto
   ```
2. Build file APK thành phẩm cho Android:
   ```powershell
   cd frontend
   flutter build apk --release
   ```
3. Lấy tệp APK tại:
   `frontend/build/app/outputs/flutter-apk/app-release.apk`
4. Cài đặt APK cho các máy điện thoại. Mọi điện thoại khi kết nối 4G/Wi-Fi ở bất cứ đâu đều sẽ tự động kết nối về máy chủ Backend của bạn.

---

## 5. Các Tối Ưu Đã Được Cấu Hình Sẵn Trong Mã Nguồn

- **Auto-Discovery & Failover**: `api_client.dart` tự động phát hiện endpoint nhanh nhất trong 50ms khi khởi động app và tự động chuyển đổi dự phòng nếu một đường truyền bị ngắt kết nối.
- **Bảo mật Authtoken**: Không lưu trữ hardcode token cá nhân trong source code git; hỗ trợ cấu hình động qua file `ngrok_token.txt` (đã gitignore).
- **Tự động thử lại (Retry on 4G)**: Trong [`api_client.dart`](../frontend/lib/core/services/api_client.dart), đã thiết lập timeout 15s và tự động thử lại 1 lần nếu điện thoại chuyển trạm sóng 4G chập chờn.
- **Tự động bóc tách Envelope**: `api_client.dart` hỗ trợ nhận cả định dạng JSON Array thuần (.NET) lẫn Envelope JSON `{ status, data }` (Express).
- **Reverse Proxy Header**: Trong [`Program.cs`](../backend/HairFit.Api/Program.cs), đã bật `UseForwardedHeaders` để Backend nhận đúng IP thật và giao thức HTTPS từ Cloudflare/Ngrok.
- **CORS mở rộng**: Cho phép tất cả các loại thiết bị (Android, iOS, Web Chrome, Edge, Safari) kết nối mà không bị chặn quyền truy cập.

<!-- CreBy: MenBoyBMN -->
