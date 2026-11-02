# HAIRFIT AI — HƯỚNG DẪN THIẾT LẬP MÁY CHỦ NGROK STATIC DOMAIN MIỄN PHÍ

> **Tài liệu thuộc:** `About System/`  
> **Giải pháp:** Sử dụng **Ngrok Free Static Domain** (100% miễn phí, không cần mua tên miền, link cố định vĩnh viễn không bao giờ đổi).  
> **Áp dụng cho:** Máy chủ Backend tại nhà và 10+ điện thoại chạy ứng dụng Flutter phân tán trong thành phố.

---

## 1. TẠI SAO GIẢI PHÁP NÀY PHÙ HỢP NHẤT VỚI BẠN?

1. **Miễn phí 100% tên miền cố định**: Bạn không cần tốn tiền mua domain như Cloudflare. Ngrok cấp sẵn cho bạn 1 tên miền cố định vĩnh viễn (dạng `*.ngrok-free.app`).
2. **Không bao giờ bị đổi link**: Tắt máy, mở lại, reset modem thoải mái—đường link vẫn giữ nguyên 100%. Bạn chỉ cần build file APK gửi 10 máy đúng 1 lần duy nhất.
3. **Đã tự động hóa toàn bộ**: Hệ thống đã được lập trình sẵn script để tự cài đặt và kích hoạt mã token khi bạn bê sang máy khác.

---

## 2. BƯỚC DUY NHẤT BẠN CẦN LÀM NGAY BÂY GIỜ

Mở trình duyệt web và lấy **1 Tên Miền Miễn Phí**:

1. Truy cập vào trang quản lý Domain của Ngrok:
   👉 **[https://dashboard.ngrok.com/cloud-edge/domains](https://dashboard.ngrok.com/cloud-edge/domains)**
2. Bấm nút **`+ Create Domain`** (hoặc **`New Domain`**).
3. Ngrok đã tự động tạo tên miền cố định miễn phí cho bạn:
   ```text
   clothing-similarly-delicacy.ngrok-free.dev
   ```
4. Đã được tự động lưu vào [`server_setup/ngrok_domain.txt`](../server_setup/ngrok_domain.txt).

---

## 3. CÁCH SỬ DỤNG TRÊN MÁY TÍNH HIỆN TẠI

1. Nhấp đúp chạy file:
   ```text
   server_setup/2_start_server_ngrok.bat
   ```
2. Cửa sổ sẽ tự động:
   - Khởi động Backend ASP.NET Core trên cổng 5000.
   - Kết nối Ngrok với tên miền cố định của bạn: `https://clothing-similarly-delicacy.ngrok-free.dev`.
3. Mở file [`frontend/.env`](../frontend/.env) cập nhật:
   ```env
   API_BASE_URL=https://clothing-similarly-delicacy.ngrok-free.dev
   ```
4. Build APK nạp cho 10 máy điện thoại:
   ```powershell
   cd frontend
   flutter build apk --release
   ```
   Tệp APK tại: `frontend/build/app/outputs/flutter-apk/app-release.apk`.

---

## 4. KHI BÊ SANG MÁY TÍNH KHÁC (SETUP TRONG 2 BƯỚC)

Khi bạn copy toàn bộ thư mục dự án này sang một máy tính khác để làm máy server cố định ở nhà:

### Bước 1: Nhấp đúp chạy `server_setup/1_setup_new_machine.bat`
- File này sẽ:
  - Tự động kiểm tra và cài .NET 8 SDK qua Winget.
  - Tự động cài Ngrok qua Winget.
  - **Tự động kích hoạt Authtoken tài khoản của bạn** (đã được cấu hình sẵn trong script).

### Bước 2: Nhấp đúp chạy `server_setup/2_start_server_ngrok.bat`
- Server sẽ lập tức khởi chạy và nhận đúng tên miền tĩnh của bạn ngay trên máy mới!

---

## 5. BẢO MẬT & TỐI ƯU MẠNG 4G ĐÃ TÍCH HỢP

- **Bỏ qua màn hình cảnh báo**: [`api_client.dart`](../frontend/lib/core/services/api_client.dart) đã đính kèm sẵn header `ngrok-skip-browser-warning: true` để các lệnh gọi API từ điện thoại không bị trang web trung gian của Ngrok chặn lại.
- **Tự động thử lại khi mất sóng**: Khi người dùng di chuyển 4G ngoài đường, nếu sóng chập chờn, app sẽ tự động thử lại sau 600ms mà không báo lỗi đứt kết nối.

<!-- CreBy: MenBoyBMN -->

